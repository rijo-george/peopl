import SwiftUI

struct JournalView: View {
    @EnvironmentObject var store: PeoplStore
    @EnvironmentObject var theme: ThemeManager
    let person: Person
    var namespace: Namespace.ID
    var onBack: () -> Void
    @Binding var showingAddMemory: Bool
    @Binding var showingAddInteraction: Bool
    @Binding var showingEditPerson: Bool

    @State private var memoryToDelete: Memory?

    private var tc: ThemeColors { theme.colors }

    var body: some View {
        ZStack {
            tc.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                journalHeader

                // Two-column layout
                HStack(spacing: 0) {
                    // Left: timeline
                    leftColumn

                    // Divider
                    Rectangle()
                        .fill(tc.borderInactive)
                        .frame(width: 1)

                    // Right: details
                    PersonDetailsPanel(person: person)
                        .frame(width: 300)
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
                        .help("We talked (Cmd+Shift+I)")

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
                        .help("I want to remember... (Cmd+Shift+M)")
                    }
                    .padding(.trailing, 28)
                    .padding(.bottom, 24)
                }
            }
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

    // MARK: - Left Column (timeline)

    private var leftColumn: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if !person.notes.isEmpty {
                    pinnedNotes
                        .padding(.horizontal, 32)
                        .padding(.top, 16)
                }

