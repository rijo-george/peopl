import SwiftUI

struct NudgeCard: View {
    @EnvironmentObject var store: PeoplStore
    @EnvironmentObject var theme: ThemeManager
    let nudge: (person: Person, daysSince: Int, lastSnippet: String?)?
    var onOpen: (Person) -> Void
    var onSkip: () -> Void

    private var tc: ThemeColors { theme.colors }

    var body: some View {
        if let nudge {
            nudgeContent(nudge)
        } else {
            caughtUpContent
        }
    }

    // MARK: - Nudge variant

    private func nudgeContent(_ nudge: (person: Person, daysSince: Int, lastSnippet: String?)) -> some View {
        let weather = store.weather(for: nudge.person.id)
        let isUrgent = weather >= .rainy

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                // Initials circle
                ZStack {
                    let wc = weather.colorRGB
                    Circle()
                        .fill(Color(red: wc.r, green: wc.g, blue: wc.b).opacity(0.2))
                        .frame(width: 52, height: 52)
                    Text(nudge.person.displayInitials)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(Color(red: wc.r, green: wc.g, blue: wc.b))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("It's been \(nudge.daysSince) days since you talked to \(nudge.person.name).")
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .foregroundColor(tc.textPrimary)

                    if let snippet = nudge.lastSnippet, !snippet.isEmpty {
                        Text(snippet)
                            .font(.system(size: 12, design: .serif))
                            .foregroundColor(tc.textSecondary)
                            .italic()
                            .lineLimit(2)
                    }
                }

                Spacer()
            }

            // Action pills
            HStack(spacing: 8) {
                if !nudge.person.phone.isEmpty {
                    Link(destination: URL(string: "tel:\(nudge.person.phone)")!) {
                        actionPill(icon: "phone.fill", label: "Call")
                    }
                    Link(destination: URL(string: "sms:\(nudge.person.phone)")!) {
                        actionPill(icon: "message.fill", label: "Text")
                    }
                }

                Button(action: { onOpen(nudge.person) }) {
                    actionPill(icon: "book.fill", label: "Open")
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: onSkip) {
                    Text("Skip")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(tc.textSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(tc.surface.opacity(0.5))
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [
                    isUrgent ? tc.urgencyGlow.opacity(0.15) : tc.nudgeGradientStart.opacity(0.2),
                    tc.nudgeGradientEnd.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .background(tc.cardBg)
        )
        .cornerRadius(12)
        .shadow(color: tc.shadowWarm, radius: 8, y: 4)
    }

    // MARK: - All caught up variant

    private var caughtUpContent: some View {
        HStack(spacing: 10) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 22))
                .foregroundColor(Color(r: 1.0, g: 0.85, b: 0.2))
            Text("All caught up. Your relationships are thriving.")
                .font(.system(size: 14, design: .serif))
                .foregroundColor(tc.textSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tc.cardBg.opacity(0.6))
        .cornerRadius(12)
    }

    // MARK: - Helpers

    private func actionPill(icon: String, label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(label)
                .font(.system(size: 11, design: .monospaced))
        }
        .foregroundColor(tc.warmAccent)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(tc.warmAccent.opacity(0.1))
        .cornerRadius(14)
    }
}
