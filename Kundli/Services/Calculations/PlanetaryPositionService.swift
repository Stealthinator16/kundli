import Foundation

/// Service for calculating planetary positions with Vedic astrological context
final class PlanetaryPositionService {
    static let shared = PlanetaryPositionService()

    private let ephemeris = EphemerisService.shared
    private let nakshatraService = NakshatraService.shared

    private init() {}

    // MARK: - Calculate All Planets

    /// Calculate positions for all 9 Vedic planets
    func calculateAllPlanets(
        date: Date,
        timezone: TimeZone,
        settings: CalculationSettings = .default
    ) -> [VedicPlanetPosition] {
        let jd = ephemeris.julianDay(for: date, timezone: timezone)

        return VedicPlanet.allCases.compactMap { planet in
            calculatePlanet(planet, julianDay: jd, settings: settings)
        }
    }

    /// Calculate position for a single planet
    func calculatePlanet(
        _ planet: VedicPlanet,
        julianDay jd: Double,
        settings: CalculationSettings = .default
    ) -> VedicPlanetPosition? {
        // Get sidereal position using the specified ayanamsa
        guard let position = ephemeris.siderealLongitude(
            planet: planet,
            julianDay: jd,
            ayanamsa: settings.ayanamsa
        ) else {
            return nil
        }

        // Get nakshatra info
        let nakshatraInfo = nakshatraService.nakshatra(fromSiderealLongitude: position.longitude)

        // Determine planetary status (dignity)
        let status = determineStatus(
            planet: planet,
            sign: position.sign,
            degree: position.degreeInSign,
            isRetrograde: position.isRetrograde
        )

        return VedicPlanetPosition(
            planet: planet,
            longitude: position.longitude,
            signIndex: position.signIndex,
            sign: position.sign,
            degreeInSign: position.degreeInSign,
            minutes: position.dms.minutes,
            seconds: position.dms.seconds,
            nakshatra: nakshatraInfo.nakshatra,
            nakshatraPada: nakshatraInfo.pada,
            nakshatraLord: nakshatraInfo.lord,
            isRetrograde: position.isRetrograde,
            speedPerDay: position.speedLongitude,
            status: status
        )
    }

    // MARK: - Calculate with Birth Details

    /// Calculate planetary positions from birth details
    func calculatePlanets(
        from birthDetails: BirthDetails,
        settings: CalculationSettings = .default
    ) -> [VedicPlanetPosition] {
        // Combine date and time
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: birthDetails.dateOfBirth)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: birthDetails.timeOfBirth)

        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        combined.second = timeComponents.second
        combined.timeZone = TimeZone(identifier: birthDetails.timezone)

        guard let birthDateTime = calendar.date(from: combined) else {
            return []
        }

        let timezone = TimeZone(identifier: birthDetails.timezone) ?? .current
        return calculateAllPlanets(date: birthDateTime, timezone: timezone, settings: settings)
    }

    // MARK: - Planetary Status (Dignity)

    /// Determine the dignity/status of a planet
    func determineStatus(
        planet: VedicPlanet,
        sign: ZodiacSign,
        degree: Double,
        isRetrograde: Bool
    ) -> PlanetStatus {
        // Check for retrograde (overrides if true)
        if isRetrograde && planet != .sun && planet != .moon {
            return .retrograde
        }

        // Check for exaltation
        if planet.isExalted(in: sign) {
            // Check if within orb of exact exaltation degree
            let orbDegree = 5.0
            if abs(degree - planet.exaltationDegree) <= orbDegree ||
               (planet.exaltationDegree > 25 && degree < 5) ||
               (planet.exaltationDegree < 5 && degree > 25) {
                return .exalted
            }
        }

        // Check for debilitation
        if planet.isDebilitated(in: sign) {
            return .debilitated
        }

        // Check for own sign
        if planet.owns(sign: sign) {
            return .ownSign
        }

        // Otherwise direct or neutral
        return isRetrograde ? .retrograde : .direct
    }

    // MARK: - Planet Details

    /// Get detailed status description
    func statusDescription(for position: VedicPlanetPosition) -> String {
        switch position.status {
        case .exalted:
            return "\(position.planet.rawValue) is exalted in \(position.sign.rawValue), indicating strong beneficial effects"
        case .debilitated:
            return "\(position.planet.rawValue) is debilitated in \(position.sign.rawValue), its effects may be weakened"
        case .ownSign:
            return "\(position.planet.rawValue) is in its own sign \(position.sign.rawValue), comfortable and effective"
        case .retrograde:
            return "\(position.planet.rawValue) is retrograde, its energy is internalized and may manifest differently"
        case .direct:
            return "\(position.planet.rawValue) is direct and functioning normally in \(position.sign.rawValue)"
        case .neutral:
            return "\(position.planet.rawValue) is in a neutral position in \(position.sign.rawValue)"
        }
    }

    // MARK: - Aspect Calculations

    /// Check if two planets are in conjunction (within orb)
    func areInConjunction(
        planet1: VedicPlanetPosition,
        planet2: VedicPlanetPosition,
        orb: Double = 10.0
    ) -> Bool {
        planet1.signIndex == planet2.signIndex ||
        abs(planet1.longitude - planet2.longitude) <= orb ||
        abs(planet1.longitude - planet2.longitude) >= (360 - orb)
    }

    /// Check if two planets aspect each other (Vedic aspects)
    func hasAspect(
        from planet: VedicPlanetPosition,
        to target: VedicPlanetPosition
    ) -> Bool {
        let houseDiff = (target.signIndex - planet.signIndex + 12) % 12

        // All planets aspect the 7th house (180°)
        if houseDiff == 6 {
            return true
        }

        // Special aspects
        switch planet.planet {
        case .mars:
            // Mars aspects 4th, 7th, 8th houses
            return houseDiff == 3 || houseDiff == 6 || houseDiff == 7
        case .jupiter:
            // Jupiter aspects 5th, 7th, 9th houses
            return houseDiff == 4 || houseDiff == 6 || houseDiff == 8
        case .saturn:
            // Saturn aspects 3rd, 7th, 10th houses
            return houseDiff == 2 || houseDiff == 6 || houseDiff == 9
        case .rahu, .ketu:
            // Rahu/Ketu aspect like Jupiter (5th, 7th, 9th)
            return houseDiff == 4 || houseDiff == 6 || houseDiff == 8
        default:
            // Other planets only aspect 7th
            return houseDiff == 6
        }
    }
}

