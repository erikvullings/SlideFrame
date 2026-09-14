import Foundation
import XCTest
@testable import SlideFrame

final class FramePreferencesTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "SlideFrameTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testMissingValueLoadsDefaults() {
        let store = FramePreferencesStore(defaults: defaults)
        XCTAssertEqual(store.load(), .defaults)
    }

    func testRoundTripPersistsFrameColorVisibilityClickThroughAndRatio() {
        let store = FramePreferencesStore(defaults: defaults)
        let expected = FramePreferences(
            innerFrame: PersistedFrame(CGRect(x: -1200, y: 48, width: 1280, height: 720)),
            color: .red,
            clickThrough: true,
            isVisible: false,
            borderVisible: false,
            aspectRatio: .standard,
            aspectMode: .standard
        )
        store.save(expected)
        XCTAssertEqual(store.load(), expected)
    }

    func testResetRemovesStoredValue() {
        let store = FramePreferencesStore(defaults: defaults)
        store.save(
            FramePreferences(
                innerFrame: PersistedFrame(CGRect(x: 1, y: 2, width: 960, height: 540)),
                color: .black,
                clickThrough: true,
                isVisible: false,
                aspectRatio: .mobilePortrait,
                aspectMode: .mobilePortrait
            )
        )
        store.reset()
        XCTAssertEqual(store.load(), .defaults)
    }

    func testMalformedDataFallsBackToDefaults() {
        defaults.set(Data("not-json".utf8), forKey: "framePreferences")
        XCTAssertEqual(FramePreferencesStore(defaults: defaults).load(), .defaults)
    }

    func testLegacyRatioWithoutModeInfersNamedMode() throws {
        struct LegacyPreferences: Codable {
            let innerFrame: PersistedFrame?
            let color: GuideColor
            let clickThrough: Bool
            let isVisible: Bool
            let aspectRatio: GuideAspectRatio
        }
        let legacy = LegacyPreferences(
            innerFrame: nil,
            color: .presentationBlue,
            clickThrough: false,
            isVisible: true,
            aspectRatio: .ultrawide
        )
        defaults.set(try JSONEncoder().encode(legacy), forKey: "framePreferences")
        XCTAssertEqual(FramePreferencesStore(defaults: defaults).load().aspectMode, .ultrawide)
        XCTAssertTrue(FramePreferencesStore(defaults: defaults).load().borderVisible)
    }
}
