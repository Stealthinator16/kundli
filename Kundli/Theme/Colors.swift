import SwiftUI

extension Color {
    // Primary Colors
    static let kundliPrimary = Color(hex: "f4c025")          // Gold
    static let kundliPrimaryDark = Color(hex: "d4a520")      // Darker gold

    // Background Colors - Static (for backward compatibility)
    static let kundliBackground = Color(hex: "221e10")       // Dark brown
    static let kundliBackgroundLight = Color(hex: "f8f8f5")  // Light mode background
    static let kundliCardBg = Color(hex: "342d18")           // Card background
    static let kundliCardBgLight = Color(hex: "ffffff")      // Light card background

    // Text Colors - Static
    static let kundliTextPrimary = Color(hex: "ffffff")      // White text
    static let kundliTextSecondary = Color(hex: "cbbc90")    // Muted gold text
    static let kundliTextTertiary = Color(hex: "8a7d5a")     // Even more muted text
    static let kundliTextDark = Color(hex: "1a1a1a")         // Dark text

    // Status Colors
    static let kundliSuccess = Color(hex: "4ade80")          // Green
    static let kundliWarning = Color(hex: "fbbf24")          // Yellow/Orange
    static let kundliError = Color(hex: "ef4444")            // Red
    static let kundliInfo = Color(hex: "60a5fa")             // Blue

    // Chart Colors
    static let kundliChartBorder = Color(hex: "f4c025")      // Gold border
    static let kundliChartLine = Color(hex: "f4c025").opacity(0.6)

    // Gradient Colors
    static let kundliGradientStart = Color(hex: "f4c025")
    static let kundliGradientEnd = Color(hex: "d4a520")

    // MARK: - Adaptive Colors (Light/Dark mode aware)

    /// Adaptive background color
    static func adaptiveBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? kundliBackground : kundliBackgroundLight
    }

    /// Adaptive card background color
    static func adaptiveCardBg(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? kundliCardBg : kundliCardBgLight
    }

    /// Adaptive primary text color
    static func adaptiveTextPrimary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? kundliTextPrimary : kundliTextDark
    }

    /// Adaptive secondary text color
    static func adaptiveTextSecondary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? kundliTextSecondary : Color(hex: "6b5c3a")
    }

    /// Adaptive tertiary text color
    static func adaptiveTextTertiary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? kundliTextTertiary : Color(hex: "9a8b6a")
    }

    /// Adaptive chart border color
    static func adaptiveChartBorder(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? kundliChartBorder : Color(hex: "c9a020")
    }

    /// Adaptive divider color
    static func adaptiveDivider(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1)
    }

    // Light mode specific colors
    static let kundliLightTextSecondary = Color(hex: "6b5c3a")
    static let kundliLightTextTertiary = Color(hex: "9a8b6a")
    static let kundliLightChartBorder = Color(hex: "c9a020")

    // Initialize from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Color associated with a Vedic astrology planet
    static func forPlanet(_ name: String) -> Color {
        switch name.lowercased() {
        case "sun": return .orange
        case "moon": return .white
        case "mars": return .red
        case "mercury": return .green
        case "jupiter": return .yellow
        case "venus": return .pink
        case "saturn": return .blue
        case "rahu": return .purple
        case "ketu": return .brown
        default: return .kundliPrimary
        }
    }
}

// MARK: - Gradients
extension LinearGradient {
    static let kundliGold = LinearGradient(
        colors: [.kundliGradientStart, .kundliGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let kundliBackground = LinearGradient(
        colors: [Color(hex: "2a2515"), Color(hex: "221e10")],
        startPoint: .top,
        endPoint: .bottom
    )

    static let kundliCard = LinearGradient(
        colors: [Color(hex: "3d3520"), Color(hex: "342d18")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
