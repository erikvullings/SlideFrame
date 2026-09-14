import CoreGraphics
import Foundation

struct GuideAspectRatio: Codable, Equatable, Sendable {
    let width: CGFloat
    let height: CGFloat

    static let widescreen = GuideAspectRatio(width: 16, height: 9)
    static let standard = GuideAspectRatio(width: 4, height: 3)
    static let ultrawide = GuideAspectRatio(width: 21, height: 9)
    static let mobilePortrait = GuideAspectRatio(width: 9, height: 16)
    static let classicPortrait = GuideAspectRatio(width: 3, height: 4)

    init(width: CGFloat, height: CGFloat) {
        self.width = max(1, width)
        self.height = max(1, height)
    }

    init(displaySize: CGSize) {
        self.init(width: displaySize.width, height: displaySize.height)
    }

    var value: CGFloat {
        width / height
    }

    var label: String {
        switch self {
        case .widescreen: "16:9"
        case .standard: "4:3"
        case .ultrawide: "21:9"
        case .mobilePortrait: "9:16"
        case .classicPortrait: "3:4"
        default: "\(Int(width.rounded())):\(Int(height.rounded()))"
        }
    }
}

enum GuideAspectMode: String, Codable, Equatable, Sendable {
    case widescreen
    case standard
    case ultrawide
    case mobilePortrait
    case classicPortrait
    case currentDisplay

    var fixedRatio: GuideAspectRatio? {
        switch self {
        case .widescreen: .widescreen
        case .standard: .standard
        case .ultrawide: .ultrawide
        case .mobilePortrait: .mobilePortrait
        case .classicPortrait: .classicPortrait
        case .currentDisplay: nil
        }
    }

    var title: String {
        switch self {
        case .widescreen: "16:9"
        case .standard: "4:3"
        case .ultrawide: "21:9"
        case .mobilePortrait: "9:16"
        case .classicPortrait: "3:4"
        case .currentDisplay: "Display"
        }
    }

    static func inferred(from ratio: GuideAspectRatio) -> GuideAspectMode {
        switch ratio {
        case .widescreen: .widescreen
        case .standard: .standard
        case .ultrawide: .ultrawide
        case .mobilePortrait: .mobilePortrait
        case .classicPortrait: .classicPortrait
        default: .currentDisplay
        }
    }
}

enum GuideCorner: CaseIterable, Sendable {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight

    var horizontalDirection: CGFloat {
        switch self {
        case .topLeft, .bottomLeft: -1
        case .topRight, .bottomRight: 1
        }
    }

    var verticalDirection: CGFloat {
        switch self {
        case .topLeft, .topRight: 1
        case .bottomLeft, .bottomRight: -1
        }
    }
}

enum GuideGeometry {
    static let aspectRatio = GuideAspectRatio.widescreen.value
    static let minimumSize = CGSize(width: 320, height: 180)
    static let minimumVisibleLength: CGFloat = 80

    static func size(
        width: CGFloat,
        aspectRatio: GuideAspectRatio = .widescreen,
        quantized: Bool = true
    ) -> CGSize {
        let pair = integerPair(for: aspectRatio)
        if !quantized {
            let minimumWidth = max(minimumSize.width, minimumSize.height * aspectRatio.value)
            let resolvedWidth = max(minimumWidth, width)
            return CGSize(width: resolvedWidth, height: resolvedWidth / aspectRatio.value)
        }
        let units = max(
            Int(ceil(minimumSize.width / pair.width)),
            Int(ceil(minimumSize.height / pair.height)),
            Int((width / pair.width).rounded())
        )
        return CGSize(width: CGFloat(units) * pair.width, height: CGFloat(units) * pair.height)
    }

    static func size(
        height: CGFloat,
        aspectRatio: GuideAspectRatio = .widescreen,
        quantized: Bool = true
    ) -> CGSize {
        let pair = integerPair(for: aspectRatio)
        if !quantized {
            let minimumHeight = max(minimumSize.height, minimumSize.width / aspectRatio.value)
            let resolvedHeight = max(minimumHeight, height)
            return CGSize(width: resolvedHeight * aspectRatio.value, height: resolvedHeight)
        }
        let units = max(
            Int(ceil(minimumSize.width / pair.width)),
            Int(ceil(minimumSize.height / pair.height)),
            Int((height / pair.height).rounded())
        )
        return CGSize(width: CGFloat(units) * pair.width, height: CGFloat(units) * pair.height)
    }

    static func resizedFrame(
        from frame: CGRect,
        corner: GuideCorner,
        translation: CGSize,
        aspectRatio: GuideAspectRatio = .widescreen,
        quantized: Bool = true
    ) -> CGRect {
        let anchor = oppositePoint(of: corner, in: frame)
        let dragged = cornerPoint(of: corner, in: frame)
        let desired = CGPoint(
            x: dragged.x + translation.width,
            y: dragged.y + translation.height
        )
        let horizontal = (desired.x - anchor.x) * corner.horizontalDirection
        let vertical = (desired.y - anchor.y) * corner.verticalDirection
        let projectedWidth = (
            horizontal + vertical / aspectRatio.value
        ) / (
            1 + 1 / (aspectRatio.value * aspectRatio.value)
        )
        let constrainedSize = size(
            width: max(minimumSize.width, projectedWidth),
            aspectRatio: aspectRatio,
            quantized: quantized
        )

        return CGRect(
            x: corner.horizontalDirection < 0 ? anchor.x - constrainedSize.width : anchor.x,
            y: corner.verticalDirection < 0 ? anchor.y - constrainedSize.height : anchor.y,
            width: constrainedSize.width,
            height: constrainedSize.height
        )
    }

