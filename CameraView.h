#import <Cocoa/Cocoa.h>

@interface CameraView : NSView
@property (nonatomic, copy) void (^onMagnify)(CGFloat delta); // Trackpad pinch and mouse wheel (delta factor)
@property (nonatomic, copy) void (^onKeyPress)(unichar key);  // +/- keys
@property (nonatomic, copy) void (^onClick)(NSPoint pointInView); // Left-click point (unused for centering now)
@property (nonatomic, copy) void (^onRightClick)(NSPoint pointInView); // Right-click point
@property (nonatomic, copy) void (^onDragDelta)(CGFloat dx, CGFloat dy); // Drag to pan (left mouse)
@end
