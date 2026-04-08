import SwiftUI

struct JournalView: View {
    @EnvironmentObject var store: PeoplStore
    @EnvironmentObject var theme: ThemeManager
    let person: Person
    var namespace: Namespace.ID
    var onBack: () -> Void

    @State private var showingAddMemory = false
    @State private var showingAddInteraction = false
    @State private var showingEditPerson = false
    @State private var showInteractions = false
    @State private var memoryToDelete: Memory?

    private var tc: ThemeColors { theme.colors }

    var body: some View {
        ZStack {
            tc.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Journal header
                journalHeader

                // Memory train + interactions
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        memoryTrain
                            .padding(.horizontal, 40)
                            .padding(.top, 20)

                        interactionSection
                            .padding(.horizontal, 40)
                            .padding(.top, 24)
                            .padding(.bottom, 80)
                    }
                }
            }

            // Floating action buttons
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Button(action: { showingAddInteraction = true }) {
                            Image(systemName: "bubble.left.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(tc.textSecondary.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .help("Log interaction [I]")

                        Button(action: { showingAddMemory = true }) {
                            Image(systemName: "brain.filled.head.profile")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .frame(width: 48, height: 48)
                                .background(tc.warmAccent)
                                .clipShape(Circle())
                                .shadow(color: tc.warmAccent.opacity(0.4), radius: 8, y: 4)
                        }
                        .buttonStyle(.plain)
                        .help("Add memory [M]")
                    }
                    .padding(.trailing, 28)
                    .padding(.bottom, 24)
                }
            }
        }
        .focusable()
        .onKeyPress(.escape) { onBack(); return .handled }
        .onKeyPress(characters: CharacterSet(charactersIn: "mM")) { _ in showingAddMemory = true; return .handled }
        .onKeyPress(characters: CharacterSet(charactersIn: "iI")) { _ in showingAddInteraction = true; return .handled }
        .onKeyPress(characters: CharacterSet(charactersIn: "eE")) { _ in showingEditPerson = true; return .handled }
        .sheet(isPresented: $showingAddMemory) {
            AddMemorySheet(person: person)
                .environmentObject(store)
                .environmentObject(theme)
        }
        .sheet(isPresented: $showingAddInteraction) {
            AddInteractionSheet(person: person)
                .environmentObject(store)
                .environmentObject(theme)
        }
        .sheet(isPresented: $showingEditPerson) {
            EditPersonSheet(person: person)
                .environmentObject(store)
                .environmentObject(theme)
        }
        .alert("Delete this memory?", isPresented: Binding(
            get: { memoryToDelete != nil },
            set: { if !$0 { memoryToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let mem = memoryToDelete {
                    store.deleteMemory(mem)
                    memoryToDelete = nil
                }
            }
            Button("Cancel", role: .cancel) { memoryToDelete = nil }
        }
    }

    // MARK: - Journal Header

    private var journalHeader: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                // Back button
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Wall")
                            .font(.system(size: 12, design: .monospaced))
                    }
                    .foregroundColor(tc.warmAccent)
                }
                .buttonStyle(.plain)

                Spacer()

                // Edit button
                Button(action: { showingEditPerson = true }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 12))
                        .foregroundColor(tc.textSecondary)
                        .padding(6)
                        .background(tc.surface.opacity(0.6))
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)

            HStack(spacing: 16) {
                // Large initials
                ZStack {
                    let wc = store.weather(for: person.id).colorRGB
                    Circle()
                        .fill(Color(red: wc.r, green: wc.g, blue: wc.b).opacity(0.15))
                        .frame(width: 64, height: 64)
                    Circle()
                        .stroke(Color(red: wc.r, green: wc.g, blue: wc.b).opacity(0.3), lineWidth: 2)
                        .frame(width: 64, height: 64)
                    Text(person.displayInitials)
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(Color(red: wc.r, green: wc.g, blue: wc.b))
                }
                .matchedGeometryEffect(id: "avatar-\(person.id)", in: namespace)

                VStack(alignment: .leading, spacing: 4) {
                    Text(person.name)
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(tc.textPrimary)
                        .matchedGeometryEffect(id: "name-\(person.id)", in: namespace)

                    if !person.company.isEmpty {
                        Text(person.company)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(tc.textSecondary)
                    }

                    // Tags
                    if !person.tags.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(person.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 10, design: .monospaced))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(tc.warmAccent.opacity(0.1))
                                    .foregroundColor(tc.warmAccent)
                                    .cornerRadius(4)
                            }
                        }
                    }

                    // Contact info
                    HStack(spacing: 12) {
                        if !person.email.isEmpty {
                            Link(destination: URL(string: "mailto:\(person.email)")!) {
                                HStack(spacing: 3) {
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 9))
                                    Text(person.email)
                                        .font(.system(size: 10, design: .monospaced))
                                }
                                .foregroundColor(tc.warmAccent.opacity(0.7))
                            }
                        }
                        if !person.phone.isEmpty {
                            Link(destination: URL(string: "tel:\(person.phone)")!) {
                                HStack(spacing: 3) {
                                    Image(systemName: "phone.fill")
                                        .font(.system(size: 9))
                                    Text(person.phone)
                                        .font(.system(size: 10, design: .monospaced))
                                }
                                .foregroundColor(tc.warmAccent.opacity(0.7))
                            }
                        }
                    }
                }

                Spacer()

                // Weather badge
                let w = store.weather(for: person.id)
                let wc = w.colorRGB
                VStack(spacing: 3) {
                    Image(systemName: w.icon)
                        .font(.system(size: 28))
                        .foregroundColor(Color(red: wc.r, green: wc.g, blue: wc.b))
                    Text(w.label)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: wc.r, green: wc.g, blue: wc.b))
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 16)

            // Birthday / dates row
            if !person.birthday.isEmpty || !person.dates.isEmpty {
                HStack(spacing: 16) {
                    if !person.birthday.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "birthday.cake.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.pink)
                            Text(person.birthday)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(tc.textSecondary)
                        }
                    }
                    ForEach(person.dates) { nd in
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                                .foregroundColor(tc.listAccent)
                            Text("\(nd.label): \(nd.date)")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(tc.textSecondary)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 8)
            }

            // Notes
            if !person.notes.isEmpty {
                HStack {
                    Text(person.notes)
                        .font(.system(size: 12, design: .serif))
                        .foregroundColor(tc.textSecondary.opacity(0.8))
                        .italic()
                        .textSelection(.enabled)
                    Spacer()
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 8)
            }

            // Divider
            Rectangle()
                .fill(tc.borderInactive)
                .frame(height: 1)
                .padding(.horizontal, 24)
        }
        .background(tc.journalBg)
    }

    // MARK: - Memory Train

    private var memoryTrain: some View {
        let memories = store.memories(for: person.id)

        return VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("MEMORIES")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(tc.textSecondary)
                Text("(\(memories.count))")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(tc.textSecondary.opacity(0.6))
                Spacer()
            }
            .padding(.bottom, 8)

            if memories.isEmpty {
                VStack(spacing: 12) {
                    Text("No memories yet")
                        .font(.system(size: 16, design: .serif))
                        .foregroundColor(tc.textSecondary.opacity(0.5))
                        .italic()
                    Text("Capture thoughts, voice memos, and photos about \(person.name)")
                        .font(.system(size: 12, design: .serif))
                        .foregroundColor(tc.textSecondary.opacity(0.3))
                    Button(action: { showingAddMemory = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add a memory")
                                .font(.system(size: 12, design: .serif))
                        }
                        .foregroundColor(tc.warmAccent)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                // Group by date
                let grouped = groupMemoriesByDate(memories)
                ForEach(grouped, id: \.date) { group in
                    // Date separator
                    HStack {
                        Rectangle().fill(tc.borderInactive).frame(height: 1)
                        Text(group.date)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(tc.textSecondary.opacity(0.5))
                            .fixedSize()
                        Rectangle().fill(tc.borderInactive).frame(height: 1)
                    }
                    .padding(.vertical, 8)

                    ForEach(group.memories) { memory in
                        MemoryRow(memory: memory, onDelete: { memoryToDelete = memory })
                            .padding(.bottom, CGFloat(stableRandom(from: memory.id, range: 8...16)))
                    }
                }
            }
        }
    }

    // MARK: - Interaction Section

    private var interactionSection: some View {
        let interactions = store.interactions(for: person.id)

        return VStack(alignment: .leading, spacing: 0) {
            Button(action: { withAnimation { showInteractions.toggle() } }) {
                HStack(spacing: 6) {
                    Image(systemName: showInteractions ? "chevron.down" : "chevron.right")
                        .font(.system(size: 9))
                    Text("INTERACTIONS")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                    Text("(\(interactions.count))")
                        .font(.system(size: 11, design: .monospaced))
                        .opacity(0.6)
                    Spacer()
                }
                .foregroundColor(tc.textSecondary)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 8)

            if showInteractions {
                if interactions.isEmpty {
                    Text("No interactions logged yet")
                        .font(.system(size: 12, design: .serif))
                        .foregroundColor(tc.textSecondary.opacity(0.4))
                        .italic()
                        .padding(.vertical, 12)
                } else {
                    // Timeline
                    ForEach(interactions) { interaction in
                        HStack(alignment: .top, spacing: 10) {
                            // Timeline dot + line
                            VStack(spacing: 0) {
                                let ch = Channel.from(interaction.channel)
                                Circle()
                                    .fill(tc.warmAccent.opacity(0.6))
                                    .frame(width: 8, height: 8)
                                    .overlay(
                                        Image(systemName: ch.icon)
                                            .font(.system(size: 6))
                                            .foregroundColor(.white)
                                    )
                                Rectangle()
                                    .fill(tc.borderInactive)
                                    .frame(width: 1)
                            }
                            .frame(width: 8)

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(Channel.from(interaction.channel).displayName)
                                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                                        .foregroundColor(tc.textPrimary)
                                    Text(interaction.shortDateDisplay)
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(tc.textSecondary.opacity(0.6))
                                }
                                if !interaction.note.isEmpty {
                                    Text(interaction.note)
                                        .font(.system(size: 12, design: .serif))
                                        .foregroundColor(tc.textSecondary.opacity(0.8))
                                }
                            }
                            .padding(.bottom, 12)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private struct DateGroup {
        let date: String
        let memories: [Memory]
    }

    private func groupMemoriesByDate(_ memories: [Memory]) -> [DateGroup] {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM yyyy"

        var groups: [(String, [Memory])] = []
        var currentLabel = ""
        var currentGroup: [Memory] = []

        for mem in memories {
            let label: String
            if let d = ISO8601Flexible.date(from: mem.created_at) {
                label = fmt.string(from: d)
            } else {
                label = "Unknown"
            }

            if label != currentLabel {
                if !currentGroup.isEmpty {
                    groups.append((currentLabel, currentGroup))
                }
                currentLabel = label
                currentGroup = [mem]
            } else {
                currentGroup.append(mem)
            }
        }
        if !currentGroup.isEmpty {
            groups.append((currentLabel, currentGroup))
        }

        return groups.map { DateGroup(date: $0.0, memories: $0.1) }
    }
}
