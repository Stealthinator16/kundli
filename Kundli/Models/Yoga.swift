import Foundation

/// Represents an astrological Yoga (combination) found in a chart
struct Yoga: Identifiable, Codable {
    let id: UUID
    let name: String
    let sanskritName: String
    let category: YogaCategory
    let nature: YogaNature
    let strength: YogaStrength
    let description: String
    let effects: String
    let formingPlanets: [String]

    init(
        id: UUID = UUID(),
        name: String,
        sanskritName: String,
        category: YogaCategory,
        nature: YogaNature,
        strength: YogaStrength,
        description: String,
        effects: String,
        formingPlanets: [String]
    ) {
        self.id = id
        self.name = name
        self.sanskritName = sanskritName
        self.category = category
        self.nature = nature
        self.strength = strength
        self.description = description
        self.effects = effects
        self.formingPlanets = formingPlanets
    }
}

// MARK: - Yoga Categories
enum YogaCategory: String, Codable, CaseIterable {
    case mahapurusha = "Panch Mahapurusha"
    case wealth = "Wealth Yoga"
    case raja = "Raja Yoga"
    case lunar = "Lunar Yoga"
    case solar = "Solar Yoga"
    case nabhas = "Nabhas Yoga"
    case exchange = "Exchange Yoga"
    case other = "Other"

    var description: String {
        switch self {
        case .mahapurusha:
            return "Five great person yogas formed by Mars, Mercury, Jupiter, Venus, Saturn"
        case .wealth:
            return "Yogas indicating wealth and prosperity"
        case .raja:
            return "Yogas indicating power, authority, and success"
        case .lunar:
            return "Yogas based on Moon's position"
        case .solar:
            return "Yogas based on Sun's position"
        case .nabhas:
            return "Yogas based on planetary patterns"
        case .exchange:
            return "Yogas formed by planets exchanging signs"
        case .other:
            return "Other beneficial or malefic combinations"
        }
    }
}

// MARK: - Yoga Nature
enum YogaNature: String, Codable {
    case benefic = "Benefic"
    case malefic = "Malefic"
    case mixed = "Mixed"
}

// MARK: - Yoga Strength
enum YogaStrength: String, Codable {
    case strong = "Strong"
    case moderate = "Moderate"
    case weak = "Weak"

    var percentage: Int {
        switch self {
        case .strong: return 100
        case .moderate: return 60
        case .weak: return 30
        }
    }
}

// MARK: - Common Yoga Definitions
extension Yoga {
    /// Gaja Kesari Yoga - Jupiter in kendra from Moon
    static func gajaKesari(strength: YogaStrength, formingPlanets: [String]) -> Yoga {
        Yoga(
            name: "Gaja Kesari Yoga",
            sanskritName: "Gaja Kesari",
            category: .lunar,
            nature: .benefic,
            strength: strength,
            description: "Jupiter is in a kendra (1st, 4th, 7th, or 10th house) from Moon",
            effects: "Blessed with intelligence, wealth, good reputation, and long life. The native earns respect and holds positions of authority.",
            formingPlanets: formingPlanets
        )
    }

    /// Budhaditya Yoga - Sun and Mercury conjunction
    static func budhaditya(strength: YogaStrength, formingPlanets: [String]) -> Yoga {
        Yoga(
            name: "Budhaditya Yoga",
            sanskritName: "Budhaditya",
            category: .solar,
            nature: .benefic,
            strength: strength,
            description: "Sun and Mercury are conjunct in the same sign",
            effects: "Sharp intellect, good communication skills, success in education, skilled in multiple fields.",
            formingPlanets: formingPlanets
        )
    }

    /// Ruchaka Yoga - Mars in own/exalted sign in kendra
    static func ruchaka(strength: YogaStrength, formingPlanets: [String]) -> Yoga {
        Yoga(
            name: "Ruchaka Yoga",
            sanskritName: "Ruchaka",
            category: .mahapurusha,
            nature: .benefic,
            strength: strength,
            description: "Mars is in its own sign (Aries/Scorpio) or exalted (Capricorn) in a kendra house",
            effects: "Courageous, strong physique, commander or leader, valorous deeds, wins over enemies.",
            formingPlanets: formingPlanets
        )
    }

