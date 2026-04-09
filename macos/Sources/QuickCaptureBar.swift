import SwiftUI

struct QuickCaptureBar: View {
    @EnvironmentObject var store: PeoplStore
    @EnvironmentObject var theme: ThemeManager
    var contextPersonID: String?
    @FocusState.Binding var isFocused: Bool

    @State private var text = ""
    @State private var showSuccess = false
    @State private var isVoiceMode = false
    @StateObject private var audio = AudioRecorder()
    @State private var personPickerQuery = ""
    @State private var showPersonPicker = false
    @State private var pendingAudioURL: URL?

    private var tc: ThemeColors { theme.colors }

    private var contextPerson: Person? {
        guard let id = contextPersonID else { return nil }
        return store.data.people.first { $0.id == id }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Person picker for voice (when no context person)
            if showPersonPicker {
                personPickerView
            }

            HStack(spacing: 10) {
                if isVoiceMode {
                    voiceModeContent
                } else {
                    textModeContent
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(tc.captureBarBg)
        }
    }

    // MARK: - Text Mode

    private var textModeContent: some View {
        HStack(spacing: 10) {
            if showSuccess {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Saved")
                        .font(.system(size: 12, design: .serif))
                        .foregroundColor(.green)
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                let placeholder = contextPerson != nil
                    ? "I want to remember..."
                    : "priya - loves pottery"

                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13, design: .serif))
                    .foregroundColor(tc.textPrimary)
                    .focused($isFocused)
                    .onSubmit { submitText() }
            }

            Spacer()

            // Mic toggle
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isVoiceMode = true
                    audio.startRecording()
                }
            }) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 14))
                    .foregroundColor(tc.textSecondary)
                    .padding(6)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Voice Mode

    private var voiceModeContent: some View {
        HStack(spacing: 12) {
            // Red pulse dot
            Circle()
                .fill(Color.red)
                .frame(width: 10, height: 10)
                .opacity(audio.isRecording ? 1 : 0.3)

            // Timer
            Text(audio.formatTime(audio.recordingTime))
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(tc.textPrimary)

            // Mini waveform
            HStack(spacing: 2) {
                ForEach(0..<12, id: \.self) { i in
                    let height = CGFloat.random(in: 4...16)
                    RoundedRectangle(cornerRadius: 1)
                        .fill(tc.warmAccent.opacity(0.6))
                        .frame(width: 2, height: audio.isRecording ? height : 4)
                        .animation(.easeInOut(duration: 0.15), value: audio.isRecording)
                }
            }
            .frame(height: 16)

            Spacer()

            // Stop button
            Button(action: stopVoice) {
                HStack(spacing: 4) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 10))
                    Text("Done")
                        .font(.system(size: 11, design: .monospaced))
                }
                .foregroundColor(.red)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)

            // Cancel
            Button(action: cancelVoice) {
                Image(systemName: "xmark")
                    .font(.system(size: 11))
                    .foregroundColor(tc.textSecondary)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Person Picker

    private var personPickerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: "person.fill")
                    .font(.system(size: 10))
                    .foregroundColor(tc.textSecondary)
                TextField("Who is this about?", text: $personPickerQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12, design: .serif))
                    .foregroundColor(tc.textPrimary)
                    .onSubmit { saveVoiceWithPerson() }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(tc.surface)

            // Suggestions
            if !personPickerQuery.isEmpty {
                let matches = store.activePeople.filter {
                    $0.name.lowercased().contains(personPickerQuery.lowercased())
                }.prefix(4)
                ForEach(Array(matches)) { person in
                    Button(action: {
                        personPickerQuery = person.name
                        saveVoiceForPerson(person)
                    }) {
                        Text(person.name)
                            .font(.system(size: 12, design: .serif))
                            .foregroundColor(tc.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .background(tc.captureBarBg)
    }

    // MARK: - Actions

    private func submitText() {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let parsed = store.parseQuickCapture(input: trimmed)
        let person: Person?

        if let contextPersonID, let p = store.data.people.first(where: { $0.id == contextPersonID }) {
            person = p
        } else if let query = parsed.personQuery {
            person = store.fuzzyMatchPerson(query: query)
        } else {
            person = nil
        }

        let memoryText = parsed.personQuery != nil ? parsed.text : trimmed

        guard let person, !memoryText.trimmingCharacters(in: .whitespaces).isEmpty else {
            // If no person matched and no context, we can't save
            return
        }

        store.addTextMemory(personID: person.id, text: memoryText.trimmingCharacters(in: .whitespaces), color: "plain")
        text = ""
        flashSuccess()
    }

    private func stopVoice() {
        audio.stopRecording()
        if let contextPersonID {
            // Save directly
            if let url = audio.recordedURL {
                store.saveVoiceMemory(personID: contextPersonID, audioURL: url, caption: "", color: "plain")
                audio.cleanup()
                withAnimation { isVoiceMode = false }
                flashSuccess()
            }
        } else {
            // Show person picker
            pendingAudioURL = audio.recordedURL
            withAnimation {
                isVoiceMode = false
                showPersonPicker = true
            }
        }
    }

    private func cancelVoice() {
        audio.cleanup()
        withAnimation {
            isVoiceMode = false
            showPersonPicker = false
        }
    }

    private func saveVoiceWithPerson() {
        guard let person = store.fuzzyMatchPerson(query: personPickerQuery) else { return }
        saveVoiceForPerson(person)
    }

    private func saveVoiceForPerson(_ person: Person) {
        if let url = pendingAudioURL ?? audio.recordedURL {
            store.saveVoiceMemory(personID: person.id, audioURL: url, caption: "", color: "plain")
        }
        audio.cleanup()
        pendingAudioURL = nil
        personPickerQuery = ""
        withAnimation {
            showPersonPicker = false
        }
        flashSuccess()
    }

    private func flashSuccess() {
        withAnimation(.easeIn(duration: 0.2)) { showSuccess = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.3)) { showSuccess = false }
        }
    }
}
