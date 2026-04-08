import SwiftUI

struct AddMemorySheet: View {
    @EnvironmentObject var store: PeoplStore
    @EnvironmentObject var theme: ThemeManager
    @Environment(\.dismiss) var dismiss

    let person: Person

    @State private var memoryType: MemoryType = .text
    @State private var text = ""
    @State private var selectedColor: MemoryColor = .plain
    @State private var selectedImage: NSImage?
    @State private var caption = ""
    @StateObject private var audio = AudioRecorder()

    private var tc: ThemeColors { theme.colors }

    enum MemoryType: String, CaseIterable {
        case text, voice, image

        var icon: String {
            switch self {
            case .text:  return "pencil.line"
            case .voice: return "mic.fill"
            case .image: return "photo.fill"
            }
        }

        var label: String {
            switch self {
            case .text:  return "Write"
            case .voice: return "Record"
            case .image: return "Photo"
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "brain.filled.head.profile")
                    .foregroundColor(tc.warmAccent)
                Text("New Memory")
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                Spacer()
                Text("about \(person.name)")
                    .font(.system(size: 12, design: .serif))
                    .foregroundColor(tc.textSecondary)
                    .italic()
            }

            // Type selector
            HStack(spacing: 8) {
                ForEach(MemoryType.allCases, id: \.rawValue) { type in
                    Button(action: { withAnimation(.easeInOut(duration: 0.2)) { memoryType = type } }) {
                        VStack(spacing: 4) {
                            Image(systemName: type.icon)
                                .font(.system(size: 18))
                            Text(type.label)
                                .font(.system(size: 10, design: .monospaced))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(memoryType == type ? tc.warmAccent.opacity(0.12) : tc.surface)
                        .foregroundColor(memoryType == type ? tc.warmAccent : tc.textSecondary)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(memoryType == type ? tc.warmAccent.opacity(0.5) : tc.borderInactive, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            // Content area
            switch memoryType {
            case .text:  textContent
            case .voice: voiceContent
            case .image: imageContent
            }

            // Color picker
            VStack(alignment: .leading, spacing: 6) {
                Text("Color").font(.system(size: 10, design: .monospaced)).foregroundColor(tc.textSecondary)
                HStack(spacing: 8) {
                    ForEach(MemoryColor.allCases) { mc in
                        Button(action: { selectedColor = mc }) {
                            ZStack {
                                let c = mc.displayColor
                                Circle()
                                    .fill(mc == .plain ? tc.cardBg : Color(red: c.r, green: c.g, blue: c.b))
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle().stroke(tc.borderInactive, lineWidth: 1)
                                    )
                                if selectedColor == mc {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(tc.textPrimary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Actions
            HStack {
                Spacer()
                Button("Cancel") {
                    audio.cleanup()
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                Button("Save") { saveMemory() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!canSave)
            }
        }
        .padding(24)
        .frame(width: 480)
    }

    // MARK: - Text Content

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("What do you want to remember?")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(tc.textSecondary)
            TextEditor(text: $text)
                .font(.system(size: 15, design: .serif))
                .frame(height: 120)
                .padding(8)
                .background(tc.memoryTint)
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(tc.borderInactive))
        }
    }

    // MARK: - Voice Content

    private var voiceContent: some View {
        VStack(spacing: 16) {
            if audio.isRecording {
                // Recording state
                VStack(spacing: 8) {
                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "stop.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.red)
                        )
                        .onTapGesture { audio.stopRecording() }

                    Text(audio.formatTime(audio.recordingTime))
                        .font(.system(size: 18, design: .monospaced))
                        .foregroundColor(.red)
                    Text("recording... tap to stop")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(tc.textSecondary)
                }
            } else if let _ = audio.recordedURL {
                // Recorded, preview
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        Button(action: {
                            if let url = audio.recordedURL {
                                audio.togglePlayback(url: url)
                            }
                        }) {
                            Image(systemName: audio.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(tc.warmAccent)
                        }
                        .buttonStyle(.plain)

                        Text(audio.formatTime(audio.recordingTime))
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(tc.textPrimary)

                        Spacer()

                        Button("Re-record") {
                            audio.cleanup()
                            audio.startRecording()
                        }
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(tc.textSecondary)
                    }

                    TextField("Caption (optional)", text: $caption)
                        .font(.system(size: 13, design: .serif))
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(tc.memoryTint)
                        .cornerRadius(4)
                }
            } else {
                // Ready to record
                VStack(spacing: 8) {
                    Button(action: { audio.startRecording() }) {
                        Circle()
                            .fill(Color.red.opacity(0.15))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle().fill(Color.red).frame(width: 32, height: 32)
                            )
                    }
                    .buttonStyle(.plain)

                    Text("tap to record a voice memo")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(tc.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }

    // MARK: - Image Content

    private var imageContent: some View {
        VStack(spacing: 12) {
            if let image = selectedImage {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .cornerRadius(6)
                    .shadow(color: tc.cardShadow, radius: 4, y: 2)

                Button("Choose different image") { pickImage() }
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(tc.textSecondary)

                TextField("Caption (optional)", text: $caption)
                    .font(.system(size: 13, design: .serif))
                    .textFieldStyle(.plain)
                    .padding(8)
                    .background(tc.memoryTint)
                    .cornerRadius(4)
            } else {
                Button(action: pickImage) {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 32))
                            .foregroundColor(tc.textSecondary.opacity(0.4))
                        Text("Click to choose an image")
                            .font(.system(size: 12, design: .serif))
                            .foregroundColor(tc.textSecondary.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 140)
                    .background(tc.memoryTint)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(tc.borderInactive, style: StrokeStyle(lineWidth: 1, dash: [6]))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Actions

    private var canSave: Bool {
        switch memoryType {
        case .text:  return !text.trimmingCharacters(in: .whitespaces).isEmpty
        case .voice: return audio.recordedURL != nil
        case .image: return selectedImage != nil
        }
    }

    private func saveMemory() {
        let color = selectedColor.rawValue
        switch memoryType {
        case .text:
            store.addTextMemory(personID: person.id, text: text.trimmingCharacters(in: .whitespaces), color: color)
        case .voice:
            if let url = audio.recordedURL {
                store.saveVoiceMemory(personID: person.id, audioURL: url,
                                      caption: caption.trimmingCharacters(in: .whitespaces), color: color)
            }
        case .image:
            if let image = selectedImage {
                store.saveImageMemory(personID: person.id, image: image,
                                      caption: caption.trimmingCharacters(in: .whitespaces), color: color)
            }
        }
        audio.cleanup()
        dismiss()
    }

    private func pickImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK, let url = panel.url {
            selectedImage = NSImage(contentsOf: url)
        }
    }
}
