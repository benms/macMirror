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

## Build
```
make build
```

## Test
```
make test
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
  - Click the “Flip” button (top-right) to toggle mirroring
- Reset
  - Right-click anywhere to reset zoom to 1.0x and re-center (clear pan)

## Notes and Limitations
- On macOS, device-level camera zoom is generally unavailable. MacMirror applies zoom using an affine transform on the preview layer.
- Panning is available when zoom > 1.0x. At 1.0x, drag does nothing.
- If you need pan bounds/clamping (to avoid moving the view too far), this can be added.

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

