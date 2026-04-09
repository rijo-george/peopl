import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: PeoplStore
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var shortcuts: ShortcutState
    @State private var selectedPersonID: String?
    @State private var showingAddPerson = false
    @State private var showingThemePicker = false
    @State private var showingAddMemory = false
    @State private var showingAddInteraction = false
    @State private var showingEditPerson = false
    @FocusState private var captureBarFocused: Bool
    @Namespace private var cardTransition

    private var tc: ThemeColors { theme.colors }

    private var selectedPerson: Person? {
        guard let id = selectedPersonID else { return nil }
        return store.data.people.first { $0.id == id }
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                tc.bg.ignoresSafeArea()

                if let person = selectedPerson {
                    JournalView(
                        person: person,
                        namespace: cardTransition,
                        onBack: { withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { selectedPersonID = nil } },
                        showingAddMemory: $showingAddMemory,
                        showingAddInteraction: $showingAddInteraction,
                        showingEditPerson: $showingEditPerson
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                } else {
                    WallView(
                        selectedPersonID: $selectedPersonID,
                        namespace: cardTransition,
                        onAddPerson: { showingAddPerson = true },
                        onOpenThemePicker: { showingThemePicker = true }
                    )
                    .transition(.opacity)
                }
            }

            QuickCaptureBar(
                contextPersonID: selectedPersonID,
                isFocused: $captureBarFocused
            )
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: selectedPersonID)
        .sheet(isPresented: $showingAddPerson) {
            AddPersonSheet()
                .environmentObject(store)
                .environmentObject(theme)
        }
        .sheet(isPresented: $showingThemePicker) {
            ThemePickerSheet()
                .environmentObject(theme)
        }
        .sheet(isPresented: $showingAddMemory) {
            if let person = selectedPerson {
                AddMemorySheet(person: person)
                    .environmentObject(store)
                    .environmentObject(theme)
            }
        }
        .sheet(isPresented: $showingAddInteraction) {
            if let person = selectedPerson {
                AddInteractionSheet(person: person)
                    .environmentObject(store)
                    .environmentObject(theme)
            }
        }
        .sheet(isPresented: $showingEditPerson) {
            if let person = selectedPerson {
                EditPersonSheet(person: person)
                    .environmentObject(store)
                    .environmentObject(theme)
            }
        }
        .onChange(of: shortcuts.lastAction) { _, action in
            guard let action else { return }
            switch action {
            case .addPerson:
                if selectedPersonID == nil { showingAddPerson = true }
            case .addMemory:
                if selectedPersonID != nil { showingAddMemory = true }
            case .addInteraction:
                if selectedPersonID != nil { showingAddInteraction = true }
            case .editPerson:
                if selectedPersonID != nil { showingEditPerson = true }
            case .changeTheme:
                showingThemePicker = true
            case .goBack:
                if selectedPersonID != nil {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { selectedPersonID = nil }
                }
            case .quickCapture:
                captureBarFocused = true
            }
        }
        .onAppear { store.load() }
    }
}

// MARK: - Flow Layout for tags

struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            if index < result.positions.count {
                let pos = result.positions[index]
                subview.place(at: CGPoint(x: bounds.minX + pos.x, y: bounds.minY + pos.y),
                              proposal: .unspecified)
            }
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (positions, CGSize(width: maxX, height: y + rowHeight))
    }
}
