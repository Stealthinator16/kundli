import Foundation
import SwiftUI

// MARK: - Personalized Remedies Container

/// Contains all personalized remedies generated based on chart analysis
struct PersonalizedRemedies: Identifiable {
    let id: UUID
    let generatedAt: Date
    let gemstones: [Gemstone]
    let mantras: [Mantra]
    let charities: [Charity]
    let fastingDays: [FastingDay]
    let pujas: [Puja]

    init(
        id: UUID = UUID(),
        generatedAt: Date = Date(),
        gemstones: [Gemstone] = [],
        mantras: [Mantra] = [],
        charities: [Charity] = [],
        fastingDays: [FastingDay] = [],
        pujas: [Puja] = []
    ) {
        self.id = id
        self.generatedAt = generatedAt
        self.gemstones = gemstones
        self.mantras = mantras
        self.charities = charities
        self.fastingDays = fastingDays
        self.pujas = pujas
    }

    var isEmpty: Bool {
        gemstones.isEmpty && mantras.isEmpty && charities.isEmpty && fastingDays.isEmpty && pujas.isEmpty
    }

    var totalRemedies: Int {
        gemstones.count + mantras.count + charities.count + fastingDays.count + pujas.count
    }
}

// MARK: - Gemstone Remedy

/// Represents a gemstone recommendation for planetary strengthening
struct Gemstone: Identifiable, Codable {
    let id: UUID
    let name: String
    let sanskritName: String
    let planet: String
    let planetVedName: String
    let weight: String              // e.g., "5-7 carats"
    let metal: String               // e.g., "Gold", "Silver"
    let finger: String              // Which finger to wear on
    let hand: String                // Left or Right
    let dayToWear: String           // Best day to start wearing
    let mantraToChant: String       // Mantra while wearing
    let reason: RemedyReason
    let alternativeStones: [String] // Cheaper alternatives
    let precautions: [String]

    init(
        id: UUID = UUID(),
        name: String,
        sanskritName: String,
        planet: String,
        planetVedName: String,
        weight: String,
        metal: String,
        finger: String,
        hand: String,
        dayToWear: String,
        mantraToChant: String,
        reason: RemedyReason,
        alternativeStones: [String] = [],
        precautions: [String] = []
    ) {
        self.id = id
        self.name = name
        self.sanskritName = sanskritName
        self.planet = planet
        self.planetVedName = planetVedName
        self.weight = weight
        self.metal = metal
        self.finger = finger
        self.hand = hand
        self.dayToWear = dayToWear
        self.mantraToChant = mantraToChant
        self.reason = reason
        self.alternativeStones = alternativeStones
        self.precautions = precautions
    }

    var wearingInstructions: String {
        "Wear in \(metal) on the \(finger) finger of the \(hand) hand. Best to start wearing on \(dayToWear) during \(planet) hora."
    }
}

// MARK: - Mantra Remedy

/// Represents a mantra recommendation for planetary propitiation
struct Mantra: Identifiable, Codable {
    let id: UUID
    let text: String
    let meaning: String
    let planet: String
    let planetVedName: String
    let deity: String
    let repetitions: Int            // Daily count (e.g., 108)
    let totalCount: Int?            // Total to complete (e.g., 11000)
    let bestTime: String            // Best time to chant
    let bestDay: String             // Best day of week
    let duration: String            // e.g., "40 days", "Ongoing"
    let reason: RemedyReason
    let benefits: [String]

    init(
        id: UUID = UUID(),
        text: String,
        meaning: String,
        planet: String,
        planetVedName: String,
        deity: String,
        repetitions: Int = 108,
        totalCount: Int? = nil,
        bestTime: String,
        bestDay: String,
        duration: String,
        reason: RemedyReason,
        benefits: [String] = []
    ) {
        self.id = id
        self.text = text
        self.meaning = meaning
        self.planet = planet
        self.planetVedName = planetVedName
        self.deity = deity
        self.repetitions = repetitions
        self.totalCount = totalCount
        self.bestTime = bestTime
        self.bestDay = bestDay
        self.duration = duration
        self.reason = reason
        self.benefits = benefits
    }

    var chantingInstructions: String {
        var instructions = "Chant \(repetitions) times daily"
        if let total = totalCount {
            instructions += " (total \(total.formatted()) times)"
        }
        instructions += ". Best time: \(bestTime) on \(bestDay)s."
        return instructions
    }
}

// MARK: - Charity Remedy

/// Represents a charity/donation recommendation
struct Charity: Identifiable, Codable {
    let id: UUID
    let item: String                // What to donate
    let itemDescription: String     // Details about the item
    let planet: String
    let planetVedName: String
    let day: String                 // Day of week to donate
    let beneficiary: String         // Who to donate to
    let frequency: String           // How often (weekly, monthly)
    let reason: RemedyReason
    let alternatives: [String]      // Alternative items

