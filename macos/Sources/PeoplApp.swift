import SwiftUI

@main
struct PeoplApp: App {
    @StateObject private var store = PeoplStore()
    @StateObject private var theme = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(theme)
                .frame(minWidth: 800, minHeight: 500)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 960, height: 640)
    }
}
