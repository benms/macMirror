#import "CameraController.h"
#import "CameraMath.h"

@interface CameraController ()
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *videoDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic) CGFloat currentZoom;
@property (nonatomic) CGFloat maxZoom;
@property (nonatomic, weak) NSView *hostView;
@property (nonatomic) CGPoint zoomAnchorUnit; // 0..1 in layer bounds space
@property (nonatomic) CGPoint panOffset; // in view points
@end

@implementation CameraController

- (void)setZoomCenterWithViewPoint:(NSPoint)pointInView {
    // Compute pan offset so that clicked point moves to center at current zoom
    NSView *view = self.hostView;
    CGPoint center = CGPointMake(NSMidX(view.bounds), NSMidY(view.bounds));
    // Desired change in position equals vector from current center to clicked point
    self.panOffset = CGPointMake(pointInView.x - center.x, pointInView.y - center.y);
    [self applyAnchorAndCenter];
}

- (BOOL)setupInView:(NSView *)hostView error:(NSError **)error {
    self.hostView = hostView;

    // Create session
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetHigh;

    // Find a camera device
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device) {
        if (error) *error = [NSError errorWithDomain:@"CameraController" code:1 userInfo:@{NSLocalizedDescriptionKey: @"No camera device found"}];
        return NO;
    }
    self.videoDevice = device;

    NSError *localErr = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&localErr];
    if (!input) {
        if (error) *error = localErr ?: [NSError errorWithDomain:@"CameraController" code:2 userInfo:@{NSLocalizedDescriptionKey: @"Could not open camera input"}];
        return NO;
    }
    self.videoInput = input;

    if ([session canAddInput:input]) {
        [session addInput:input];
    } else {
        if (error) *error = [NSError errorWithDomain:@"CameraController" code:3 userInfo:@{NSLocalizedDescriptionKey: @"Cannot add camera input to session"}];
        return NO;
    }

    // Preview layer
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    preview.frame = hostView.bounds;

    hostView.wantsLayer = YES;
    [hostView.layer addSublayer:preview];

    self.previewLayer = preview;
    self.session = session;

    // On macOS, device-level zoom is unavailable; use preview-layer transform
    self.maxZoom = 5.0; // UI cap; adjust as desired
    self.currentZoom = 1.0;
    self.zoomAnchorUnit = CGPointMake(0.5, 0.5); // default center
    self.panOffset = CGPointZero;

    // Default to horizontally flipped (mirror)
    self.flipped = YES;
    [self applyTransform];

    return YES;
}

- (void)start {
    if (!self.session.isRunning) {
        [self.session startRunning];
    }
}

- (void)stop {
    if (self.session.isRunning) {
        [self.session stopRunning];
    }
}

- (void)setZoom:(CGFloat)zoomFactor {
    zoomFactor = ClampZoom(zoomFactor, self.maxZoom);
    self.currentZoom = zoomFactor;

    [self applyTransform];
    [self applyAnchorAndCenter];
}

- (void)centerPreviewLayer {
    // Deprecated by applyAnchorAndCenter, but keep for compatibility
    [self applyAnchorAndCenter];
}

- (void)applyAnchorAndCenter {
    CALayer *layer = self.previewLayer;
    NSView *view = self.hostView;

    // Ensure layer bounds match view bounds for unit anchor space
    layer.bounds = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);

    // Keep anchor at center for predictable panning
    layer.anchorPoint = CGPointMake(0.5, 0.5);

    // Position layer including pan offset
    layer.position = CGPointMake(NSMidX(view.bounds) + self.panOffset.x,
                                 NSMidY(view.bounds) + self.panOffset.y);
}

- (void)applyTransform {
    // Compose horizontal flip (if any) and zoom scale
    CGFloat sx = 1.0, sy = 1.0;
    ComputeScale(self.flipped, self.currentZoom, &sx, &sy);
    if (self.currentZoom == 1.0 && !self.flipped) {
        self.previewLayer.affineTransform = CGAffineTransformIdentity;
    } else {
        self.previewLayer.affineTransform = CGAffineTransformMakeScale(sx, sy);
    }
}

- (void)setFlipped:(BOOL)flipped {
    _flipped = flipped;
    [self applyTransform];
    [self applyAnchorAndCenter];
}

- (void)panBy:(NSSize)deltaInView {
    if (self.currentZoom <= 1.0) return; // no pan when not zoomed
    // Adjust for flip: panning direction in X should follow finger movement
    CGFloat dx = deltaInView.width;
    if (self.flipped) {
        // When flipped horizontally, moving mouse right should move content right visually,
        // which corresponds to increasing layer position.x as usual.
        // No inversion needed because we're moving the layer, not the content.
    }
    self.panOffset = CGPointMake(self.panOffset.x + dx, self.panOffset.y + deltaInView.height);
    [self applyAnchorAndCenter];
}

- (void)resetPan {
    self.panOffset = CGPointZero;
    [self applyAnchorAndCenter];
}

@end
