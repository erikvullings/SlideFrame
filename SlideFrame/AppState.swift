import AppKit
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var isVisible: Bool
    @Published private(set) var guideColor: GuideColor
    @Published private(set) var clickThrough: Bool
    @Published private(set) var borderVisible: Bool
    @Published private(set) var aspectRatio: GuideAspectRatio
    @Published private(set) var aspectMode: GuideAspectMode
    @Published private(set) var apertureSize: CGSize

    private let store: FramePreferencesStore
    private var innerFrame: CGRect
    private var controller: GuidePanelController?
    private var screenObserver: NSObjectProtocol?

    init(store: FramePreferencesStore = FramePreferencesStore()) {
        self.store = store
        let preferences = store.load()
        isVisible = preferences.isVisible
        guideColor = preferences.color
        clickThrough = preferences.clickThrough
        borderVisible = preferences.borderVisible
        aspectRatio = preferences.aspectRatio
        aspectMode = preferences.aspectMode
        apertureSize = .zero

        let screens = NSScreen.screens
        let initialScreen = Self.pointerScreen(in: screens) ?? NSScreen.main
        let defaultFrame = Self.defaultFrame(in: initialScreen?.visibleFrame ?? .zero)
        innerFrame = preferences.innerFrame?.cgRect ?? defaultFrame
        innerFrame = GuideGeometry.restoredFrame(
            innerFrame,
            visibleFrames: screens.map(\.visibleFrame),
            aspectRatio: aspectRatio
        )
        apertureSize = innerFrame.size

        controller = GuidePanelController(
            innerFrame: innerFrame,
            color: guideColor,
            clickThrough: clickThrough,
            borderVisible: borderVisible,
            aspectRatio: aspectRatio,
            aspectMode: aspectMode,
            frameDidChange: { [weak self] frame in
                self?.innerFrame = frame
                self?.apertureSize = frame.size
                self?.save()
            },
            aspectRatioDidChange: { [weak self] ratio, mode in
                self?.aspectRatio = ratio
                self?.aspectMode = mode
                self?.save()
            },
            borderVisibilityDidChange: { [weak self] visible in
                self?.borderVisible = visible
                self?.save()
            }
        )
        if isVisible {
            controller?.show()
        }

        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.controller?.clampToCurrentScreens()
            }
        }
    }

    deinit {
        if let screenObserver {
            NotificationCenter.default.removeObserver(screenObserver)
        }
    }

    func toggleVisibility() {
        isVisible.toggle()
        isVisible ? controller?.show() : controller?.hide()
        save()
    }

    func applyPreset(width: CGFloat, height: CGFloat) {
        aspectRatio = .widescreen
        aspectMode = .widescreen
        controller?.setAspectRatio(aspectRatio, mode: aspectMode)
        let size = CGSize(width: width, height: height)
        let centered = CGRect(
            x: innerFrame.midX - size.width / 2,
            y: innerFrame.midY - size.height / 2,
            width: size.width,
            height: size.height
        )
        controller?.setInnerFrame(centered)
        controller?.clampToCurrentScreens()
    }

    func fitToCurrentScreen() {
        controller?.fitToCurrentScreen()
    }

    func useCurrentDisplayRatio() {
        controller?.useCurrentDisplayRatio()
    }

    func applyAspectRatio(_ ratio: GuideAspectRatio) {
        let mode: GuideAspectMode
        switch ratio {
        case .widescreen: mode = .widescreen
        case .standard: mode = .standard
        case .ultrawide: mode = .ultrawide
        case .mobilePortrait: mode = .mobilePortrait
        case .classicPortrait: mode = .classicPortrait
        default: mode = .currentDisplay
        }
        controller?.setAspectRatio(ratio, mode: mode)
        controller?.fitToCurrentScreen()
    }

    func centerOnCurrentScreen() {
        controller?.centerOnCurrentScreen()
    }

    func toggleClickThrough() {
        clickThrough.toggle()
        controller?.setClickThrough(clickThrough)
        save()
    }

    func toggleBorderVisibility() {
        borderVisible.toggle()
        controller?.setBorderVisible(borderVisible)
        save()
    }

    func setColor(_ color: GuideColor) {
        guideColor = color
        controller?.setColor(color)
        save()
    }

    func reset() {
        store.reset()
        let target = Self.pointerScreen(in: NSScreen.screens) ?? NSScreen.main
        innerFrame = Self.defaultFrame(in: target?.visibleFrame ?? .zero)
        apertureSize = innerFrame.size
        guideColor = .presentationBlue
        clickThrough = false
        borderVisible = true
        isVisible = true
        aspectRatio = .widescreen
        aspectMode = .widescreen
        controller?.setColor(guideColor)
        controller?.setClickThrough(false)
        controller?.setBorderVisible(true)
        controller?.setAspectRatio(aspectRatio, mode: aspectMode)
        controller?.setInnerFrame(innerFrame)
        controller?.show()
        save()
    }

    private func save() {
        store.save(
            FramePreferences(
                innerFrame: PersistedFrame(innerFrame),
                color: guideColor,
                clickThrough: clickThrough,
                isVisible: isVisible,
                borderVisible: borderVisible,
                aspectRatio: aspectRatio,
                aspectMode: aspectMode
            )
        )
    }

    private static func defaultFrame(in visibleFrame: CGRect) -> CGRect {
        let desired = CGSize(width: 1280, height: 720)
        if visibleFrame.width >= desired.width, visibleFrame.height >= desired.height {
            return GuideGeometry.centeredFrame(size: desired, in: visibleFrame)
        }
        return GuideGeometry.fittedFrame(in: visibleFrame)
    }

    private static func pointerScreen(in screens: [NSScreen]) -> NSScreen? {
        let pointer = NSEvent.mouseLocation
        return screens.first(where: { $0.frame.contains(pointer) })
    }

    func isPreset(width: CGFloat, height: CGFloat) -> Bool {
        aspectMode == .widescreen
            && apertureSize == CGSize(width: width, height: height)
    }
}
