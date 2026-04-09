import SwiftUI

struct WallView: View {
    @EnvironmentObject var store: PeoplStore
    @EnvironmentObject var theme: ThemeManager
    @Binding var selectedPersonID: String?
    var namespace: Namespace.ID
    var onAddPerson: () -> Void
    var onOpenThemePicker: () -> Void

    @State private var searchText = ""
    @State private var filter: WallFilter = .all
    @State private var skippedNudgeIDs: Set<String> = []
    @State private var appearedCardIDs: Set<String> = []

    private var tc: ThemeColors { theme.colors }

    enum WallFilter: String, CaseIterable {
        case all = "All"
        case attention = "Needs Love"
        case archived = "Archived"
    }

    var body: some View {
        ZStack {
            tc.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                header

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

                // Content
                if filteredPeople.isEmpty && filter == .all && store.activePeople.isEmpty {
                    Spacer()
                    emptyState
                    Spacer()
                } else if filteredPeople.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.dashed")
                            .font(.system(size: 40))
                            .foregroundColor(tc.textSecondary.opacity(0.3))
                        Text("No matches")
                            .font(.system(size: 14, design: .serif))
                            .foregroundColor(tc.textSecondary.opacity(0.5))
                    }
                    Spacer()
                } else {
                    scrollContent
                }
            }

            // Paper grain overlay
            grainOverlay
        }
    }

    // MARK: - Header

    private var header: some View {
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

            // Inline birthday text
            let upcoming = store.upcomingEvents(withinDays: 7)
            if let next = upcoming.first, next.isBirthday {
                Text("\(next.personName)'s birthday in \(next.daysUntil) day\(next.daysUntil == 1 ? "" : "s")")
                    .font(.system(size: 11, design: .serif))
                    .foregroundColor(.pink)
                    .italic()
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
    }

    // MARK: - Scroll Content

    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Nudge card
                nudgeCardSection
                    .padding(.horizontal, 24)

                // Surfaced memory
                surfacedMemorySection
                    .padding(.horizontal, 24)

                // Card grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 170, maximum: 220), spacing: 16)],
                          spacing: 16) {
                    ForEach(Array(filteredPeople.enumerated()), id: \.element.id) { index, person in
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
                        .opacity(appearedCardIDs.contains(person.id) ? 1 : 0)
                        .offset(y: appearedCardIDs.contains(person.id) ? 0 : 12)
                        .onAppear {
                            if !appearedCardIDs.contains(person.id) {
                                let delay = Double(index) * 0.05
                                let anim = Animation.spring(response: 0.4, dampingFraction: 0.8).delay(delay)
                                _ = withAnimation(anim) {
                                    appearedCardIDs.insert(person.id)
                                }
                            }
                        }
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                selectedPersonID = person.id
                            }
                        }
                    }

                    // "Someone new" dashed card
                    someoneNewCard
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 80)
            }
        }
    }

    // MARK: - Nudge Card Section

    @ViewBuilder
    private var nudgeCardSection: some View {
        if filter == .all {
            let nudge = store.nudgePerson()
            let filteredNudge: (person: Person, daysSince: Int, lastSnippet: String?)? = {
                guard let n = nudge, !skippedNudgeIDs.contains(n.person.id) else { return nil }
                return n
            }()

            NudgeCard(
                nudge: filteredNudge,
                onOpen: { person in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        selectedPersonID = person.id
                    }
                },
                onSkip: {
                    if let n = nudge {
                        skippedNudgeIDs.insert(n.person.id)
                    }
                }
            )
        }
    }

    // MARK: - Surfaced Memory

    @ViewBuilder
    private var surfacedMemorySection: some View {
        if filter == .all, let surfaced = store.surfaceMemory() {
            HStack(spacing: 10) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 13))
                    .foregroundColor(tc.warmAccent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(surfaced.timeAgo) — about \(surfaced.person.name)")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(tc.textSecondary)
                    if !surfaced.memory.text.isEmpty {
                        Text("\u{201C}\(String(surfaced.memory.text.prefix(100)))\u{201D}")
                            .font(.system(size: 13, design: .serif))
                            .foregroundColor(tc.textPrimary)
                            .italic()
                            .lineLimit(2)
                    }
                }
                Spacer()
            }
            .padding(14)
            .background(tc.surfacedMemoryBg)
            .cornerRadius(10)
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selectedPersonID = surfaced.person.id
                }
            }
        }
    }

    // MARK: - Someone New Card

    private var someoneNewCard: some View {
        Button(action: onAddPerson) {
            VStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 20))
                    .foregroundColor(tc.textSecondary.opacity(0.4))
                Text("Someone new")
                    .font(.system(size: 12, design: .serif))
                    .foregroundColor(tc.textSecondary.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 120)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(tc.borderInactive, style: StrokeStyle(lineWidth: 1, dash: [6]))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.text.clipboard")
                .font(.system(size: 44))
                .foregroundColor(tc.textSecondary.opacity(0.2))
            Text("Your memory box is empty.")
                .font(.system(size: 16, design: .serif))
                .foregroundColor(tc.textSecondary.opacity(0.6))
            Text("Add someone you care about.")
                .font(.system(size: 13, design: .serif))
                .foregroundColor(tc.textSecondary.opacity(0.4))
            Button(action: onAddPerson) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                    Text("Someone new")
                        .font(.system(size: 13, design: .serif))
                }
                .foregroundColor(tc.warmAccent)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Paper Grain

    private var grainOverlay: some View {
        GrainView()
            .opacity(tc.grainOpacity)
            .ignoresSafeArea()
            .allowsHitTesting(false)
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
        if total == 0 { return "your people, your memories" }
        return "\(total) people in your life"
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
    @State private var breatheScale: CGFloat = 1.0

    private var tc: ThemeColors { theme.colors }
    private var rotation: Double { stableRandom(from: person.id, range: -2.5...2.5) }
    private var breathePeriod: Double { stableRandom(from: person.id + "breath", range: 4.0...8.0) }
    private var isUrgent: Bool { weather >= .rainy }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Top row: initials + weather
            HStack {
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
        .shadow(color: tc.shadowWarm, radius: isHovered ? 12 : 4, y: isHovered ? 6 : 2)
        .shadow(color: isUrgent ? tc.urgencyGlow.opacity(0.2) : Color.clear, radius: 12, y: 0)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isHovered ? tc.warmAccent.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .rotationEffect(.degrees(isHovered ? 0 : rotation))
        .scaleEffect(isHovered ? 1.04 : breatheScale)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .onHover { isHovered = $0 }
        .onAppear { startBreathing() }
    }

    private func startBreathing() {
        withAnimation(
            .easeInOut(duration: breathePeriod)
            .repeatForever(autoreverses: true)
        ) {
            breatheScale = 1.002
        }
    }
}

// MARK: - Paper Grain View (pure SwiftUI, no event interception)

struct GrainView: View {
    private static let grainImage: Image = {
        let size = 128
        let nsImage = NSImage(size: NSSize(width: size, height: size))
        nsImage.lockFocus()
        for x in 0..<size {
            for y in 0..<size {
                let val = CGFloat.random(in: 0...1)
                NSColor(white: val, alpha: 0.08).setFill()
                NSRect(x: x, y: y, width: 1, height: 1).fill()
            }
        }
        nsImage.unlockFocus()
        return Image(nsImage: nsImage)
    }()

    var body: some View {
        Self.grainImage
            .resizable(resizingMode: .tile)
    }
}
