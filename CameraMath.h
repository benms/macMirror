#import <Cocoa/Cocoa.h>

// Pure helper functions for testable math/logic used by CameraController

static inline CGFloat ClampZoom(CGFloat desiredZoom, CGFloat maxZoom) {
    if (desiredZoom < 1.0) return 1.0;
    if (desiredZoom > maxZoom) return maxZoom;
    return desiredZoom;
}

static inline void ComputeScale(BOOL flipped, CGFloat zoom, CGFloat *outSX, CGFloat *outSY) {
    CGFloat sx = (flipped ? -1.0 : 1.0) * zoom;
    CGFloat sy = zoom;
    if (outSX) *outSX = sx;
    if (outSY) *outSY = sy;
}
