#import <Cocoa/Cocoa.h>
#import "../CameraMath.h"

static int tests_run = 0;
static int tests_failed = 0;

static void assert_true(BOOL cond, const char *msg) {
    tests_run++;
    if (!cond) {
        tests_failed++;
        fprintf(stderr, "[FAIL] %s\n", msg);
    }
}

static void test_ClampZoom_basic() {
    assert_true(ClampZoom(0.5, 5.0) == 1.0, "ClampZoom below 1 clamps to 1.0");
    assert_true(ClampZoom(10.0, 5.0) == 5.0, "ClampZoom above max clamps to max");
    assert_true(ClampZoom(3.0, 5.0) == 3.0, "ClampZoom within range stays same");
    assert_true(ClampZoom(1.0, 5.0) == 1.0, "ClampZoom at 1 stays 1");
}

static void test_ComputeScale_flip_zoom() {
    CGFloat sx = 0, sy = 0;
    ComputeScale(NO, 1.0, &sx, &sy);
    assert_true(sx == 1.0 && sy == 1.0, "Scale no flip, 1x");

    ComputeScale(YES, 1.0, &sx, &sy);
    assert_true(sx == -1.0 && sy == 1.0, "Scale flip, 1x");

    ComputeScale(NO, 2.5, &sx, &sy);
    assert_true(sx == 2.5 && sy == 2.5, "Scale no flip, 2.5x");

    ComputeScale(YES, 2.0, &sx, &sy);
    assert_true(sx == -2.0 && sy == 2.0, "Scale flip, 2x");
}

int main(void) {
    @autoreleasepool {
        test_ClampZoom_basic();
        test_ComputeScale_flip_zoom();

        if (tests_failed == 0) {
            printf("All tests passed (%d).\n", tests_run);
            return 0;
        } else {
            printf("Tests run: %d, failures: %d\n", tests_run, tests_failed);
            return 1;
        }
    }
}

