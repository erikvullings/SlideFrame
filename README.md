# SlideFrame

SlideFrame is a macOS 14+ menu-bar utility for positioning an exact screenshot guide over the desktop. It supports 16:9, 4:3, 21:9, 9:16, 3:4, and the current display ratio.

## Build and run

- Xcode: open `SlideFrame.xcodeproj`, select **My Mac**, then run.
- Full Xcode: `xcodebuild test -project SlideFrame.xcodeproj -scheme SlideFrame -destination 'platform=macOS'`
- Command Line Tools fallback: `swiftc -warnings-as-errors SlideFrame/GuideGeometry.swift SlideFrame/Persistence/FramePreferences.swift Validation/main.swift -o .build/validation && .build/validation`
- Package: `./scripts/package.sh`
- Start: `open release/SlideFrame.app`

SlideFrame is menu-bar-only: it has no Dock icon or main window. Use its menu-bar icon to show/hide the guide, choose a size or ratio, fit or center it, change its border color, enable click-through, reset, or quit.

## Guide semantics

Displayed dimensions are the transparent **inner aperture**, measured in logical AppKit points, not pixels. The 2-point border is drawn outside that boundary. Drag anywhere in the transparent interior that is not a control to move the frame with native pointer tracking; the cursor changes from an open hand to a closed hand while moving. Drag one of four corner handles to resize at the selected ratio while keeping the opposite corner fixed. The compact in-frame capsule shows dimensions and aspect ratio and exposes border visibility, size/ratio selection, and Quit. Hiding the border leaves only this capsule visible; Hide Frame hides the entire overlay without losing geometry. Click Through hides the capsule and handles and passes input to apps below; use the menu bar to turn it off.

The four exact presets—960 × 540, 1280 × 720, 1600 × 900, and 1920 × 1080—select 16:9. Other ratio modes fit to the current display when selected. Current Display Ratio derives its ratio from the active screen.

## macOS limitations

macOS controls whether auxiliary windows can appear above every third-party full-screen app. SlideFrame requests all Spaces and full-screen auxiliary behavior, but protected content and some full-screen configurations may remain above it. Logical-point dimensions intentionally produce different pixel counts at different backing scales. Apple exposes no supported API for preloading the Shift-Command-5 selection rectangle.

## Manual release checklist

- Retina/non-Retina: dimensions remain logical-point exact and the aperture unobscured.
- Multiple monitors: negative origins, center/fit, disconnect/reconnect, and 80-point restore visibility.
- Light/Dark: badge, four border colors, and menu remain legible.
- Accessibility: Increase Contrast and Reduce Motion.
- Interaction: full-area native move, four anchored corner resizes, ratio switching, 320 × 180 minimum, and click-through recovery.
