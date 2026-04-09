import SwiftUI

// MARK: - Theme definitions

struct ThemeColors {
    let bg: Color
    let surface: Color
    let headerBg: Color
    let statusBarBg: Color

    let listAccent: Color
    let listBg: Color
    let detailAccent: Color
    let detailBg: Color

    let textPrimary: Color
    let textSecondary: Color

    let accent: Color
    let selectedBg: Color
    let borderActive: Color
    let borderInactive: Color

    let modalBg: Color
    let modalTitle: Color

    // New: card & journal
    let cardBg: Color
    let cardShadow: Color
    let journalBg: Color
    let warmAccent: Color
    let memoryTint: Color

    // v3: Living Memory Box
    let grainOpacity: Double
    let shadowWarm: Color
    let nudgeGradientStart: Color
    let nudgeGradientEnd: Color
    let urgencyGlow: Color
    let captureBarBg: Color
    let surfacedMemoryBg: Color
}

enum ThemeName: String, CaseIterable, Identifiable {
    case journal, dark, light, sunset, ocean, forest, rose

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .journal: return "Journal"
        case .dark:    return "Dark"
        case .light:   return "Light"
        case .sunset:  return "Sunset"
        case .ocean:   return "Ocean"
        case .forest:  return "Forest"
        case .rose:    return "Rose"
        }
    }

    var icon: String {
        switch self {
        case .journal: return "book.fill"
        case .dark:    return "moon.fill"
        case .light:   return "sun.max.fill"
        case .sunset:  return "sunset.fill"
        case .ocean:   return "water.waves"
        case .forest:  return "leaf.fill"
        case .rose:    return "camera.macro"
        }
    }

    var colors: ThemeColors {
        switch self {
        case .journal:
            return ThemeColors(
                bg:             Color(r: 0.96, g: 0.93, b: 0.88),
                surface:        Color(r: 0.98, g: 0.96, b: 0.92),
                headerBg:       Color(r: 0.93, g: 0.88, b: 0.80),
                statusBarBg:    Color(r: 0.90, g: 0.85, b: 0.77),
                listAccent:     Color(r: 0.75, g: 0.50, b: 0.20),
                listBg:         Color(r: 0.95, g: 0.91, b: 0.85),
                detailAccent:   Color(r: 0.60, g: 0.35, b: 0.15),
                detailBg:       Color(r: 0.97, g: 0.94, b: 0.89),
                textPrimary:    Color(r: 0.20, g: 0.15, b: 0.10),
                textSecondary:  Color(r: 0.50, g: 0.43, b: 0.35),
                accent:         Color(r: 0.85, g: 0.45, b: 0.15),
                selectedBg:     Color(r: 0.92, g: 0.87, b: 0.78),
                borderActive:   Color(r: 0.85, g: 0.45, b: 0.15),
                borderInactive: Color(r: 0.85, g: 0.80, b: 0.72),
                modalBg:        Color(r: 0.97, g: 0.94, b: 0.89),
                modalTitle:     Color(r: 0.60, g: 0.35, b: 0.15),
                cardBg:         Color(r: 0.99, g: 0.97, b: 0.94),
                cardShadow:     Color(r: 0.40, g: 0.30, b: 0.20).opacity(0.12),
                journalBg:      Color(r: 0.97, g: 0.94, b: 0.89),
                warmAccent:     Color(r: 0.85, g: 0.45, b: 0.15),
                memoryTint:     Color(r: 0.95, g: 0.90, b: 0.82),
                grainOpacity:   0.04,
                shadowWarm:     Color(r: 0.40, g: 0.28, b: 0.15).opacity(0.15),
                nudgeGradientStart: Color(r: 0.95, g: 0.75, b: 0.45),
                nudgeGradientEnd:   Color(r: 0.96, g: 0.93, b: 0.88),
                urgencyGlow:    Color(r: 0.85, g: 0.35, b: 0.45),
                captureBarBg:   Color(r: 0.94, g: 0.90, b: 0.84),
                surfacedMemoryBg: Color(r: 0.97, g: 0.93, b: 0.86)
            )

        case .dark:
            return ThemeColors(
                bg:             Color(r: 0.11, g: 0.11, b: 0.14),
                surface:        Color(r: 0.14, g: 0.14, b: 0.18),
                headerBg:       Color(r: 0.10, g: 0.10, b: 0.14),
                statusBarBg:    Color(r: 0.07, g: 0.07, b: 0.10),
                listAccent:     Color(r: 0.90, g: 0.65, b: 0.35),
                listBg:         Color(r: 0.13, g: 0.12, b: 0.16),
                detailAccent:   Color(r: 0.85, g: 0.55, b: 0.25),
                detailBg:       Color(r: 0.15, g: 0.14, b: 0.19),
                textPrimary:    Color(r: 0.92, g: 0.88, b: 0.82),
                textSecondary:  Color(r: 0.55, g: 0.50, b: 0.45),
                accent:         Color(r: 0.90, g: 0.50, b: 0.18),
                selectedBg:     Color(r: 0.20, g: 0.18, b: 0.22),
                borderActive:   Color(r: 0.90, g: 0.50, b: 0.18),
                borderInactive: Color.gray.opacity(0.25),
                modalBg:        Color(r: 0.12, g: 0.12, b: 0.16),
                modalTitle:     Color(r: 0.90, g: 0.65, b: 0.35),
                cardBg:         Color(r: 0.16, g: 0.15, b: 0.20),
                cardShadow:     Color.black.opacity(0.3),
                journalBg:      Color(r: 0.13, g: 0.13, b: 0.17),
                warmAccent:     Color(r: 0.90, g: 0.50, b: 0.18),
                memoryTint:     Color(r: 0.18, g: 0.17, b: 0.22),
                grainOpacity:   0.03,
                shadowWarm:     Color(r: 0.10, g: 0.08, b: 0.05).opacity(0.3),
                nudgeGradientStart: Color(r: 0.90, g: 0.55, b: 0.20),
                nudgeGradientEnd:   Color(r: 0.14, g: 0.14, b: 0.18),
                urgencyGlow:    Color(r: 0.80, g: 0.30, b: 0.50),
                captureBarBg:   Color(r: 0.16, g: 0.15, b: 0.20),
                surfacedMemoryBg: Color(r: 0.20, g: 0.18, b: 0.25)
            )

        case .light:
            return ThemeColors(
                bg:             Color(r: 0.97, g: 0.97, b: 0.98),
                surface:        .white,
                headerBg:       Color(r: 0.95, g: 0.95, b: 0.96),
                statusBarBg:    Color(r: 0.93, g: 0.93, b: 0.94),
                listAccent:     Color(r: 0.70, g: 0.40, b: 0.15),
                listBg:         Color(r: 0.96, g: 0.96, b: 0.97),
                detailAccent:   Color(r: 0.55, g: 0.30, b: 0.10),
                detailBg:       Color(r: 0.98, g: 0.98, b: 0.99),
                textPrimary:    Color(r: 0.15, g: 0.13, b: 0.10),
                textSecondary:  Color(r: 0.50, g: 0.48, b: 0.45),
                accent:         Color(r: 0.80, g: 0.42, b: 0.12),
                selectedBg:     Color(r: 0.93, g: 0.91, b: 0.88),
                borderActive:   Color(r: 0.80, g: 0.42, b: 0.12),
                borderInactive: Color.gray.opacity(0.2),
                modalBg:        .white,
                modalTitle:     Color(r: 0.55, g: 0.30, b: 0.10),
                cardBg:         .white,
                cardShadow:     Color.black.opacity(0.08),
                journalBg:      Color(r: 0.98, g: 0.97, b: 0.96),
                warmAccent:     Color(r: 0.80, g: 0.42, b: 0.12),
                memoryTint:     Color(r: 0.96, g: 0.95, b: 0.93),
                grainOpacity:   0.03,
                shadowWarm:     Color(r: 0.35, g: 0.25, b: 0.15).opacity(0.10),
                nudgeGradientStart: Color(r: 0.90, g: 0.65, b: 0.30),
                nudgeGradientEnd:   Color(r: 0.97, g: 0.97, b: 0.98),
                urgencyGlow:    Color(r: 0.80, g: 0.35, b: 0.45),
                captureBarBg:   Color(r: 0.95, g: 0.94, b: 0.93),
                surfacedMemoryBg: Color(r: 0.96, g: 0.94, b: 0.91)
            )

        case .sunset:
            return ThemeColors(
                bg:             Color(r: 0.15, g: 0.10, b: 0.10),
                surface:        Color(r: 0.18, g: 0.12, b: 0.12),
                headerBg:       Color(r: 0.20, g: 0.10, b: 0.08),
                statusBarBg:    Color(r: 0.12, g: 0.07, b: 0.07),
                listAccent:     Color(r: 1.00, g: 0.75, b: 0.30),
                listBg:         Color(r: 0.20, g: 0.14, b: 0.12),
                detailAccent:   Color(r: 1.00, g: 0.55, b: 0.30),
                detailBg:       Color(r: 0.22, g: 0.12, b: 0.10),
                textPrimary:    Color(r: 1.00, g: 0.95, b: 0.90),
                textSecondary:  Color(r: 0.60, g: 0.50, b: 0.45),
                accent:         Color(r: 1.00, g: 0.55, b: 0.20),
                selectedBg:     Color(r: 0.28, g: 0.18, b: 0.14),
                borderActive:   Color(r: 1.00, g: 0.55, b: 0.20),
                borderInactive: Color(r: 0.35, g: 0.25, b: 0.20),
                modalBg:        Color(r: 0.20, g: 0.12, b: 0.10),
                modalTitle:     Color(r: 1.00, g: 0.75, b: 0.40),
                cardBg:         Color(r: 0.22, g: 0.15, b: 0.13),
                cardShadow:     Color.black.opacity(0.3),
                journalBg:      Color(r: 0.18, g: 0.12, b: 0.10),
                warmAccent:     Color(r: 1.00, g: 0.55, b: 0.20),
                memoryTint:     Color(r: 0.25, g: 0.18, b: 0.14),
                grainOpacity:   0.05,
                shadowWarm:     Color(r: 0.08, g: 0.05, b: 0.02).opacity(0.35),
                nudgeGradientStart: Color(r: 1.00, g: 0.60, b: 0.25),
                nudgeGradientEnd:   Color(r: 0.18, g: 0.12, b: 0.12),
                urgencyGlow:    Color(r: 0.90, g: 0.30, b: 0.40),
                captureBarBg:   Color(r: 0.20, g: 0.14, b: 0.12),
                surfacedMemoryBg: Color(r: 0.25, g: 0.16, b: 0.14)
            )

        case .ocean:
            return ThemeColors(
                bg:             Color(r: 0.08, g: 0.12, b: 0.18),
                surface:        Color(r: 0.10, g: 0.15, b: 0.22),
                headerBg:       Color(r: 0.06, g: 0.10, b: 0.18),
                statusBarBg:    Color(r: 0.05, g: 0.08, b: 0.14),
                listAccent:     Color(r: 0.90, g: 0.65, b: 0.35),
                listBg:         Color(r: 0.09, g: 0.14, b: 0.20),
                detailAccent:   Color(r: 0.85, g: 0.55, b: 0.25),
                detailBg:       Color(r: 0.10, g: 0.15, b: 0.22),
                textPrimary:    Color(r: 0.90, g: 0.92, b: 0.95),
                textSecondary:  Color(r: 0.50, g: 0.55, b: 0.62),
                accent:         Color(r: 0.90, g: 0.55, b: 0.20),
                selectedBg:     Color(r: 0.12, g: 0.18, b: 0.28),
                borderActive:   Color(r: 0.90, g: 0.55, b: 0.20),
                borderInactive: Color(r: 0.20, g: 0.28, b: 0.38),
                modalBg:        Color(r: 0.08, g: 0.12, b: 0.20),
                modalTitle:     Color(r: 0.90, g: 0.65, b: 0.35),
                cardBg:         Color(r: 0.12, g: 0.17, b: 0.25),
                cardShadow:     Color.black.opacity(0.3),
                journalBg:      Color(r: 0.09, g: 0.14, b: 0.20),
                warmAccent:     Color(r: 0.90, g: 0.55, b: 0.20),
                memoryTint:     Color(r: 0.12, g: 0.18, b: 0.26),
                grainOpacity:   0.04,
                shadowWarm:     Color(r: 0.05, g: 0.08, b: 0.12).opacity(0.35),
                nudgeGradientStart: Color(r: 0.90, g: 0.60, b: 0.25),
                nudgeGradientEnd:   Color(r: 0.10, g: 0.15, b: 0.22),
                urgencyGlow:    Color(r: 0.75, g: 0.30, b: 0.55),
                captureBarBg:   Color(r: 0.12, g: 0.17, b: 0.25),
                surfacedMemoryBg: Color(r: 0.14, g: 0.20, b: 0.30)
            )

        case .forest:
            return ThemeColors(
                bg:             Color(r: 0.10, g: 0.14, b: 0.10),
                surface:        Color(r: 0.12, g: 0.18, b: 0.12),
                headerBg:       Color(r: 0.08, g: 0.14, b: 0.08),
                statusBarBg:    Color(r: 0.06, g: 0.10, b: 0.06),
                listAccent:     Color(r: 0.90, g: 0.70, b: 0.35),
                listBg:         Color(r: 0.11, g: 0.16, b: 0.11),
                detailAccent:   Color(r: 0.85, g: 0.60, b: 0.25),
                detailBg:       Color(r: 0.12, g: 0.18, b: 0.12),
                textPrimary:    Color(r: 0.92, g: 0.94, b: 0.88),
                textSecondary:  Color(r: 0.55, g: 0.58, b: 0.50),
                accent:         Color(r: 0.85, g: 0.55, b: 0.20),
                selectedBg:     Color(r: 0.15, g: 0.22, b: 0.15),
                borderActive:   Color(r: 0.85, g: 0.55, b: 0.20),
                borderInactive: Color(r: 0.22, g: 0.30, b: 0.22),
                modalBg:        Color(r: 0.10, g: 0.16, b: 0.10),
                modalTitle:     Color(r: 0.90, g: 0.70, b: 0.35),
                cardBg:         Color(r: 0.14, g: 0.20, b: 0.14),
                cardShadow:     Color.black.opacity(0.25),
                journalBg:      Color(r: 0.11, g: 0.16, b: 0.11),
                warmAccent:     Color(r: 0.85, g: 0.55, b: 0.20),
                memoryTint:     Color(r: 0.15, g: 0.22, b: 0.15),
                grainOpacity:   0.05,
                shadowWarm:     Color(r: 0.06, g: 0.08, b: 0.04).opacity(0.30),
                nudgeGradientStart: Color(r: 0.85, g: 0.60, b: 0.25),
                nudgeGradientEnd:   Color(r: 0.12, g: 0.18, b: 0.12),
                urgencyGlow:    Color(r: 0.75, g: 0.35, b: 0.45),
                captureBarBg:   Color(r: 0.14, g: 0.20, b: 0.14),
                surfacedMemoryBg: Color(r: 0.16, g: 0.24, b: 0.16)
            )

        case .rose:
            return ThemeColors(
                bg:             Color(r: 0.14, g: 0.10, b: 0.14),
                surface:        Color(r: 0.18, g: 0.12, b: 0.18),
                headerBg:       Color(r: 0.16, g: 0.08, b: 0.16),
                statusBarBg:    Color(r: 0.10, g: 0.06, b: 0.10),
                listAccent:     Color(r: 1.00, g: 0.65, b: 0.75),
                listBg:         Color(r: 0.16, g: 0.11, b: 0.16),
                detailAccent:   Color(r: 0.90, g: 0.50, b: 0.60),
                detailBg:       Color(r: 0.18, g: 0.12, b: 0.18),
                textPrimary:    Color(r: 0.96, g: 0.90, b: 0.92),
                textSecondary:  Color(r: 0.58, g: 0.48, b: 0.52),
                accent:         Color(r: 0.90, g: 0.45, b: 0.55),
                selectedBg:     Color(r: 0.22, g: 0.15, b: 0.22),
                borderActive:   Color(r: 0.90, g: 0.45, b: 0.55),
                borderInactive: Color(r: 0.30, g: 0.22, b: 0.28),
                modalBg:        Color(r: 0.16, g: 0.10, b: 0.16),
                modalTitle:     Color(r: 1.00, g: 0.65, b: 0.75),
                cardBg:         Color(r: 0.20, g: 0.14, b: 0.20),
                cardShadow:     Color.black.opacity(0.25),
                journalBg:      Color(r: 0.16, g: 0.11, b: 0.16),
                warmAccent:     Color(r: 0.90, g: 0.45, b: 0.55),
                memoryTint:     Color(r: 0.22, g: 0.15, b: 0.22),
                grainOpacity:   0.04,
                shadowWarm:     Color(r: 0.10, g: 0.05, b: 0.08).opacity(0.30),
                nudgeGradientStart: Color(r: 0.90, g: 0.50, b: 0.60),
                nudgeGradientEnd:   Color(r: 0.18, g: 0.12, b: 0.18),
                urgencyGlow:    Color(r: 0.85, g: 0.30, b: 0.50),
                captureBarBg:   Color(r: 0.20, g: 0.14, b: 0.20),
                surfacedMemoryBg: Color(r: 0.24, g: 0.16, b: 0.24)
            )
        }
    }
}

// MARK: - Color convenience

extension Color {
    init(r: Double, g: Double, b: Double) {
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Config persistence

struct AppConfig: Codable {
    var theme: String

    static var configFile: URL {
        StorageLocation.resolve().appendingPathComponent("config.json")
    }

    static func load() -> AppConfig {
        guard let raw = try? Data(contentsOf: configFile),
              let config = try? JSONDecoder().decode(AppConfig.self, from: raw)
        else { return AppConfig(theme: "journal") }
        return config
    }

    func save() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let raw = try? encoder.encode(self) else { return }
        try? raw.write(to: AppConfig.configFile, options: .atomic)
    }
}

// MARK: - Theme manager

class ThemeManager: ObservableObject {
    @Published var current: ThemeName {
        didSet {
            var config = AppConfig.load()
            config.theme = current.rawValue
            config.save()
        }
    }

    var colors: ThemeColors { current.colors }

    init() {
        let config = AppConfig.load()
        self.current = ThemeName(rawValue: config.theme) ?? .journal
    }
}
