import Foundation

/// Service for Nakshatra (lunar mansion) calculations
/// Each nakshatra spans 13°20' (13.3333°) and has 4 padas of 3°20' (3.3333°) each
final class NakshatraService {
    static let shared = NakshatraService()

    /// Each nakshatra spans exactly 13°20' = 800 arc-minutes = 13.3333...°
    static let nakshatraDegrees: Double = 360.0 / 27.0  // 13.3333...

    /// Each pada (quarter) spans 3°20' = 200 arc-minutes = 3.3333...°
    static let padaDegrees: Double = nakshatraDegrees / 4.0  // 3.3333...

    private init() {}

    // MARK: - Nakshatra Calculation

    /// Calculate nakshatra from sidereal longitude (0-360)
    func nakshatra(fromSiderealLongitude longitude: Double) -> NakshatraInfo {
        // Normalize longitude to 0-360
        var normalizedLongitude = longitude
        while normalizedLongitude < 0 { normalizedLongitude += 360.0 }
        while normalizedLongitude >= 360.0 { normalizedLongitude -= 360.0 }

        // Calculate nakshatra index (0-26)
        let nakshatraIndex = Int(normalizedLongitude / NakshatraService.nakshatraDegrees)
        let nakshatra = Nakshatra.allCases[nakshatraIndex]

        // Calculate degree within nakshatra (0 to 13.3333)
        let degreeInNakshatra = normalizedLongitude.truncatingRemainder(dividingBy: NakshatraService.nakshatraDegrees)

        // Calculate pada (1-4)
        let padaIndex = Int(degreeInNakshatra / NakshatraService.padaDegrees)
        let pada = min(padaIndex + 1, 4)  // Ensure pada is 1-4

        // Calculate degree within pada (0 to 3.3333)
        let degreeInPada = degreeInNakshatra.truncatingRemainder(dividingBy: NakshatraService.padaDegrees)

        // Calculate percentage traveled in current nakshatra
        let percentageInNakshatra = (degreeInNakshatra / NakshatraService.nakshatraDegrees) * 100.0

        return NakshatraInfo(
            nakshatra: nakshatra,
            index: nakshatraIndex,
            pada: pada,
            degreeInNakshatra: degreeInNakshatra,
            degreeInPada: degreeInPada,
            percentageTraveled: percentageInNakshatra,
            absoluteLongitude: normalizedLongitude
        )
    }

    /// Get nakshatra lord (ruling planet) for a given nakshatra
    func lord(for nakshatra: Nakshatra) -> VedicPlanet {
        guard let planet = VedicPlanet.from(nakshatraLord: nakshatra.lord) else {
            // Fallback shouldn't happen but return Ketu as default
            return .ketu
        }
        return planet
    }

    /// Get all nakshatras ruled by a specific planet
    func nakshatras(ruledBy planet: VedicPlanet) -> [Nakshatra] {
        Nakshatra.allCases.filter { $0.lord == planet.rawValue }
    }

    // MARK: - Nakshatra Navigation

    /// Get the starting longitude of a nakshatra (in sidereal zodiac)
    func startingLongitude(of nakshatra: Nakshatra) -> Double {
        guard let index = Nakshatra.allCases.firstIndex(of: nakshatra) else {
            return 0
        }
        return Double(index) * NakshatraService.nakshatraDegrees
    }

    /// Get the ending longitude of a nakshatra
    func endingLongitude(of nakshatra: Nakshatra) -> Double {
        startingLongitude(of: nakshatra) + NakshatraService.nakshatraDegrees
    }

    /// Get the nakshatra at a specific pada boundary
    func nakshatra(atPadaBoundary padaNumber: Int) -> Nakshatra {
        // There are 108 padas total (27 * 4)
        let normalizedPada = ((padaNumber - 1) % 108)
        let nakshatraIndex = normalizedPada / 4
        return Nakshatra.allCases[nakshatraIndex]
    }

    // MARK: - Dasha Calculation Helpers

    /// Calculate the remaining percentage of the current nakshatra
    /// This is used for calculating dasha balance at birth
    func remainingPercentage(fromSiderealLongitude longitude: Double) -> Double {
        let info = nakshatra(fromSiderealLongitude: longitude)
        return 100.0 - info.percentageTraveled
    }

    /// Get the starting dasha planet based on Moon's nakshatra
    func startingDashaPlanet(moonLongitude: Double) -> VedicPlanet {
        let info = nakshatra(fromSiderealLongitude: moonLongitude)
        return lord(for: info.nakshatra)
    }

