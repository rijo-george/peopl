import SwiftUI

struct ThemePickerSheet: View {
    @EnvironmentObject var theme: ThemeManager
    @Environment(\.dismiss) var dismiss

    private let allThemes = ThemeName.allCases

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "paintpalette.fill")
                    .foregroundColor(theme.colors.accent)
                Text("Choose Theme")
                    .font(.system(size: 16, weight: .semibold, design: .serif))
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 12)], spacing: 12) {
                ForEach(Array(allThemes.enumerated()), id: \.element.id) { index, t in
                    ThemeCard(themeName: t, isSelected: theme.current == t, shortcutKey: "\(index + 1)")
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                theme.current = t
                            }
                        }
                }
            }

            HStack {
                Text("Press 1-\(allThemes.count) to pick, Enter to close")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
            .padding(.top, 4)
        }
        .padding(24)
        .frame(width: 520)
        .focusable()
        .onKeyPress(characters: CharacterSet(charactersIn: "1234567")) { press in
            if let digit = press.characters.first?.wholeNumberValue,
               digit >= 1, digit <= allThemes.count {
                withAnimation(.easeInOut(duration: 0.2)) {
                    theme.current = allThemes[digit - 1]
                }
                return .handled
            }
            return .ignored
        }
        .onKeyPress(.leftArrow) { cycleTheme(-1); return .handled }
        .onKeyPress(.rightArrow) { cycleTheme(1); return .handled }
    }

    private func cycleTheme(_ delta: Int) {
        guard let idx = allThemes.firstIndex(of: theme.current) else { return }
        let newIdx = (idx + delta + allThemes.count) % allThemes.count
        withAnimation(.easeInOut(duration: 0.2)) {
            theme.current = allThemes[newIdx]
        }
    }
}

struct ThemeCard: View {
    let themeName: ThemeName
    let isSelected: Bool
    var shortcutKey: String = ""

    private var tc: ThemeColors { themeName.colors }

    var body: some View {
        VStack(spacing: 6) {
            // Mini preview: wall + journal feel
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(tc.bg)
                    .frame(height: 50)

                HStack(spacing: 4) {
                    // Mini cards
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(tc.cardBg)
                            .frame(width: 18, height: 20)
                            .shadow(color: tc.cardShadow, radius: 1, y: 1)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(tc.cardBg)
                            .frame(width: 18, height: 20)
                            .shadow(color: tc.cardShadow, radius: 1, y: 1)
                    }
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(tc.cardBg)
                            .frame(width: 18, height: 20)
                            .shadow(color: tc.cardShadow, radius: 1, y: 1)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(tc.cardBg)
                            .frame(width: 18, height: 20)
                            .shadow(color: tc.cardShadow, radius: 1, y: 1)
                    }

                    // Mini journal
                    RoundedRectangle(cornerRadius: 3)
                        .fill(tc.journalBg)
                        .frame(width: 30, height: 42)
                        .overlay(
                            VStack(spacing: 2) {
                                Circle().fill(tc.warmAccent.opacity(0.3)).frame(width: 8, height: 8)
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(tc.textSecondary.opacity(0.2))
                                    .frame(width: 16, height: 2)
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(tc.textSecondary.opacity(0.15))
                                    .frame(width: 12, height: 2)
                            }
                        )
                }
            }
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? tc.accent : Color.clear, lineWidth: 1.5)
            )

            HStack(spacing: 3) {
                Image(systemName: themeName.icon)
                    .font(.system(size: 10))
                if !shortcutKey.isEmpty {
                    Text(shortcutKey)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                Text(themeName.displayName)
                    .font(.system(size: 11, weight: .medium, design: .serif))
            }
            .foregroundColor(isSelected ? tc.accent : .secondary)
        }
        .padding(8)
        .background(isSelected ? tc.accent.opacity(0.08) : Color.clear)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? tc.accent.opacity(0.5) : Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
}
