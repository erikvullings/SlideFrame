import AppKit
import SwiftUI

enum GuidePanelLayout {
    static let borderWidth: CGFloat = 2
    static let handleInset: CGFloat = 8
    static let badgeAreaHeight: CGFloat = 0

    static func panelFrame(for innerFrame: CGRect) -> CGRect {
        CGRect(
            x: innerFrame.minX - handleInset,
            y: innerFrame.minY - handleInset,
            width: innerFrame.width + handleInset * 2,
            height: innerFrame.height + handleInset * 2
        )
    }

    static func innerFrame(for panelFrame: CGRect) -> CGRect {
        CGRect(
            x: panelFrame.minX + handleInset,
            y: panelFrame.minY + handleInset,
            width: panelFrame.width - handleInset * 2,
            height: panelFrame.height - handleInset * 2
        )
    }

    static func panelSize(for apertureSize: CGSize) -> CGSize {
        CGSize(
            width: apertureSize.width + handleInset * 2,
            height: apertureSize.height + handleInset * 2
        )
    }
}

@MainActor
final class GuidePanelController: NSObject, NSWindowDelegate {
    private let panel: GuidePanel
    private let viewModel: GuideViewModel
    private var innerFrame: CGRect
    private var resizeStartFrame: CGRect?
    private var movePersistenceTask: Task<Void, Never>?
    private var aspectRatio: GuideAspectRatio
    private var aspectMode: GuideAspectMode
    private let frameDidChange: (CGRect) -> Void
    private let aspectRatioDidChange: (GuideAspectRatio, GuideAspectMode) -> Void
    private let borderVisibilityDidChange: (Bool) -> Void

    init(
        innerFrame: CGRect,
        color: GuideColor,
        clickThrough: Bool,
        borderVisible: Bool,
        aspectRatio: GuideAspectRatio,
        aspectMode: GuideAspectMode,
        frameDidChange: @escaping (CGRect) -> Void,
        aspectRatioDidChange: @escaping (GuideAspectRatio, GuideAspectMode) -> Void,
        borderVisibilityDidChange: @escaping (Bool) -> Void
    ) {
        self.aspectRatio = aspectRatio
        self.aspectMode = aspectMode
        self.innerFrame = GuideGeometry.normalized(innerFrame, aspectRatio: aspectRatio)
        viewModel = GuideViewModel(
            apertureSize: self.innerFrame.size,
            guideColor: color,
            clickThrough: clickThrough,
            borderVisible: borderVisible,
            aspectLabel: aspectRatio.label
        )
        self.frameDidChange = frameDidChange
        self.aspectRatioDidChange = aspectRatioDidChange
        self.borderVisibilityDidChange = borderVisibilityDidChange
        panel = GuidePanel(contentRect: GuidePanelLayout.panelFrame(for: self.innerFrame))
        super.init()
        panel.delegate = self
        panel.ignoresMouseEvents = clickThrough
        render()
        panel.contentView?.wantsLayer = true
        panel.contentView?.layer?.backgroundColor = NSColor.clear.cgColor
        panel.contentView?.layer?.isOpaque = false
        panel.contentView?.layerContentsRedrawPolicy = .duringViewResize
    }

    func show() {
        panel.orderFrontRegardless()
    }

    func hide() {
        panel.orderOut(nil)
    }

    func setColor(_ color: GuideColor) {
        viewModel.guideColor = color
    }

    func setClickThrough(_ enabled: Bool) {
        panel.ignoresMouseEvents = enabled
        viewModel.clickThrough = enabled
    }

    func setBorderVisible(_ visible: Bool) {
        viewModel.borderVisible = visible
    }

    func setInnerFrame(_ frame: CGRect, notify: Bool = true) {
        innerFrame = GuideGeometry.normalized(frame, aspectRatio: aspectRatio)
        viewModel.apertureSize = innerFrame.size
        panel.setFrame(GuidePanelLayout.panelFrame(for: innerFrame), display: true)
        panel.contentView?.needsLayout = true
        panel.contentView?.needsDisplay = true
        panel.displayIfNeeded()
        if notify {
            frameDidChange(innerFrame)
        }
    }

    func fitToCurrentScreen() {
        guard let screen = currentScreen() else { return }
        setInnerFrame(
            GuideGeometry.fittedFrame(
                in: screen.visibleFrame,
                aspectRatio: aspectRatio
            )
        )
    }

    func useCurrentDisplayRatio() {
        guard let screen = currentScreen() else { return }
        setAspectRatio(
            GuideAspectRatio(displaySize: screen.frame.size),
            mode: .currentDisplay
        )
        fitToCurrentScreen()
    }

    func setAspectRatio(_ ratio: GuideAspectRatio, mode: GuideAspectMode) {
        aspectRatio = ratio
        aspectMode = mode
        viewModel.aspectLabel = ratio.label
        aspectRatioDidChange(ratio, mode)
    }

    func centerOnCurrentScreen() {
        guard let screen = currentScreen() else { return }
        setInnerFrame(GuideGeometry.centeredFrame(size: innerFrame.size, in: screen.visibleFrame))
    }

    func clampToCurrentScreens() {
        let restored = GuideGeometry.restoredFrame(
            innerFrame,
            visibleFrames: NSScreen.screens.map(\.visibleFrame),
            aspectRatio: aspectRatio
        )
        if restored != innerFrame {
            setInnerFrame(restored)
        }
    }

