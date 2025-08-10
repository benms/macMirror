APP_NAME := MacMirror
# Version used for packaging (can be overridden via environment)
VERSION ?= 0.1
BUNDLE := $(APP_NAME).app
EXECUTABLE := $(BUNDLE)/Contents/MacOS/$(APP_NAME)
INFOPLIST := Info.plist
ICONSET := build/AppIcon.iconset
ICNS := Resources/AppIcon.icns
SRC := main.m AppDelegate.m CameraController.m CameraView.m

$(BUNDLE): $(EXECUTABLE) $(INFOPLIST) $(ICNS)
	@mkdir -p "$(BUNDLE)/Contents/Resources"
	@cp "$(INFOPLIST)" "$(BUNDLE)/Contents/Info.plist"
	@cp "$(ICNS)" "$(BUNDLE)/Contents/Resources/AppIcon.icns"
	@touch "$(BUNDLE)"

$(EXECUTABLE): $(SRC) CameraMath.h
	@mkdir -p "$(BUNDLE)/Contents/MacOS"
	clang -fobjc-arc -framework Cocoa -framework AVFoundation -framework QuartzCore -o "$(EXECUTABLE)" $(SRC)

build: $(BUNDLE)

$(ICNS): Assets/AppIcon.png
	@mkdir -p $(ICONSET)
	sips -z 16 16     $< --out $(ICONSET)/icon_16x16.png
	sips -z 32 32     $< --out $(ICONSET)/icon_16x16@2x.png
	sips -z 32 32     $< --out $(ICONSET)/icon_32x32.png
	sips -z 64 64     $< --out $(ICONSET)/icon_32x32@2x.png
	sips -z 128 128   $< --out $(ICONSET)/icon_128x128.png
	sips -z 256 256   $< --out $(ICONSET)/icon_128x128@2x.png
	sips -z 256 256   $< --out $(ICONSET)/icon_256x256.png
	sips -z 512 512   $< --out $(ICONSET)/icon_256x256@2x.png
	sips -z 512 512   $< --out $(ICONSET)/icon_512x512.png
	cp $< $(ICONSET)/icon_512x512@2x.png
	@mkdir -p Resources
	iconutil -c icns $(ICONSET) -o $(ICNS)

run: build
	open "$(BUNDLE)"

clean:
	rm -rf "$(BUNDLE)" "$(APP_NAME)-$(VERSION).dmg"

# Package a compressed DMG from the built app bundle
# Override VERSION when invoking to change output name: e.g., VERSION=0.2 make dmg
DMG := $(APP_NAME)-$(VERSION).dmg

dmg: build
	hdiutil create -volname "$(APP_NAME)" -srcfolder "$(BUNDLE)" -ov -format UDZO "$(DMG)"

# --- Tests ---
TEST_EXE := run_tests
TEST_SRC := Tests/CameraMathTests.m

test: $(TEST_EXE)
	./$(TEST_EXE)

$(TEST_EXE): $(TEST_SRC) CameraMath.h
	clang -fobjc-arc -framework Cocoa -o "$(TEST_EXE)" $(TEST_SRC)
