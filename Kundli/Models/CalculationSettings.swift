import Foundation

/// Settings for astrological calculations
struct CalculationSettings: Codable, Equatable {
    let ayanamsa: Ayanamsa
    let houseSystem: HouseSystem
    let nodeType: NodeType

    init(
        ayanamsa: Ayanamsa = .lahiri,
        houseSystem: HouseSystem = .equal,
        nodeType: NodeType = .mean
    ) {
        self.ayanamsa = ayanamsa
        self.houseSystem = houseSystem
        self.nodeType = nodeType
    }

    /// Default calculation settings using Lahiri ayanamsa and Equal house system
    static let `default` = CalculationSettings()

    /// KP (Krishnamurti Paddhati) calculation settings
    static let kp = CalculationSettings(
        ayanamsa: .krishnamurti,
        houseSystem: .placidus,
        nodeType: .mean
    )
}

// MARK: - Ayanamsa Types
/// Ayanamsa is the angular difference between the tropical and sidereal zodiac
enum Ayanamsa: String, Codable, CaseIterable {
    case lahiri = "Lahiri"
    case raman = "Raman"
    case krishnamurti = "Krishnamurti"
    case fagan = "Fagan-Bradley"
    case trueChitra = "True Chitrapaksha"

    /// Swiss Ephemeris ayanamsa ID
    var swissEphemerisId: Int32 {
        switch self {
        case .lahiri: return 1         // SE_SIDM_LAHIRI
        case .raman: return 3          // SE_SIDM_RAMAN
        case .krishnamurti: return 5   // SE_SIDM_KRISHNAMURTI
        case .fagan: return 0          // SE_SIDM_FAGAN_BRADLEY
        case .trueChitra: return 27    // SE_SIDM_TRUE_CITRA
        }
    }

    var description: String {
        switch self {
        case .lahiri:
            return "Most widely used in India, based on the star Spica (Chitra)"
        case .raman:
            return "Used by B.V. Raman, slightly different from Lahiri"
        case .krishnamurti:
            return "Used in KP system, based on Krishnamurti's calculations"
        case .fagan:
            return "Western sidereal astrology standard"
        case .trueChitra:
            return "True position of Chitra star at 180°"
        }
    }
}

// MARK: - House Systems
enum HouseSystem: String, Codable, CaseIterable {
    case equal = "Equal"
    case wholeSign = "Whole Sign"
    case placidus = "Placidus"
    case koch = "Koch"
    case sriPati = "Sripati"
    case bhava = "Bhava Chalita"

    /// Swiss Ephemeris house system character
    var swissEphemerisChar: CChar {
        switch self {
        case .equal: return CChar(Character("A").asciiValue!)       // Equal (cusp 1 is Ascendant)
        case .wholeSign: return CChar(Character("W").asciiValue!)   // Whole sign
        case .placidus: return CChar(Character("P").asciiValue!)    // Placidus
        case .koch: return CChar(Character("K").asciiValue!)        // Koch
        case .sriPati: return CChar(Character("A").asciiValue!)     // Use Equal for Sripati midpoints
        case .bhava: return CChar(Character("A").asciiValue!)       // Bhava Chalita uses Equal + midpoints
        }
    }

    var description: String {
        switch self {
        case .equal:
            return "Each house is exactly 30°, starting from ascendant"
        case .wholeSign:
            return "Each sign is a complete house"
        case .placidus:
            return "Time-based division, most popular in Western astrology"
        case .koch:
            return "Space-based division similar to Placidus"
        case .sriPati:
            return "Midpoint system between Bhava cusps"
        case .bhava:
            return "Traditional Vedic house system with midpoints"
        }
    }
}

// MARK: - Node Type (Rahu/Ketu)
enum NodeType: String, Codable, CaseIterable {
    case mean = "Mean"
    case `true` = "True"

    var description: String {
        switch self {
        case .mean:
            return "Average position of lunar nodes (smoother motion)"
        case .true:
            return "Actual position of lunar nodes (oscillates)"
        }
    }

    /// Swiss Ephemeris flag for node calculation
    var swissEphemerisId: Int32 {
        switch self {
        case .mean: return 10  // SE_MEAN_NODE
        case .true: return 11  // SE_TRUE_NODE
        }
    }
}
