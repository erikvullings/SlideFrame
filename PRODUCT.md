# Product

<!-- impeccable:product-schema 1 -->

## Platform

macos

## Stack

Delegated: native macOS 14+ application using SwiftUI and AppKit, with no third-party dependencies.

## Users

Presenters and designers who repeatedly prepare exact-size screenshots in presentation, ultrawide, standard, and mobile formats while arranging content across one or more Mac displays.

## Product Purpose

SlideFrame provides a persistent, exact-size, transparent framing guide above normal windows. Success means users can position and resize a nonintrusive aperture, capture reliably sized content, and leave the guide in place without disrupting the application being framed.

## Positioning

Unlike screenshot editors or post-capture crop tools, SlideFrame defines the capture boundary directly on the desktop in logical points before the screenshot is taken.

## Operating Context

The app runs only in the macOS menu bar. Users work across Retina and non-Retina displays, Spaces, full-screen apps where macOS permits overlays, negative display coordinates, and changing monitor arrangements. Frequent actions are selecting an exact preset, fitting or centering the guide on the current display, changing border color for contrast, and toggling click-through.

## Capabilities and Constraints

- A transparent inner aperture with an outside 2-point guide border, compact in-frame controls, and four restrained corner handles.
- The boundary can be hidden independently, leaving the compact dimensions/aspect capsule available; Hide Frame hides the complete overlay without discarding geometry.
- Exact presets: 960x540, 1280x720, 1600x900, and 1920x1080 logical points.
- Named aspect modes: 16:9, 4:3, 21:9, 9:16, 3:4, and the current display ratio.
- Corner resize keeps the opposite corner anchored, enforces the selected ratio, and never goes below 320x180.
- Native diagonal cursors identify corner resizing.
- Fit uses the largest centered aperture at the selected ratio inside the current screen's visible frame.
- Center uses the screen containing the frame center, falling back to the screen under the pointer.
- Geometry, color, visibility behavior, and click-through state persist without assuming a display scale.
- Restored frames retain at least 80 points on a current display after display changes.
- The overlay is nonactivating, does not steal focus, remains above normal windows, and participates across Spaces/full-screen where macOS allows.
- Increase Contrast and Reduce Motion are respected.

## Brand Commitments

The product name is SlideFrame. Its visual direction is a restrained, precise native utility: presentation blue by default, with white, black, and red working alternatives. It must not acquire decorative concepts or web-like chrome.

## Evidence on Hand

No external brand assets, commercial claims, screenshots, or supplied imagery exist. Future work must not fabricate them.

## Product Principles

- Exact means logical-point exact, independent of display backing scale.
- The framed content remains visually untouched.
- The utility stays available without taking focus from the user's work.
- Geometry survives restarts and display changes safely.
- Controls use familiar macOS vocabulary and remain fast under repetition.
- The menu bar remains the complete fallback control surface; the compact badge provides frequent size and quit actions.
- Native full-area dragging keeps movement directly coupled to the pointer while controls and corner handles retain priority.
- Open/closed-hand cursor feedback communicates the full-area move interaction.
- The app is menu-bar-only with no Dock icon; Quit remains available from both native control surfaces.

## Accessibility & Inclusion

Use native menu semantics, keyboard-accessible menu commands, system colors where appropriate, and explicit adaptations for Reduce Motion and Increase Contrast.
