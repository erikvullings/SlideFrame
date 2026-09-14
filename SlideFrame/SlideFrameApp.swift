import SwiftUI

@main
struct SlideFrameApp: App {
    @StateObject private var state = AppState()

    var body: some Scene {
        MenuBarExtra("SlideFrame", systemImage: "rectangle.inset.filled") {
            MenuBarContent(state: state)
        }
        .menuBarExtraStyle(.menu)
    }
}
