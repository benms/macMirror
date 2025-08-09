#import "CameraView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CameraView {
    NSMagnificationGestureRecognizer *_magnify;
    BOOL _dragging;
    NSPoint _lastPoint;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if ((self = [super initWithFrame:frameRect])) {
        self.wantsLayer = YES;
        self.layer.backgroundColor = [[NSColor blackColor] CGColor];

        _magnify = [[NSMagnificationGestureRecognizer alloc] initWithTarget:self action:@selector(handleMagnify:)];
        [self addGestureRecognizer:_magnify];
    }
    return self;
}

- (BOOL)acceptsFirstResponder { return YES; }

- (void)keyDown:(NSEvent *)event {
    if (self.onKeyPress && event.characters.length > 0) {
        unichar c = [event.characters characterAtIndex:0];
        self.onKeyPress(c);
        return;
    }
    [super keyDown:event];
}

- (void)mouseDown:(NSEvent *)event {
    NSPoint p = [self convertPoint:event.locationInWindow fromView:nil];
    _dragging = YES;
    _lastPoint = p;
    // Show hand cursor while dragging
    [[NSCursor closedHandCursor] push];
    [[NSCursor closedHandCursor] set];
    if (self.onClick) {
        self.onClick(p);
    }
}

- (void)mouseDragged:(NSEvent *)event {
    if (!_dragging) { return; }
    // Keep hand cursor during drag
    [[NSCursor closedHandCursor] set];
    NSPoint p = [self convertPoint:event.locationInWindow fromView:nil];
    CGFloat dx = p.x - _lastPoint.x;
    CGFloat dy = p.y - _lastPoint.y;
    _lastPoint = p;
    if (self.onDragDelta) {
        self.onDragDelta(dx, dy);
    }
}

- (void)mouseUp:(NSEvent *)event {
    _dragging = NO;
    // Restore previous cursor
    [NSCursor pop];
}

- (void)rightMouseDown:(NSEvent *)event {
    NSPoint p = [self convertPoint:event.locationInWindow fromView:nil];
    if (self.onRightClick) {
        self.onRightClick(p);
    }
}

- (void)handleMagnify:(NSMagnificationGestureRecognizer *)gr {
    if (self.onMagnify) {
        // gr.magnification is delta since gesture began; use gr.magnification for smooth change
        self.onMagnify(gr.magnification);
    }
}

- (void)scrollWheel:(NSEvent *)event {
    if (!self.onMagnify) { [super scrollWheel:event]; return; }
    // Use vertical delta for zoom. Positive = zoom in, Negative = zoom out.
    // Tune sensitivity: small factor for smoothness; adapt for precise scrolling deltas
    CGFloat base = event.hasPreciseScrollingDeltas ? 0.01 : 0.05;
    CGFloat delta = event.scrollingDeltaY * base;
    self.onMagnify(delta);
}

- (void)showClickIndicatorAt:(NSPoint)p {
    if (!self.layer) return;
    CGFloat radius = 16.0;
    NSRect circleRect = NSMakeRect(p.x - radius, p.y - radius, radius * 2, radius * 2);
    CAShapeLayer *ring = [CAShapeLayer layer];
    CGPathRef path = CGPathCreateWithEllipseInRect(NSRectToCGRect(circleRect), NULL);
    ring.path = path;
    CGPathRelease(path);
    ring.fillColor = [[NSColor clearColor] CGColor];
    ring.strokeColor = [[NSColor colorWithCalibratedWhite:1 alpha:0.95] CGColor];
    ring.lineWidth = 2.0;
    ring.opacity = 1.0;

    [self.layer addSublayer:ring];

    // Fade out and remove
    CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fade.fromValue = @(1.0);
    fade.toValue = @(0.0);
    fade.duration = 0.6;
    fade.fillMode = kCAFillModeForwards;
    fade.removedOnCompletion = NO;

    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [ring removeFromSuperlayer];
    }];
    [ring addAnimation:fade forKey:@"fade"]; 
    [CATransaction commit];
}

- (void)layout {
    [super layout];
    // Sub layers (preview) will autoresize; nothing else required here
}

@end