    init(
        id: UUID = UUID(),
        item: String,
        itemDescription: String,
        planet: String,
        planetVedName: String,
        day: String,
        beneficiary: String,
        frequency: String,
        reason: RemedyReason,
        alternatives: [String] = []
    ) {
        self.id = id
        self.item = item
        self.itemDescription = itemDescription
        self.planet = planet
        self.planetVedName = planetVedName
        self.day = day
        self.beneficiary = beneficiary
        self.frequency = frequency
        self.reason = reason
        self.alternatives = alternatives
    }

    var donationInstructions: String {
        "Donate \(item) on \(day)s to \(beneficiary). Frequency: \(frequency)."
    }
}

// MARK: - Fasting Day Remedy

/// Represents a fasting recommendation for planetary propitiation
struct FastingDay: Identifiable, Codable {
    let id: UUID
    let day: String                 // Day of week
    let planet: String
    let planetVedName: String
    let whatToAvoid: [String]       // Foods to avoid
    let whatToEat: [String]         // Permitted foods
    let breakFastTime: String       // When to break the fast
    let frequency: String           // Weekly, monthly, etc.
    let duration: String            // How long to observe
    let reason: RemedyReason
    let deity: String               // Deity to worship while fasting

    init(
        id: UUID = UUID(),
        day: String,
        planet: String,
        planetVedName: String,
        whatToAvoid: [String],
        whatToEat: [String],
        breakFastTime: String,
        frequency: String,
        duration: String,
        reason: RemedyReason,
        deity: String
    ) {
        self.id = id
        self.day = day
        self.planet = planet
        self.planetVedName = planetVedName
        self.whatToAvoid = whatToAvoid
        self.whatToEat = whatToEat
        self.breakFastTime = breakFastTime
        self.frequency = frequency
        self.duration = duration
        self.reason = reason
        self.deity = deity
    }

    var fastingInstructions: String {
        "Fast on \(day)s. Worship \(deity). Break fast \(breakFastTime)."
    }
}

// MARK: - Puja Remedy

/// Represents a puja/ritual recommendation
struct Puja: Identifiable, Codable {
    let id: UUID
    let name: String
    let sanskritName: String
    let deity: String
    let planet: String?             // nil if general puja
    let planetVedName: String?
    let purpose: String
    let timing: String              // When to perform
    let frequency: String           // One-time, annual, etc.
    let estimatedDuration: String   // How long the puja takes
    let reason: RemedyReason
    let benefits: [String]
    let templeRecommendations: [String]  // Famous temples for this puja

    init(
        id: UUID = UUID(),
        name: String,
        sanskritName: String,
        deity: String,
        planet: String? = nil,
        planetVedName: String? = nil,
        purpose: String,
        timing: String,
        frequency: String,
        estimatedDuration: String,
        reason: RemedyReason,
        benefits: [String] = [],
        templeRecommendations: [String] = []
    ) {
        self.id = id
        self.name = name
        self.sanskritName = sanskritName
        self.deity = deity
        self.planet = planet
        self.planetVedName = planetVedName
        self.purpose = purpose
        self.timing = timing
        self.frequency = frequency
        self.estimatedDuration = estimatedDuration
        self.reason = reason
        self.benefits = benefits
        self.templeRecommendations = templeRecommendations
    }

    var pujaInstructions: String {
        "Perform \(name) for \(deity). Best timing: \(timing). Duration: \(estimatedDuration)."
    }
}

// MARK: - Remedy Reason

/// Describes why a remedy is recommended
struct RemedyReason: Codable, Equatable {
    let type: RemedyReasonType
    let description: String
    let severity: RemedySeverity

    init(type: RemedyReasonType, description: String, severity: RemedySeverity = .moderate) {
        self.type = type
        self.description = description
        self.severity = severity
    }
}

/// Types of reasons for recommending remedies
enum RemedyReasonType: String, Codable, CaseIterable {
    case weakPlanet = "Weak Planet"
    case debilitatedPlanet = "Debilitated Planet"
    case afflictedPlanet = "Afflicted Planet"
    case dosha = "Dosha"
    case dashaLord = "Dasha Lord"
    case transitEffect = "Transit Effect"
    case houseAffliction = "House Affliction"
    case generalWellbeing = "General Wellbeing"

    var icon: String {
        switch self {
        case .weakPlanet: return "arrow.down.circle"
        case .debilitatedPlanet: return "exclamationmark.triangle"
        case .afflictedPlanet: return "xmark.circle"
        case .dosha: return "exclamationmark.shield"
        case .dashaLord: return "calendar.circle"
        case .transitEffect: return "arrow.triangle.2.circlepath"
        case .houseAffliction: return "house.circle"
        case .generalWellbeing: return "sparkles"
        }
    }

