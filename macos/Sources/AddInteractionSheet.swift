import SwiftUI

struct AddInteractionSheet: View {
    @EnvironmentObject var store: PeoplStore
    @EnvironmentObject var theme: ThemeManager
    @Environment(\.dismiss) var dismiss

    let person: Person

    @State private var selectedChannel: Channel = .coffee
    @State private var note = ""
    @State private var date = Date()

    private var tc: ThemeColors { theme.colors }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "bubble.left.fill")
                    .foregroundColor(tc.warmAccent)
                Text("We talked")
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                Spacer()
                Text("with \(person.name)")
                    .font(.system(size: 12, design: .serif))
                    .foregroundColor(tc.textSecondary)
                    .italic()
            }

            // Channel picker
            VStack(alignment: .leading, spacing: 6) {
                Text("How?")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(tc.textSecondary)
                HStack(spacing: 6) {
                    ForEach(Channel.allCases) { channel in
                        Button(action: { selectedChannel = channel }) {
                            VStack(spacing: 3) {
                                Image(systemName: channel.icon)
                                    .font(.system(size: 16))
                                Text(channel.displayName)
                                    .font(.system(size: 9, design: .monospaced))
                            }
                            .frame(width: 56, height: 44)
                            .background(selectedChannel == channel
                                        ? tc.warmAccent.opacity(0.15)
                                        : tc.memoryTint)
                            .foregroundColor(selectedChannel == channel
                                             ? tc.warmAccent
                                             : tc.textSecondary)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedChannel == channel
                                            ? tc.warmAccent.opacity(0.5) : tc.borderInactive, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Date
            VStack(alignment: .leading, spacing: 4) {
                Text("When?")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(tc.textSecondary)
                DatePicker("", selection: $date, displayedComponents: [.date])
                    .labelsHidden()
                    .datePickerStyle(.field)
            }

            // Note
            VStack(alignment: .leading, spacing: 4) {
                Text("What did you talk about?")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(tc.textSecondary)
                TextField("Caught up about her new role...", text: $note)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14, design: .serif))
                    .padding(.vertical, 6)
                    .overlay(alignment: .bottom) {
                        Rectangle().fill(tc.borderInactive).frame(height: 1)
                    }
            }

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                    .foregroundColor(tc.textSecondary)
                Button(action: logInteraction) {
                    Text("Log")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                        .background(tc.warmAccent)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 460)
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