    func resize(corner: GuideCorner, translation: CGSize, ended: Bool) {
        if resizeStartFrame == nil {
            resizeStartFrame = innerFrame
        }
        guard let start = resizeStartFrame else { return }
        let resized = GuideGeometry.resizedFrame(
            from: start,
            corner: corner,
            translation: translation,
            aspectRatio: aspectRatio
        )
        setInnerFrame(resized, notify: ended)
        if ended {
            resizeStartFrame = nil
        }
    }

    func windowDidMove(_ notification: Notification) {
        guard updateInnerFrameFromPanel() else { return }
        movePersistenceTask?.cancel()
        movePersistenceTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 150_000_000)
            guard !Task.isCancelled, let self else { return }
            self.frameDidChange(self.innerFrame)
        }
    }

    private func persistCurrentPanelFrame() {
        _ = updateInnerFrameFromPanel()
        movePersistenceTask?.cancel()
        frameDidChange(innerFrame)
    }

    private func updateInnerFrameFromPanel() -> Bool {
        let movedFrame = GuidePanelLayout.innerFrame(for: panel.frame)
        let origin = CGPoint(
            x: movedFrame.origin.x.rounded(),
            y: movedFrame.origin.y.rounded()
        )
        guard origin != innerFrame.origin else { return false }
        innerFrame.origin = origin
        return true
    }

    private func currentScreen() -> NSScreen? {
        let center = CGPoint(x: innerFrame.midX, y: innerFrame.midY)
        if let containing = NSScreen.screens.first(where: { $0.frame.contains(center) }) {
            return containing
        }
        let pointer = NSEvent.mouseLocation
        return NSScreen.screens.first(where: { $0.frame.contains(pointer) }) ?? NSScreen.main
    }

    private func render() {
        panel.contentView = NSHostingView(
            rootView: GuideView(
                model: viewModel,
                onResize: { [weak self] corner, translation, ended in
                    self?.resize(corner: corner, translation: translation, ended: ended)
                },
                onMoveEnded: { [weak self] in
                    self?.persistCurrentPanelFrame()
                },
                onShowSizeMenu: { [weak self] in
                    self?.showSizeMenu()
                },
                onToggleBorder: { [weak self] in
                    guard let self else { return }
                    let visible = !self.viewModel.borderVisible
                    self.setBorderVisible(visible)
                    self.borderVisibilityDidChange(visible)
                },
                onQuit: {
                    NSApplication.shared.terminate(nil)
                }
            )
        )
    }

    private func showSizeMenu() {
        let menu = NSMenu(title: "Frame Size")
        let presets = [
            CGSize(width: 960, height: 540),
            CGSize(width: 1280, height: 720),
            CGSize(width: 1600, height: 900),
            CGSize(width: 1920, height: 1080)
        ]
        for (index, size) in presets.enumerated() {
            let item = NSMenuItem(
                title: "\(Int(size.width)) × \(Int(size.height))",
                action: #selector(selectPreset(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.tag = index
            item.state = aspectMode == .widescreen && innerFrame.size == size ? .on : .off
            menu.addItem(item)
        }
        menu.addItem(.separator())
        let displayRatio = NSMenuItem(
            title: "Current Display Ratio",
            action: #selector(selectCurrentDisplayRatio),
            keyEquivalent: ""
        )
        displayRatio.target = self
        displayRatio.state = aspectMode == .currentDisplay ? .on : .off
        menu.addItem(displayRatio)
        menu.addItem(.separator())
        addAspectItem(to: menu, title: "Widescreen 16:9", ratio: .widescreen, tag: 0)
        addAspectItem(to: menu, title: "Standard 4:3", ratio: .standard, tag: 1)
        addAspectItem(to: menu, title: "Ultrawide 21:9", ratio: .ultrawide, tag: 2)
        addAspectItem(to: menu, title: "Mobile 9:16", ratio: .mobilePortrait, tag: 3)
        addAspectItem(to: menu, title: "Portrait 3:4", ratio: .classicPortrait, tag: 4)
        menu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
    }

    private func addAspectItem(
        to menu: NSMenu,
        title: String,
        ratio: GuideAspectRatio,
        tag: Int
    ) {
        let item = NSMenuItem(
            title: title,
            action: #selector(selectAspectRatio(_:)),
            keyEquivalent: ""
        )
        item.target = self
        item.tag = tag
        item.state = aspectMode.fixedRatio == ratio ? .on : .off
        menu.addItem(item)
    }

    @objc private func selectPreset(_ sender: NSMenuItem) {
        let presets = [
            CGSize(width: 960, height: 540),
            CGSize(width: 1280, height: 720),
            CGSize(width: 1600, height: 900),
            CGSize(width: 1920, height: 1080)
        ]
        guard presets.indices.contains(sender.tag) else { return }
        let size = presets[sender.tag]
        setAspectRatio(.widescreen, mode: .widescreen)
        setInnerFrame(
            CGRect(
                x: innerFrame.midX - size.width / 2,
                y: innerFrame.midY - size.height / 2,
                width: size.width,
                height: size.height
            )
        )
        clampToCurrentScreens()
    }

    @objc private func selectCurrentDisplayRatio() {
        useCurrentDisplayRatio()
    }

    @objc private func selectAspectRatio(_ sender: NSMenuItem) {
        let modes: [GuideAspectMode] = [
            .widescreen,
            .standard,
            .ultrawide,
            .mobilePortrait,
            .classicPortrait
        ]
        guard modes.indices.contains(sender.tag),
              let ratio = modes[sender.tag].fixedRatio
        else { return }
        setAspectRatio(ratio, mode: modes[sender.tag])
        fitToCurrentScreen()
    }
}