    var color: Color {
        switch self {
        case .weakPlanet: return .orange
        case .debilitatedPlanet: return .red
        case .afflictedPlanet: return .red
        case .dosha: return .purple
        case .dashaLord: return .blue
        case .transitEffect: return .cyan
        case .houseAffliction: return .orange
        case .generalWellbeing: return .green
        }
    }
}

/// Severity of the issue requiring remedy
enum RemedySeverity: String, Codable, CaseIterable {
    case high = "High Priority"
    case moderate = "Moderate"
    case low = "Suggested"

    var color: Color {
        switch self {
        case .high: return .red
        case .moderate: return .orange
        case .low: return .yellow
        }
    }

    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .moderate: return 1
        case .low: return 2
        }
    }
}

// MARK: - Remedy Category (for UI grouping)

enum RemedyType: String, CaseIterable {
    case gemstones = "Gemstones"
    case mantras = "Mantras"
    case charity = "Charity"
    case fasting = "Fasting"
    case puja = "Puja & Rituals"

    var icon: String {
        switch self {
        case .gemstones: return "diamond.fill"
        case .mantras: return "waveform"
        case .charity: return "gift.fill"
        case .fasting: return "leaf.fill"
        case .puja: return "flame.fill"
        }
    }

    var color: Color {
        switch self {
        case .gemstones: return .cyan
        case .mantras: return .orange
        case .charity: return .green
        case .fasting: return .purple
        case .puja: return .red
        }
    }

    var description: String {
        switch self {
        case .gemstones:
            return "Wearing specific gemstones can strengthen weak planets in your chart"
        case .mantras:
            return "Sacred chants to invoke planetary blessings and reduce malefic effects"
        case .charity:
            return "Donations aligned with planetary significations to balance karma"
        case .fasting:
            return "Observing fasts on specific days to propitiate planets"
        case .puja:
            return "Ritual worship to seek divine blessings and remedy afflictions"
        }
    }
}

// MARK: - Planet Remedy Data

/// Static data for planet-specific remedies
struct PlanetRemedyData {
    let planet: VedicPlanet
    let gemstone: String
    let gemstoneSanskrit: String
    let alternativeStones: [String]
    let metal: String
    let finger: String
    let day: String
    let mantra: String
    let mantraMeaning: String
    let deity: String
    let charityItems: [String]
    let charityBeneficiary: String
    let fastingFood: [String]
    let color: String

