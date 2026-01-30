import Foundation

/// Represents the 9 Vedic planets (Navagraha) used in Jyotish
enum VedicPlanet: String, CaseIterable, Codable {
    case sun = "Sun"
    case moon = "Moon"
    case mars = "Mars"
    case mercury = "Mercury"
    case jupiter = "Jupiter"
    case venus = "Venus"
    case saturn = "Saturn"
    case rahu = "Rahu"
    case ketu = "Ketu"

    /// Swiss Ephemeris planet ID
    /// SE_SUN = 0, SE_MOON = 1, SE_MARS = 4, SE_MERCURY = 2, SE_JUPITER = 5
    /// SE_VENUS = 3, SE_SATURN = 6, SE_MEAN_NODE (Rahu) = 10
    var swissEphemerisId: Int32 {
        switch self {
        case .sun: return 0       // SE_SUN
        case .moon: return 1      // SE_MOON
        case .mars: return 4      // SE_MARS
        case .mercury: return 2   // SE_MERCURY
        case .jupiter: return 5   // SE_JUPITER
        case .venus: return 3     // SE_VENUS
        case .saturn: return 6    // SE_SATURN
        case .rahu: return 10     // SE_MEAN_NODE (Mean Lunar Node)
        case .ketu: return 10     // Ketu is calculated as Rahu + 180°
        }
    }

    /// Sanskrit/Vedic name of the planet
    var vedName: String {
        switch self {
        case .sun: return "Surya"
        case .moon: return "Chandra"
        case .mars: return "Mangal"
        case .mercury: return "Budha"
        case .jupiter: return "Guru"
        case .venus: return "Shukra"
        case .saturn: return "Shani"
        case .rahu: return "Rahu"
        case .ketu: return "Ketu"
        }
    }

    /// Short symbol for chart display
    var symbol: String {
        switch self {
        case .sun: return "Su"
        case .moon: return "Mo"
        case .mars: return "Ma"
        case .mercury: return "Me"
        case .jupiter: return "Ju"
        case .venus: return "Ve"
        case .saturn: return "Sa"
        case .rahu: return "Ra"
        case .ketu: return "Ke"
        }
    }

    /// Vimshottari Dasha years for this planet
    var dashaYears: Int {
        switch self {
        case .sun: return 6
        case .moon: return 10
        case .mars: return 7
        case .rahu: return 18
        case .jupiter: return 16
        case .saturn: return 19
        case .mercury: return 17
        case .ketu: return 7
        case .venus: return 20
        }
    }

    /// Signs where this planet is exalted
    var exaltationSign: ZodiacSign {
        switch self {
        case .sun: return .aries
        case .moon: return .taurus
        case .mars: return .capricorn
        case .mercury: return .virgo
        case .jupiter: return .cancer
        case .venus: return .pisces
        case .saturn: return .libra
        case .rahu: return .taurus    // Some traditions use Gemini
        case .ketu: return .scorpio   // Some traditions use Sagittarius
        }
    }

    /// Exact degree of maximum exaltation
    var exaltationDegree: Double {
        switch self {
        case .sun: return 10.0
        case .moon: return 3.0
        case .mars: return 28.0
        case .mercury: return 15.0
        case .jupiter: return 5.0
        case .venus: return 27.0
        case .saturn: return 20.0
        case .rahu: return 20.0
        case .ketu: return 20.0
        }
    }

    /// Signs where this planet is debilitated
    var debilitationSign: ZodiacSign {
        switch self {
        case .sun: return .libra
        case .moon: return .scorpio
        case .mars: return .cancer
        case .mercury: return .pisces
        case .jupiter: return .capricorn
        case .venus: return .virgo
        case .saturn: return .aries
        case .rahu: return .scorpio
        case .ketu: return .taurus
        }
    }

    /// Signs owned by this planet
    var ownSigns: [ZodiacSign] {
        switch self {
        case .sun: return [.leo]
        case .moon: return [.cancer]
        case .mars: return [.aries, .scorpio]
        case .mercury: return [.gemini, .virgo]
        case .jupiter: return [.sagittarius, .pisces]
        case .venus: return [.taurus, .libra]
        case .saturn: return [.capricorn, .aquarius]
        case .rahu: return [.aquarius]  // Co-rulership in Vedic astrology
        case .ketu: return [.scorpio]   // Co-rulership in Vedic astrology
        }
    }

    /// Check if planet owns the given sign
    func owns(sign: ZodiacSign) -> Bool {
        ownSigns.contains(sign)
    }

    /// Check if planet is exalted in the given sign
    func isExalted(in sign: ZodiacSign) -> Bool {
        sign == exaltationSign
    }

    /// Check if planet is debilitated in the given sign
    func isDebilitated(in sign: ZodiacSign) -> Bool {
        sign == debilitationSign
    }
}

// MARK: - Vimshottari Dasha Sequence
extension VedicPlanet {
    /// The standard Vimshottari Dasha sequence (120-year cycle)
    static let vimshottariSequence: [VedicPlanet] = [
        .ketu, .venus, .sun, .moon, .mars, .rahu, .jupiter, .saturn, .mercury
    ]

    /// Get the next planet in Vimshottari sequence
    var nextInVimshottari: VedicPlanet {
        let sequence = VedicPlanet.vimshottariSequence
        guard let currentIndex = sequence.firstIndex(of: self) else {
            return .ketu
        }
        let nextIndex = (currentIndex + 1) % sequence.count
        return sequence[nextIndex]
    }

    /// Create from nakshatra lord name
    static func from(nakshatraLord: String) -> VedicPlanet? {
        switch nakshatraLord.lowercased() {
        case "ketu": return .ketu
        case "venus", "shukra": return .venus
        case "sun", "surya": return .sun
        case "moon", "chandra": return .moon
        case "mars", "mangal": return .mars
        case "rahu": return .rahu
        case "jupiter", "guru": return .jupiter
        case "saturn", "shani": return .saturn
        case "mercury", "budha": return .mercury
        default: return nil
        }
    }
}
