import SwiftUI

struct AddPersonSheet: View {
    @EnvironmentObject var store: PeoplStore
    @EnvironmentObject var theme: ThemeManager
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var company = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var tagsText = ""
    @State private var birthday = ""
    @State private var notes = ""

    private var tc: ThemeColors { theme.colors }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "person.badge.plus")
                    .foregroundColor(tc.warmAccent)
                Text("Someone new")
                    .font(.system(size: 16, weight: .semibold, design: .serif))
            }

            journalField("Name", text: $name, placeholder: "Jane Smith")

            HStack(spacing: 16) {
                journalField("Company / Context", text: $company, placeholder: "Acme Corp, yoga class")
                journalField("Birthday", text: $birthday, placeholder: "MM-DD")
                    .frame(width: 100)
            }

            HStack(spacing: 16) {
                journalField("Email", text: $email, placeholder: "email@example.com")
                journalField("Phone", text: $phone, placeholder: "+1 555-1234")
            }

            journalField("Tags", text: $tagsText, placeholder: "work, seattle, mentor (comma separated)")

            VStack(alignment: .leading, spacing: 4) {
                Text("Notes")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(tc.textSecondary)
                TextEditor(text: $notes)
                    .font(.system(size: 14, design: .serif))
                    .frame(height: 50)
                    .padding(6)
                    .background(tc.memoryTint)
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(tc.borderInactive))
            }

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                    .foregroundColor(tc.textSecondary)
                Button(action: addPerson) {
                    Text("Add")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                        .background(name.trimmingCharacters(in: .whitespaces).isEmpty ? tc.textSecondary.opacity(0.3) : tc.warmAccent)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.defaultAction)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 480)
    }

    private func journalField(_ label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(tc.textSecondary)
            TextField(placeholder, text: text)
                .textFieldStyle(.plain)
                .font(.system(size: 14, design: .serif))
                .padding(.vertical, 6)
                .overlay(alignment: .bottom) {
                    Rectangle().fill(tc.borderInactive).frame(height: 1)
                }
        }
    }

    private func addPerson() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        let tags = tagsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        store.addPerson(
            name: trimmedName,
            company: company.trimmingCharacters(in: .whitespaces),
            email: email.trimmingCharacters(in: .whitespaces),
            phone: phone.trimmingCharacters(in: .whitespaces),
            tags: tags,
            notes: notes.trimmingCharacters(in: .whitespaces),
            birthday: birthday.trimmingCharacters(in: .whitespaces),
            dates: []
        )
        dismiss()
    }
}
