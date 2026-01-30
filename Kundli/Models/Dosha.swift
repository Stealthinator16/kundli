import Foundation

/// Represents an astrological Dosha (affliction) found in a chart
struct Dosha: Identifiable, Codable {
    let id: UUID
    let name: String
    let sanskritName: String
    let type: DoshaType
    let severity: DoshaSeverity
    let description: String
    let effects: String
    let remedies: [String]
    let cancellations: [DoshaCancellation]
    let isCancelled: Bool
    let formingPlanets: [String]

    init(
        id: UUID = UUID(),
        name: String,
        sanskritName: String,
        type: DoshaType,
        severity: DoshaSeverity,
        description: String,
        effects: String,
        remedies: [String],
        cancellations: [DoshaCancellation] = [],
        isCancelled: Bool = false,
        formingPlanets: [String]
    ) {
        self.id = id
        self.name = name
        self.sanskritName = sanskritName
        self.type = type
        self.severity = severity
        self.description = description
        self.effects = effects
        self.remedies = remedies
        self.cancellations = cancellations
        self.isCancelled = isCancelled
        self.formingPlanets = formingPlanets
    }
}

// MARK: - Dosha Types
enum DoshaType: String, Codable, CaseIterable {
    case manglik = "Manglik"
    case kaalSarp = "Kaal Sarp"
    case kemdrum = "Kemdrum"
    case pitra = "Pitra"
    case grahan = "Grahan"
    case guruChandal = "Guru Chandal"
    case shrapit = "Shrapit"
    case gandmool = "Gandmool"
    case nadi = "Nadi"
    case bhakoot = "Bhakoot"
    case gana = "Gana"
    case shani = "Shani"
    case other = "Other"

    var description: String {
        switch self {
        case .manglik:
            return "Affliction caused by Mars placement affecting marriage"
        case .kaalSarp:
            return "All planets hemmed between Rahu and Ketu"
        case .kemdrum:
            return "Moon without planets in adjacent houses"
        case .pitra:
            return "Ancestral karma indicated by Sun-Rahu or Sun-Saturn"
        case .grahan:
            return "Eclipse dosha caused by Rahu/Ketu conjunct Sun/Moon"
        case .guruChandal:
            return "Jupiter afflicted by Rahu conjunction or aspect"
        case .shrapit:
            return "Saturn-Rahu conjunction indicating past life karma"
        case .gandmool:
            return "Moon in Gandmool nakshatra at birth"
        case .nadi:
            return "Same Nadi in matching charts"
        case .bhakoot:
            return "Unfavorable Moon sign relationship in matching"
        case .gana:
            return "Incompatible Gana types in matching"
        case .shani:
            return "Saturn-related affliction"
        case .other:
            return "Other astrological afflictions"
        }
    }
}

// MARK: - Dosha Severity
enum DoshaSeverity: String, Codable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    case cancelled = "Cancelled"

    var displayColor: String {
        switch self {
        case .high: return "red"
        case .medium: return "orange"
        case .low: return "yellow"
        case .cancelled: return "green"
        }
    }

    var percentage: Int {
        switch self {
        case .high: return 100
        case .medium: return 60
        case .low: return 30
        case .cancelled: return 0
        }
    }
}

// MARK: - Dosha Cancellation
struct DoshaCancellation: Codable, Equatable {
    let rule: String
    let isActive: Bool
    let description: String
}

// MARK: - Common Dosha Definitions
extension Dosha {
    /// Manglik Dosha - Mars in 1, 4, 7, 8, or 12th house
    static func manglik(
        severity: DoshaSeverity,
        formingPlanets: [String],
        cancellations: [DoshaCancellation],
        fromLagna: Bool,
        fromMoon: Bool,
        fromVenus: Bool
    ) -> Dosha {
        var sources: [String] = []
        if fromLagna { sources.append("Lagna") }
        if fromMoon { sources.append("Moon") }
        if fromVenus { sources.append("Venus") }

        let isCancelled = cancellations.contains { $0.isActive }

        return Dosha(
            name: "Manglik Dosha",
            sanskritName: "Mangal Dosha",
            type: .manglik,
            severity: isCancelled ? .cancelled : severity,
            description: "Mars is placed in the 1st, 4th, 7th, 8th, or 12th house from \(sources.joined(separator: ", "))",
            effects: "Can cause delays in marriage, discord in married life, or health issues to spouse. The severity depends on the exact placement and aspects.",
            remedies: [
                "Chant Mangal mantra: Om Kraam Kreem Kraum Sah Bhaumaya Namah",
                "Wear a coral (Moonga) after consulting an astrologer",
                "Perform Kumbh Vivah (ritual marriage with a pot) before actual marriage",
                "Visit Mangalnath temple in Ujjain",
                "Fast on Tuesdays"
            ],
            cancellations: cancellations,
            isCancelled: isCancelled,
            formingPlanets: formingPlanets
        )
    }

