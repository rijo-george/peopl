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

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.badge.plus")
                    .foregroundColor(theme.colors.accent)
                Text("Add Person")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Name *").font(.caption).foregroundColor(.secondary)
                TextField("e.g. Jane Smith", text: $name)
                    .textFieldStyle(.roundedBorder)
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Company / Context").font(.caption).foregroundColor(.secondary)
                    TextField("e.g. Acme Corp, yoga class", text: $company)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Birthday (MM-DD)").font(.caption).foregroundColor(.secondary)
                    TextField("e.g. 03-15", text: $birthday)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                }
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Email").font(.caption).foregroundColor(.secondary)
                    TextField("email@example.com", text: $email)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Phone").font(.caption).foregroundColor(.secondary)
                    TextField("+1 555-1234", text: $phone)
                        .textFieldStyle(.roundedBorder)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Tags (comma separated)").font(.caption).foregroundColor(.secondary)
                TextField("e.g. work, seattle, mentor", text: $tagsText)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Notes").font(.caption).foregroundColor(.secondary)
                TextField("anything you want to remember", text: $notes)
                    .textFieldStyle(.roundedBorder)
            }

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Add") { addPerson() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 460)
    }

    private func addPerson() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let tags = tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

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
