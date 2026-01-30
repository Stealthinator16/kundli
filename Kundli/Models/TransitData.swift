import Foundation

/// Represents current planetary transit data
struct TransitData: Codable {
    let calculationDate: Date
    let transitPositions: [TransitPosition]
    let activeTransits: [ActiveTransit]
    let majorTransitPeriods: [MajorTransitPeriod]

    /// Get position for a specific planet
    func position(for planet: String) -> TransitPosition? {
        transitPositions.first { $0.planet.lowercased() == planet.lowercased() }
    }

    /// Get all active transits for a specific natal planet
    func transits(over natalPlanet: String) -> [ActiveTransit] {
        activeTransits.filter { $0.natalPlanet.lowercased() == natalPlanet.lowercased() }
    }

    /// Check if Saturn Sade-Sati is active
    var isSadeSatiActive: Bool {
        majorTransitPeriods.contains { $0.type == .sadeSati && $0.isCurrentlyActive }
    }

    /// Get current Sade-Sati phase if active
    var sadeSatiPhase: SadeSatiPhase? {
        majorTransitPeriods
            .first { $0.type == .sadeSati && $0.isCurrentlyActive }?
            .sadeSatiPhase
    }
}

// MARK: - Transit Position
struct TransitPosition: Identifiable, Codable {
    let id: UUID
    let planet: String
    let vedName: String
    let longitude: Double
    let signIndex: Int
    let signName: String
    let degreeInSign: Double
    let nakshatra: String
    let nakshatraPada: Int
    let isRetrograde: Bool

    init(
        id: UUID = UUID(),
        planet: String,
        vedName: String,
        longitude: Double,
        signIndex: Int,
        signName: String,
        degreeInSign: Double,
        nakshatra: String,
        nakshatraPada: Int,
        isRetrograde: Bool
    ) {
        self.id = id
        self.planet = planet
        self.vedName = vedName
        self.longitude = longitude
        self.signIndex = signIndex
        self.signName = signName
        self.degreeInSign = degreeInSign
        self.nakshatra = nakshatra
        self.nakshatraPada = nakshatraPada
        self.isRetrograde = isRetrograde
    }

    var formattedDegree: String {
        let deg = Int(degreeInSign)
        let min = Int((degreeInSign - Double(deg)) * 60)
        return "\(deg)° \(min)'"
    }
}

// MARK: - Active Transit
struct ActiveTransit: Identifiable, Codable {
    let id: UUID
    let transitingPlanet: String
    let natalPlanet: String
    let aspectType: TransitAspect
    let orb: Double
    let isApplying: Bool
    let strength: TransitStrength
    let effects: String

    init(
        id: UUID = UUID(),
        transitingPlanet: String,
        natalPlanet: String,
        aspectType: TransitAspect,
        orb: Double,
        isApplying: Bool,
        strength: TransitStrength,
        effects: String
    ) {
        self.id = id
        self.transitingPlanet = transitingPlanet
        self.natalPlanet = natalPlanet
        self.aspectType = aspectType
        self.orb = orb
        self.isApplying = isApplying
        self.strength = strength
        self.effects = effects
    }

    var description: String {
        let direction = isApplying ? "applying" : "separating"
        return "\(transitingPlanet) \(aspectType.rawValue) natal \(natalPlanet) (\(direction), orb: \(String(format: "%.1f", orb))°)"
    }
}

// MARK: - Transit Aspect Types
enum TransitAspect: String, Codable {
    case conjunction = "Conjunction"
    case opposition = "Opposition"
    case trine = "Trine"
    case square = "Square"
    case sextile = "Sextile"
    case quincunx = "Quincunx"

    var degrees: Double {
        switch self {
        case .conjunction: return 0
        case .opposition: return 180
        case .trine: return 120
        case .square: return 90
        case .sextile: return 60
        case .quincunx: return 150
        }
    }

    var orb: Double {
        switch self {
        case .conjunction, .opposition: return 10
        case .trine, .square: return 8
        case .sextile: return 6
        case .quincunx: return 3
        }
    }

    var nature: AspectNature {
        switch self {
        case .conjunction: return .neutral
        case .trine, .sextile: return .harmonious
        case .opposition, .square: return .challenging
        case .quincunx: return .adjusting
        }
    }
}

