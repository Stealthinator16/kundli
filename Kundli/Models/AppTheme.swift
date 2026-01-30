import SwiftUI

/// App theme options for appearance customization
enum AppTheme: String, CaseIterable, Codable {
    case dark = "Dark"
    case light = "Light"
    case system = "System"

    var description: String {
        switch self {
        case .dark: return "Always use dark mode"
        case .light: return "Always use light mode"
        case .system: return "Follow system settings"
        }
    }

    var icon: String {
        switch self {
        case .dark: return "moon.fill"
        case .light: return "sun.max.fill"
        case .system: return "iphone"
        }
    }

    /// Convert to SwiftUI ColorScheme
    var colorScheme: ColorScheme? {
        switch self {
        case .dark: return .dark
        case .light: return .light
        case .system: return nil // nil means follow system
        }
    }
}
