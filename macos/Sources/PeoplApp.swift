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
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 1080, height: 720)
    }
}
