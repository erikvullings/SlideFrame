import AppKit
import SwiftUI

private final class ReviewBackgroundView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        NSGradient(
            starting: NSColor(calibratedRed: 0.10, green: 0.14, blue: 0.20, alpha: 1),
            ending: NSColor(calibratedRed: 0.24, green: 0.31, blue: 0.40, alpha: 1)
        )?.draw(in: bounds, angle: -28)

        let window = NSRect(x: 96, y: 72, width: 1088, height: 656)
        NSColor(calibratedWhite: 0.94, alpha: 0.96).setFill()
        NSBezierPath(roundedRect: window, xRadius: 12, yRadius: 12).fill()

        NSColor(calibratedWhite: 0.82, alpha: 1).setFill()
        NSBezierPath(
            roundedRect: NSRect(x: window.minX, y: window.maxY - 46, width: window.width, height: 46),
            xRadius: 12,
            yRadius: 12
        ).fill()

        for x in [118.0, 140.0, 162.0] {
            NSColor(calibratedRed: x == 118 ? 0.95 : 0.58, green: x == 140 ? 0.72 : 0.45, blue: 0.38, alpha: 1).setFill()
            NSBezierPath(ovalIn: NSRect(x: x, y: 697, width: 12, height: 12)).fill()
        }

        NSColor(calibratedWhite: 0.84, alpha: 1).setFill()
        NSBezierPath(rect: NSRect(x: 132, y: 124, width: 218, height: 526)).fill()

        NSColor(calibratedWhite: 0.75, alpha: 1).setFill()
        for row in 0..<8 {
            NSBezierPath(
                roundedRect: NSRect(x: 164, y: 586 - CGFloat(row * 48), width: 146, height: 12),
                xRadius: 6,
                yRadius: 6
            ).fill()
        }

        NSColor(calibratedWhite: 0.73, alpha: 1).setFill()
        NSBezierPath(
            roundedRect: NSRect(x: 414, y: 604, width: 348, height: 20),
            xRadius: 8,
            yRadius: 8
        ).fill()
        NSColor(calibratedWhite: 0.83, alpha: 1).setFill()
        for row in 0..<7 {
            let width = row == 6 ? 310.0 : 612.0
            NSBezierPath(
                roundedRect: NSRect(x: 414, y: 552 - CGFloat(row * 44), width: width, height: 12),
                xRadius: 6,
                yRadius: 6
            ).fill()
        }
    }
}

@main
struct RenderReview {
    @MainActor
    static func main() throws {
        let canvas = CGSize(width: 1280, height: 800)
        let root = NSView(frame: CGRect(origin: .zero, size: canvas))
        root.addSubview(ReviewBackgroundView(frame: root.bounds))

        let model = GuideViewModel(
            apertureSize: CGSize(width: 960, height: 540),
            guideColor: .presentationBlue,
            clickThrough: false,
            borderVisible: true,
            aspectLabel: "16:9"
        )
        let guide = GuideView(
            model: model,
            onResize: { _, _, _ in },
            onMoveEnded: {},
            onShowSizeMenu: {},
            onToggleBorder: {},
            onQuit: {}
        )
        let host = NSHostingView(rootView: guide)
        host.frame = CGRect(
            x: 152,
            y: 122,
            width: GuidePanelLayout.panelSize(for: model.apertureSize).width,
            height: GuidePanelLayout.panelSize(for: model.apertureSize).height
        )
        host.wantsLayer = true
        host.layer?.backgroundColor = NSColor.clear.cgColor
        root.addSubview(host)
        root.layoutSubtreeIfNeeded()

        guard let bitmap = root.bitmapImageRepForCachingDisplay(in: root.bounds) else {
            throw CocoaError(.fileWriteUnknown)
        }
        root.cacheDisplay(in: root.bounds, to: bitmap)
        guard let data = bitmap.representation(using: .png, properties: [:]) else {
            throw CocoaError(.fileWriteUnknown)
        }
        try data.write(to: URL(fileURLWithPath: ".impeccable/review/macos.png"))
    }
}