// MARK: - Supporting Types

/// Complete Vedic planetary position information
struct VedicPlanetPosition: Identifiable {
    let id = UUID()
    let planet: VedicPlanet
    let longitude: Double           // 0-360 sidereal
    let signIndex: Int              // 0-11
    let sign: ZodiacSign
    let degreeInSign: Double        // 0-30
    let minutes: Int
    let seconds: Int
    let nakshatra: Nakshatra
    let nakshatraPada: Int          // 1-4
    let nakshatraLord: String
    let isRetrograde: Bool
    let speedPerDay: Double
    let status: PlanetStatus

    /// Formatted degree string (e.g., "15°23'45\"")
    var degreeString: String {
        String(format: "%02d°%02d'%02d\"", Int(degreeInSign), minutes, seconds)
    }

    /// Full position description
    var fullPosition: String {
        "\(sign.rawValue) \(degreeString)"
    }

    /// Nakshatra with pada
    var nakshatraWithPada: String {
        "\(nakshatra.rawValue) (Pada \(nakshatraPada))"
    }

    /// Convert to Planet model for existing UI
    func toPlanet(house: Int) -> Planet {
        Planet(
            name: planet.rawValue,
            vedName: planet.vedName,
            sign: sign.rawValue,
            vedSign: sign.vedName,
            nakshatra: nakshatra.rawValue,
            nakshatraPada: nakshatraPada,
            degree: degreeInSign,
            minutes: minutes,
            seconds: seconds,
            house: house,
            status: status,
            symbol: planet.symbol,
            lord: nakshatraLord
        )
    }
}

// MARK: - Dignity Rules Reference

/*
 Planet Dignity Rules (Vedic Astrology):

 | Planet   | Exalted    | Exact Deg | Debilitated | Own Signs            |
 |----------|------------|-----------|-------------|----------------------|
 | Sun      | Aries      | 10°       | Libra       | Leo                  |
 | Moon     | Taurus     | 3°        | Scorpio     | Cancer               |
 | Mars     | Capricorn  | 28°       | Cancer      | Aries, Scorpio       |
 | Mercury  | Virgo      | 15°       | Pisces      | Gemini, Virgo        |
 | Jupiter  | Cancer     | 5°        | Capricorn   | Sagittarius, Pisces  |
 | Venus    | Pisces     | 27°       | Virgo       | Taurus, Libra        |
 | Saturn   | Libra      | 20°       | Aries       | Capricorn, Aquarius  |
 | Rahu     | Taurus*    | 20°       | Scorpio     | Aquarius*            |
 | Ketu     | Scorpio*   | 20°       | Taurus      | Scorpio*             |

 * Rahu/Ketu dignities vary by tradition
*/