    /// Calculate dasha balance at birth
    /// Returns the remaining years of the first dasha
    func dashaBalanceAtBirth(moonLongitude: Double) -> (planet: VedicPlanet, remainingYears: Double) {
        let info = nakshatra(fromSiderealLongitude: moonLongitude)
        let planet = lord(for: info.nakshatra)
        let remainingPercentage = (100.0 - info.percentageTraveled) / 100.0
        let remainingYears = Double(planet.dashaYears) * remainingPercentage
        return (planet, remainingYears)
    }

    // MARK: - Navamsa Sign from Nakshatra Pada

    /// Calculate the Navamsa sign from nakshatra and pada
    /// This is an alternative method to direct D-9 calculation
    func navamsaSign(nakshatra: Nakshatra, pada: Int) -> ZodiacSign {
        guard let nakshatraIndex = Nakshatra.allCases.firstIndex(of: nakshatra) else {
            return .aries
        }

        // Each pada corresponds to one navamsa
        // Pada 1 of Ashwini = Aries, Pada 2 = Taurus, etc.
        let totalPada = nakshatraIndex * 4 + (pada - 1)
        let navamsaIndex = totalPada % 12

        return ZodiacSign.allCases[navamsaIndex]
    }
}

// MARK: - Supporting Types

/// Detailed nakshatra information
struct NakshatraInfo {
    let nakshatra: Nakshatra
    let index: Int                    // 0-26
    let pada: Int                     // 1-4
    let degreeInNakshatra: Double     // 0-13.3333
    let degreeInPada: Double          // 0-3.3333
    let percentageTraveled: Double    // 0-100
    let absoluteLongitude: Double     // 0-360

    var lord: String {
        nakshatra.lord
    }

    var lordPlanet: VedicPlanet? {
        VedicPlanet.from(nakshatraLord: lord)
    }

    var formatted: String {
        "\(nakshatra.rawValue) Pada \(pada)"
    }

    var detailedDescription: String {
        let deg = Int(degreeInNakshatra)
        let min = Int((degreeInNakshatra - Double(deg)) * 60)
        return "\(nakshatra.rawValue) - \(deg)°\(min)' (Pada \(pada))"
    }
}

// MARK: - Nakshatra Extensions

extension Nakshatra {
    /// Get the Vimshottari Dasha ruling planet
    var dashaLord: VedicPlanet? {
        VedicPlanet.from(nakshatraLord: lord)
    }

    /// Get the navamsa starting sign for this nakshatra
    var navamsaStartSign: ZodiacSign {
        guard let index = Nakshatra.allCases.firstIndex(of: self) else {
            return .aries
        }
        // Each group of 9 nakshatras starts the navamsa cycle from Aries, Leo, or Sagittarius
        let groupIndex = index / 9
        let startSignIndex = (groupIndex * 4) % 12
        return ZodiacSign.allCases[startSignIndex]
    }

    /// Get the nature/characteristic of the nakshatra
    var nature: NakshatraNature {
        switch self {
        case .ashwini, .pushya, .hasta:
            return .laghu   // Light, swift
        case .bharani, .magha, .purvaphalguni, .purvaashadha, .purvabhadrapada:
            return .ugra    // Fierce
        case .krittika, .ashlesha, .vishakha:
            return .mixed   // Mixed nature
        case .rohini, .uttaraphalguni, .uttaraashadha, .uttarabhadrapada:
            return .dhruva  // Fixed, stable
        case .mrigashira, .chitra, .anuradha:
            return .mridu   // Soft, tender
        case .ardra, .jyeshtha, .mula:
            return .tikshna // Sharp, dreadful
        case .punarvasu, .swati, .shravana, .dhanishta, .shatabhisha:
            return .chara   // Movable
        case .revati:
            return .mridu   // Soft
        }
    }
}

/// Nature categories of nakshatras
enum NakshatraNature: String, CaseIterable {
    case laghu = "Light"       // Good for quick, light activities
    case ugra = "Fierce"       // Good for aggressive actions
    case mixed = "Mixed"       // Neutral, depends on other factors
    case dhruva = "Fixed"      // Good for stable, permanent actions
    case mridu = "Soft"        // Good for gentle, creative activities
    case tikshna = "Sharp"     // Good for severe, harsh actions
    case chara = "Movable"     // Good for travel, changes

    var description: String {
        switch self {
        case .laghu: return "Suitable for quick tasks, learning, starting businesses"
        case .ugra: return "Suitable for confrontation, competition, surgery"
        case .mixed: return "Can be used for various purposes"
        case .dhruva: return "Suitable for building, laying foundations, long-term projects"
        case .mridu: return "Suitable for arts, romance, making friends"
        case .tikshna: return "Suitable for defeating enemies, casting spells, black magic"
        case .chara: return "Suitable for travel, vehicle purchase, gardening"
        }
    }
}