                timelineContent
                    .padding(.horizontal, 32)
                    .padding(.top, 16)
                    .padding(.bottom, 80)
            }
        }
    }

    // MARK: - Journal Header (compact)

    private var journalHeader: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
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

            HStack(spacing: 14) {
                ZStack {
                    let wc = store.weather(for: person.id).colorRGB
                    Circle()
                        .fill(Color(red: wc.r, green: wc.g, blue: wc.b).opacity(0.15))
                        .frame(width: 44, height: 44)
                    Text(person.displayInitials)
                        .font(.system(size: 17, weight: .bold, design: .serif))
                        .foregroundColor(Color(red: wc.r, green: wc.g, blue: wc.b))
                }
                .matchedGeometryEffect(id: "avatar-\(person.id)", in: namespace)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(person.name)
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundColor(tc.textPrimary)
                            .matchedGeometryEffect(id: "name-\(person.id)", in: namespace)

                        let w = store.weather(for: person.id)
                        let wc = w.colorRGB
                        Image(systemName: w.icon)
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: wc.r, green: wc.g, blue: wc.b))
                    }

                    if !person.company.isEmpty {
                        Text(person.company)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(tc.textSecondary)
                    }
                }

                Spacer()

                // Tags inline in header
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
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 10)

            Rectangle()
                .fill(tc.borderInactive)
                .frame(height: 1)
                .padding(.horizontal, 24)
        }
        .background(tc.journalBg)
    }

    // MARK: - Pinned Notes

    private var pinnedNotes: some View {
        HStack {
            Text(person.notes)
                .font(.system(size: 13, design: .serif))
                .foregroundColor(tc.textSecondary.opacity(0.8))
                .italic()
                .textSelection(.enabled)
            Spacer()
        }
        .padding(.bottom, 8)
    }

    // MARK: - Unified Timeline

    private var timelineContent: some View {
        let items = store.interleaveTimeline(for: person.id)
        let grouped = groupTimelineByMonth(items)

        return VStack(alignment: .leading, spacing: 0) {
            if items.isEmpty {
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
                            Text("I want to remember...")
                                .font(.system(size: 12, design: .serif))
                        }
                        .foregroundColor(tc.warmAccent)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(grouped, id: \.label) { group in
                    Text(group.label)
                        .font(.system(size: 12, design: .serif))
                        .foregroundColor(tc.textSecondary.opacity(0.5))
                        .italic()
                        .padding(.top, 16)
                        .padding(.bottom, 8)

                    ForEach(group.items) { item in
                        switch item {
                        case .memory(let memory):
                            MemoryRow(memory: memory, onDelete: { memoryToDelete = memory })
                                .padding(.bottom, CGFloat(stableRandom(from: memory.id, range: 8...16)))
                        case .interaction(let interaction):
                            InteractionRow(interaction: interaction)
                                .padding(.bottom, 8)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Interaction Row

    private struct InteractionRow: View {
        @EnvironmentObject var theme: ThemeManager
        let interaction: Interaction

        private var tc: ThemeColors { theme.colors }

        var body: some View {
            let ch = Channel.from(interaction.channel)
            let channelColor = tc.warmAccent

            HStack(alignment: .top, spacing: 10) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(channelColor.opacity(0.5))
                    .frame(width: 3)

                Image(systemName: ch.icon)
                    .font(.system(size: 10))
                    .foregroundColor(channelColor.opacity(0.7))

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(ch.displayName)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(tc.textPrimary)
                        Text(interaction.shortDateDisplay)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(tc.textSecondary.opacity(0.5))
                    }
                    if !interaction.note.isEmpty {
                        Text(interaction.note)
                            .font(.system(size: 12, design: .serif))
                            .foregroundColor(tc.textSecondary.opacity(0.8))
                    }
                }

                Spacer()
            }
            .padding(.vertical, 6)
        }
    }

    // MARK: - Helpers

    private struct MonthGroup {
        let label: String
        let items: [PeoplStore.TimelineItem]
    }

    private func groupTimelineByMonth(_ items: [PeoplStore.TimelineItem]) -> [MonthGroup] {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM yyyy"

        var groups: [(String, [PeoplStore.TimelineItem])] = []
        var currentLabel = ""
        var currentGroup: [PeoplStore.TimelineItem] = []

        for item in items {
            let label = fmt.string(from: item.sortDate).lowercased()
            if label != currentLabel {
                if !currentGroup.isEmpty {
                    groups.append((currentLabel, currentGroup))
                }
                currentLabel = label
                currentGroup = [item]
            } else {
                currentGroup.append(item)
            }
        }
        if !currentGroup.isEmpty {
            groups.append((currentLabel, currentGroup))
        }

        return groups.map { MonthGroup(label: $0.0, items: $0.1) }
    }
}

// MARK: - Person Details Panel (right column)

struct PersonDetailsPanel: View {
    @EnvironmentObject var store: PeoplStore
    @EnvironmentObject var theme: ThemeManager
    let person: Person

    @State private var editingFieldID: String?
    @State private var editText = ""
    @State private var showAddField = false
    @State private var newFieldLabel = ""
    @State private var newFieldIcon = "star.fill"
    @State private var showSuggestions = false

    private var tc: ThemeColors { theme.colors }

    // Current person from store (live)
    private var livePerson: Person {
        store.data.people.first { $0.id == person.id } ?? person
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Section header
                HStack {
                    Text("About \(livePerson.name)")
                        .font(.system(size: 13, weight: .semibold, design: .serif))
                        .foregroundColor(tc.textPrimary)
                    Spacer()
                }
                .padding(.bottom, 16)

                // Built-in fields (always visible)
                builtInFields

                // Divider
                if !livePerson.details.isEmpty {
                    Rectangle()
                        .fill(tc.borderInactive)
                        .frame(height: 1)
                        .padding(.vertical, 12)
                }

                // Custom detail fields
                ForEach(livePerson.details) { field in
                    detailFieldRow(field)
                }

                // Add field area
                addFieldSection
                    .padding(.top, 16)
            }
            .padding(20)
        }
        .background(tc.journalBg)
    }

    // MARK: - Built-in Fields

    private var builtInFields: some View {
        VStack(spacing: 0) {
            if !livePerson.email.isEmpty {
                staticFieldRow(icon: "envelope.fill", label: "Email", value: livePerson.email, link: "mailto:\(livePerson.email)")
            }
            if !livePerson.phone.isEmpty {
                staticFieldRow(icon: "phone.fill", label: "Phone", value: livePerson.phone, link: "tel:\(livePerson.phone)")
            }
            if !livePerson.company.isEmpty {
                staticFieldRow(icon: "building.2.fill", label: "Company", value: livePerson.company)
            }
            if !livePerson.birthday.isEmpty {
                staticFieldRow(icon: "birthday.cake.fill", label: "Birthday", value: livePerson.birthday)
            }
            if !livePerson.dates.isEmpty {
                ForEach(livePerson.dates) { nd in
                    staticFieldRow(icon: "calendar", label: nd.label, value: nd.date)
                }
            }
        }
    }

    private func staticFieldRow(icon: String, label: String, value: String, link: String? = nil) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(tc.warmAccent.opacity(0.7))
                .frame(width: 16, alignment: .center)

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(tc.textSecondary.opacity(0.6))
                if let link, let url = URL(string: link) {
                    Link(destination: url) {
                        Text(value)
                            .font(.system(size: 12, design: .serif))
                            .foregroundColor(tc.warmAccent)
                    }
                } else {
                    Text(value)
                        .font(.system(size: 12, design: .serif))
                        .foregroundColor(tc.textPrimary)
                        .textSelection(.enabled)
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }

    // MARK: - Detail Field Row (editable)

    private func detailFieldRow(_ field: PersonField) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: field.icon)
                .font(.system(size: 11))
                .foregroundColor(tc.warmAccent.opacity(0.7))
                .frame(width: 16, alignment: .center)

            VStack(alignment: .leading, spacing: 1) {
                Text(field.label)
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(tc.textSecondary.opacity(0.6))

                if editingFieldID == field.id {
                    TextField("", text: $editText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12, design: .serif))
                        .foregroundColor(tc.textPrimary)
                        .onSubmit { saveFieldEdit(field) }
                        .overlay(alignment: .bottom) {
                            Rectangle().fill(tc.warmAccent.opacity(0.5)).frame(height: 1)
                        }
                } else {
                    Text(field.value.isEmpty ? "..." : field.value)
                        .font(.system(size: 12, design: .serif))
                        .foregroundColor(field.value.isEmpty ? tc.textSecondary.opacity(0.3) : tc.textPrimary)
                        .textSelection(.enabled)
                        .onTapGesture {
                            editingFieldID = field.id
                            editText = field.value
                        }
                }
            }

            Spacer()

            // Delete button (on hover would be ideal, but simpler to always show small)
            if editingFieldID == field.id {
                HStack(spacing: 6) {
                    Button(action: { saveFieldEdit(field) }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.green)
                    }
                    .buttonStyle(.plain)
                    Button(action: { editingFieldID = nil }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(tc.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Button(action: { removeField(field) }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(tc.textSecondary.opacity(0.2))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - Add Field Section

    private var addFieldSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Suggestions (collapsed by default)
            if showSuggestions {
                suggestionsGrid
            }

            if showAddField {
                // Custom field entry
                HStack(spacing: 8) {
                    TextField("Field name", text: $newFieldLabel)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12, design: .serif))
                        .padding(.vertical, 4)
                        .overlay(alignment: .bottom) {
                            Rectangle().fill(tc.borderInactive).frame(height: 1)
                        }
                    Button(action: addCustomField) {
                        Text("Add")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(tc.warmAccent)
                    }
                    .buttonStyle(.plain)
                    .disabled(newFieldLabel.trimmingCharacters(in: .whitespaces).isEmpty)
                    Button(action: { showAddField = false; newFieldLabel = "" }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 10))
                            .foregroundColor(tc.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(spacing: 12) {
                Button(action: { withAnimation(.easeInOut(duration: 0.2)) { showSuggestions.toggle() } }) {
                    HStack(spacing: 4) {
                        Image(systemName: showSuggestions ? "chevron.up" : "sparkles")
                            .font(.system(size: 10))
                        Text(showSuggestions ? "Hide suggestions" : "Add a detail")
                            .font(.system(size: 11, design: .serif))
                    }
                    .foregroundColor(tc.warmAccent)
                }
                .buttonStyle(.plain)

                if !showAddField {
                    Button(action: { showAddField = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 10))
                            Text("Custom field")
                                .font(.system(size: 11, design: .serif))
                        }
                        .foregroundColor(tc.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Suggestions Grid

    private var suggestionsGrid: some View {
        let existingLabels = Set(livePerson.details.map { $0.label })
        let available = SuggestedField.allCases.filter { !existingLabels.contains($0.label) }

        return FlowLayout(spacing: 6) {
            ForEach(available, id: \.rawValue) { suggestion in
                Button(action: { addSuggestedField(suggestion) }) {
                    HStack(spacing: 4) {
                        Image(systemName: suggestion.icon)
                            .font(.system(size: 9))
                        Text(suggestion.label)
                            .font(.system(size: 10, design: .serif))
                    }
                    .foregroundColor(tc.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(tc.surface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(tc.borderInactive, lineWidth: 0.5)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, 4)
    }

    // MARK: - Actions

    private func addSuggestedField(_ suggestion: SuggestedField) {
        var updated = livePerson
        let field = PersonField(id: UUID().uuidString, label: suggestion.label, value: "", icon: suggestion.icon)
        updated.details.append(field)
        store.updatePerson(updated)
        // Auto-focus the new field for editing
        editingFieldID = field.id
        editText = ""
    }

    private func addCustomField() {
        let label = newFieldLabel.trimmingCharacters(in: .whitespaces)
        guard !label.isEmpty else { return }
        var updated = livePerson
        let field = PersonField(id: UUID().uuidString, label: label, value: "", icon: newFieldIcon)
        updated.details.append(field)
        store.updatePerson(updated)
        newFieldLabel = ""
        showAddField = false
        editingFieldID = field.id
        editText = ""
    }

    private func saveFieldEdit(_ field: PersonField) {
        var updated = livePerson
        if let idx = updated.details.firstIndex(where: { $0.id == field.id }) {
            updated.details[idx].value = editText.trimmingCharacters(in: .whitespaces)
            store.updatePerson(updated)
        }
        editingFieldID = nil
    }

    private func removeField(_ field: PersonField) {
        var updated = livePerson
        updated.details.removeAll { $0.id == field.id }
        store.updatePerson(updated)
    }
}
