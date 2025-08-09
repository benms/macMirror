APP_NAME := MacMirror
BUNDLE := $(APP_NAME).app
EXECUTABLE := $(BUNDLE)/Contents/MacOS/$(APP_NAME)
INFOPLIST := Info.plist
SRC := main.m AppDelegate.m CameraController.m CameraView.m

$(BUNDLE): $(EXECUTABLE) $(INFOPLIST)
	@mkdir -p "$(BUNDLE)/Contents/Resources"
	@cp "$(INFOPLIST)" "$(BUNDLE)/Contents/Info.plist"
	@touch "$(BUNDLE)"

$(EXECUTABLE): $(SRC)
	@mkdir -p "$(BUNDLE)/Contents/MacOS"
	clang -fobjc-arc -framework Cocoa -framework AVFoundation -framework QuartzCore -o "$(EXECUTABLE)" $(SRC)

build: $(BUNDLE)

run: build
	open "$(BUNDLE)"

clean:
	rm -rf "$(BUNDLE)"