    /// Kaal Sarp Dosha - All planets between Rahu and Ketu
    static func kaalSarp(
        severity: DoshaSeverity,
        yogaType: String,
        formingPlanets: [String],
        isPartial: Bool
    ) -> Dosha {
        Dosha(
            name: "Kaal Sarp Dosha",
            sanskritName: "Kaal Sarpa Yoga",
            type: .kaalSarp,
            severity: severity,
            description: isPartial
                ? "Partial Kaal Sarp - Most planets are between Rahu and Ketu axis (\(yogaType))"
                : "All seven planets are hemmed between Rahu and Ketu (\(yogaType))",
            effects: "Struggles and obstacles in life, delays in achievements, need for extra effort. Can also indicate spiritual inclination when handled well.",
            remedies: [
                "Perform Kaal Sarp Dosh Nivaran Puja at Trimbakeshwar or Kalahasti",
                "Chant Maha Mrityunjaya Mantra",
                "Offer prayers to Lord Shiva",
                "Keep a silver snake idol at home",
                "Feed birds, especially on Saturdays"
            ],
            formingPlanets: formingPlanets
        )
    }

    /// Kemdrum Dosha - No planets in 2nd or 12th from Moon
    static func kemdrum(
        severity: DoshaSeverity,
        formingPlanets: [String],
        cancellations: [DoshaCancellation]
    ) -> Dosha {
        let isCancelled = cancellations.contains { $0.isActive }

        return Dosha(
            name: "Kemdrum Dosha",
            sanskritName: "Kemdrum Yoga",
            type: .kemdrum,
            severity: isCancelled ? .cancelled : severity,
            description: "No planets are present in the 2nd or 12th house from Moon",
            effects: "Can indicate poverty, loneliness, or lack of comforts. However, this is often cancelled by other factors.",
            remedies: [
                "Chant Chandra mantra: Om Shraam Shreem Shraum Sah Chandramase Namah",
                "Wear a pearl (Moti) after consulting an astrologer",
                "Observe fasts on Mondays",
                "Keep water in a silver vessel near your bed",
                "Donate white items on Mondays"
            ],
            cancellations: cancellations,
            isCancelled: isCancelled,
            formingPlanets: formingPlanets
        )
    }

    /// Pitra Dosha - Afflictions related to ancestors
    static func pitra(
        severity: DoshaSeverity,
        formingPlanets: [String],
        description: String
    ) -> Dosha {
        Dosha(
            name: "Pitra Dosha",
            sanskritName: "Pitra Dosha",
            type: .pitra,
            severity: severity,
            description: description,
            effects: "Can cause obstacles in career, problems in having children, or family discord. Often indicates need to honor ancestors.",
            remedies: [
                "Perform Pitra Tarpan during Pitru Paksha",
                "Feed Brahmins and poor on ancestors' death anniversaries",
                "Plant a Peepal tree",
                "Perform Narayan Bali puja at Gaya",
                "Chant Pitra Gayatri Mantra"
            ],
            formingPlanets: formingPlanets
        )
    }

    /// Grahan Dosha - Rahu/Ketu conjunct Sun/Moon
    static func grahanDosha(
        type: String,
        severity: DoshaSeverity,
        formingPlanets: [String],
        cancellations: [DoshaCancellation] = []
    ) -> Dosha {
        let isCancelled = cancellations.contains { $0.isActive }
        return Dosha(
            name: "Grahan Dosha",
            sanskritName: "Grahan Dosha",
            type: .grahan,
            severity: isCancelled ? .cancelled : severity,
            description: "\(type) - Eclipse combination in the birth chart",
            effects: "Can cause health issues, mental disturbances, and obstacles related to the affected luminary. The native may face challenges in areas ruled by Sun (authority, father) or Moon (mind, mother).",
            remedies: [
                "Chant Rahu/Ketu mantras on eclipse days",
                "Perform Grahan Dosha Shanti puja",
                "Donate black cloth and sesame seeds",
                "Worship Lord Ganesha regularly",
                "Observe fast on Amavasya and Purnima"
            ],
            cancellations: cancellations,
            isCancelled: isCancelled,
            formingPlanets: formingPlanets
        )
    }

