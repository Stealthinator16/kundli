import Foundation

/// Represents a Vedic astrology term with its explanation and metadata
struct AstrologyTerm: Identifiable, Codable {
    let id: String                      // e.g., "tithi.shukla.dwadashi"
    let englishName: String             // "Twelfth Lunar Day (Waxing)"
    let sanskritName: String            // "Shukla Dwadashi"
    let category: TermCategory
    let shortExplanation: String        // 1-2 sentences for tooltips/cards
    let fullExplanation: String         // 2-3 paragraphs for detail sheets
    let howCalculated: String?          // For those wanting the math/astronomy
    let significance: String?           // Spiritual/practical meaning
    let relatedTermIds: [String]        // Links to related concepts
    let parentTermId: String?           // For hierarchical terms
    let tags: [String]                  // For search
    let iconName: String?               // SF Symbol
    let groupInfo: TermGroupInfo?       // Position in a group (e.g., 12th of 30 tithis)

    init(
        id: String,
        englishName: String,
        sanskritName: String,
        category: TermCategory,
        shortExplanation: String,
        fullExplanation: String,
        howCalculated: String? = nil,
        significance: String? = nil,
        relatedTermIds: [String] = [],
        parentTermId: String? = nil,
        tags: [String] = [],
        iconName: String? = nil,
        groupInfo: TermGroupInfo? = nil
    ) {
        self.id = id
        self.englishName = englishName
        self.sanskritName = sanskritName
        self.category = category
        self.shortExplanation = shortExplanation
        self.fullExplanation = fullExplanation
        self.howCalculated = howCalculated
        self.significance = significance
        self.relatedTermIds = relatedTermIds
        self.parentTermId = parentTermId
        self.tags = tags
        self.iconName = iconName
        self.groupInfo = groupInfo
    }
}

/// Information about a term's position within a group
struct TermGroupInfo: Codable {
    let groupName: String               // "30 Tithis"
    let groupTermId: String             // "tithi" - links to parent explanation
    let position: Int                   // 12
    let totalInGroup: Int               // 30

    var positionText: String {
        "\(position) of \(totalInGroup)"
    }
}

/// Categories of astrology terms for organization
enum TermCategory: String, Codable, CaseIterable {
    case fundamentals = "Fundamentals"
    case panchang = "Panchang"
    case planet = "Planets"
    case sign = "Signs"
    case house = "Houses"
    case nakshatra = "Nakshatras"
    case dasha = "Dasha"
    case yoga = "Yogas"
    case dosha = "Doshas"
    case matching = "Matching"
    case strength = "Strength"
    case divisionalChart = "Divisional Charts"
    case transit = "Transits"
    case remedy = "Remedies"

    var iconName: String {
        switch self {
        case .fundamentals: return "sparkles"
        case .panchang: return "calendar"
        case .planet: return "globe"
        case .sign: return "star.circle"
        case .house: return "square.grid.2x2"
        case .nakshatra: return "star.fill"
        case .dasha: return "clock"
        case .yoga: return "link"
        case .dosha: return "exclamationmark.triangle"
        case .matching: return "heart.fill"
        case .strength: return "bolt.fill"
        case .divisionalChart: return "square.split.2x2"
        case .transit: return "arrow.triangle.2.circlepath"
        case .remedy: return "leaf.fill"
        }
    }

    var description: String {
        switch self {
        case .fundamentals: return "Core concepts of Vedic astrology"
        case .panchang: return "Daily almanac elements"
        case .planet: return "The nine celestial bodies (Navagraha)"
        case .sign: return "The twelve zodiac signs (Rashis)"
        case .house: return "The twelve houses (Bhavas)"
        case .nakshatra: return "The 27 lunar mansions"
        case .dasha: return "Planetary period systems"
        case .yoga: return "Beneficial planetary combinations"
        case .dosha: return "Challenging planetary afflictions"
        case .matching: return "Compatibility analysis"
        case .strength: return "Planetary and house strength"
        case .divisionalChart: return "Divisional charts (Vargas)"
        case .transit: return "Current planetary movements"
        case .remedy: return "Astrological remedies"
        }
    }

    var color: String {
        switch self {
        case .fundamentals: return "kundliPrimary"
        case .panchang: return "kundliInfo"
        case .planet: return "orange"
        case .sign: return "purple"
        case .house: return "blue"
        case .nakshatra: return "indigo"
        case .dasha: return "teal"
        case .yoga: return "green"
        case .dosha: return "red"
        case .matching: return "pink"
        case .strength: return "yellow"
        case .divisionalChart: return "cyan"
        case .transit: return "mint"
        case .remedy: return "green"
        }
    }
}
