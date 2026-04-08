import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: PeoplStore
    @EnvironmentObject var theme: ThemeManager
    @State private var selectedPersonID: String?
    @State private var searchText = ""
    @State private var sortByWeather = true
    @State private var showingAddPerson = false
    @State private var showingEditPerson = false
    @State private var showingAddInteraction = false
    @State private var showingThemePicker = false
    @State private var showingArchived = false
    @State private var showingComingUp = true

    private var tc: ThemeColors { theme.colors }

    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Image(systemName: "person.2.fill")
                    .font(.title2)
                Text("Peopl")
                    .font(.title2.bold())
                Spacer()
                statusText
                    .font(.caption)
                    .foregroundColor(tc.textSecondary)
                Button(action: { showingThemePicker = true }) {
                    Image(systemName: theme.current.icon)
                        .font(.system(size: 14))
                        .padding(6)
                        .background(tc.accent.opacity(0.2))
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .help("Change theme [T]")
            }
            .foregroundColor(tc.textPrimary)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(tc.headerBg)

            // Main content: list + detail
            HStack(spacing: 1) {
                // Left: person list
                VStack(alignment: .leading, spacing: 0) {
                    // Search bar
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(tc.textSecondary)
                            .font(.system(size: 12))
                        TextField("Search people...", text: $searchText)
                            .textFieldStyle(.plain)
                            .font(.system(size: 13))
                            .foregroundColor(tc.textPrimary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(tc.surface)
                    .cornerRadius(8)
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                    // Coming Up section
                    let upcoming = store.upcomingEvents(withinDays: 14)
                    if !upcoming.isEmpty {
                        ComingUpSection(events: upcoming, isExpanded: $showingComingUp,
                                        selectedPersonID: $selectedPersonID)
                            .padding(.horizontal, 8)
                            .padding(.bottom, 4)
                    }

                    // Sort toggle
                    HStack {
                        Button(action: { sortByWeather.toggle() }) {
                            HStack(spacing: 3) {
                                Image(systemName: sortByWeather ? "cloud.fill" : "textformat.abc")
                                    .font(.system(size: 10))
                                Text(sortByWeather ? "By weather" : "A-Z")
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(tc.textSecondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(tc.textSecondary.opacity(0.1))
                            .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        Text("\(filteredPeople.count) people")
                            .font(.system(size: 10))
                            .foregroundColor(tc.textSecondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 4)

                    // Person list
                    if filteredPeople.isEmpty {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(store.activePeople.isEmpty ? "No people yet -- press [A] to add" : "No matches")
                                .foregroundColor(tc.textSecondary.opacity(0.5))
                                .font(.caption)
                            Spacer()
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 2) {
                                ForEach(filteredPeople) { person in
                                    PersonRow(person: person,
                                              weather: store.weather(for: person.id),
                                              lastInteraction: store.lastInteraction(for: person.id),
                                              hasBirthdaySoon: hasBirthdaySoon(person),
                                              isSelected: selectedPersonID == person.id)
                                        .onTapGesture {
                                            selectedPersonID = person.id
                                        }
                                }
                            }
                            .padding(8)
                        }
                    }
                }
                .background(tc.surface)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(tc.borderActive, lineWidth: 1)
                )
                .frame(minWidth: 280, idealWidth: 320, maxWidth: 380)

                // Right: detail
                if let person = selectedPerson {
                    PersonDetailView(person: person)
                        .id(person.id)
                } else {
                    VStack {
                        Spacer()
                        Image(systemName: "person.crop.circle.dashed")
                            .font(.system(size: 48))
                            .foregroundColor(tc.textSecondary.opacity(0.3))
                        Text("Select a person")
                            .foregroundColor(tc.textSecondary.opacity(0.5))
                            .font(.caption)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(tc.surface)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(tc.borderInactive, lineWidth: 1)
                    )
                }
            }
            .padding(12)

            // Bottom toolbar
            HStack(spacing: 16) {
                toolbarButton("Add", icon: "plus.circle.fill", key: "A") { showingAddPerson = true }
                toolbarButton("Interact", icon: "bubble.left.circle.fill", key: "I") { promptInteraction() }
                toolbarButton("Edit", icon: "pencil.circle.fill", key: "E") { promptEdit() }
                toolbarButton("Archive", icon: "archivebox.circle.fill", key: "D") { promptArchive() }
                toolbarButton("Theme", icon: "paintpalette.fill", key: "T") { showingThemePicker = true }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(tc.statusBarBg)
        }
        .focusable()
        .onKeyPress(characters: CharacterSet(charactersIn: "aA")) { _ in showingAddPerson = true; return .handled }
        .onKeyPress(characters: CharacterSet(charactersIn: "iI")) { _ in promptInteraction(); return .handled }
        .onKeyPress(characters: CharacterSet(charactersIn: "eE")) { _ in promptEdit(); return .handled }
        .onKeyPress(characters: CharacterSet(charactersIn: "dD")) { _ in promptArchive(); return .handled }
        .onKeyPress(characters: CharacterSet(charactersIn: "tT")) { _ in showingThemePicker = true; return .handled }
        .onKeyPress(.upArrow) { moveCursor(-1); return .handled }
        .onKeyPress(.downArrow) { moveCursor(1); return .handled }
        .onKeyPress(characters: CharacterSet(charactersIn: "kK")) { _ in moveCursor(-1); return .handled }
        .onKeyPress(characters: CharacterSet(charactersIn: "jJ")) { _ in moveCursor(1); return .handled }
        .background(tc.bg)
        .sheet(isPresented: $showingAddPerson) {
            AddPersonSheet()
                .environmentObject(store)
                .environmentObject(theme)
        }
        .sheet(isPresented: $showingEditPerson) {
            if let person = selectedPerson {
                EditPersonSheet(person: person)
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
        .sheet(isPresented: $showingThemePicker) {
            ThemePickerSheet()
                .environmentObject(theme)
        }
        .onAppear {
            store.load()
            if selectedPersonID == nil {
                selectedPersonID = filteredPeople.first?.id
            }
        }
    }

    // MARK: - Computed

    private var selectedPerson: Person? {
        guard let id = selectedPersonID else { return nil }
        return store.activePeople.first { $0.id == id }
    }

    private var filteredPeople: [Person] {
        var people = store.activePeople

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            people = people.filter {
                $0.name.lowercased().contains(query) ||
                $0.company.lowercased().contains(query) ||
                $0.tags.contains { $0.lowercased().contains(query) } ||
                $0.notes.lowercased().contains(query)
            }
        }

        if sortByWeather {
            people.sort { a, b in
                let wa = store.weather(for: a.id)
                let wb = store.weather(for: b.id)
                if wa != wb { return wa > wb } // stormiest first
                return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
            }
        } else {
            people.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }

        return people
    }

    private func hasBirthdaySoon(_ person: Person) -> Bool {
        store.upcomingEvents(withinDays: 7).contains { $0.personID == person.id && $0.isBirthday }
    }

    // MARK: - Actions

    private func moveCursor(_ delta: Int) {
        let people = filteredPeople
        guard !people.isEmpty else { return }
        let currentIdx = people.firstIndex(where: { $0.id == selectedPersonID }) ?? -1
        let newIdx = max(0, min(people.count - 1, currentIdx + delta))
        selectedPersonID = people[newIdx].id
    }

    private func promptInteraction() {
        guard selectedPerson != nil else { return }
        showingAddInteraction = true
    }

    private func promptEdit() {
        guard selectedPerson != nil else { return }
        showingEditPerson = true
    }

    private func promptArchive() {
        guard let person = selectedPerson else { return }
        store.archivePerson(person)
        selectedPersonID = filteredPeople.first?.id
    }

    // MARK: - Status

    private var statusText: some View {
        let total = store.activePeople.count
        let stormy = store.activePeople.filter { store.weather(for: $0.id) >= .rainy }.count
        var parts: [String] = []
        if total > 0 { parts.append("\(total) people") }
        if stormy > 0 { parts.append("\(stormy) need attention") }
        let text = parts.isEmpty ? "Add someone!" : parts.joined(separator: "  ·  ")
        return Text(text)
    }

    // MARK: - Toolbar button

    private func toolbarButton(_ title: String, icon: String, key: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                Text(title)
                    .font(.caption)
                Text("[\(key)]")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(tc.textSecondary)
            }
            .foregroundColor(tc.textPrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tc.textPrimary.opacity(0.05))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Coming Up Section

struct ComingUpSection: View {
    @EnvironmentObject var theme: ThemeManager
    let events: [UpcomingEvent]
    @Binding var isExpanded: Bool
    @Binding var selectedPersonID: String?

    private var tc: ThemeColors { theme.colors }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack(spacing: 4) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 9))
                    Image(systemName: "calendar")
                        .font(.system(size: 10))
                    Text("COMING UP")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                    Text("(\(events.count))")
                        .font(.system(size: 10, design: .monospaced))
                    Spacer()
                }
                .foregroundColor(tc.listAccent)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 2) {
                    ForEach(events) { event in
                        HStack(spacing: 6) {
                            Image(systemName: event.isBirthday ? "birthday.cake.fill" : "calendar")
                                .font(.system(size: 10))
                                .foregroundColor(event.isBirthday ? .pink : tc.listAccent)
                            Text(event.personName)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(tc.textPrimary)
                            Text(event.label)
                                .font(.system(size: 10))
                                .foregroundColor(tc.textSecondary)
                            Spacer()
                            Text(event.daysUntil == 0 ? "Today!" : "in \(event.daysUntil)d")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(event.daysUntil <= 1 ? .pink : tc.textSecondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(tc.selectedBg.opacity(0.5))
                        .cornerRadius(4)
                        .onTapGesture {
                            selectedPersonID = event.personID
                        }
                    }
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 6)
            }
        }
        .background(tc.listBg.opacity(0.5))
        .cornerRadius(8)
    }
}