    /// Bhadra Yoga - Mercury in own/exalted sign in kendra
    static func bhadra(strength: YogaStrength, formingPlanets: [String]) -> Yoga {
        Yoga(
            name: "Bhadra Yoga",
            sanskritName: "Bhadra",
            category: .mahapurusha,
            nature: .benefic,
            strength: strength,
            description: "Mercury is in its own sign (Gemini/Virgo) or exalted (Virgo) in a kendra house",
            effects: "Intelligent, learned in sciences, good speaker, skilled in arts, long-lived.",
            formingPlanets: formingPlanets
        )
    }

    /// Hamsa Yoga - Jupiter in own/exalted sign in kendra
    static func hamsa(strength: YogaStrength, formingPlanets: [String]) -> Yoga {
        Yoga(
            name: "Hamsa Yoga",
            sanskritName: "Hamsa",
            category: .mahapurusha,
            nature: .benefic,
            strength: strength,
            description: "Jupiter is in its own sign (Sagittarius/Pisces) or exalted (Cancer) in a kendra house",
            effects: "Righteous, learned, respected by rulers, blessed with good family and wealth.",
            formingPlanets: formingPlanets
        )
    }

    /// Malavya Yoga - Venus in own/exalted sign in kendra
    static func malavya(strength: YogaStrength, formingPlanets: [String]) -> Yoga {
        Yoga(
            name: "Malavya Yoga",
            sanskritName: "Malavya",
            category: .mahapurusha,
            nature: .benefic,
            strength: strength,
            description: "Venus is in its own sign (Taurus/Libra) or exalted (Pisces) in a kendra house",
            effects: "Attractive appearance, wealthy, enjoys luxuries, artistic, happy married life.",
            formingPlanets: formingPlanets
        )
    }

    /// Sasa Yoga - Saturn in own/exalted sign in kendra
    static func sasa(strength: YogaStrength, formingPlanets: [String]) -> Yoga {
        Yoga(
            name: "Sasa Yoga",
            sanskritName: "Sasa",
            category: .mahapurusha,
            nature: .benefic,
            strength: strength,
            description: "Saturn is in its own sign (Capricorn/Aquarius) or exalted (Libra) in a kendra house",
            effects: "Commands servants, head of village/city, wicked disposition but wealthy and powerful.",
            formingPlanets: formingPlanets
        )
    }

    /// Raja Yoga - Connection between Kendra and Trikona lords
    static func raja(strength: YogaStrength, formingPlanets: [String], description: String) -> Yoga {
        Yoga(
            name: "Raja Yoga",
            sanskritName: "Raja Yoga",
            category: .raja,
            nature: .benefic,
            strength: strength,
            description: description,
            effects: "Power, authority, success, rise to prominent position, leadership.",
            formingPlanets: formingPlanets
        )
    }

    // MARK: - Lunar Yogas

    /// Sunapha Yoga - Planet (not Sun/Rahu/Ketu) in 2nd from Moon
    static func sunapha(formingPlanets: [String], strength: YogaStrength) -> Yoga {
        Yoga(
            name: "Sunapha Yoga",
            sanskritName: "Sunapha",
            category: .lunar,
            nature: .benefic,
            strength: strength,
            description: "A planet (other than Sun, Rahu, Ketu) is placed in the 2nd house from Moon",
            effects: "Self-made wealth, intelligence, good reputation. The native acquires wealth through their own efforts.",
            formingPlanets: formingPlanets
        )
    }

    /// Anapha Yoga - Planet (not Sun/Rahu/Ketu) in 12th from Moon
    static func anapha(formingPlanets: [String], strength: YogaStrength) -> Yoga {
        Yoga(
            name: "Anapha Yoga",
            sanskritName: "Anapha",
            category: .lunar,
            nature: .benefic,
            strength: strength,
            description: "A planet (other than Sun, Rahu, Ketu) is placed in the 12th house from Moon",
            effects: "Good health, pleasant personality, comfortable life. The native has good physical appearance and moral character.",
            formingPlanets: formingPlanets
        )
    }

    /// Durudhara Yoga - Planets in both 2nd AND 12th from Moon
    static func durudhara(formingPlanets: [String], strength: YogaStrength) -> Yoga {
        Yoga(
            name: "Durudhara Yoga",
            sanskritName: "Durudhara",
            category: .lunar,
            nature: .benefic,
            strength: strength,
            description: "Planets (other than Sun, Rahu, Ketu) are placed in both 2nd and 12th houses from Moon",
            effects: "Wealthy, charitable, enjoys all comforts. The native is blessed with vehicles, property, and good fortune.",
            formingPlanets: formingPlanets
        )
    }

