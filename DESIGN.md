---
name: SlideFrame
description: A restrained native measuring aperture for exact presentation, standard, ultrawide, and mobile framing.
colors:
  presentation-blue: "rgb(10% 48% 100%)"
  working-white: "white"
  working-black: "black"
  working-red: "red"
  transparent-field: "transparent"
typography:
  measurement-label:
    fontFamily: "SF Pro Rounded, system-ui, sans-serif"
    fontSize: "12px"
    fontWeight: 500
    fontFeature: "tabular-nums"
  capsule-icon:
    fontFamily: "SF Symbols, system-ui, sans-serif"
    fontSize: "9px"
    fontWeight: 600
rounded:
  handle: "1.5px"
  capsule: "999px"
spacing:
  interaction-inset: "8px"
  capsule-horizontal: "7px"
  capsule-item-gap: "5px"
components:
  control-capsule:
    typography: "{typography.measurement-label}"
    rounded: "{rounded.capsule}"
    padding: "0 7px"
    height: "22px"
  corner-handle:
    backgroundColor: "{colors.presentation-blue}"
    rounded: "{rounded.handle}"
    size: "8px"
---

# Design System: SlideFrame

## Overview

**Creative North Star: "The Desktop Aperture"**

SlideFrame is a restrained native measuring instrument, not an application window laid over the desktop. Its transparent field leaves the user's work visually untouched while one exact perimeter, one compact in-frame control capsule, and four quiet corner handles communicate the complete overlay state.

The system is sparse, direct, and geometrically trustworthy. It uses macOS-native material, menus, cursors, SF Symbols, and system type rather than decorative chrome. Multiple output ratios are first-class, but the overlay keeps one consistent visual vocabulary across them.

**Key Characteristics:**
- A transparent aperture at the selected ratio is the dominant form.
- Presentation blue is the default working signal; white, black, and red are contrast alternatives.
- Four exact 16:9 presets coexist with 16:9, 4:3, 21:9, 9:16, 3:4, and current-display ratio modes.
- Native full-area dragging uses open- and closed-hand cursor feedback while capsule controls and corner handles retain interaction priority.
- The in-frame capsule reports dimensions and aspect ratio and exposes frequent border, size, and quit actions.

## Colors

The palette is functional and contrast-led: one default signal color, three working alternatives, and an otherwise transparent field.

### Primary
- **Presentation Blue:** The default perimeter and handle color; use it only to mark the guaranteed capture boundary and its resize affordances.

### Secondary
- **Working Red:** A high-salience contrast alternative for desktop content that obscures the default blue.

### Neutral
- **Working White:** A light contrast alternative for dark desktop content.
- **Working Black:** A dark contrast alternative for light desktop content and the opposing edge on colored handles.
- **Transparent Field:** The panel and aperture remain optically absent so framed content is not tinted, dimmed, or covered.

### Named Rules

**The Boundary-Only Color Rule.** Working colors identify the measured perimeter and handles; they do not decorate menus or create branded surfaces.

**The Functional Alternatives Rule.** White, black, and red are user-selected contrast tools, never a simultaneous palette.

## Typography

**Display Font:** Not used  
**Body Font:** macOS system type  
**Label/Mono Font:** SF Pro Rounded with tabular numerals

**Character:** Type is native, compact, and factual. The measurement role uses the rounded system design and fixed-width numerals so changing dimensions remain calm and aligned; menu and symbol labels retain native defaults.

### Hierarchy
- **Measurement Label** (medium, 12 points, tabular numerals): The `width × height · ratio` control in the capsule.
- **Capsule Symbols** (semibold or bold, 8–10 points): Native move, border, disclosure, and quit glyphs.
- **Menu Text** (native menu defaults): Presets, aspect modes, visibility, positioning, color, reset, and quit commands.

### Named Rules

**The Measurement Type Rule.** Dimensions and ratio use SF Pro Rounded medium with tabular numerals; command text and symbols stay at native macOS defaults.

## Layout

The transparent inner aperture uses the selected ratio in logical AppKit points. Named modes are 16:9, 4:3, 21:9, 9:16, 3:4, and the current display ratio. The exact presets are 960 × 540, 1280 × 720, 1600 × 900, and 1920 × 1080; choosing one also selects 16:9. The default is a centered 1280 × 720 aperture when the current visible screen can contain it, otherwise the largest centered 16:9 size that fits.

Four corner handles preserve the selected ratio exactly, keep the diagonally opposite corner anchored, resolve dimensions to whole ratio units, and never go below 320 × 180. Fit chooses the largest centered aperture at the selected ratio within the current screen's visible frame. Restored geometry retains at least 80 points on a current display.

The panel adds an 8-point interaction inset on every side without adding an external badge area. The 22-point control capsule is centered just inside the aperture's top edge. Four 8-point handles sit at the perimeter intersections. A native drag surface spans the full panel behind the capsule and handles, making the open aperture itself the primary move target.