    static let all: [VedicPlanet: PlanetRemedyData] = [
        .sun: PlanetRemedyData(
            planet: .sun,
            gemstone: "Ruby",
            gemstoneSanskrit: "Manikya",
            alternativeStones: ["Red Garnet", "Red Spinel"],
            metal: "Gold",
            finger: "Ring",
            day: "Sunday",
            mantra: "Om Hraam Hreem Hraum Sah Suryaya Namah",
            mantraMeaning: "Salutations to the Sun God",
            deity: "Lord Surya",
            charityItems: ["Wheat", "Jaggery", "Copper", "Red cloth"],
            charityBeneficiary: "Father figures, temples",
            fastingFood: ["Wheat", "Jaggery"],
            color: "Red/Orange"
        ),
        .moon: PlanetRemedyData(
            planet: .moon,
            gemstone: "Pearl",
            gemstoneSanskrit: "Moti",
            alternativeStones: ["Moonstone", "White Coral"],
            metal: "Silver",
            finger: "Little",
            day: "Monday",
            mantra: "Om Shraam Shreem Shraum Sah Chandramase Namah",
            mantraMeaning: "Salutations to the Moon God",
            deity: "Lord Chandra/Goddess Parvati",
            charityItems: ["Rice", "Milk", "White cloth", "Silver"],
            charityBeneficiary: "Mother figures, women",
            fastingFood: ["Milk products", "Rice"],
            color: "White"
        ),
        .mars: PlanetRemedyData(
            planet: .mars,
            gemstone: "Red Coral",
            gemstoneSanskrit: "Moonga",
            alternativeStones: ["Carnelian", "Red Jasper"],
            metal: "Gold/Copper",
            finger: "Ring",
            day: "Tuesday",
            mantra: "Om Kraam Kreem Kraum Sah Bhaumaya Namah",
            mantraMeaning: "Salutations to Mars",
            deity: "Lord Hanuman/Kartikeya",
            charityItems: ["Red lentils", "Jaggery", "Copper", "Red items"],
            charityBeneficiary: "Young men, brothers",
            fastingFood: ["Masoor dal avoided"],
            color: "Red"
        ),
        .mercury: PlanetRemedyData(
            planet: .mercury,
            gemstone: "Emerald",
            gemstoneSanskrit: "Panna",
            alternativeStones: ["Green Tourmaline", "Peridot"],
            metal: "Gold",
            finger: "Little",
            day: "Wednesday",
            mantra: "Om Braam Breem Braum Sah Budhaya Namah",
            mantraMeaning: "Salutations to Mercury",
            deity: "Lord Vishnu/Budha",
            charityItems: ["Green moong", "Green vegetables", "Books"],
            charityBeneficiary: "Students, scholars",
            fastingFood: ["Green vegetables"],
            color: "Green"
        ),
        .jupiter: PlanetRemedyData(
            planet: .jupiter,
            gemstone: "Yellow Sapphire",
            gemstoneSanskrit: "Pukhraj",
            alternativeStones: ["Yellow Topaz", "Citrine"],
            metal: "Gold",
            finger: "Index",
            day: "Thursday",
            mantra: "Om Graam Greem Graum Sah Gurave Namah",
            mantraMeaning: "Salutations to Jupiter/Guru",
            deity: "Lord Vishnu/Brihaspati",
            charityItems: ["Chana dal", "Turmeric", "Yellow cloth", "Bananas"],
            charityBeneficiary: "Brahmins, teachers, priests",
            fastingFood: ["Chana dal", "Yellow foods"],
            color: "Yellow"
        ),
        .venus: PlanetRemedyData(
            planet: .venus,
            gemstone: "Diamond",
            gemstoneSanskrit: "Heera",
            alternativeStones: ["White Sapphire", "Zircon", "Opal"],
            metal: "Silver/Platinum",
            finger: "Middle",
            day: "Friday",
            mantra: "Om Draam Dreem Draum Sah Shukraya Namah",
            mantraMeaning: "Salutations to Venus",
            deity: "Goddess Lakshmi/Shukra",
            charityItems: ["White rice", "Ghee", "White cloth", "Perfume"],
            charityBeneficiary: "Young women, artists",
            fastingFood: ["Rice", "Milk products"],
            color: "White/Pink"
        ),
        .saturn: PlanetRemedyData(
            planet: .saturn,
            gemstone: "Blue Sapphire",
            gemstoneSanskrit: "Neelam",
            alternativeStones: ["Amethyst", "Blue Spinel", "Iolite"],
            metal: "Iron/Silver",
            finger: "Middle",
            day: "Saturday",
            mantra: "Om Praam Preem Praum Sah Shanaischaraya Namah",
            mantraMeaning: "Salutations to Saturn",
            deity: "Lord Shani/Hanuman",
            charityItems: ["Black sesame", "Mustard oil", "Iron", "Black cloth"],
            charityBeneficiary: "Poor, disabled, elderly",
            fastingFood: ["Sesame", "Urad dal avoided"],
            color: "Black/Blue"
        ),
        .rahu: PlanetRemedyData(
            planet: .rahu,
            gemstone: "Hessonite",
            gemstoneSanskrit: "Gomed",
            alternativeStones: ["Orange Zircon"],
            metal: "Silver",
            finger: "Middle",
            day: "Saturday",
            mantra: "Om Bhraam Bhreem Bhraum Sah Rahave Namah",
            mantraMeaning: "Salutations to Rahu",
            deity: "Goddess Durga/Saraswati",
            charityItems: ["Black sesame", "Blue cloth", "Lead"],
            charityBeneficiary: "Outcastes, sweepers",
            fastingFood: ["Sesame"],
            color: "Smoky/Blue"
        ),
        .ketu: PlanetRemedyData(
            planet: .ketu,
            gemstone: "Cat's Eye",
            gemstoneSanskrit: "Lehsunia",
            alternativeStones: ["Tiger's Eye"],
            metal: "Silver",
            finger: "Middle",
            day: "Tuesday/Saturday",
            mantra: "Om Sraam Sreem Sraum Sah Ketave Namah",
            mantraMeaning: "Salutations to Ketu",
            deity: "Lord Ganesha/Chitragupta",
            charityItems: ["Two-colored blanket", "Sesame", "Dog food"],
            charityBeneficiary: "Dogs, renunciants",
            fastingFood: ["Sesame"],
            color: "Grey/Brown"
        )
    ]

    static func data(for planet: VedicPlanet) -> PlanetRemedyData? {
        all[planet]
    }

    static func data(forPlanetName name: String) -> PlanetRemedyData? {
        guard let planet = VedicPlanet(rawValue: name) ?? VedicPlanet.allCases.first(where: { $0.vedName == name }) else {
            return nil
        }
        return all[planet]
    }
}
