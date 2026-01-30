import Foundation

/// Represents the Shadbala (six-fold strength) calculation for a planet
struct PlanetaryStrength: Identifiable, Codable {
    let id: UUID
    let planet: String
    let vedName: String

    // Individual Shadbala components (in Virupas, max 60 each)
    let sthanaBala: Double      // Positional strength
    let dikBala: Double         // Directional strength
    let kalaBala: Double        // Temporal strength
    let chestaBala: Double      // Motional strength
    let naisargikaBala: Double  // Natural strength
    let drigBala: Double        // Aspectual strength

    // Total and derived values
    let totalShadbala: Double   // Sum of all components
    let requiredStrength: Double // Minimum required for planet
    let strengthRatio: Double   // totalShadbala / requiredStrength

    init(
        id: UUID = UUID(),
        planet: String,
        vedName: String,
        sthanaBala: Double,
        dikBala: Double,
        kalaBala: Double,
        chestaBala: Double,
        naisargikaBala: Double,
        drigBala: Double,
        requiredStrength: Double
    ) {
        self.id = id
        self.planet = planet
        self.vedName = vedName
        self.sthanaBala = sthanaBala
        self.dikBala = dikBala
        self.kalaBala = kalaBala
        self.chestaBala = chestaBala
        self.naisargikaBala = naisargikaBala
        self.drigBala = drigBala
        self.requiredStrength = requiredStrength

        self.totalShadbala = sthanaBala + dikBala + kalaBala + chestaBala + naisargikaBala + drigBala
        self.strengthRatio = totalShadbala / requiredStrength
    }

    /// Strength level based on ratio to required strength
    var strengthLevel: StrengthLevel {
        switch strengthRatio {
        case 1.5...: return .veryStrong
        case 1.2..<1.5: return .strong
        case 0.8..<1.2: return .moderate
        case 0.5..<0.8: return .weak
        default: return .veryWeak
        }
    }

    /// Individual component strengths as array for display
    var components: [(name: String, value: Double, maxValue: Double)] {
        [
            ("Sthana Bala", sthanaBala, 60),
            ("Dik Bala", dikBala, 60),
            ("Kala Bala", kalaBala, 60),
            ("Chesta Bala", chestaBala, 60),
            ("Naisargika Bala", naisargikaBala, 60),
            ("Drig Bala", drigBala, 60)
        ]
    }

    /// Percentage of total possible strength (360 virupas max)
    var percentageStrength: Double {
        (totalShadbala / 360.0) * 100
    }
}

// MARK: - Strength Level
enum StrengthLevel: String, Codable {
    case veryStrong = "Very Strong"
    case strong = "Strong"
    case moderate = "Moderate"
    case weak = "Weak"
    case veryWeak = "Very Weak"

    var colorName: String {
        switch self {
        case .veryStrong: return "green"
        case .strong: return "blue"
        case .moderate: return "yellow"
        case .weak: return "orange"
        case .veryWeak: return "red"
        }
    }

    var description: String {
        switch self {
        case .veryStrong:
            return "Planet is exceptionally powerful and delivers excellent results"
        case .strong:
            return "Planet is well-placed and gives good results"
        case .moderate:
            return "Planet has average strength, results depend on other factors"
        case .weak:
            return "Planet is weak and may struggle to deliver positive results"
        case .veryWeak:
            return "Planet is very weak and needs remedies for improvement"
        }
    }
}

// MARK: - Shadbala Components Detail
struct ShadbalaComponent: Identifiable {
    let id = UUID()
    let name: String
    let sanskritName: String
    let value: Double
    let maxValue: Double
    let description: String
    let subComponents: [ShadbalaSubComponent]

    var percentage: Double {
        (value / maxValue) * 100
    }
}

struct ShadbalaSubComponent: Identifiable {
    let id = UUID()
    let name: String
    let value: Double
    let description: String
}

// MARK: - Required Strength Values (in Rupas)
extension PlanetaryStrength {
    /// Get minimum required Shadbala for each planet (in Rupas, 1 Rupa = 60 Virupas)
    static func requiredStrength(for planet: String) -> Double {
        switch planet.lowercased() {
        case "sun", "surya": return 390      // 6.5 Rupas
        case "moon", "chandra": return 360   // 6.0 Rupas
        case "mars", "mangal": return 300    // 5.0 Rupas
        case "mercury", "budha": return 420  // 7.0 Rupas
        case "jupiter", "guru": return 390   // 6.5 Rupas
        case "venus", "shukra": return 330   // 5.5 Rupas
        case "saturn", "shani": return 300   // 5.0 Rupas
        default: return 300
        }
    }
}

// MARK: - Shadbala Summary
struct ShadbalaSummary {
    let planetaryStrengths: [PlanetaryStrength]

    var strongestPlanet: PlanetaryStrength? {
        planetaryStrengths.max(by: { $0.strengthRatio < $1.strengthRatio })
    }

    var weakestPlanet: PlanetaryStrength? {
        planetaryStrengths.min(by: { $0.strengthRatio < $1.strengthRatio })
    }

    var strongPlanets: [PlanetaryStrength] {
        planetaryStrengths.filter { $0.strengthLevel == .strong || $0.strengthLevel == .veryStrong }
    }

    var weakPlanets: [PlanetaryStrength] {
        planetaryStrengths.filter { $0.strengthLevel == .weak || $0.strengthLevel == .veryWeak }
    }

    var averageStrengthRatio: Double {
        guard !planetaryStrengths.isEmpty else { return 0 }
        return planetaryStrengths.reduce(0) { $0 + $1.strengthRatio } / Double(planetaryStrengths.count)
    }
}
