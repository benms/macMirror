#import "AppDelegate.h"
#import "CameraView.h"
#import "CameraController.h"

@interface AppDelegate ()
@property (strong) NSWindow *window;
@property (strong) CameraView *cameraView;
@property (strong) CameraController *cameraController;
@property (strong) NSSlider *zoomSlider;
@property (strong) NSTextField *zoomLabel;
@property (strong) NSButton *flipButton;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self setupMenu];
    [self setupWindow];
    [self setupCamera];
}

- (void)setupMenu {
    // Create main menu bar
    NSMenu *mainMenu = [[NSMenu alloc] initWithTitle:@""];
    
    // Application menu (first menu in menu bar)
    NSMenuItem *appMenuItem = [[NSMenuItem alloc] init];
    NSMenu *appMenu = [[NSMenu alloc] initWithTitle:@"MacMirror"];
    
    // Quit MacMirror menu item with Cmd+Q
    NSMenuItem *quitMenuItem = [[NSMenuItem alloc] initWithTitle:@"Quit MacMirror"
                                                          action:@selector(quitApp:)
                                                   keyEquivalent:@"q"];
    quitMenuItem.target = self;
    [appMenu addItem:quitMenuItem];
    
    [appMenuItem setSubmenu:appMenu];
    [mainMenu addItem:appMenuItem];
    
    // File menu
    NSMenuItem *fileMenuItem = [[NSMenuItem alloc] init];
    NSMenu *fileMenu = [[NSMenu alloc] initWithTitle:@"File"];
    
    // Close window menu item with Cmd+W
    NSMenuItem *closeMenuItem = [[NSMenuItem alloc] initWithTitle:@"Close Window"
                                                           action:@selector(closeWindow:)
                                                    keyEquivalent:@"w"];
    closeMenuItem.target = self;
    [fileMenu addItem:closeMenuItem];
    
    [fileMenuItem setSubmenu:fileMenu];
    [mainMenu addItem:fileMenuItem];
    
    // Set the main menu
    [NSApp setMainMenu:mainMenu];
}

- (void)setupWindow {
    NSRect frame = NSMakeRect(100, 100, 1000, 700);
    self.window = [[NSWindow alloc] initWithContentRect:frame
                                              styleMask:(NSWindowStyleMaskTitled |
                                                         NSWindowStyleMaskClosable |
                                                         NSWindowStyleMaskResizable |
                                                         NSWindowStyleMaskMiniaturizable)
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    self.window.title = @"MacMirror";

    // Camera view fills the window content, with an optional control bar at bottom
    NSView *content = self.window.contentView;

    self.cameraView = [[CameraView alloc] initWithFrame:content.bounds];
    self.cameraView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [content addSubview:self.cameraView];

    // Flip toggle button at top-right
    self.flipButton = [NSButton buttonWithTitle:@"Flip" target:self action:@selector(flipTapped:)];
    CGFloat btnW = 70, btnH = 28, pad = 10;
    self.flipButton.frame = NSMakeRect(content.bounds.size.width - btnW - pad,
                                       content.bounds.size.height - btnH - pad,
                                       btnW, btnH);
    self.flipButton.autoresizingMask = NSViewMinXMargin | NSViewMinYMargin;
    [content addSubview:self.flipButton];

    // Control bar at bottom
    NSView *bar = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, content.bounds.size.width, 44)];
    bar.wantsLayer = YES;
    bar.layer.backgroundColor = [[NSColor colorWithWhite:0 alpha:0.2] CGColor];
    bar.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;

    self.zoomLabel = [NSTextField labelWithString:@"Zoom: 1.0x"];
    self.zoomLabel.textColor = [NSColor whiteColor];
    self.zoomLabel.frame = NSMakeRect(12, 12, 120, 20);
    [bar addSubview:self.zoomLabel];

    self.zoomSlider = [NSSlider sliderWithValue:1.0 minValue:1.0 maxValue:5.0 target:self action:@selector(sliderChanged:)];
    self.zoomSlider.frame = NSMakeRect(140, 10, content.bounds.size.width - 200, 24);
    self.zoomSlider.autoresizingMask = NSViewWidthSizable;
    [bar addSubview:self.zoomSlider];

    [content addSubview:bar];

    // Keyboard zoom: +/-
    [self.window setInitialFirstResponder:self.cameraView];

    [self.window makeKeyAndOrderFront:nil];
}

- (void)setupCamera {
    self.cameraController = [CameraController new];
    NSError *err = nil;
    BOOL ok = [self.cameraController setupInView:self.cameraView error:&err];
    if (!ok) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Could not start camera";
        alert.informativeText = err.localizedDescription ?: @"Unknown error";
        [alert runModal];
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.cameraView.onMagnify = ^(CGFloat delta){
        typeof(self) selfRef = weakSelf;
        if (!selfRef) return;
        CGFloat current = selfRef.cameraController.currentZoom;
        // Magnification delta is small; scale to be smooth
        CGFloat newZoom = MAX(1.0, MIN(selfRef.cameraController.maxZoom, current * (1.0 + delta)));
        [selfRef.cameraController setZoom:newZoom];
        [selfRef syncUIToZoom];
    };

    self.cameraView.onClick = ^(NSPoint p){
        // No-op for centering now; dragging will handle panning
    };

    self.cameraView.onRightClick = ^(NSPoint p){
        typeof(self) selfRef = weakSelf;
        if (!selfRef) return;
        // Reset zoom to 1.0x and clear pan
        [selfRef.cameraController setZoom:1.0];
        [selfRef.cameraController resetPan];
        [selfRef syncUIToZoom];
    };

    self.cameraView.onDragDelta = ^(CGFloat dx, CGFloat dy){
        typeof(self) selfRef = weakSelf;
        if (!selfRef) return;
        [selfRef.cameraController panBy:NSMakeSize(dx, dy)];
    };

    self.cameraView.onKeyPress = ^(unichar key){
        typeof(self) selfRef = weakSelf;
        if (!selfRef) return;
        if (key == '+' || key == '=') {
            CGFloat step = 0.1;
            CGFloat z = MIN(selfRef.cameraController.maxZoom, selfRef.cameraController.currentZoom + step);
            [selfRef.cameraController setZoom:z];
            [selfRef syncUIToZoom];
        } else if (key == '-' || key == '_') {
            CGFloat step = 0.1;
            CGFloat z = MAX(1.0, selfRef.cameraController.currentZoom - step);
            [selfRef.cameraController setZoom:z];
            [selfRef syncUIToZoom];
        }
    };

    [self.cameraController start];
    [self syncUIToZoom];
}

- (void)syncUIToZoom {
    CGFloat z = self.cameraController.currentZoom;
    self.zoomSlider.doubleValue = z;
    self.zoomLabel.stringValue = [NSString stringWithFormat:@"Zoom: %.2fx", z];
}

- (void)sliderChanged:(NSSlider *)sender {
    [self.cameraController setZoom:sender.doubleValue];
    [self syncUIToZoom];
}

- (void)flipTapped:(NSButton *)sender {
    self.cameraController.flipped = !self.cameraController.isFlipped;
}

- (void)quitApp:(id)sender {
    [NSApp terminate:self];
}

- (void)closeWindow:(id)sender {
    [self.window performClose:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
