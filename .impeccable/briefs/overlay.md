# SlideFrame Overlay Surface Brief

## Mode

Operate

## Audience and task

Presenters and designers repeatedly position exact screenshot boundaries for presentation, standard, ultrawide, and mobile output over live desktop content. The guide must be immediately legible, geometrically trustworthy, and visually subordinate to the content inside it.

## Direction contract

**THESIS:** A precise native measuring instrument whose only visual statement is the boundary it guarantees. It refuses decorative dashboard chrome, skeuomorphic measurement tools, and branded spectacle.

**OWN-WORLD:** Transparent desktop aperture; crisp two-point presentation-blue perimeter; compact in-frame system-material control capsule showing dimensions and aspect ratio; four restrained square corner handles; SF Pro system typography with tabular numerals. White, black, and red are functional contrast alternatives, never decoration.

**STORY:** The user sees the exact aperture, drags its open surface to position it, chooses an exact preset or output ratio from the in-frame capsule or menu bar, confirms dimensions at a glance, then enables click-through so only the boundary remains.

**FIRST VIEWPORT:** The user's desktop remains the field. One centered 1280x720 aperture dominates, reduced only to fit the visible frame. The border sits outside the exact inner boundary, a compact capsule sits just inside the top edge, and four low-salience handles sit at the corners. The native menu bar remains the fallback control surface.

**FORM:** Brief-pinned restrained macOS utility direction; category-standard native conventions executed precisely. The required direction roll ran with seed key `4fbec81b`; its assigned fifth grounded candidate is superseded by the user's explicit pinned world.

**FINISH:** unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance

## Interaction and motion

The signature interaction is direct native full-area dragging with open/closed-hand cursor feedback. Corner resizing keeps the diagonally opposite corner fixed at the selected ratio. No decorative animation; any state transition uses the system's reduced-motion preference and should remain effectively instantaneous.

## States

- Visible and interactive: compact move/size/quit capsule and four corner handles shown.
- Boundary hidden: only the compact capsule remains visible, with its restore action available.
- Visible and click-through: panel ignores pointer events; badge and handles hidden.
- Hidden: geometry retained without destroying the panel.
- Increased contrast: stronger badge separation and handle/border clarity without changing aperture dimensions.

## Boundary semantics

Preset dimensions describe the transparent inner aperture in logical AppKit points. The two-point stroke is rendered outside that aperture where AppKit window bounds permit, so no guide pixel covers content intended for capture.
