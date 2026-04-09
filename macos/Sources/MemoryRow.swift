import SwiftUI
import AVFoundation

struct MemoryRow: View {
    @EnvironmentObject var store: PeoplStore
    @EnvironmentObject var theme: ThemeManager
    let memory: Memory
    var onDelete: (() -> Void)?

    @State private var isHovered = false
    @StateObject private var audio = AudioRecorder()

    private var tc: ThemeColors { theme.colors }
    private var rotation: Double { stableRandom(from: memory.id, range: -1.5...1.5) }

    var body: some View {
        Group {
            switch memory.type {
            case "voice": voiceCard
            case "image": imageCard
            default:      textCard
            }
        }
        .onHover { isHovered = $0 }
    }

    // MARK: - Text Memory

    private var textCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(memory.text)
                .font(.system(size: 15, design: .serif))
                .foregroundColor(tc.textPrimary)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Spacer()
                Text(memory.relativeTime)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(tc.textSecondary.opacity(0.4))
                if isHovered, let onDelete {
                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(tc.textSecondary.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity)
                }
            }
        }
        .padding(16)
        .background(memoryColorBg)
        .cornerRadius(4)
        .shadow(color: tc.shadowWarm, radius: isHovered ? 8 : 3, y: isHovered ? 4 : 2)
        .rotationEffect(.degrees(isHovered ? 0 : rotation))
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
    }

    // MARK: - Voice Memory

    private var voiceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Play button
                Button(action: {
                    if let url = store.mediaURL(for: memory) {
                        audio.togglePlayback(url: url)
                    }
                }) {
                    Image(systemName: audio.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(tc.warmAccent)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 4) {
                    // Waveform
                    HStack(spacing: 2) {
                        ForEach(0..<24, id: \.self) { i in
                            let height = waveformHeight(index: i)
                            let progress = audio.isPlaying ? audio.playbackProgress : 0
                            let isPlayed = Double(i) / 24.0 < progress
                            RoundedRectangle(cornerRadius: 1)
                                .fill(isPlayed ? tc.warmAccent : tc.textSecondary.opacity(0.3))
                                .frame(width: 3, height: height)
                        }
                    }
                    .frame(height: 24)

                    // Duration
                    if audio.isPlaying {
                        Text(audio.formatTime(audio.playbackProgress * audio.playbackDuration))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(tc.textSecondary)
                    }
                }

                Spacer()
            }

            if !memory.text.isEmpty {
                Text(memory.text)
                    .font(.system(size: 13, design: .serif))
                    .foregroundColor(tc.textPrimary.opacity(0.8))
            }

            HStack {
                Spacer()
                Text(memory.relativeTime)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(tc.textSecondary.opacity(0.4))
                if isHovered, let onDelete {
                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(tc.textSecondary.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity)
                }
            }
        }
        .padding(16)
        .background(memoryColorBg)
        .cornerRadius(4)
        .shadow(color: tc.shadowWarm, radius: isHovered ? 8 : 3, y: isHovered ? 4 : 2)
        .rotationEffect(.degrees(isHovered ? 0 : rotation))
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
    }

    // MARK: - Image Memory

    private var imageCard: some View {
        VStack(spacing: 0) {
            // Polaroid image
            if let url = store.mediaURL(for: memory),
               let nsImage = NSImage(contentsOf: url) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 360, maxHeight: 280)
                    .clipped()
            } else {
                ZStack {
                    Rectangle().fill(tc.memoryTint)
                        .frame(height: 120)
                    VStack(spacing: 4) {
                        Image(systemName: "icloud.and.arrow.down")
                            .font(.system(size: 20))
                        Text("Syncing...")
                            .font(.system(size: 10, design: .monospaced))
                    }
                    .foregroundColor(tc.textSecondary.opacity(0.5))
                }
            }

            // Caption area (polaroid bottom)
            VStack(alignment: .leading, spacing: 4) {
                if !memory.text.isEmpty {
                    Text(memory.text)
                        .font(.system(size: 13, design: .serif))
                        .foregroundColor(tc.textPrimary.opacity(0.8))
                }
                HStack {
                    Spacer()
                    Text(memory.relativeTime)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(tc.textSecondary.opacity(0.4))
                    if isHovered, let onDelete {
                        Button(action: onDelete) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 11))
                                .foregroundColor(tc.textSecondary.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                        .transition(.opacity)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .padding(6)
        .background(tc.cardBg)
        .cornerRadius(4)
        .shadow(color: tc.shadowWarm, radius: isHovered ? 10 : 4, y: isHovered ? 5 : 2)
        .rotationEffect(.degrees(isHovered ? 0 : rotation))
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
    }

    // MARK: - Helpers

    private var memoryColorBg: Color {
        let mc = MemoryColor(rawValue: memory.color) ?? .plain
        if mc == .plain { return tc.cardBg }
        let c = mc.displayColor
        return Color(red: c.r, green: c.g, blue: c.b).opacity(c.a)
            .blending(with: tc.cardBg)
    }

    private func waveformHeight(index: Int) -> CGFloat {
        let hash = abs((memory.id + "\(index)").hashValue)
        let normalized = CGFloat(hash % 100) / 100.0
        return 4 + normalized * 20
    }
}

// MARK: - Color blending helper

extension Color {
    func blending(with other: Color) -> Color {
        // Simple approach: just return self as the tinted color
        // The opacity in displayColor handles the blending visually
        return self
    }
}
