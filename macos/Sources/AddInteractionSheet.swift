import SwiftUI

struct AddInteractionSheet: View {
    @EnvironmentObject var store: PeoplStore
    @EnvironmentObject var theme: ThemeManager
    @Environment(\.dismiss) var dismiss

    let person: Person

    @State private var selectedChannel: Channel = .coffee
    @State private var note = ""
    @State private var date = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "bubble.left.fill")
                    .foregroundColor(theme.colors.accent)
                Text("Log Interaction")
                    .font(.headline)
                Spacer()
                Text("with \(person.name)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Channel picker
            VStack(alignment: .leading, spacing: 4) {
                Text("How?").font(.caption).foregroundColor(.secondary)
                HStack(spacing: 6) {
                    ForEach(Channel.allCases) { channel in
                        Button(action: { selectedChannel = channel }) {
                            VStack(spacing: 3) {
                                Image(systemName: channel.icon)
                                    .font(.system(size: 16))
                                Text(channel.displayName)
                                    .font(.system(size: 9))
                            }
                            .frame(width: 56, height: 44)
                            .background(selectedChannel == channel
                                        ? theme.colors.accent.opacity(0.2)
                                        : theme.colors.textSecondary.opacity(0.05))
                            .foregroundColor(selectedChannel == channel
                                             ? theme.colors.accent
                                             : theme.colors.textSecondary)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedChannel == channel
                                            ? theme.colors.accent
                                            : Color.clear, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Date
            VStack(alignment: .leading, spacing: 4) {
                Text("When?").font(.caption).foregroundColor(.secondary)
                DatePicker("", selection: $date, displayedComponents: [.date])
                    .labelsHidden()
                    .datePickerStyle(.field)
            }

            // Note
            VStack(alignment: .leading, spacing: 4) {
                Text("What happened?").font(.caption).foregroundColor(.secondary)
                TextField("e.g. Caught up about her new role", text: $note)
                    .textFieldStyle(.roundedBorder)
            }

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Log") { logInteraction() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 440)
    }

    private func logInteraction() {
        store.addInteraction(
            personID: person.id,
            channel: selectedChannel.rawValue,
            note: note.trimmingCharacters(in: .whitespaces),
            date: date
        )
        dismiss()
    }
}
