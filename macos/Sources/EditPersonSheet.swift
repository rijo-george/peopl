import SwiftUI

struct EditPersonSheet: View {
    @EnvironmentObject var store: PeoplStore
    @EnvironmentObject var theme: ThemeManager
    @Environment(\.dismiss) var dismiss

    let person: Person

    @State private var name = ""
    @State private var company = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var tagsText = ""
    @State private var birthday = ""
    @State private var notes = ""
    @State private var dates: [NamedDate] = []
    @State private var newDateLabel = ""
    @State private var newDateValue = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(theme.colors.accent)
                Text("Edit Person")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Name *").font(.caption).foregroundColor(.secondary)
                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Company / Context").font(.caption).foregroundColor(.secondary)
                    TextField("Company", text: $company)
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
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Phone").font(.caption).foregroundColor(.secondary)
                    TextField("Phone", text: $phone)
                        .textFieldStyle(.roundedBorder)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Tags (comma separated)").font(.caption).foregroundColor(.secondary)
                TextField("Tags", text: $tagsText)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Notes").font(.caption).foregroundColor(.secondary)
                TextEditor(text: $notes)
                    .font(.system(size: 13))
                    .frame(height: 60)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.3)))
            }

            // Custom dates
            VStack(alignment: .leading, spacing: 4) {
                Text("CUSTOM DATES")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)

                ForEach(dates) { nd in
                    HStack {
                        Text("\(nd.label): \(nd.date)")
                            .font(.system(size: 12))
                        Spacer()
                        Button(action: { dates.removeAll { $0.id == nd.id } }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }

                HStack(spacing: 8) {
                    TextField("Label", text: $newDateLabel)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 140)
                    TextField("MM-DD", text: $newDateValue)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                    Button("Add") {
                        let label = newDateLabel.trimmingCharacters(in: .whitespaces)
                        let value = newDateValue.trimmingCharacters(in: .whitespaces)
                        guard !label.isEmpty, !value.isEmpty else { return }
                        dates.append(NamedDate(id: UUID().uuidString, label: label, date: value))
                        newDateLabel = ""
                        newDateValue = ""
                    }
                    .disabled(newDateLabel.trimmingCharacters(in: .whitespaces).isEmpty ||
                              newDateValue.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Save") { savePerson() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 460)
        .onAppear {
            name = person.name
            company = person.company
            email = person.email
            phone = person.phone
            tagsText = person.tags.joined(separator: ", ")
            birthday = person.birthday
            notes = person.notes
            dates = person.dates
        }
    }

    private func savePerson() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let tags = tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        var updated = person
        updated.name = trimmedName
        updated.company = company.trimmingCharacters(in: .whitespaces)
        updated.email = email.trimmingCharacters(in: .whitespaces)
        updated.phone = phone.trimmingCharacters(in: .whitespaces)
        updated.tags = tags
        updated.notes = notes.trimmingCharacters(in: .whitespaces)
        updated.birthday = birthday.trimmingCharacters(in: .whitespaces)
        updated.dates = dates

        store.updatePerson(updated)
        dismiss()
    }
}
