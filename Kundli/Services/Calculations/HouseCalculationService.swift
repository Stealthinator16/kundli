import Foundation

/// Service for calculating houses (Bhavas) in Vedic astrology
final class HouseCalculationService {
    static let shared = HouseCalculationService()

    private let ephemeris = EphemerisService.shared

    private init() {}

    // MARK: - House Calculation

    /// Calculate all 12 house cusps and determine which house each planet occupies
    func calculateHouses(
        date: Date,
        timezone: TimeZone,
        location: GeoLocation,
        planets: [VedicPlanetPosition],
        settings: CalculationSettings = .default
    ) -> HouseCalculationResult {
        let jd = ephemeris.julianDay(for: date, timezone: timezone)

        // Get sidereal house cusps
        guard let houseData = ephemeris.calculateSiderealHouses(
            julianDay: jd,
            location: location,
            houseSystem: settings.houseSystem,
            ayanamsa: settings.ayanamsa
        ) else {
            // Fallback to equal house system based on ascendant
            return calculateEqualHouses(planets: planets, ascendantLongitude: 0)
        }

        // Determine ascendant sign and degree
        let ascendantSignIndex = houseData.ascendantSignIndex
        let ascendantDegree = houseData.ascendantDegreeInSign
        let ascendantSign = ZodiacSign.allCases[ascendantSignIndex]

        // Calculate nakshatra for ascendant
        let nakshatraService = NakshatraService.shared
        let ascNakshatra = nakshatraService.nakshatra(fromSiderealLongitude: houseData.ascendant)

        // Create ascendant
        let ascendant = Ascendant(
            sign: ascendantSign,
            degree: ascendantDegree,
            minutes: Int((ascendantDegree - Double(Int(ascendantDegree))) * 60),
            seconds: Int(((ascendantDegree - Double(Int(ascendantDegree))) * 60 -
                         Double(Int((ascendantDegree - Double(Int(ascendantDegree))) * 60))) * 60),
            nakshatra: ascNakshatra.nakshatra.rawValue,
            nakshatraPada: ascNakshatra.pada,
            lord: ascendantSign.lord
        )

        // Determine which house each planet is in
        let planetHouses = determinePlanetHouses(
            planets: planets,
            cusps: houseData.cusps,
            houseSystem: settings.houseSystem
        )

        // Create house information array
        var houses: [HouseInfo] = []
        for i in 0..<12 {
            let houseNumber = i + 1
            let cusp = houseData.cusps[i]
            let signIndex = Int(cusp / 30.0) % 12
            let sign = ZodiacSign.allCases[signIndex]
            let degreeInSign = cusp.truncatingRemainder(dividingBy: 30.0)

            // Find planets in this house
            let planetsInHouse = planetHouses
                .filter { $0.value == houseNumber }
                .map { $0.key }

            houses.append(HouseInfo(
                number: houseNumber,
                cusp: cusp,
                sign: sign,
                degreeInSign: degreeInSign,
                lord: sign.lord,
                planets: planetsInHouse,
                significance: houseSignificance(houseNumber)
            ))
        }

        return HouseCalculationResult(
            ascendant: ascendant,
            houses: houses,
            planetHouses: planetHouses,
            mcLongitude: houseData.mc
        )
    }

    /// Calculate houses from birth details
    func calculateHouses(
        from birthDetails: BirthDetails,
        planets: [VedicPlanetPosition],
        settings: CalculationSettings = .default
    ) -> HouseCalculationResult {
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
            return calculateEqualHouses(planets: planets, ascendantLongitude: 0)
        }

        let timezone = TimeZone(identifier: birthDetails.timezone) ?? .current
        let location = GeoLocation(from: birthDetails)

