import AppKit

final class GuidePanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    init(contentRect: CGRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        preservesContentDuringLiveResize = false
        level = .floating
        hidesOnDeactivate = false
        isMovable = false
        isMovableByWindowBackground = true
        animationBehavior = .none
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        setAccessibilityLabel("SlideFrame guide")
    }
}