// MARK: - Person Row

struct PersonRow: View {
    @EnvironmentObject var theme: ThemeManager
    let person: Person
    let weather: Weather
    let lastInteraction: Interaction?
    let hasBirthdaySoon: Bool
    let isSelected: Bool

    private var tc: ThemeColors { theme.colors }

    var body: some View {
        HStack(spacing: 8) {
            if isSelected {
                Image(systemName: "arrowtriangle.right.fill")
                    .font(.system(size: 8))
                    .foregroundColor(tc.accent)
            }

            // Weather icon
            let wc = weather.colorRGB
            Image(systemName: weather.icon)
                .font(.system(size: 13))
                .foregroundColor(Color(red: wc.r, green: wc.g, blue: wc.b))

            // Name
            Text(person.name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(tc.textPrimary)
                .lineLimit(1)

            // Company
            if !person.company.isEmpty {
                Text("·").foregroundColor(tc.textSecondary)
                Text(person.company)
                    .font(.system(size: 12))
                    .foregroundColor(tc.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            // Birthday cake
            if hasBirthdaySoon {
                Image(systemName: "birthday.cake.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.pink)
            }

            // Last interaction date
            if let last = lastInteraction {
                Text(last.shortDateDisplay)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(tc.textSecondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(isSelected ? tc.selectedBg : Color.clear)
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isSelected ? tc.accent.opacity(0.5) : Color.clear, lineWidth: 1)
        )
    }
}
