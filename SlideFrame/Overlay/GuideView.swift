import AppKit
import SwiftUI

@MainActor
final class GuideViewModel: ObservableObject {
    @Published var apertureSize: CGSize
    @Published var guideColor: GuideColor
    @Published var clickThrough: Bool
    @Published var borderVisible: Bool
    @Published var aspectLabel: String

    init(
        apertureSize: CGSize,
        guideColor: GuideColor,
        clickThrough: Bool,
        borderVisible: Bool,
        aspectLabel: String
    ) {
        self.apertureSize = apertureSize
        self.guideColor = guideColor
        self.clickThrough = clickThrough
        self.borderVisible = borderVisible
        self.aspectLabel = aspectLabel
    }
}

struct GuideView: View {
    @ObservedObject var model: GuideViewModel
    let onResize: (GuideCorner, CGSize, Bool) -> Void
    let onMoveEnded: () -> Void
    let onShowSizeMenu: () -> Void
    let onToggleBorder: () -> Void
    let onQuit: () -> Void

    @Environment(\.colorSchemeContrast) private var contrast

    private let borderWidth: CGFloat = GuidePanelLayout.borderWidth
    private let handleSize: CGFloat = GuidePanelLayout.handleInset

    var body: some View {
        ZStack(alignment: .topLeading) {
            if model.borderVisible {
                border
            }
            if !model.clickThrough {
                WindowDragSurface(onDragEnded: onMoveEnded)
                badge
                if model.borderVisible {
                    cornerHandles
                }
            }
        }
        .frame(
            width: GuidePanelLayout.panelSize(for: model.apertureSize).width,
            height: GuidePanelLayout.panelSize(for: model.apertureSize).height
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("SlideFrame \(dimensionText)")
    }

    private var border: some View {
        ZStack(alignment: .topLeading) {
            if contrast == .increased {
                Rectangle()
                    .strokeBorder(oppositeColor, lineWidth: 1)
                    .frame(
                        width: model.apertureSize.width + borderWidth * 2 + 2,
                        height: model.apertureSize.height + borderWidth * 2 + 2
                    )
                    .offset(x: -1, y: -1)
            }
            Rectangle()
                .strokeBorder(resolvedColor, lineWidth: borderWidth)
                .frame(
                    width: model.apertureSize.width + borderWidth * 2,
                    height: model.apertureSize.height + borderWidth * 2
                )
        }
        .offset(
            x: GuidePanelLayout.handleInset - borderWidth,
            y: GuidePanelLayout.handleInset - borderWidth
        )
        .allowsHitTesting(false)
    }

    private var badge: some View {
        HStack(spacing: 5) {
            Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                .font(.system(size: 10, weight: .semibold))
                .frame(width: 16, height: 18)
                .allowsHitTesting(false)
                .accessibilityHidden(true)

            Button(action: onToggleBorder) {
                Image(systemName: model.borderVisible ? "rectangle.slash" : "rectangle")
                    .font(.system(size: 9, weight: .semibold))
                    .frame(width: 16, height: 18)
            }
            .buttonStyle(.plain)
            .help(model.borderVisible ? "Hide frame" : "Show frame")

            Button(action: onShowSizeMenu) {
                HStack(spacing: 3) {
                    Text("\(dimensionText) · \(model.aspectLabel)")
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8, weight: .semibold))
                }
                .font(.system(size: 12, weight: .medium, design: .rounded).monospacedDigit())
                .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
            .fixedSize()
            .accessibilityLabel("Frame size, \(dimensionText)")
            .accessibilityHint("Opens exact sizes, aspect ratios, and current display ratio")
            .help("Choose frame size or aspect ratio")

            Button(action: onQuit) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .frame(width: 16, height: 18)
            }
            .buttonStyle(.plain)
            .help("Quit SlideFrame")
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 7)
        .frame(height: 22)
        .background(.regularMaterial, in: Capsule())
        .overlay {
            Capsule().stroke(.primary.opacity(contrast == .increased ? 0.55 : 0.18))
        }
        .fixedSize()
        .position(
            x: GuidePanelLayout.handleInset + model.apertureSize.width / 2,
            y: GuidePanelLayout.handleInset + 15
        )
    }

    private var cornerHandles: some View {
        let inset = GuidePanelLayout.handleInset
        let cornerOffset = inset - borderWidth - handleSize / 2 + borderWidth / 2
        let farX = inset + model.apertureSize.width + borderWidth / 2 - handleSize / 2
        let farY = inset + model.apertureSize.height + borderWidth / 2 - handleSize / 2
        return ZStack(alignment: .topLeading) {
            handle(.topLeft).offset(x: cornerOffset, y: cornerOffset)
            handle(.topRight).offset(x: farX, y: cornerOffset)
            handle(.bottomLeft).offset(x: cornerOffset, y: farY)
            handle(.bottomRight).offset(x: farX, y: farY)
        }
    }

    private func handle(_ corner: GuideCorner) -> some View {
        RoundedRectangle(cornerRadius: 1.5)
            .fill(resolvedColor)
            .overlay {
                RoundedRectangle(cornerRadius: 1.5)
                    .stroke(oppositeColor.opacity(contrast == .increased ? 1 : 0.4))
            }
            .frame(width: handleSize, height: handleSize)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onChanged { value in
                        onResize(
                            corner,
                            CGSize(width: value.translation.width, height: -value.translation.height),
                            false
                        )
                    }
                    .onEnded { value in
                        onResize(
                            corner,
                            CGSize(width: value.translation.width, height: -value.translation.height),
                            true
                        )
                    }
            )
            .onHover { isInside in
                (isInside ? resizeCursor(for: corner) : NSCursor.arrow).set()
            }
    }

    private var dimensionText: String {
        "\(Int(model.apertureSize.width)) × \(Int(model.apertureSize.height))"
    }

    private var resolvedColor: Color {
        switch model.guideColor {
        case .white: .white
        case .black: .black
        case .red: .red
        case .presentationBlue: Color(red: 0.10, green: 0.48, blue: 1.0)
        }
    }

    private var oppositeColor: Color {
        switch model.guideColor {
        case .white: .black
        case .black: .white
        case .red, .presentationBlue: .black
        }
    }

    private func resizeCursor(for corner: GuideCorner) -> NSCursor {
        let symbolName: String
        switch corner {
        case .topLeft, .bottomRight:
            symbolName = "arrow.up.left.and.down.right"
        case .topRight, .bottomLeft:
            symbolName = "arrow.up.right.and.down.left"
        }
        guard let image = NSImage(
            systemSymbolName: symbolName,
            accessibilityDescription: "Resize"
        ) else {
            return .crosshair
        }
        image.size = CGSize(width: 18, height: 18)
        return NSCursor(image: image, hotSpot: CGPoint(x: 9, y: 9))
    }
}

private struct WindowDragSurface: NSViewRepresentable {
    let onDragEnded: () -> Void

    func makeNSView(context: Context) -> DraggingView {
        DraggingView(onDragEnded: onDragEnded)
    }

    func updateNSView(_ nsView: DraggingView, context: Context) {
        nsView.onDragEnded = onDragEnded
    }
}

private final class DraggingView: NSView {
    var onDragEnded: () -> Void

    init(onDragEnded: @escaping () -> Void) {
        self.onDragEnded = onDragEnded
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func mouseDown(with event: NSEvent) {
        NSCursor.closedHand.set()
        window?.performDrag(with: event)
        NSCursor.openHand.set()
        onDragEnded()
    }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .openHand)
    }
}
