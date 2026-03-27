import SwiftUI

@Observable
final class AppearanceManager {
    static let shared = AppearanceManager()

    var theme: AppTheme {
        didSet {
            UserDefaults.standard.set(theme.rawValue, forKey: "app_theme")
        }
    }

    private init() {
        let storedTheme = UserDefaults.standard.string(forKey: "app_theme") ?? AppTheme.classic.rawValue
        self.theme = AppTheme(rawValue: storedTheme) ?? .classic
    }
}

nonisolated enum AppTheme: String, CaseIterable, Sendable {
    case classic = "Classic"
    case sand = "Sand"
    case rose = "Rosé"
    case noir = "Noir"
    case sage = "Sage"

    var colorScheme: ColorScheme? {
        switch self {
        case .classic: return nil
        case .sand: return .light
        case .rose: return .light
        case .noir: return .dark
        case .sage: return .light
        }
    }

    var tintColor: Color {
        switch self {
        case .classic: return .blue
        case .sand: return Color(red: 0.72, green: 0.58, blue: 0.42)
        case .rose: return Color(red: 0.76, green: 0.42, blue: 0.48)
        case .noir: return Color(red: 0.82, green: 0.76, blue: 0.68)
        case .sage: return Color(red: 0.45, green: 0.58, blue: 0.42)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .classic: return Color(.systemGroupedBackground)
        case .sand: return Color(red: 0.96, green: 0.93, blue: 0.88)
        case .rose: return Color(red: 0.97, green: 0.92, blue: 0.93)
        case .noir: return Color(red: 0.08, green: 0.08, blue: 0.09)
        case .sage: return Color(red: 0.93, green: 0.96, blue: 0.92)
        }
    }

    var cardColor: Color {
        switch self {
        case .classic: return Color(.secondarySystemGroupedBackground)
        case .sand: return Color(red: 1.0, green: 0.97, blue: 0.93)
        case .rose: return Color(red: 1.0, green: 0.96, blue: 0.97)
        case .noir: return Color(red: 0.14, green: 0.14, blue: 0.16)
        case .sage: return Color(red: 0.97, green: 0.99, blue: 0.96)
        }
    }

    var chipColor: Color {
        switch self {
        case .classic: return Color(.tertiarySystemBackground)
        case .sand: return Color(red: 0.92, green: 0.88, blue: 0.82)
        case .rose: return Color(red: 0.94, green: 0.88, blue: 0.90)
        case .noir: return Color(red: 0.20, green: 0.20, blue: 0.22)
        case .sage: return Color(red: 0.88, green: 0.92, blue: 0.87)
        }
    }

    var icon: String {
        switch self {
        case .classic: return "drop.fill"
        case .sand: return "sun.haze.fill"
        case .rose: return "leaf.fill"
        case .noir: return "moon.stars.fill"
        case .sage: return "tree.fill"
        }
    }

    var previewColors: [Color] {
        switch self {
        case .classic: return [.blue, .blue.opacity(0.6)]
        case .sand: return [Color(red: 0.76, green: 0.64, blue: 0.50), Color(red: 0.87, green: 0.78, blue: 0.66)]
        case .rose: return [Color(red: 0.78, green: 0.50, blue: 0.52), Color(red: 0.90, green: 0.70, blue: 0.72)]
        case .noir: return [Color(red: 0.30, green: 0.28, blue: 0.26), Color(red: 0.50, green: 0.47, blue: 0.44)]
        case .sage: return [Color(red: 0.55, green: 0.65, blue: 0.52), Color(red: 0.72, green: 0.80, blue: 0.68)]
        }
    }
}