        return calculateHouses(
            date: birthDateTime,
            timezone: timezone,
            location: location,
            planets: planets,
            settings: settings
        )
    }

    // MARK: - Equal House System

    /// Calculate houses using the Equal house system
    /// Each house is exactly 30° starting from ascendant
    private func calculateEqualHouses(
        planets: [VedicPlanetPosition],
        ascendantLongitude: Double
    ) -> HouseCalculationResult {
        let ascendantSignIndex = Int(ascendantLongitude / 30.0) % 12
        let ascendantDegree = ascendantLongitude.truncatingRemainder(dividingBy: 30.0)
        let ascendantSign = ZodiacSign.allCases[ascendantSignIndex]

        // Calculate nakshatra for ascendant
        let nakshatraService = NakshatraService.shared
        let ascNakshatra = nakshatraService.nakshatra(fromSiderealLongitude: ascendantLongitude)

        let ascendant = Ascendant(
            sign: ascendantSign,
            degree: ascendantDegree,
            minutes: Int((ascendantDegree - Double(Int(ascendantDegree))) * 60),
            seconds: 0,
            nakshatra: ascNakshatra.nakshatra.rawValue,
            nakshatraPada: ascNakshatra.pada,
            lord: ascendantSign.lord
        )

        // In Equal house, each house cusp starts at the same degree as ascendant
        // but in consecutive signs
        var houses: [HouseInfo] = []
        var planetHouses: [VedicPlanet: Int] = [:]

        for i in 0..<12 {
            let houseNumber = i + 1
            let signIndex = (ascendantSignIndex + i) % 12
            let sign = ZodiacSign.allCases[signIndex]
            let cusp = Double(signIndex * 30) + ascendantDegree

            let planetsInHouse = planets.filter { planet in
                let planetSignIndex = planet.signIndex
                return planetSignIndex == signIndex
            }.map { $0.planet }

            // Update planet houses dictionary
            for planet in planetsInHouse {
                planetHouses[planet] = houseNumber
            }

            houses.append(HouseInfo(
                number: houseNumber,
                cusp: cusp,
                sign: sign,
                degreeInSign: ascendantDegree,
                lord: sign.lord,
                planets: planetsInHouse,
                significance: houseSignificance(houseNumber)
            ))
        }

        return HouseCalculationResult(
            ascendant: ascendant,
            houses: houses,
            planetHouses: planetHouses,
            mcLongitude: nil
        )
    }

    // MARK: - Planet-House Mapping

    /// Determine which house each planet occupies
    private func determinePlanetHouses(
        planets: [VedicPlanetPosition],
        cusps: [Double],
        houseSystem: HouseSystem
    ) -> [VedicPlanet: Int] {
        var planetHouses: [VedicPlanet: Int] = [:]

        for planet in planets {
            let planetLong = planet.longitude

            // For Equal and Whole Sign, use simple sign-based calculation
            if houseSystem == .equal || houseSystem == .wholeSign {
                let ascendantSignIndex = Int(cusps[0] / 30.0) % 12
                let planetSignIndex = Int(planetLong / 30.0) % 12
                let house = ((planetSignIndex - ascendantSignIndex + 12) % 12) + 1
                planetHouses[planet.planet] = house
            } else {
                // For other systems, check which cusp range the planet falls in
                var house = 12  // Default to 12th if not found
                for i in 0..<12 {
                    let currentCusp = cusps[i]
                    let nextCusp = cusps[(i + 1) % 12]

                    // Handle wrap-around at 0°
                    if nextCusp < currentCusp {
                        // Cusp crosses 0° Aries
                        if planetLong >= currentCusp || planetLong < nextCusp {
                            house = i + 1
                            break
                        }
                    } else {
                        if planetLong >= currentCusp && planetLong < nextCusp {
                            house = i + 1
                            break
                        }
                    }
                }
                planetHouses[planet.planet] = house
            }
        }

        return planetHouses
    }

    // MARK: - House Significance

    /// Get the significance/significations of each house
    func houseSignificance(_ house: Int) -> HouseSignificance {
        switch house {
        case 1: return .init(
            name: "Lagna",
            keywords: ["Self", "Body", "Personality", "Health", "Appearance"],
            category: .kendra
        )
        case 2: return .init(
            name: "Dhana",
            keywords: ["Wealth", "Family", "Speech", "Food", "Right eye"],
            category: .panaphara
        )
        case 3: return .init(
            name: "Sahaja",
            keywords: ["Siblings", "Courage", "Short journeys", "Communication", "Hands"],
            category: .apoklima
        )
        case 4: return .init(
            name: "Sukha",
            keywords: ["Mother", "Home", "Education", "Happiness", "Vehicles"],
            category: .kendra
        )
        case 5: return .init(
            name: "Putra",
            keywords: ["Children", "Intelligence", "Creativity", "Romance", "Speculation"],
            category: .trikona
        )
        case 6: return .init(
            name: "Shatru",
            keywords: ["Enemies", "Disease", "Debts", "Service", "Obstacles"],
            category: .dusthana
        )
        case 7: return .init(
            name: "Kalatra",
            keywords: ["Spouse", "Partnership", "Business", "Foreign travel", "Public"],
            category: .kendra
        )
        case 8: return .init(
            name: "Mrityu",
            keywords: ["Death", "Transformation", "Inheritance", "Occult", "Longevity"],
            category: .dusthana
        )
        case 9: return .init(
            name: "Dharma",
            keywords: ["Father", "Luck", "Religion", "Higher education", "Long journeys"],
            category: .trikona
        )
        case 10: return .init(
            name: "Karma",
            keywords: ["Career", "Status", "Authority", "Government", "Fame"],
            category: .kendra
        )
        case 11: return .init(
            name: "Labha",
            keywords: ["Gains", "Income", "Friends", "Elder siblings", "Desires fulfilled"],
            category: .panaphara
        )
        case 12: return .init(
            name: "Vyaya",
            keywords: ["Loss", "Expenses", "Foreign lands", "Moksha", "Bed pleasures"],
            category: .dusthana
        )
        default: return .init(name: "", keywords: [], category: .apoklima)
        }
    }

    // MARK: - House Classifications

    /// Get all Kendra houses (1, 4, 7, 10) - Angular houses
    var kendraHouses: [Int] { [1, 4, 7, 10] }

    /// Get all Trikona houses (1, 5, 9) - Trine houses
    var trikonaHouses: [Int] { [1, 5, 9] }

    /// Get all Dusthana houses (6, 8, 12) - Malefic houses
    var dusthanaHouses: [Int] { [6, 8, 12] }

    /// Get all Upachaya houses (3, 6, 10, 11) - Houses that improve with time
    var upachayaHouses: [Int] { [3, 6, 10, 11] }

    /// Get all Maraka houses (2, 7) - Houses related to death
    var marakaHouses: [Int] { [2, 7] }

    /// Check if a house is a Kendra
    func isKendra(_ house: Int) -> Bool {
        kendraHouses.contains(house)
    }

    /// Check if a house is a Trikona
    func isTrikona(_ house: Int) -> Bool {
        trikonaHouses.contains(house)
    }
}