    /// Adhi Yoga - Jupiter/Venus/Mercury in 6th, 7th, or 8th from Moon
    static func adhiYoga(formingPlanets: [String], strength: YogaStrength) -> Yoga {
        Yoga(
            name: "Adhi Yoga",
            sanskritName: "Adhi",
            category: .lunar,
            nature: .benefic,
            strength: strength,
            description: "Jupiter, Venus, and/or Mercury placed in 6th, 7th, or 8th house from Moon",
            effects: "Leadership qualities, commands respect, trustworthy. The native may become a leader, minister, or commander.",
            formingPlanets: formingPlanets
        )
    }

    // MARK: - Wealth Yogas

    /// Dhana Yoga - 2nd lord + 11th lord connection
    static func dhanaYoga(variation: Int, formingPlanets: [String], strength: YogaStrength) -> Yoga {
        let descriptions = [
            "2nd lord placed in 11th house or 11th lord placed in 2nd house",
            "2nd lord conjunct with 11th lord",
            "Jupiter aspects 2nd or 11th house"
        ]
        return Yoga(
            name: "Dhana Yoga",
            sanskritName: "Dhana",
            category: .wealth,
            nature: .benefic,
            strength: strength,
            description: variation <= descriptions.count ? descriptions[variation - 1] : descriptions[0],
            effects: "Accumulation of wealth, financial prosperity. The native gains wealth through multiple sources.",
            formingPlanets: formingPlanets
        )
    }

    /// Lakshmi Yoga - 9th lord in Kendra with strong Venus
    static func lakshmiYoga(formingPlanets: [String], strength: YogaStrength) -> Yoga {
        Yoga(
            name: "Lakshmi Yoga",
            sanskritName: "Lakshmi",
            category: .wealth,
            nature: .benefic,
            strength: strength,
            description: "9th lord placed in Kendra (1st, 4th, 7th, or 10th) and Venus is in own/exalted sign",
            effects: "Blessed by Goddess Lakshmi, abundant wealth, virtuous. The native enjoys all luxuries and comforts.",
            formingPlanets: formingPlanets
        )
    }

    /// Chandra-Mangal Yoga - Moon-Mars conjunction
    static func chandraMangalYoga(strength: YogaStrength) -> Yoga {
        Yoga(
            name: "Chandra-Mangal Yoga",
            sanskritName: "Chandra-Mangal",
            category: .wealth,
            nature: .benefic,
            strength: strength,
            description: "Moon and Mars are conjunct in the same sign",
            effects: "Wealth through business, real estate, or mother. The native earns money through their own enterprise.",
            formingPlanets: ["Moon", "Mars"]
        )
    }

    /// Shubh Kartari Yoga - Benefics on both sides of a house
    static func shubhKartariYoga(protectedHouse: Int, formingPlanets: [String]) -> Yoga {
        Yoga(
            name: "Shubh Kartari Yoga",
            sanskritName: "Shubha Kartari",
            category: .wealth,
            nature: .benefic,
            strength: .moderate,
            description: "Benefic planets (Jupiter, Venus, Mercury, waxing Moon) placed on both sides of house \(protectedHouse)",
            effects: "Protection and enhancement of house \(protectedHouse) significations. The matters of this house flourish.",
            formingPlanets: formingPlanets
        )
    }

    // MARK: - Raja Yoga Variations

    /// Viparita Raja Yoga - Lords of 6th, 8th, 12th mutually connected
    static func viparitaRajaYoga(formingPlanets: [String], strength: YogaStrength) -> Yoga {
        Yoga(
            name: "Viparita Raja Yoga",
            sanskritName: "Viparita Raja",
            category: .raja,
            nature: .benefic,
            strength: strength,
            description: "Lords of dusthana houses (6th, 8th, 12th) are conjunct or in mutual aspect",
            effects: "Rise through unconventional means, success after struggles. The native gains from enemies' losses or through inheritance.",
            formingPlanets: formingPlanets
        )
    }

    /// Neecha Bhanga Raja Yoga - Debilitated planet's lord in Kendra/Trikona
    static func neechaBhangaRajaYoga(debilitatedPlanet: String, strength: YogaStrength) -> Yoga {
        Yoga(
            name: "Neecha Bhanga Raja Yoga",
            sanskritName: "Neecha Bhanga Raja",
            category: .raja,
            nature: .benefic,
            strength: strength,
            description: "Debilitated \(debilitatedPlanet) has its sign lord in Kendra (1,4,7,10) or Trikona (1,5,9)",
            effects: "Transformation of weakness into strength. Initial challenges lead to great success later in life.",
            formingPlanets: [debilitatedPlanet]
        )
    }

