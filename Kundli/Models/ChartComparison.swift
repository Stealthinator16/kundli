import Foundation

/// Model representing comparison between two charts (synastry)
struct ChartComparison: Identifiable {
    let id = UUID()
    let kundli1: Kundli
    let kundli2: Kundli
    let synastryAspects: [SynastryAspect]
    let compositeScore: Double
    let calculatedAt: Date

    init(
        kundli1: Kundli,
        kundli2: Kundli,
        synastryAspects: [SynastryAspect],
        compositeScore: Double
    ) {
        self.kundli1 = kundli1
        self.kundli2 = kundli2
        self.synastryAspects = synastryAspects
        self.compositeScore = compositeScore
        self.calculatedAt = Date()
    }

    /// Number of harmonious aspects
    var harmoniousAspects: Int {
        synastryAspects.filter { $0.nature == .harmonious }.count
    }

    /// Number of challenging aspects
    var challengingAspects: Int {
        synastryAspects.filter { $0.nature == .challenging }.count
    }

    /// Overall compatibility rating
    var compatibilityRating: CompatibilityRating {
        if compositeScore >= 80 { return .excellent }
        if compositeScore >= 65 { return .good }
        if compositeScore >= 50 { return .moderate }
        if compositeScore >= 35 { return .challenging }
        return .difficult
    }

    /// Get aspects for a specific planet from chart 1
    func aspectsFor(planet1: String) -> [SynastryAspect] {
        synastryAspects.filter { $0.planet1Name.lowercased() == planet1.lowercased() }
    }

    /// Get aspects to a specific planet in chart 2
    func aspectsTo(planet2: String) -> [SynastryAspect] {
        synastryAspects.filter { $0.planet2Name.lowercased() == planet2.lowercased() }
    }
}

// MARK: - Synastry Aspect

struct SynastryAspect: Identifiable {
    let id = UUID()
    let planet1Name: String
    let planet1Symbol: String
    let planet2Name: String
    let planet2Symbol: String
    let aspectType: TransitAspect
    let orb: Double
    let nature: AspectNature
    let interpretation: String

    init(
        planet1Name: String,
        planet1Symbol: String,
        planet2Name: String,
        planet2Symbol: String,
        aspectType: TransitAspect,
        orb: Double,
        interpretation: String = ""
    ) {
        self.planet1Name = planet1Name
        self.planet1Symbol = planet1Symbol
        self.planet2Name = planet2Name
        self.planet2Symbol = planet2Symbol
        self.aspectType = aspectType
        self.orb = orb
        self.nature = aspectType.nature
        self.interpretation = interpretation.isEmpty ? Self.defaultInterpretation(planet1: planet1Name, planet2: planet2Name, aspect: aspectType) : interpretation
    }

    var description: String {
        "\(planet1Symbol) \(aspectType.rawValue) \(planet2Symbol) (orb: \(String(format: "%.1f", orb))°)"
    }

    var shortDescription: String {
        "\(planet1Symbol) \(aspectSymbol) \(planet2Symbol)"
    }

    var aspectSymbol: String {
        switch aspectType {
        case .conjunction: return "☌"
        case .opposition: return "☍"
        case .trine: return "△"
        case .square: return "□"
        case .sextile: return "⚹"
        case .quincunx: return "⚻"
        }
    }

    /// Default interpretation based on planets and aspect
    private static func defaultInterpretation(planet1: String, planet2: String, aspect: TransitAspect) -> String {
        let p1 = planet1.lowercased()
        let p2 = planet2.lowercased()

        // Sun aspects
        if p1 == "sun" || p2 == "sun" {
            let other = p1 == "sun" ? p2 : p1
            switch aspect.nature {
            case .harmonious:
                return "The Sun-\(other.capitalized) connection brings vitality and harmony to the relationship in matters of \(planetDomain(other))."
            case .challenging:
                return "The Sun-\(other.capitalized) aspect may create tension around ego, identity and \(planetDomain(other))."
            default:
                return "The Sun-\(other.capitalized) connection influences identity and self-expression in the relationship."
            }
        }

        // Moon aspects
        if p1 == "moon" || p2 == "moon" {
            let other = p1 == "moon" ? p2 : p1
            switch aspect.nature {
            case .harmonious:
                return "The Moon-\(other.capitalized) connection creates emotional comfort and nurturing energy around \(planetDomain(other))."
            case .challenging:
                return "The Moon-\(other.capitalized) aspect may create emotional sensitivities related to \(planetDomain(other))."
            default:
                return "The Moon-\(other.capitalized) connection affects emotional dynamics in the relationship."
            }
        }

        // Venus aspects
        if p1 == "venus" || p2 == "venus" {
            switch aspect.nature {
            case .harmonious:
                return "Venus aspects bring love, affection, and romantic harmony to the relationship."
            case .challenging:
                return "Venus aspects may create challenges in expressing love and handling values differences."
            default:
                return "Venus influences love, beauty, and relationship values."
            }
        }

        // Mars aspects
        if p1 == "mars" || p2 == "mars" {
            switch aspect.nature {
            case .harmonious:
                return "Mars aspects bring passion, energy, and motivation to the relationship."
            case .challenging:
                return "Mars aspects may create conflicts, competition, or anger issues."
            default:
                return "Mars influences drive, passion, and physical energy in the relationship."
            }
        }

        // Default
        switch aspect.nature {
        case .harmonious:
            return "This harmonious aspect supports mutual understanding and cooperation."
        case .challenging:
            return "This challenging aspect requires patience and growth in the relationship."
        default:
            return "This aspect creates a connection between the two charts."
        }
    }

    private static func planetDomain(_ planet: String) -> String {
        switch planet.lowercased() {
        case "moon": return "emotions and nurturing"
        case "mars": return "action and desire"
        case "mercury": return "communication"
        case "jupiter": return "growth and optimism"
        case "venus": return "love and values"
        case "saturn": return "responsibility and commitment"
        case "rahu", "ketu": return "karmic patterns"
        default: return "life expression"
        }
    }
}

// MARK: - Compatibility Rating

enum CompatibilityRating: String {
    case excellent = "Excellent"
    case good = "Good"
    case moderate = "Moderate"
    case challenging = "Challenging"
    case difficult = "Difficult"

    var color: String {
        switch self {
        case .excellent: return "green"
        case .good: return "blue"
        case .moderate: return "yellow"
        case .challenging: return "orange"
        case .difficult: return "red"
        }
    }

    var description: String {
        switch self {
        case .excellent:
            return "Exceptional compatibility with strong harmonious connections"
        case .good:
            return "Solid compatibility with mostly supportive aspects"
        case .moderate:
            return "Balanced mix of harmonious and challenging aspects"
        case .challenging:
            return "Several challenging aspects requiring conscious effort"
        case .difficult:
            return "Many challenging aspects, relationship requires significant work"
        }
    }
}