    /// Guru Chandal Dosha - Jupiter conjunct/aspected by Rahu
    static func guruChandalDosha(
        severity: DoshaSeverity,
        formingPlanets: [String],
        cancellations: [DoshaCancellation] = []
    ) -> Dosha {
        let isCancelled = cancellations.contains { $0.isActive }
        return Dosha(
            name: "Guru Chandal Dosha",
            sanskritName: "Guru Chandal Yoga",
            type: .guruChandal,
            severity: isCancelled ? .cancelled : severity,
            description: "Jupiter is conjunct with or aspected by Rahu",
            effects: "May cause disrespect towards teachers and elders, unconventional beliefs, challenges in education and spirituality. Can also indicate unorthodox wisdom when positively manifested.",
            remedies: [
                "Chant Guru Beej Mantra: Om Graam Greem Graum Sah Gurave Namah",
                "Worship Lord Vishnu on Thursdays",
                "Wear yellow sapphire after consultation",
                "Respect teachers and learned people",
                "Donate yellow items on Thursdays"
            ],
            cancellations: cancellations,
            isCancelled: isCancelled,
            formingPlanets: formingPlanets
        )
    }

    /// Shrapit Dosha - Saturn-Rahu conjunction
    static func shrapitDosha(
        severity: DoshaSeverity,
        formingPlanets: [String],
        cancellations: [DoshaCancellation] = []
    ) -> Dosha {
        let isCancelled = cancellations.contains { $0.isActive }
        return Dosha(
            name: "Shrapit Dosha",
            sanskritName: "Shrapit Dosha",
            type: .shrapit,
            severity: isCancelled ? .cancelled : severity,
            description: "Saturn and Rahu are conjunct in the birth chart",
            effects: "Indicates past-life karma, may cause delays and obstacles in life. The native might face unusual troubles, fear, and anxiety. Effects manifest strongly during Saturn or Rahu dasha.",
            remedies: [
                "Perform Shrapit Dosha Nivaran puja",
                "Chant Hanuman Chalisa daily",
                "Feed black dogs and crows",
                "Donate iron items on Saturdays",
                "Worship Lord Shiva regularly"
            ],
            cancellations: cancellations,
            isCancelled: isCancelled,
            formingPlanets: formingPlanets
        )
    }

    /// Gandmool Dosha - Moon in specific nakshatras
    static func gandmoolDosha(
        nakshatra: String,
        severity: DoshaSeverity,
        formingPlanets: [String],
        cancellations: [DoshaCancellation] = []
    ) -> Dosha {
        let isCancelled = cancellations.contains { $0.isActive }
        return Dosha(
            name: "Gandmool Dosha",
            sanskritName: "Gandmool Dosha",
            type: .gandmool,
            severity: isCancelled ? .cancelled : severity,
            description: "Moon is placed in \(nakshatra) nakshatra at the time of birth",
            effects: "Can indicate hardships in early life, health issues, or concerns for parents. The specific effects depend on the nakshatra involved.",
            remedies: [
                "Perform Gandmool Shanti puja within 27 days of birth",
                "Chant Moon and nakshatra lord mantras",
                "Donate white items on Mondays",
                "Worship the deity of the nakshatra",
                "Observe fast on the birth nakshatra day"
            ],
            cancellations: cancellations,
            isCancelled: isCancelled,
            formingPlanets: formingPlanets
        )
    }

    /// Nadi Dosha - Same Nadi in matching (for compatibility)
    static func nadiDosha(
        nadi: String,
        severity: DoshaSeverity,
        formingPlanets: [String]
    ) -> Dosha {
        Dosha(
            name: "Nadi Dosha",
            sanskritName: "Nadi Dosha",
            type: .nadi,
            severity: severity,
            description: "Both partners have the same Nadi (\(nadi))",
            effects: "May cause health issues in offspring, physical incompatibility, and progeny-related problems. This is considered a major dosha in Kundli matching.",
            remedies: [
                "Perform Nadi Dosha Nivaran puja before marriage",
                "Donate gold equivalent to partner's weight (symbolic)",
                "Both partners should observe fast on certain days",
                "Worship Lord Shiva and Parvati together",
                "Chant Mahamrityunjaya Mantra 108 times daily"
            ],
            formingPlanets: formingPlanets
        )
    }

