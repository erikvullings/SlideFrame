import XCTest
@testable import SlideFrame

final class GuideGeometryTests: XCTestCase {
    func testRatioDerivationRoundsToWholeSixteenByNineUnits() {
        XCTAssertEqual(GuideGeometry.size(width: 1000), CGSize(width: 1008, height: 567))
        XCTAssertEqual(GuideGeometry.size(height: 720), CGSize(width: 1280, height: 720))
        XCTAssertEqual(GuideGeometry.size(width: 1), GuideGeometry.minimumSize)
    }

    func testNamedRatiosDeriveWholePointSizes() {
        XCTAssertEqual(
            GuideGeometry.size(width: 1000, aspectRatio: .standard),
            CGSize(width: 1000, height: 750)
        )
        XCTAssertEqual(
            GuideGeometry.size(height: 1600, aspectRatio: .mobilePortrait),
            CGSize(width: 900, height: 1600)
        )
        XCTAssertEqual(
            GuideAspectRatio(displaySize: CGSize(width: 1512, height: 982)),
            GuideAspectRatio(width: 1512, height: 982)
        )
    }

    func testEveryCornerKeepsOppositeCornerAnchored() {
        let original = CGRect(x: 100, y: 200, width: 640, height: 360)
        let translation = CGSize(width: 160, height: 90)

        for corner in GuideCorner.allCases {
            let adjusted = CGSize(
                width: translation.width * corner.horizontalDirection,
                height: translation.height * corner.verticalDirection
            )
            let resized = GuideGeometry.resizedFrame(
                from: original,
                corner: corner,
                translation: adjusted
            )
            XCTAssertEqual(anchor(of: corner, in: resized), anchor(of: corner, in: original))
            XCTAssertEqual(resized.width / resized.height, 16.0 / 9.0, accuracy: 0.000_001)
        }

    }

    func testEveryCornerPreservesSelectedRatio() {
        let ratios: [GuideAspectRatio] = [
            .widescreen,
            .standard,
            .ultrawide,
            .mobilePortrait,
            .classicPortrait
        ]
        for ratio in ratios {
            let size = GuideGeometry.size(width: 800, aspectRatio: ratio)
            let original = CGRect(origin: CGPoint(x: -200, y: 80), size: size)
            for corner in GuideCorner.allCases {
                let resized = GuideGeometry.resizedFrame(
                    from: original,
                    corner: corner,
                    translation: CGSize(
                        width: 120 * corner.horizontalDirection,
                        height: 90 * corner.verticalDirection
                    ),
                    aspectRatio: ratio
                )
                XCTAssertEqual(anchor(of: corner, in: resized), anchor(of: corner, in: original))
                XCTAssertEqual(resized.width / resized.height, ratio.value, accuracy: 0.000_001)
            }
        }
    }

    func testResizeEnforcesMinimum() {
        let original = CGRect(x: 0, y: 0, width: 640, height: 360)
        let resized = GuideGeometry.resizedFrame(
            from: original,
            corner: .topRight,
            translation: CGSize(width: -1000, height: -1000)
        )
        XCTAssertEqual(resized.size, GuideGeometry.minimumSize)
        XCTAssertEqual(resized.origin, original.origin)
    }

    func testFitUsesLargestWholePointSixteenByNineFrame() {
        let visible = CGRect(x: -1440, y: 23, width: 1440, height: 877)
        let fitted = GuideGeometry.fittedFrame(in: visible)
        XCTAssertEqual(fitted.size, CGSize(width: 1440, height: 810))
        XCTAssertEqual(fitted.origin, CGPoint(x: -1440, y: 57))
        XCTAssertTrue(visible.contains(fitted))
    }

    func testFitNeverDropsBelowMinimumAperture() {
        let fitted = GuideGeometry.fittedFrame(in: CGRect(x: 0, y: 0, width: 200, height: 100))
        XCTAssertEqual(fitted.size, GuideGeometry.minimumSize)
    }

    func testFitUsesSelectedPortraitRatio() {
        let fitted = GuideGeometry.fittedFrame(
            in: CGRect(x: 0, y: 0, width: 1000, height: 800),
            aspectRatio: .classicPortrait
        )
        XCTAssertEqual(fitted.size, CGSize(width: 600, height: 800))
        XCTAssertEqual(fitted.origin, CGPoint(x: 200, y: 0))
    }

    func testNonWidescreenFitNeverExceedsVisibleFrame() {
        let visible = CGRect(x: -999, y: 23, width: 999, height: 749)
        let fitted = GuideGeometry.fittedFrame(in: visible, aspectRatio: .standard)
        XCTAssertEqual(fitted.size, CGSize(width: 996, height: 747))
        XCTAssertTrue(visible.contains(fitted))
    }

    func testCurrentDisplayRatioRemainsExact() {
        let ratio = GuideAspectRatio(displaySize: CGSize(width: 1512, height: 982))
        let fitted = GuideGeometry.fittedFrame(
            in: CGRect(x: 0, y: 0, width: 1512, height: 982),
            aspectRatio: ratio
        )
        XCTAssertEqual(fitted.size, CGSize(width: 1512, height: 982))
        XCTAssertEqual(fitted.width / fitted.height, ratio.value, accuracy: 0.000_001)
    }

    func testRestorePreservesNegativeOriginWhenVisible() {
        let saved = CGRect(x: -1300, y: 100, width: 960, height: 540)
        let screens = [CGRect(x: -1440, y: 0, width: 1440, height: 900)]
        XCTAssertEqual(GuideGeometry.restoredFrame(saved, visibleFrames: screens), saved)
    }

    func testRestoreClampsRemovedSecondaryDisplay() {
        let saved = CGRect(x: 2200, y: 200, width: 1280, height: 720)
        let primary = CGRect(x: 0, y: 0, width: 1440, height: 900)
        let restored = GuideGeometry.restoredFrame(saved, visibleFrames: [primary])
        XCTAssertGreaterThanOrEqual(restored.intersection(primary).width, 80)
        XCTAssertGreaterThanOrEqual(restored.intersection(primary).height, 80)
    }

    func testNormalizationRoundsOriginAndMaintainsWholePointRatio() {
        let normalized = GuideGeometry.normalized(
            CGRect(x: -12.6, y: 42.4, width: 1001.2, height: 600)
        )
        XCTAssertEqual(normalized.origin, CGPoint(x: -13, y: 42))
        XCTAssertEqual(normalized.size, CGSize(width: 1008, height: 567))
    }

    private func anchor(of corner: GuideCorner, in frame: CGRect) -> CGPoint {
        switch corner {
        case .topLeft: CGPoint(x: frame.maxX, y: frame.minY)
        case .topRight: CGPoint(x: frame.minX, y: frame.minY)
        case .bottomLeft: CGPoint(x: frame.maxX, y: frame.maxY)
        case .bottomRight: CGPoint(x: frame.minX, y: frame.maxY)
        }
    }
}