enum AspectNature: String, Codable {
    case harmonious = "Harmonious"
    case challenging = "Challenging"
    case neutral = "Neutral"
    case adjusting = "Adjusting"

    var colorName: String {
        switch self {
        case .harmonious: return "green"
        case .challenging: return "red"
        case .neutral: return "blue"
        case .adjusting: return "orange"
        }
    }
}

// MARK: - Transit Strength
enum TransitStrength: String, Codable {
    case strong = "Strong"
    case moderate = "Moderate"
    case weak = "Weak"

    var colorName: String {
        switch self {
        case .strong: return "red"
        case .moderate: return "orange"
        case .weak: return "yellow"
        }
    }
}

// MARK: - Major Transit Period
struct MajorTransitPeriod: Identifiable, Codable {
    let id: UUID
    let type: MajorTransitType
    let planet: String
    let startDate: Date
    let endDate: Date
    let houseNumber: Int?
    let signName: String
    let effects: String
    let sadeSatiPhase: SadeSatiPhase?

    init(
        id: UUID = UUID(),
        type: MajorTransitType,
        planet: String,
        startDate: Date,
        endDate: Date,
        houseNumber: Int? = nil,
        signName: String,
        effects: String,
        sadeSatiPhase: SadeSatiPhase? = nil
    ) {
        self.id = id
        self.type = type
        self.planet = planet
        self.startDate = startDate
        self.endDate = endDate
        self.houseNumber = houseNumber
        self.signName = signName
        self.effects = effects
        self.sadeSatiPhase = sadeSatiPhase
    }

    var isCurrentlyActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }

    var durationString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }

    var remainingDuration: String? {
        guard isCurrentlyActive else { return nil }
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: now, to: endDate)

        if let years = components.year, years > 0 {
            if let months = components.month {
                return "\(years)y \(months)m remaining"
            }
            return "\(years) years remaining"
        } else if let months = components.month, months > 0 {
            if let days = components.day {
                return "\(months)m \(days)d remaining"
            }
            return "\(months) months remaining"
        } else if let days = components.day {
            return "\(days) days remaining"
        }
        return nil
    }
}

// MARK: - Major Transit Types
enum MajorTransitType: String, Codable {
    case sadeSati = "Saturn Sade-Sati"
    case jupiterTransit = "Jupiter Transit"
    case saturnTransit = "Saturn Transit"
    case rahuKetuTransit = "Rahu-Ketu Transit"
    case saturnReturn = "Saturn Return"

    var typicalDuration: String {
        switch self {
        case .sadeSati: return "7.5 years"
        case .jupiterTransit: return "1 year"
        case .saturnTransit: return "2.5 years"
        case .rahuKetuTransit: return "1.5 years"
        case .saturnReturn: return "2.5 years"
        }
    }
}

// MARK: - Sade-Sati Phase
enum SadeSatiPhase: String, Codable {
    case rising = "Rising Phase"     // Saturn in 12th from Moon
    case peak = "Peak Phase"          // Saturn over natal Moon
    case setting = "Setting Phase"    // Saturn in 2nd from Moon

    var description: String {
        switch self {
        case .rising:
            return "Beginning phase - Saturn transiting 12th from Moon. Mental stress, expenses, but also spiritual growth."
        case .peak:
            return "Peak phase - Saturn transiting over Moon. Most intense period. Health and emotional challenges."
        case .setting:
            return "Final phase - Saturn transiting 2nd from Moon. Financial matters, family concerns, but gradually improving."
        }
    }

    var intensity: String {
        switch self {
        case .rising: return "Moderate"
        case .peak: return "Intense"
        case .setting: return "Moderate to Light"
        }
    }
}

// MARK: - Transit Timeline Event
struct TransitTimelineEvent: Identifiable {
    let id = UUID()
    let date: Date
    let planet: String
    let eventType: TransitEventType
    let fromSign: String?
    let toSign: String?
    let description: String

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

enum TransitEventType: String {
    case signEntry = "Sign Entry"
    case signExit = "Sign Exit"
    case retrogradeStart = "Retrograde Begins"
    case retrogradeEnd = "Retrograde Ends"
    case exactAspect = "Exact Aspect"
}