// MARK: - Supporting Types

/// Result of house calculation
struct HouseCalculationResult {
    let ascendant: Ascendant
    let houses: [HouseInfo]
    let planetHouses: [VedicPlanet: Int]  // Planet to house number mapping
    let mcLongitude: Double?  // Medium Coeli longitude (if available)

    /// Get house number for a planet
    func house(for planet: VedicPlanet) -> Int {
        planetHouses[planet] ?? 1
    }

    /// Get all planets in a specific house
    func planets(in house: Int) -> [VedicPlanet] {
        houses.first { $0.number == house }?.planets ?? []
    }

    /// Get the lord of a house
    func lord(of house: Int) -> String {
        houses.first { $0.number == house }?.lord ?? ""
    }
}

/// Information about a single house
struct HouseInfo {
    let number: Int              // 1-12
    let cusp: Double             // Longitude of house cusp
    let sign: ZodiacSign         // Sign on the cusp
    let degreeInSign: Double     // Degree within sign
    let lord: String             // Ruling planet of the sign
    let planets: [VedicPlanet]   // Planets in this house
    let significance: HouseSignificance
}

/// House significance and category
struct HouseSignificance {
    let name: String             // Sanskrit name
    let keywords: [String]       // Key significations
    let category: HouseCategory
}

/// Categories of houses
enum HouseCategory: String {
    case kendra = "Kendra"       // Angular (1, 4, 7, 10)
    case trikona = "Trikona"     // Trine (1, 5, 9)
    case dusthana = "Dusthana"   // Malefic (6, 8, 12)
    case panaphara = "Panaphara" // Succedent (2, 5, 8, 11)
    case apoklima = "Apoklima"   // Cadent (3, 6, 9, 12)
}
