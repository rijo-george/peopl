import SwiftUI

struct WallView: View {
    @EnvironmentObject var store: PeoplStore
    @EnvironmentObject var theme: ThemeManager
    @Binding var selectedPersonID: String?
    var namespace: Namespace.ID
    var onAddPerson: () -> Void
    var onOpenThemePicker: () -> Void

    @State private var searchText = ""
    @State private var showSearch = false
    @State private var filter: WallFilter = .all

    private var tc: ThemeColors { theme.colors }

    enum WallFilter: String, CaseIterable {
        case all = "All"
        case attention = "Needs Love"
        case archived = "Archived"
    }

    var body: some View {
        ZStack {
            // Background
            tc.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Peopl")
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundColor(tc.textPrimary)
                        Text(statusString)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(tc.textSecondary)
                    }

                    Spacer()

                    // Coming up badge
                    let upcoming = store.upcomingEvents(withinDays: 7)
                    if !upcoming.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "birthday.cake.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.pink)
                            Text("\(upcoming.count) coming up")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(tc.textSecondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(tc.surface.opacity(0.8))
                        .cornerRadius(12)
                    }

                    // Filter pills
                    HStack(spacing: 4) {
                        ForEach(WallFilter.allCases, id: \.rawValue) { f in
                            Button(action: { filter = f }) {
                                Text(f.rawValue)
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(filter == f ? tc.warmAccent : tc.textSecondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(filter == f ? tc.warmAccent.opacity(0.12) : Color.clear)
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Button(action: onOpenThemePicker) {
                        Image(systemName: theme.current.icon)
                            .font(.system(size: 13))
                            .foregroundColor(tc.textSecondary)
                            .padding(6)
                            .background(tc.surface.opacity(0.8))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)

                // Search bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 12))
                        .foregroundColor(tc.textSecondary)
                    TextField("Search people...", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13, design: .serif))
                        .foregroundColor(tc.textPrimary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(tc.surface.opacity(0.6))
                .cornerRadius(20)
                .padding(.horizontal, 24)
                .padding(.bottom, 12)

                // Card grid
                if filteredPeople.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.dashed")
                            .font(.system(size: 40))
                            .foregroundColor(tc.textSecondary.opacity(0.3))
                        Text(store.activePeople.isEmpty ? "No people yet" : "No matches")
                            .font(.system(size: 14, design: .serif))
                            .foregroundColor(tc.textSecondary.opacity(0.5))
                        if store.activePeople.isEmpty {
                            Text("Press A or click + to add someone")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(tc.textSecondary.opacity(0.3))
                        }
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 170, maximum: 220), spacing: 16)],
                                  spacing: 16) {
                            ForEach(filteredPeople) { person in
                                PersonCard(
                                    person: person,
                                    weather: store.weather(for: person.id),
                                    snippet: store.latestMemorySnippet(for: person.id)
                                        ?? store.lastInteraction(for: person.id)?.note,
                                    memoryCount: store.memories(for: person.id).count,
                                    hasBirthdaySoon: store.upcomingEvents(withinDays: 7)
                                        .contains { $0.personID == person.id && $0.isBirthday },
                                    namespace: namespace
                                )
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                        selectedPersonID = person.id
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 80)
                    }
                }
            }

            // Floating add button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: onAddPerson) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(tc.warmAccent)
                            .clipShape(Circle())
                            .shadow(color: tc.warmAccent.opacity(0.4), radius: 8, y: 4)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 28)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    // MARK: - Computed

    private var filteredPeople: [Person] {
        var people: [Person]
        switch filter {
        case .all:       people = store.activePeople
        case .attention: people = store.activePeople.filter { store.weather(for: $0.id) >= .rainy }
        case .archived:  people = store.archivedPeople
        }

        if !searchText.isEmpty {
            let q = searchText.lowercased()
            people = people.filter {
                $0.name.lowercased().contains(q) ||
                $0.company.lowercased().contains(q) ||
                $0.tags.contains { $0.lowercased().contains(q) }
            }
        }

        // Sort: stormiest first
        people.sort { a, b in
            let wa = store.weather(for: a.id)
            let wb = store.weather(for: b.id)
            if wa != wb { return wa > wb }
            return a.name < b.name
        }
        return people
    }

    private var statusString: String {
        let total = store.activePeople.count
        let storms = store.activePeople.filter { store.weather(for: $0.id) >= .rainy }.count
        if total == 0 { return "your people, your memories" }
        var parts = ["\(total) people"]
        if storms > 0 { parts.append("\(storms) need love") }
        return parts.joined(separator: " · ")
    }
}

// MARK: - Person Card

struct PersonCard: View {
    @EnvironmentObject var store: PeoplStore
    @EnvironmentObject var theme: ThemeManager
    let person: Person
    let weather: Weather
    let snippet: String?
    let memoryCount: Int
    let hasBirthdaySoon: Bool
    var namespace: Namespace.ID

    @State private var isHovered = false

    private var tc: ThemeColors { theme.colors }
    private var rotation: Double { stableRandom(from: person.id, range: -2.5...2.5) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Top row: initials + weather
            HStack {
                // Initials
                ZStack {
                    let wc = weather.colorRGB
                    Circle()
                        .fill(Color(red: wc.r, green: wc.g, blue: wc.b).opacity(0.2))
                        .frame(width: 42, height: 42)
                    Text(person.displayInitials)
                        .font(.system(size: 15, weight: .bold, design: .serif))
                        .foregroundColor(Color(red: wc.r, green: wc.g, blue: wc.b))
                }
                .matchedGeometryEffect(id: "avatar-\(person.id)", in: namespace)

                Spacer()

                VStack(spacing: 2) {
                    let wc = weather.colorRGB
                    Image(systemName: weather.icon)
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: wc.r, green: wc.g, blue: wc.b))
                    if hasBirthdaySoon {
                        Image(systemName: "birthday.cake.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.pink)
                    }
                }
            }

            // Name + company
            VStack(alignment: .leading, spacing: 2) {
                Text(person.name)
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundColor(tc.textPrimary)
                    .lineLimit(1)
                    .matchedGeometryEffect(id: "name-\(person.id)", in: namespace)

                if !person.company.isEmpty {
                    Text(person.company)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(tc.textSecondary)
                        .lineLimit(1)
                }
            }

            // Snippet or memory count
            if let snippet {
                Text(snippet)
                    .font(.system(size: 11, design: .serif))
                    .foregroundColor(tc.textSecondary.opacity(0.7))
                    .lineLimit(2)
                    .italic()
            }

            if memoryCount > 0 {
                HStack(spacing: 3) {
                    Image(systemName: "brain")
                        .font(.system(size: 8))
                    Text("\(memoryCount) memories")
                        .font(.system(size: 9, design: .monospaced))
                }
                .foregroundColor(tc.textSecondary.opacity(0.5))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tc.cardBg)
        .cornerRadius(8)
        .shadow(color: tc.cardShadow, radius: isHovered ? 12 : 4, y: isHovered ? 6 : 2)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isHovered ? tc.warmAccent.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .rotationEffect(.degrees(isHovered ? 0 : rotation))
        .scaleEffect(isHovered ? 1.04 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .onHover { isHovered = $0 }
    }
}
