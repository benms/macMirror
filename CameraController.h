#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

@interface CameraController : NSObject
@property (nonatomic, readonly) AVCaptureSession *session;
@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, readonly) CGFloat currentZoom;
@property (nonatomic, readonly) CGFloat maxZoom;
@property (nonatomic, getter=isFlipped) BOOL flipped; // horizontal flip

- (BOOL)setupInView:(NSView *)hostView error:(NSError **)error;
- (void)start;
- (void)stop;
- (void)setZoom:(CGFloat)zoomFactor; // 1.0 ... maxZoom
- (void)setZoomCenterWithViewPoint:(NSPoint)pointInView; // select anchor
- (void)panBy:(NSSize)deltaInView; // pan when zoomed
- (void)resetPan; // center
@end