    // MARK: - Special Yogas

    /// Parivartana Yoga - Two planets exchange signs
    static func parivartanaYoga(planet1: String, planet2: String, strength: YogaStrength) -> Yoga {
        Yoga(
            name: "Parivartana Yoga",
            sanskritName: "Parivartana",
            category: .exchange,
            nature: .benefic,
            strength: strength,
            description: "\(planet1) and \(planet2) are in mutual exchange (each in the other's sign)",
            effects: "Strong bond between the houses involved, mutual support. The significations of both houses are enhanced.",
            formingPlanets: [planet1, planet2]
        )
    }

    /// Vesi Yoga - Planet in 2nd from Sun
    static func vesiYoga(formingPlanets: [String], strength: YogaStrength) -> Yoga {
        Yoga(
            name: "Vesi Yoga",
            sanskritName: "Vesi",
            category: .solar,
            nature: .benefic,
            strength: strength,
            description: "A planet (other than Moon) is placed in the 2nd house from Sun",
            effects: "Good memory, eloquent speech, learned. The native is truthful and respected.",
            formingPlanets: formingPlanets
        )
    }

    /// Vosi Yoga - Planet in 12th from Sun
    static func vosiYoga(formingPlanets: [String], strength: YogaStrength) -> Yoga {
        Yoga(
            name: "Vosi Yoga",
            sanskritName: "Vosi",
            category: .solar,
            nature: .benefic,
            strength: strength,
            description: "A planet (other than Moon) is placed in the 12th house from Sun",
            effects: "Skillful, charitable, learned in scriptures. The native has good qualities and is respected.",
            formingPlanets: formingPlanets
        )
    }

    /// Ubhayachari Yoga - Planets in 2nd AND 12th from Sun
    static func ubhayachariYoga(formingPlanets: [String], strength: YogaStrength) -> Yoga {
        Yoga(
            name: "Ubhayachari Yoga",
            sanskritName: "Ubhayachari",
            category: .solar,
            nature: .benefic,
            strength: strength,
            description: "Planets (other than Moon) are placed in both 2nd and 12th houses from Sun",
            effects: "Equal to a king, eloquent, attractive, wealthy. The native enjoys all comforts and is respected.",
            formingPlanets: formingPlanets
        )
    }

    /// Amala Yoga - Benefic in 10th from Lagna/Moon
    static func amalaYoga(formingPlanet: String, strength: YogaStrength) -> Yoga {
        Yoga(
            name: "Amala Yoga",
            sanskritName: "Amala",
            category: .other,
            nature: .benefic,
            strength: strength,
            description: "\(formingPlanet) (a benefic) is placed in the 10th house from Lagna or Moon",
            effects: "Pure character, lasting fame, respected by rulers. The native's good deeds bring recognition.",
            formingPlanets: [formingPlanet]
        )
    }

    /// Parvata Yoga - Benefics in Kendras, 6th/8th empty
    static func parvataYoga(strength: YogaStrength) -> Yoga {
        Yoga(
            name: "Parvata Yoga",
            sanskritName: "Parvata",
            category: .other,
            nature: .benefic,
            strength: strength,
            description: "Benefic planets occupy Kendra houses while 6th and 8th houses are empty",
            effects: "Wealthy, prosperous, famous like a mountain. The native is fortunate and powerful.",
            formingPlanets: ["Jupiter", "Venus"]
        )
    }

    /// Kahala Yoga - 4th and 9th lords in mutual Kendras
    static func kahalaYoga(formingPlanets: [String], strength: YogaStrength) -> Yoga {
        Yoga(
            name: "Kahala Yoga",
            sanskritName: "Kahala",
            category: .other,
            nature: .benefic,
            strength: strength,
            description: "Lords of 4th and 9th houses are placed in mutual Kendra positions",
            effects: "Brave, leader of army, stubborn but determined. The native achieves success through courage.",
            formingPlanets: formingPlanets
        )
    }

    /// Chamara Yoga - Exalted Lagna lord in Kendra aspected by Jupiter
    static func chamaraYoga(formingPlanets: [String], strength: YogaStrength) -> Yoga {
        Yoga(
            name: "Chamara Yoga",
            sanskritName: "Chamara",
            category: .other,
            nature: .benefic,
            strength: strength,
            description: "Lagna lord is exalted, placed in Kendra, and aspected by Jupiter",
            effects: "Royal honors, learned, long-lived. The native is eloquent and skilled in many arts.",
            formingPlanets: formingPlanets
        )
    }
}
