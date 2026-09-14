import Foundation

enum ValidationFailure: Error, CustomStringConvertible {
    case mismatch(String)

    var description: String {
        switch self {
        case let .mismatch(message): message
        }
    }
}

func expect<T: Equatable>(_ actual: T, _ expected: T, _ message: String) throws {
    guard actual == expected else {
        throw ValidationFailure.mismatch("\(message): \(actual) != \(expected)")
    }
}

func expect(_ condition: Bool, _ message: String) throws {
    guard condition else {
        throw ValidationFailure.mismatch(message)
    }
}

func anchor(of corner: GuideCorner, in frame: CGRect) -> CGPoint {
    switch corner {
    case .topLeft: CGPoint(x: frame.maxX, y: frame.minY)
    case .topRight: CGPoint(x: frame.minX, y: frame.minY)
    case .bottomLeft: CGPoint(x: frame.maxX, y: frame.maxY)
    case .bottomRight: CGPoint(x: frame.minX, y: frame.maxY)
    }
}

do {
    try expect(
        GuideGeometry.size(width: 1000),
        CGSize(width: 1008, height: 567),
        "ratio width derivation"
    )
    try expect(
        GuideGeometry.size(height: 720),
        CGSize(width: 1280, height: 720),
        "ratio height derivation"
    )
    try expect(GuideGeometry.size(width: 1), GuideGeometry.minimumSize, "minimum size")
    try expect(
        GuideGeometry.size(width: 1000, aspectRatio: .standard),
        CGSize(width: 1000, height: 750),
        "4:3 width derivation"
    )
    try expect(
        GuideGeometry.size(height: 1600, aspectRatio: .mobilePortrait),
        CGSize(width: 900, height: 1600),
        "9:16 height derivation"
    )

    let original = CGRect(x: 100, y: 200, width: 640, height: 360)
    for corner in GuideCorner.allCases {
        let translation = CGSize(
            width: 160 * corner.horizontalDirection,
            height: 90 * corner.verticalDirection
        )
        let resized = GuideGeometry.resizedFrame(
            from: original,
            corner: corner,
            translation: translation
        )
        try expect(anchor(of: corner, in: resized), anchor(of: corner, in: original), "\(corner) anchor")
        try expect(resized.width * 9 == resized.height * 16, "\(corner) ratio")
    }

    for ratio in [
        GuideAspectRatio.widescreen,
        .standard,
        .ultrawide,
        .mobilePortrait,
        .classicPortrait
    ] {
        let ratioOriginal = CGRect(
            origin: CGPoint(x: -200, y: 80),
            size: GuideGeometry.size(width: 800, aspectRatio: ratio)
        )
        for corner in GuideCorner.allCases {
            let resized = GuideGeometry.resizedFrame(
                from: ratioOriginal,
                corner: corner,
                translation: CGSize(
                    width: 120 * corner.horizontalDirection,
                    height: 90 * corner.verticalDirection
                ),
                aspectRatio: ratio
            )
            try expect(
                anchor(of: corner, in: resized),
                anchor(of: corner, in: ratioOriginal),
                "\(corner) \(ratio.label) anchor"
            )
            try expect(
                abs(resized.width / resized.height - ratio.value) < 0.000_001,
                "\(corner) \(ratio.label) ratio"
            )
        }
    }

    let minimum = GuideGeometry.resizedFrame(
        from: CGRect(x: 0, y: 0, width: 640, height: 360),
        corner: .topRight,
        translation: CGSize(width: -1000, height: -1000)
    )
    try expect(minimum.size, GuideGeometry.minimumSize, "resize minimum")

    let visible = CGRect(x: -1440, y: 23, width: 1440, height: 877)
    let fitted = GuideGeometry.fittedFrame(in: visible)
    try expect(fitted.size, CGSize(width: 1440, height: 810), "fit size")
    try expect(fitted.origin, CGPoint(x: -1440, y: 57), "fit origin")
    try expect(visible.contains(fitted), "fit containment")
    let portraitFit = GuideGeometry.fittedFrame(
        in: CGRect(x: 0, y: 0, width: 1000, height: 800),
        aspectRatio: .classicPortrait
    )
    try expect(portraitFit, CGRect(x: 200, y: 0, width: 600, height: 800), "portrait fit")
    let containedFit = GuideGeometry.fittedFrame(
        in: CGRect(x: -999, y: 23, width: 999, height: 749),
        aspectRatio: .standard
    )
    try expect(containedFit.size, CGSize(width: 996, height: 747), "4:3 fit containment")
    let displayRatio = GuideAspectRatio(displaySize: CGSize(width: 1512, height: 982))
    let displayFit = GuideGeometry.fittedFrame(
        in: CGRect(x: 0, y: 0, width: 1512, height: 982),
        aspectRatio: displayRatio,
        quantized: false
    )
    try expect(displayFit.size, CGSize(width: 1512, height: 982), "display ratio exactness")
    let menuBarVisible = CGRect(x: 0, y: 0, width: 1512, height: 959)
    let menuBarFit = GuideGeometry.fittedFrame(
        in: menuBarVisible,
        aspectRatio: displayRatio,
        quantized: false
    )
    try expect(
        abs(menuBarFit.height - menuBarVisible.height) < 0.000_001,
        "display ratio largest visible fit"
    )
    try expect(
        abs(menuBarFit.width / menuBarFit.height - displayRatio.value) < 0.000_001,
        "display ratio fit exactness"
    )
    let widescreenDisplayFit = GuideGeometry.fittedFrame(
        in: menuBarVisible,
        aspectRatio: .widescreen,
        quantized: false
    )
    try expect(
        abs(widescreenDisplayFit.width - 1512) < 0.000_001
            && abs(widescreenDisplayFit.height - 850.5) < 0.000_001,
        "named-equivalent display ratio continuous fit"
    )

    let saved = CGRect(x: 2200, y: 200, width: 1280, height: 720)
    let primary = CGRect(x: 0, y: 0, width: 1440, height: 900)
    let restored = GuideGeometry.restoredFrame(saved, visibleFrames: [primary])
    try expect(restored.intersection(primary).width >= 80, "restore horizontal visibility")
    try expect(restored.intersection(primary).height >= 80, "restore vertical visibility")

    let negative = CGRect(x: -1300, y: 100, width: 960, height: 540)
    try expect(
        GuideGeometry.restoredFrame(
            negative,
            visibleFrames: [CGRect(x: -1440, y: 0, width: 1440, height: 900)]
        ),
        negative,
        "negative origin"
    )

    let suiteName = "SlideFrame.Validation.\(UUID().uuidString)"
    guard let defaults = UserDefaults(suiteName: suiteName) else {
        throw ValidationFailure.mismatch("could not create UserDefaults suite")
    }
    defer { defaults.removePersistentDomain(forName: suiteName) }
    let store = FramePreferencesStore(defaults: defaults)
    try expect(store.load(), .defaults, "preference defaults")
    let preferences = FramePreferences(
        innerFrame: PersistedFrame(negative),
        color: .red,
        clickThrough: true,
        isVisible: false,
        borderVisible: false,
        aspectRatio: .standard,
        aspectMode: .standard
    )
    store.save(preferences)
    try expect(store.load(), preferences, "preference round trip")

    struct LegacyPreferences: Codable {
        let innerFrame: PersistedFrame?
        let color: GuideColor
        let clickThrough: Bool
        let isVisible: Bool
        let aspectRatio: GuideAspectRatio
    }
    defaults.set(
        try JSONEncoder().encode(
            LegacyPreferences(
                innerFrame: nil,
                color: .presentationBlue,
                clickThrough: false,
                isVisible: true,
                aspectRatio: .ultrawide
            )
        ),
        forKey: "framePreferences"
    )
    try expect(store.load().aspectMode, .ultrawide, "legacy named aspect inference")

    store.reset()
    try expect(store.load(), .defaults, "preference reset")

    print("Validation passed: geometry and preferences")
} catch {
    fputs("Validation failed: \(error)\n", stderr)
    exit(1)
}
