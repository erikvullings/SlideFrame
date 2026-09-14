import AppKit
import SwiftUI

struct MenuBarContent: View {
    @ObservedObject var state: AppState

    var body: some View {
        Button(state.isVisible ? "Hide Frame" : "Show Frame") {
            state.toggleVisibility()
        }
        .keyboardShortcut("f")

        Button(state.borderVisible ? "Hide Border" : "Show Border") {
            state.toggleBorderVisibility()
        }

        Menu("Size") {
            preset("960 × 540", width: 960, height: 540)
            preset("1280 × 720", width: 1280, height: 720)
            preset("1600 × 900", width: 1600, height: 900)
            preset("1920 × 1080", width: 1920, height: 1080)
            Divider()
            Button {
                state.useCurrentDisplayRatio()
            } label: {
                if state.aspectMode == .currentDisplay {
                    Label("Current Display Ratio", systemImage: "checkmark")
                } else {
                    Text("Current Display Ratio")
                }
            }
            Divider()
            aspectButton("Widescreen 16:9", ratio: .widescreen)
            aspectButton("Standard 4:3", ratio: .standard)
            aspectButton("Ultrawide 21:9", ratio: .ultrawide)
            aspectButton("Mobile 9:16", ratio: .mobilePortrait)
            aspectButton("Portrait 3:4", ratio: .classicPortrait)
        }

        Button("Fit to Current Screen") {
            state.fitToCurrentScreen()
        }

        Button("Center on Current Screen") {
            state.centerOnCurrentScreen()
        }

        Divider()

        Button {
            state.toggleClickThrough()
        } label: {
            if state.clickThrough {
                Label("Click Through", systemImage: "checkmark")
            } else {
                Text("Click Through")
            }
        }

        Menu("Border Color") {
            ForEach(GuideColor.allCases, id: \.self) { color in
                Button {
                    state.setColor(color)
                } label: {
                    if state.guideColor == color {
                        Label(color.title, systemImage: "checkmark")
                    } else {
                        Text(color.title)
                    }
                }
            }
        }

        Divider()

        Button("Reset") {
            state.reset()
        }

        Button("Quit SlideFrame") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }

    private func preset(_ title: String, width: CGFloat, height: CGFloat) -> some View {
        Button {
            state.applyPreset(width: width, height: height)
        } label: {
            if state.isPreset(width: width, height: height) {
                Label(title, systemImage: "checkmark")
            } else {
                Text(title)
            }
        }
    }

    private func aspectButton(_ title: String, ratio: GuideAspectRatio) -> some View {
        Button {
            state.applyAspectRatio(ratio)
        } label: {
            if state.aspectMode.fixedRatio == ratio {
                Label(title, systemImage: "checkmark")
            } else {
                Text(title)
            }
        }
    }
}