    static func fittedFrame(
        in visibleFrame: CGRect,
        aspectRatio: GuideAspectRatio = .widescreen,
        quantized: Bool = true
    ) -> CGRect {
        let pair = integerPair(for: aspectRatio)
        if !quantized {
            let maximumWidth = min(visibleFrame.width, visibleFrame.height * aspectRatio.value)
            let fittedSize = size(
                width: maximumWidth,
                aspectRatio: aspectRatio,
                quantized: false
            )
            return CGRect(
                x: visibleFrame.midX - fittedSize.width / 2,
                y: visibleFrame.midY - fittedSize.height / 2,
                width: fittedSize.width,
                height: fittedSize.height
            )
        }
        let minimumUnits = max(
            Int(ceil(minimumSize.width / pair.width)),
            Int(ceil(minimumSize.height / pair.height))
        )
        let horizontalUnits = Int(floor(visibleFrame.width / pair.width))
        let verticalUnits = Int(floor(visibleFrame.height / pair.height))
        let units = max(minimumUnits, min(horizontalUnits, verticalUnits))
        let fittedSize = CGSize(
            width: CGFloat(units) * pair.width,
            height: CGFloat(units) * pair.height
        )
        return centeredFrame(size: fittedSize, in: visibleFrame)
    }

    static func centeredFrame(size: CGSize, in frame: CGRect) -> CGRect {
        CGRect(
            x: (frame.midX - size.width / 2).rounded(),
            y: (frame.midY - size.height / 2).rounded(),
            width: size.width.rounded(),
            height: size.height.rounded()
        )
    }

    static func normalized(
        _ frame: CGRect,
        aspectRatio: GuideAspectRatio = .widescreen,
        quantized: Bool = true
    ) -> CGRect {
        let normalizedSize = size(
            width: frame.width,
            aspectRatio: aspectRatio,
            quantized: quantized
        )
        return CGRect(
            x: frame.origin.x.rounded(),
            y: frame.origin.y.rounded(),
            width: normalizedSize.width,
            height: normalizedSize.height
        )
    }

    static func restoredFrame(
        _ savedFrame: CGRect,
        visibleFrames: [CGRect],
        aspectRatio: GuideAspectRatio = .widescreen,
        quantized: Bool = true
    ) -> CGRect {
        let frame = normalized(
            savedFrame,
            aspectRatio: aspectRatio,
            quantized: quantized
        )
        guard !visibleFrames.isEmpty else { return frame }
        if visibleFrames.contains(where: { sufficientlyVisible(frame, on: $0) }) {
            return frame
        }

        let target = visibleFrames.min {
            squaredDistance(from: frame.center, to: $0.center)
                < squaredDistance(from: frame.center, to: $1.center)
        } ?? visibleFrames[0]
        let xRange = (
            target.minX + minimumVisibleLength - frame.width
        )...(
            target.maxX - minimumVisibleLength
        )
        let yRange = (
            target.minY + minimumVisibleLength - frame.height
        )...(
            target.maxY - minimumVisibleLength
        )
        return CGRect(
            x: min(max(frame.minX, xRange.lowerBound), xRange.upperBound).rounded(),
            y: min(max(frame.minY, yRange.lowerBound), yRange.upperBound).rounded(),
            width: frame.width,
            height: frame.height
        )
    }

    static func sufficientlyVisible(_ frame: CGRect, on visibleFrame: CGRect) -> Bool {
        let intersection = frame.intersection(visibleFrame)
        return !intersection.isNull
            && intersection.width >= minimumVisibleLength
            && intersection.height >= minimumVisibleLength
    }

    private static func oppositePoint(of corner: GuideCorner, in frame: CGRect) -> CGPoint {
        switch corner {
        case .topLeft: CGPoint(x: frame.maxX, y: frame.minY)
        case .topRight: CGPoint(x: frame.minX, y: frame.minY)
        case .bottomLeft: CGPoint(x: frame.maxX, y: frame.maxY)
        case .bottomRight: CGPoint(x: frame.minX, y: frame.maxY)
        }
    }

    private static func cornerPoint(of corner: GuideCorner, in frame: CGRect) -> CGPoint {
        switch corner {
        case .topLeft: CGPoint(x: frame.minX, y: frame.maxY)
        case .topRight: CGPoint(x: frame.maxX, y: frame.maxY)
        case .bottomLeft: CGPoint(x: frame.minX, y: frame.minY)
        case .bottomRight: CGPoint(x: frame.maxX, y: frame.minY)
        }
    }

    private static func squaredDistance(from lhs: CGPoint, to rhs: CGPoint) -> CGFloat {
        let x = lhs.x - rhs.x
        let y = lhs.y - rhs.y
        return x * x + y * y
    }

    private static func integerPair(for ratio: GuideAspectRatio) -> CGSize {
        let width = max(1, Int(ratio.width.rounded()))
        let height = max(1, Int(ratio.height.rounded()))
        let divisor = greatestCommonDivisor(width, height)
        return CGSize(width: width / divisor, height: height / divisor)
    }

    private static func greatestCommonDivisor(_ lhs: Int, _ rhs: Int) -> Int {
        var a = lhs
        var b = rhs
        while b != 0 {
            (a, b) = (b, a % b)
        }
        return max(1, a)
    }

}

private extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}
