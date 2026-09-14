import CoreGraphics
import Foundation

enum GuideColor: String, CaseIterable, Codable, Sendable {
    case white
    case black
    case red
    case presentationBlue

    var title: String {
        switch self {
        case .white: "White"
        case .black: "Black"
        case .red: "Red"
        case .presentationBlue: "Presentation Blue"
        }
    }
}

struct PersistedFrame: Codable, Equatable, Sendable {
    var x: Double
    var y: Double
    var width: Double
    var height: Double

    init(_ frame: CGRect) {
        x = frame.origin.x
        y = frame.origin.y
        width = frame.width
        height = frame.height
    }

    var cgRect: CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }
}

struct FramePreferences: Codable, Equatable, Sendable {
    var innerFrame: PersistedFrame?
    var color: GuideColor
    var clickThrough: Bool
    var isVisible: Bool
    var borderVisible: Bool
    var aspectRatio: GuideAspectRatio
    var aspectMode: GuideAspectMode

    static let defaults = FramePreferences(
        innerFrame: nil,
        color: .presentationBlue,
        clickThrough: false,
        isVisible: true,
        borderVisible: true,
        aspectRatio: .widescreen,
        aspectMode: .widescreen
    )

    private enum CodingKeys: String, CodingKey {
        case innerFrame
        case color
        case clickThrough
        case isVisible
        case borderVisible
        case aspectRatio
        case aspectMode
    }

    init(
        innerFrame: PersistedFrame?,
        color: GuideColor,
        clickThrough: Bool,
        isVisible: Bool,
        borderVisible: Bool = true,
        aspectRatio: GuideAspectRatio = .widescreen,
        aspectMode: GuideAspectMode = .widescreen
    ) {
        self.innerFrame = innerFrame
        self.color = color
        self.clickThrough = clickThrough
        self.isVisible = isVisible
        self.borderVisible = borderVisible
        self.aspectRatio = aspectRatio
        self.aspectMode = aspectMode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        innerFrame = try container.decodeIfPresent(PersistedFrame.self, forKey: .innerFrame)
        color = try container.decodeIfPresent(GuideColor.self, forKey: .color) ?? .presentationBlue
        clickThrough = try container.decodeIfPresent(Bool.self, forKey: .clickThrough) ?? false
        isVisible = try container.decodeIfPresent(Bool.self, forKey: .isVisible) ?? true
        borderVisible = try container.decodeIfPresent(Bool.self, forKey: .borderVisible) ?? true
        aspectRatio = try container.decodeIfPresent(
            GuideAspectRatio.self,
            forKey: .aspectRatio
        ) ?? .widescreen
        aspectMode = try container.decodeIfPresent(
            GuideAspectMode.self,
            forKey: .aspectMode
        ) ?? (aspectRatio == .widescreen ? .widescreen : .currentDisplay)
    }
}

struct FramePreferencesStore {
    private let defaults: UserDefaults
    private let key = "framePreferences"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> FramePreferences {
        guard
            let data = defaults.data(forKey: key),
            let value = try? JSONDecoder().decode(FramePreferences.self, from: data)
        else {
            return .defaults
        }
        return value
    }

    func save(_ preferences: FramePreferences) {
        guard let data = try? JSONEncoder().encode(preferences) else { return }
        defaults.set(data, forKey: key)
    }

    func reset() {
        defaults.removeObject(forKey: key)
    }
}