**The Inner-Boundary Rule.** Preset dimensions describe the transparent inner aperture; the two-point guide stroke sits outside it and must never reduce the captured area.

**The Selected-Ratio Rule.** Fit, restore, and corner resize preserve the active ratio; only the four exact presets force 16:9.

**The Direct-Manipulation Rule.** The full clear panel moves natively with open- and closed-hand feedback; capsule controls and corner handles remain above that move surface.

## Elevation & Depth

The overlay is flat and shadowless. The borderless panel has no window shadow, and depth comes only from the control capsule's semi-transparent native regular material and thin adaptive primary-label outline. In increased-contrast mode, a one-point opposing outline strengthens the perimeter while capsule and handle separation increase without changing aperture geometry.

Transparent live resizing disables AppKit content preservation, places the clear hosting view on a non-opaque layer, redraws during resize, and explicitly requests layout and display after programmatic frame changes. These are rendering invariants that prevent stale transparent backing content and resize ghosts.

**The No-Window-Chrome Rule.** The guide has no opaque panel surface, title bar, window shadow, or decorative elevation.

## Shapes

Geometry is rectilinear and exact. The aperture is a sharp rectangle with a two-point perimeter. Four 8-point square handles sit at the corner intersections, using restrained 1.5-point corners and an opposing-color hairline. The control capsule is the sole pill silhouette: a compact 22-point-high native-material action cluster inside the frame.

## Components

### Guide Perimeter
- **Shape:** A sharp rectangle at the selected ratio whose two-point stroke is offset outside the exact inner aperture.
- **Color:** Presentation blue by default; one user-selected working alternative may replace it.
- **Contrast:** Increased Contrast adds a one-point opposing outline without moving the inner boundary.
- **Interaction:** A full-area native AppKit drag surface delegates movement to `NSWindow.performDrag`. The cursor is an open hand at rest and a closed hand while dragging. The panel never activates or becomes key.
- **Visibility:** The boundary can be hidden independently, leaving only the capsule.

### Control Capsule
- **Shape:** A 22-point-high capsule with 7-point horizontal padding and 5-point item spacing, centered just inside the aperture's top edge.
- **Material:** Semi-transparent native regular material with primary-label content and a subtle primary-label outline.
- **Content:** A passive move glyph; a border visibility control; `width × height · ratio` with disclosure; and a quit control.
- **Size Menu:** The disclosure opens the four exact 16:9 presets, current-display ratio, and five named ratios using native menu items and checkmarks.
- **State:** The capsule remains when the boundary is hidden and disappears when click-through is enabled.

### Corner Handles
- **Shape:** Exactly four 8-point near-square handles with 1.5-point corners, centered at the perimeter's corner intersections.
- **Color:** They match the perimeter and carry a subtle opposing-color outline.
- **Interaction:** Native diagonal resize cursors identify each corner axis. Dragging preserves the selected ratio with the opposite corner anchored.
- **State:** Handles appear only while the boundary is visible and interaction is enabled.

### Native Menu
- **Style:** A standard `MenuBarExtra` menu with native buttons, submenus, dividers, checkmarks, keyboard shortcuts, and the `rectangle.inset.filled` SF Symbol.
- **Organization:** Frame and border visibility come first; size, fit, and center follow; click-through and border color come next; Reset and Quit close the menu.
- **Role:** The menu bar is the complete fallback control surface for every overlay state.

### Dock Icon
- **Style:** A simple rounded-square blue icon showing a white aperture, four black corner handles, and one dark `16:9` capsule.
- **Role:** It echoes the shipped overlay without adding a separate brand illustration and supports standard macOS Dock management.

## Do's and Don'ts

### Do:
- **Do** keep the desktop and framed content fully transparent and visually untouched.
- **Do** preserve the selected ratio during fit, restore, and exact opposite-corner resizing.
- **Do** keep all four exact presets at 16:9 while exposing the five named ratios and current-display ratio.
- **Do** use full-area native dragging with open- and closed-hand feedback.
- **Do** keep dimensions, aspect ratio, border visibility, size choices, and quit available in the compact in-frame capsule.
- **Do** allow the boundary-hidden capsule-only state and hide capsule plus handles during click-through.
- **Do** rely on native macOS menus, materials, system colors, typography, symbols, and cursor behavior.

### Don't:
- **Don't** add dashboard chrome, inspectors, floating toolbars, title bars, or opaque framing surfaces.
- **Don't** place the perimeter stroke inside the aperture.
- **Don't** add side or midpoint resize handles; the four corners are the complete resize vocabulary.
- **Don't** restrict movement to border strips or make the transparent aperture feel inert.
- **Don't** hide the capsule merely because the boundary is hidden.
- **Don't** add window shadows or decorative animation; state changes are immediate.
- **Don't** replace native menu affordances or system typography with web-shaped controls or display faces.