    /// Bhakoot Dosha - 6-8 or 2-12 Moon sign relationship
    static func bhakootDosha(
        relationship: String,
        severity: DoshaSeverity,
        formingPlanets: [String]
    ) -> Dosha {
        Dosha(
            name: "Bhakoot Dosha",
            sanskritName: "Bhakoot Dosha",
            type: .bhakoot,
            severity: severity,
            description: "Moon signs are in \(relationship) relationship",
            effects: "May cause financial problems, loss of children, or separation. The specific effects depend on the relationship type.",
            remedies: [
                "Perform Bhakoot Dosha Shanti puja",
                "Both partners should worship their Moon sign deities",
                "Donate according to Moon sign recommendations",
                "Chant Chandra mantra on Mondays",
                "Keep fast on Purnima (full moon) days together"
            ],
            formingPlanets: formingPlanets
        )
    }

    /// Gana Dosha - Incompatible Ganas (Deva/Manushya/Rakshasa)
    static func ganaDosha(
        gana1: String,
        gana2: String,
        severity: DoshaSeverity,
        formingPlanets: [String]
    ) -> Dosha {
        Dosha(
            name: "Gana Dosha",
            sanskritName: "Gana Dosha",
            type: .gana,
            severity: severity,
            description: "Incompatible Gana match: \(gana1) with \(gana2)",
            effects: "May cause temperament clashes, daily arguments, and lack of mutual understanding. Deva-Rakshasa is considered the most challenging combination.",
            remedies: [
                "Perform Gana Dosha Shanti puja",
                "Practice patience and understanding in relationship",
                "Both partners should worship the nakshatra deities",
                "Chant Gayatri Mantra together",
                "Observe compatibility-enhancing rituals"
            ],
            formingPlanets: formingPlanets
        )
    }
}

// MARK: - Kaal Sarp Yoga Types
enum KaalSarpType: String, Codable, CaseIterable {
    case anant = "Anant"           // Rahu in 1st, Ketu in 7th
    case kulik = "Kulik"           // Rahu in 2nd, Ketu in 8th
    case vasuki = "Vasuki"         // Rahu in 3rd, Ketu in 9th
    case shankhpal = "Shankhpal"   // Rahu in 4th, Ketu in 10th
    case padma = "Padma"           // Rahu in 5th, Ketu in 11th
    case mahapadma = "Mahapadma"   // Rahu in 6th, Ketu in 12th
    case takshak = "Takshak"       // Rahu in 7th, Ketu in 1st
    case karkotak = "Karkotak"     // Rahu in 8th, Ketu in 2nd
    case shankhnath = "Shankhnath" // Rahu in 9th, Ketu in 3rd
    case ghatak = "Ghatak"         // Rahu in 10th, Ketu in 4th
    case vishdhar = "Vishdhar"     // Rahu in 11th, Ketu in 5th
    case sheshnaag = "Sheshnaag"   // Rahu in 12th, Ketu in 6th

    var description: String {
        switch self {
        case .anant: return "Rahu in 1st house, Ketu in 7th house"
        case .kulik: return "Rahu in 2nd house, Ketu in 8th house"
        case .vasuki: return "Rahu in 3rd house, Ketu in 9th house"
        case .shankhpal: return "Rahu in 4th house, Ketu in 10th house"
        case .padma: return "Rahu in 5th house, Ketu in 11th house"
        case .mahapadma: return "Rahu in 6th house, Ketu in 12th house"
        case .takshak: return "Rahu in 7th house, Ketu in 1st house"
        case .karkotak: return "Rahu in 8th house, Ketu in 2nd house"
        case .shankhnath: return "Rahu in 9th house, Ketu in 3rd house"
        case .ghatak: return "Rahu in 10th house, Ketu in 4th house"
        case .vishdhar: return "Rahu in 11th house, Ketu in 5th house"
        case .sheshnaag: return "Rahu in 12th house, Ketu in 6th house"
        }
    }

    static func from(rahuHouse: Int) -> KaalSarpType? {
        switch rahuHouse {
        case 1: return .anant
        case 2: return .kulik
        case 3: return .vasuki
        case 4: return .shankhpal
        case 5: return .padma
        case 6: return .mahapadma
        case 7: return .takshak
        case 8: return .karkotak
        case 9: return .shankhnath
        case 10: return .ghatak
        case 11: return .vishdhar
        case 12: return .sheshnaag
        default: return nil
        }
    }
}
