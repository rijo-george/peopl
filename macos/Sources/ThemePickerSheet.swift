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
                    .font(.headline)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
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
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
            .padding(.top, 4)
        }
        .padding(24)
        .frame(width: 500)
        .focusable()
        .onKeyPress(characters: CharacterSet(charactersIn: "123456")) { press in
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
            // Mini preview
            HStack(spacing: 2) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(tc.listBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3).stroke(tc.listAccent, lineWidth: 1)
                    )
                    .frame(height: 40)
                    .overlay(
                        VStack(spacing: 3) {
                            Image(systemName: "sun.max.fill").font(.system(size: 7))
                                .foregroundColor(Color(r: 1.0, g: 0.85, b: 0.2))
                            Image(systemName: "cloud.bolt.fill").font(.system(size: 7))
                                .foregroundColor(Color(r: 0.55, g: 0.3, b: 0.75))
                        }
                    )
                RoundedRectangle(cornerRadius: 3)
                    .fill(tc.detailBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3).stroke(tc.detailAccent, lineWidth: 1)
                    )
                    .frame(height: 40)
                    .overlay(
                        VStack(spacing: 2) {
                            Circle().fill(tc.detailAccent.opacity(0.3)).frame(width: 12, height: 12)
                            RoundedRectangle(cornerRadius: 1)
                                .fill(tc.textSecondary.opacity(0.3))
                                .frame(width: 20, height: 3)
                        }
                    )
            }
            .padding(6)
            .background(tc.bg)
            .cornerRadius(6)

            HStack(spacing: 4) {
                Image(systemName: themeName.icon)
                    .font(.system(size: 11))
                if !shortcutKey.isEmpty {
                    Text(shortcutKey)
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                Text(themeName.displayName)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(isSelected ? tc.accent : .secondary)
        }
        .padding(8)
        .background(isSelected ? tc.accent.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? tc.accent : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
        )
    }
}
