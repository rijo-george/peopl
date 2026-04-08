import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: PeoplStore
    @EnvironmentObject var theme: ThemeManager
    @State private var selectedPersonID: String?
    @State private var showingAddPerson = false
    @State private var showingThemePicker = false
    @Namespace private var cardTransition

    private var tc: ThemeColors { theme.colors }

    var body: some View {
        ZStack {
            tc.bg.ignoresSafeArea()

            if let personID = selectedPersonID,
               let person = store.data.people.first(where: { $0.id == personID }) {
                JournalView(
                    person: person,
                    namespace: cardTransition,
                    onBack: { withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { selectedPersonID = nil } }
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
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: selectedPersonID)
        .focusable()
        .onKeyPress(characters: CharacterSet(charactersIn: "aA")) { _ in
            if selectedPersonID == nil { showingAddPerson = true }
            return selectedPersonID == nil ? .handled : .ignored
        }
        .onKeyPress(characters: CharacterSet(charactersIn: "tT")) { _ in
            showingThemePicker = true; return .handled
        }
        .sheet(isPresented: $showingAddPerson) {
            AddPersonSheet()
                .environmentObject(store)
                .environmentObject(theme)
        }
        .sheet(isPresented: $showingThemePicker) {
            ThemePickerSheet()
                .environmentObject(theme)
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
