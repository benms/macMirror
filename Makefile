APP_NAME := MacMirror
BUNDLE := $(APP_NAME).app
EXECUTABLE := $(BUNDLE)/Contents/MacOS/$(APP_NAME)
INFOPLIST := Info.plist
SRC := main.m AppDelegate.m CameraController.m CameraView.m

$(BUNDLE): $(EXECUTABLE) $(INFOPLIST)
	@mkdir -p "$(BUNDLE)/Contents/Resources"
	@cp "$(INFOPLIST)" "$(BUNDLE)/Contents/Info.plist"
	@touch "$(BUNDLE)"

$(EXECUTABLE): $(SRC) CameraMath.h
	@mkdir -p "$(BUNDLE)/Contents/MacOS"
	clang -fobjc-arc -framework Cocoa -framework AVFoundation -framework QuartzCore -o "$(EXECUTABLE)" $(SRC)

build: $(BUNDLE)

run: build
	open "$(BUNDLE)"

clean:
	rm -rf "$(BUNDLE)"

# --- Tests ---
TEST_EXE := run_tests
TEST_SRC := Tests/CameraMathTests.m

test: $(TEST_EXE)
	./$(TEST_EXE)

$(TEST_EXE): $(TEST_SRC) CameraMath.h
	clang -fobjc-arc -framework Cocoa -o "$(TEST_EXE)" $(TEST_SRC)
