import Foundation

/// Represents data for a divisional chart (Varga)
struct DivisionalChartData: Identifiable, Codable {
    let id: UUID
    let chartType: DivisionalChart
    let ascendantSign: Int          // 0-11 index
    let ascendantDegree: Double     // Degree within sign (0-30)
    let planetPositions: [DivisionalPlanetPosition]

    init(
        id: UUID = UUID(),
        chartType: DivisionalChart,
        ascendantSign: Int,
        ascendantDegree: Double,
        planetPositions: [DivisionalPlanetPosition]
    ) {
        self.id = id
        self.chartType = chartType
        self.ascendantSign = ascendantSign
        self.ascendantDegree = ascendantDegree
        self.planetPositions = planetPositions
    }

    /// Get house number for a planet (1-12, where 1 is ascendant sign)
    func house(for planet: VedicPlanet) -> Int? {
        guard let position = planetPositions.first(where: { $0.planet == planet }) else {
            return nil
        }
        let houseIndex = (position.signIndex - ascendantSign + 12) % 12
        return houseIndex + 1
    }

    /// Get all planets in a specific house
    func planets(inHouse house: Int) -> [VedicPlanet] {
        let targetSignIndex = (ascendantSign + house - 1) % 12
        return planetPositions
            .filter { $0.signIndex == targetSignIndex }
            .map { $0.planet }
    }
}

/// Position of a planet in a divisional chart
struct DivisionalPlanetPosition: Codable, Equatable {
    let planet: VedicPlanet
    let signIndex: Int           // 0-11 (Aries = 0)
    let degreeInSign: Double     // 0-30

    var sign: ZodiacSign {
        ZodiacSign.allCases[signIndex]
    }
}

// MARK: - Divisional Chart Types
enum DivisionalChart: String, Codable, CaseIterable {
    case d1 = "D-1"    // Rashi (Main birth chart)
    case d2 = "D-2"    // Hora (Wealth)
    case d3 = "D-3"    // Drekkana (Siblings)
    case d4 = "D-4"    // Chaturthamsa (Fortune, Property)
    case d7 = "D-7"    // Saptamsa (Children)
    case d9 = "D-9"    // Navamsa (Marriage, Dharma) - Most important
    case d10 = "D-10"  // Dasamsa (Career)
    case d12 = "D-12"  // Dwadasamsa (Parents)
    case d16 = "D-16"  // Shodasamsa (Vehicles, Luxuries)
    case d20 = "D-20"  // Vimshamsa (Spiritual progress)
    case d24 = "D-24"  // Chaturvimshamsa (Education)
    case d27 = "D-27"  // Bhamsa (Strengths, Weaknesses)
    case d30 = "D-30"  // Trimshamsa (Misfortunes, Evils)
    case d40 = "D-40"  // Khavedamsa (Auspicious/Inauspicious effects)
    case d45 = "D-45"  // Akshavedamsa (Character, General well-being)
    case d60 = "D-60"  // Shashtiamsa (Past life karma, Destiny)

    var division: Int {
        switch self {
        case .d1: return 1
        case .d2: return 2
        case .d3: return 3
        case .d4: return 4
        case .d7: return 7
        case .d9: return 9
        case .d10: return 10
        case .d12: return 12
        case .d16: return 16
        case .d20: return 20
        case .d24: return 24
        case .d27: return 27
        case .d30: return 30
        case .d40: return 40
        case .d45: return 45
        case .d60: return 60
        }
    }

    var fullName: String {
        switch self {
        case .d1: return "Rashi"
        case .d2: return "Hora"
        case .d3: return "Drekkana"
        case .d4: return "Chaturthamsa"
        case .d7: return "Saptamsa"
        case .d9: return "Navamsa"
        case .d10: return "Dasamsa"
        case .d12: return "Dwadasamsa"
        case .d16: return "Shodasamsa"
        case .d20: return "Vimshamsa"
        case .d24: return "Chaturvimshamsa"
        case .d27: return "Bhamsa"
        case .d30: return "Trimshamsa"
        case .d40: return "Khavedamsa"
        case .d45: return "Akshavedamsa"
        case .d60: return "Shashtiamsa"
        }
    }

    var significance: String {
        switch self {
        case .d1: return "Overall life, Physical body, General indications"
        case .d2: return "Wealth, Financial prosperity"
        case .d3: return "Siblings, Courage, Short journeys"
        case .d4: return "Fortune, Property, Fixed assets"
        case .d7: return "Children, Progeny"
        case .d9: return "Marriage, Spouse, Dharma, Overall fortune"
        case .d10: return "Career, Profession, Status"
        case .d12: return "Parents, Lineage"
        case .d16: return "Vehicles, Comforts, Luxuries"
        case .d20: return "Spiritual advancement, Religious activities"
        case .d24: return "Education, Learning, Academic success"
        case .d27: return "Strengths, General abilities"
        case .d30: return "Evils, Misfortunes, Difficulties"
        case .d40: return "Auspicious and inauspicious effects"
        case .d45: return "General well-being, Character"
        case .d60: return "Past life karma, Ultimate destiny"
        }
    }

    var importance: ChartImportance {
        switch self {
        case .d1: return .essential
        case .d9: return .essential
        case .d10: return .primary
        case .d2, .d3, .d7, .d12: return .secondary
        default: return .tertiary
        }
    }

    /// Alias for fullName for compatibility
    var name: String {
        fullName
    }

    /// Alias for significance for compatibility
    var description: String {
        significance
    }
}

enum ChartImportance: String, Codable {
    case essential = "Essential"     // Must analyze (D1, D9)
    case primary = "Primary"         // Important for specific matters (D10)
    case secondary = "Secondary"     // Useful supplementary (D2, D3, D7, D12)
    case tertiary = "Tertiary"       // Detailed analysis
}
