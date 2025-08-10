# MacMirror

MacMirror is a minimal macOS Cocoa app written in Objective-C that displays a live camera preview with intuitive zoom, pan, and flip controls.

## Features
- Live camera preview (AVFoundation)
- Zoom
  - Mouse scroll wheel / trackpad scroll
  - Trackpad pinch gesture
  - Keyboard +/- keys
  - Bottom slider (1.0x – 5.0x)
- Pan (drag to move)
  - Left mouse button drag to move the zoomed view
  - Hand cursor while dragging
- Flip (mirror)
  - Horizontally flipped by default
  - Toggle with a button at the top-right
- Click indicator
  - Brief circle indicator on left-click
- Right-click
  - Reset zoom to 1.0x and clear pan

## Requirements
- macOS with a built-in or connected camera
- Xcode Command Line Tools (for clang and SDKs)


## Test
```
make test
```

## Build
```
make build
```
This produces a bundle at `MacMirror.app/`.

## Run
```
make run
```
On first launch, macOS will prompt for camera access. Grant permission to see the preview.

## Controls
- Zoom in/out
  - Scroll wheel / two-finger scroll
  - Pinch gesture on trackpad
  - Press `+` or `-`
  - Use the slider at the bottom
- Pan (move view)
  - Press and hold left mouse button and drag to move the zoomed preview
  - Hand cursor shows while dragging
- Flip
  - Click the "Flip" button (top-right) to toggle mirroring
- Reset
  - Right-click anywhere to reset zoom to 1.0x and re-center (clear pan)
- Keyboard shortcuts
  - Press `⌘Q` to quit the application
  - Press `⌘W` to close the window

## Notes and Limitations
- On macOS, device-level camera zoom is generally unavailable. MacMirror applies zoom using an affine transform on the preview layer.
- Panning is available when zoom > 1.0x. At 1.0x, drag does nothing.
- If you need pan bounds/clamping (to avoid moving the view too far), this can be added.

## Package (DMG)
- Create a DMG locally (defaults to VERSION=0.1):
```bash
make dmg
```
- Override version:
```bash
VERSION=0.2 make dmg
```

The DMG will include:
- The MacMirror.app bundle
- A symlink to Applications folder for easy installation
- Installation instructions file with security guidance

## Install (macOS)
- Open the generated DMG file.
- In the window that appears, drag `MacMirror.app` to the `Applications` folder.
- **Security Notice**: Since this app is not code-signed with an Apple Developer ID, macOS will show a security warning. You have two options:

### Option 1: System Settings (Recommended)
1. Try to open MacMirror from Applications
2. When macOS blocks it, go to **System Settings → Privacy & Security**
3. Scroll down to find the security notice about MacMirror
4. Click **"Open Anyway"**

### Option 2: Terminal Command
If you prefer using Terminal, run this command:
```bash
xattr -r -d com.apple.quarantine "/Applications/MacMirror.app"
```

**Note**: For the best user experience, future releases may include code signing to eliminate these security warnings.

## Troubleshooting
- "Could not start camera": Ensure no other app is exclusively using the camera and that you granted camera permissions in System Settings → Privacy & Security → Camera.
- Build errors about SDKs: Make sure you have Xcode and Command Line Tools installed.

## Project Layout
- `main.m` – App entry
- `AppDelegate.[hm]` – Window, UI wiring, and event hookups
- `CameraView.[hm]` – NSView handling gestures, mouse, and cursor
- `CameraController.[hm]` – AVFoundation session and preview layer, zoom/flip/pan logic
- `Makefile` – Builds the `.app` bundle
- `Info.plist` – App bundle metadata and camera usage description

## License
MIT

