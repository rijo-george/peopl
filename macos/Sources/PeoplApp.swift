import SwiftUI

@main
struct PeoplApp: App {
    @StateObject private var store = PeoplStore()
    @StateObject private var theme = ThemeManager()
    @StateObject private var shortcuts = ShortcutState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(theme)
                .environmentObject(shortcuts)
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 1080, height: 720)
        .commands {
            CommandGroup(after: .newItem) {
                Button("Add Person") { shortcuts.trigger(.addPerson) }
                    .keyboardShortcut("n", modifiers: [.command])
                Divider()
                Button("Add Memory") { shortcuts.trigger(.addMemory) }
                    .keyboardShortcut("m", modifiers: [.command, .shift])
                Button("Log Interaction") { shortcuts.trigger(.addInteraction) }
                    .keyboardShortcut("i", modifiers: [.command, .shift])
                Button("Edit Person") { shortcuts.trigger(.editPerson) }
                    .keyboardShortcut("e", modifiers: [.command])
                Divider()
                Button("Change Theme") { shortcuts.trigger(.changeTheme) }
                    .keyboardShortcut("t", modifiers: [.command])
                Button("Back to Wall") { shortcuts.trigger(.goBack) }
                    .keyboardShortcut(.escape, modifiers: [])
            }
        }
    }
}

// MARK: - Shortcut State

enum ShortcutAction {
    case addPerson, addMemory, addInteraction, editPerson, changeTheme, goBack
}

class ShortcutState: ObservableObject {
    @Published var lastAction: ShortcutAction?

    func trigger(_ action: ShortcutAction) {
        lastAction = action
        // Reset after a tick so it can fire again
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.lastAction = nil
        }
    }
}
