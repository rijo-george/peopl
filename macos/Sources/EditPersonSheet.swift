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

    private var tc: ThemeColors { theme.colors }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(tc.warmAccent)
                Text("Edit Person")
                    .font(.system(size: 16, weight: .semibold, design: .serif))
            }

            journalField("Name", text: $name, placeholder: "Name")

            HStack(spacing: 16) {
                journalField("Company / Context", text: $company, placeholder: "Company")
                journalField("Birthday", text: $birthday, placeholder: "MM-DD")
                    .frame(width: 100)
            }

            HStack(spacing: 16) {
                journalField("Email", text: $email, placeholder: "Email")
                journalField("Phone", text: $phone, placeholder: "Phone")
            }

            journalField("Tags", text: $tagsText, placeholder: "comma separated tags")

            VStack(alignment: .leading, spacing: 4) {
                Text("Notes")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(tc.textSecondary)
                TextEditor(text: $notes)
                    .font(.system(size: 14, design: .serif))
                    .frame(height: 60)
                    .padding(6)
                    .background(tc.memoryTint)
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(tc.borderInactive))
            }

            // Custom dates
            VStack(alignment: .leading, spacing: 6) {
                Text("Custom Dates")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(tc.textSecondary)

                ForEach(dates) { nd in
                    HStack {
                        Text("\(nd.label): \(nd.date)")
                            .font(.system(size: 12, design: .serif))
                            .foregroundColor(tc.textPrimary)
                        Spacer()
                        Button(action: { dates.removeAll { $0.id == nd.id } }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 11))
                                .foregroundColor(tc.textSecondary.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                    }
                }

                HStack(spacing: 8) {
                    TextField("Label", text: $newDateLabel)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12, design: .serif))
                        .padding(.vertical, 4)
                        .overlay(alignment: .bottom) { Rectangle().fill(tc.borderInactive).frame(height: 1) }
                        .frame(width: 140)
                    TextField("MM-DD", text: $newDateValue)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12, design: .monospaced))
                        .padding(.vertical, 4)
                        .overlay(alignment: .bottom) { Rectangle().fill(tc.borderInactive).frame(height: 1) }
                        .frame(width: 80)
                    Button("Add") {
                        let label = newDateLabel.trimmingCharacters(in: .whitespaces)
                        let value = newDateValue.trimmingCharacters(in: .whitespaces)
                        guard !label.isEmpty, !value.isEmpty else { return }
                        dates.append(NamedDate(id: UUID().uuidString, label: label, date: value))
                        newDateLabel = ""
                        newDateValue = ""
                    }
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(tc.warmAccent)
                    .disabled(newDateLabel.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                    .foregroundColor(tc.textSecondary)
                Button(action: savePerson) {
                    Text("Save")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                        .background(tc.warmAccent)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.defaultAction)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 480)
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

    private func savePerson() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        let tags = tagsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
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
