import Foundation

/// Service for calculating composite charts (midpoint method)
/// A composite chart is created by finding the midpoint between each pair of
/// corresponding planets in two natal charts, creating a single chart that
/// represents the relationship itself.
final class CompositeChartService {
    static let shared = CompositeChartService()

    private init() {}

    // MARK: - Composite Chart Calculation

    /// Calculate a composite chart from two kundlis using the midpoint method
    func calculateCompositeChart(kundli1: Kundli, kundli2: Kundli) -> CompositeChart {
        var compositePlanets: [CompositePlanet] = []

        // Calculate midpoint for each planet
        for planet1 in kundli1.planets {
            guard let planet2 = kundli2.planets.first(where: { $0.name == planet1.name }) else {
                continue
            }

            let long1 = totalLongitude(for: planet1)
            let long2 = totalLongitude(for: planet2)

            let midpoint = calculateMidpoint(long1: long1, long2: long2)
            let compositePlanet = createCompositePlanet(
                name: planet1.name,
                symbol: planet1.symbol,
                longitude: midpoint
            )

            compositePlanets.append(compositePlanet)
        }

        // Calculate composite ascendant (midpoint of both ascendants)
        let asc1Long = Double(kundli1.ascendant.sign.number - 1) * 30 + kundli1.ascendant.degree
        let asc2Long = Double(kundli2.ascendant.sign.number - 1) * 30 + kundli2.ascendant.degree
        let compositeAscLong = calculateMidpoint(long1: asc1Long, long2: asc2Long)
        let compositeAscendant = createCompositeAscendant(longitude: compositeAscLong)

        // Calculate house placements for composite planets
        let housedPlanets = assignHouses(planets: compositePlanets, ascendantLongitude: compositeAscLong)

        // Calculate aspects between composite planets
        let aspects = calculateCompositeAspects(planets: housedPlanets)

        // Generate interpretation
        let interpretation = generateInterpretation(
            planets: housedPlanets,
            ascendant: compositeAscendant,
            aspects: aspects
        )

        return CompositeChart(
            kundli1Name: kundli1.birthDetails.name,
            kundli2Name: kundli2.birthDetails.name,
            planets: housedPlanets,
            ascendant: compositeAscendant,
            aspects: aspects,
            interpretation: interpretation
        )
    }

    // MARK: - Helper Methods

    /// Calculate total ecliptic longitude (0-360) from planet's sign and degree
    private func totalLongitude(for planet: Planet) -> Double {
        let signIndex: Int
        switch planet.sign.lowercased() {
        case "aries", "mesha": signIndex = 0
        case "taurus", "vrishabha": signIndex = 1
        case "gemini", "mithuna": signIndex = 2
        case "cancer", "karka": signIndex = 3
        case "leo", "simha": signIndex = 4
        case "virgo", "kanya": signIndex = 5
        case "libra", "tula": signIndex = 6
        case "scorpio", "vrishchika": signIndex = 7
        case "sagittarius", "dhanu": signIndex = 8
        case "capricorn", "makara": signIndex = 9
        case "aquarius", "kumbha": signIndex = 10
        case "pisces", "meena": signIndex = 11
        default: signIndex = 0
        }
        return Double(signIndex * 30) + planet.degree + Double(planet.minutes) / 60.0 + Double(planet.seconds) / 3600.0
    }

    /// Calculate midpoint between two longitudes
    /// Uses the shorter arc method to find the true midpoint
    private func calculateMidpoint(long1: Double, long2: Double) -> Double {
        var diff = long2 - long1

        // Normalize difference to -180 to +180 range
        if diff > 180 { diff -= 360 }
        if diff < -180 { diff += 360 }

        var midpoint = long1 + diff / 2

        // Normalize to 0-360 range
        if midpoint < 0 { midpoint += 360 }
        if midpoint >= 360 { midpoint -= 360 }

        return midpoint
    }

    /// Create a composite planet from longitude
    private func createCompositePlanet(name: String, symbol: String, longitude: Double) -> CompositePlanet {
        let signIndex = Int(longitude / 30) % 12
        let degree = longitude.truncatingRemainder(dividingBy: 30)
        let sign = ZodiacSign.allCases[signIndex]

        // Calculate nakshatra
        let nakshatraIndex = Int(longitude / 13.333333) % 27
        let nakshatra = Nakshatra.allCases[nakshatraIndex]
        let pada = Int((longitude.truncatingRemainder(dividingBy: 13.333333)) / 3.333333) + 1

        return CompositePlanet(
            name: name,
            symbol: symbol,
            sign: sign,
            degree: degree,
            longitude: longitude,
            nakshatra: nakshatra,
            nakshatraPada: pada,
            house: 1 // Will be updated by assignHouses
        )
    }

    /// Create composite ascendant from longitude
    private func createCompositeAscendant(longitude: Double) -> CompositeAscendant {
        let signIndex = Int(longitude / 30) % 12
        let degree = longitude.truncatingRemainder(dividingBy: 30)
        let sign = ZodiacSign.allCases[signIndex]

        let nakshatraIndex = Int(longitude / 13.333333) % 27
        let nakshatra = Nakshatra.allCases[nakshatraIndex]

        return CompositeAscendant(
            sign: sign,
            degree: degree,
            longitude: longitude,
            nakshatra: nakshatra
        )
    }

    /// Assign house numbers to planets based on ascendant
    private func assignHouses(planets: [CompositePlanet], ascendantLongitude: Double) -> [CompositePlanet] {
        return planets.map { planet in
            var housedPlanet = planet

            // Calculate house based on distance from ascendant
            var houseLong = planet.longitude - ascendantLongitude
            if houseLong < 0 { houseLong += 360 }

            let house = Int(houseLong / 30) + 1
            housedPlanet.house = house

            return housedPlanet
        }
    }

    /// Calculate aspects between composite planets
    private func calculateCompositeAspects(planets: [CompositePlanet]) -> [CompositeAspect] {
        var aspects: [CompositeAspect] = []

        let aspectOrbs: [(type: TransitAspect, orb: Double)] = [
            (.conjunction, 8),
            (.opposition, 8),
            (.trine, 7),
            (.square, 7),
            (.sextile, 5)
        ]

        for i in 0..<planets.count {
            for j in (i+1)..<planets.count {
                let planet1 = planets[i]
                let planet2 = planets[j]

                var distance = abs(planet1.longitude - planet2.longitude)
                if distance > 180 { distance = 360 - distance }

                for (aspectType, orb) in aspectOrbs {
                    if abs(distance - aspectType.degrees) <= orb {
                        let exactOrb = abs(distance - aspectType.degrees)
                        let aspect = CompositeAspect(
                            planet1: planet1.name,
                            planet1Symbol: planet1.symbol,
                            planet2: planet2.name,
                            planet2Symbol: planet2.symbol,
                            aspectType: aspectType,
                            orb: exactOrb
                        )
                        aspects.append(aspect)
                        break
                    }
                }
            }
        }

        // Sort by importance
        return aspects.sorted { $0.orb < $1.orb }
    }

    /// Generate interpretation for the composite chart
    private func generateInterpretation(
        planets: [CompositePlanet],
        ascendant: CompositeAscendant,
        aspects: [CompositeAspect]
    ) -> CompositeInterpretation {
        var themes: [String] = []
        var strengths: [String] = []
        var challenges: [String] = []

        // Analyze composite ascendant
        themes.append(interpretAscendant(ascendant))

        // Analyze key planets
        if let sun = planets.first(where: { $0.name == "Sun" }) {
            themes.append(interpretCompositeSun(sun))
        }

        if let moon = planets.first(where: { $0.name == "Moon" }) {
            themes.append(interpretCompositeMoon(moon))
        }

        if let venus = planets.first(where: { $0.name == "Venus" }) {
            strengths.append(interpretCompositeVenus(venus))
        }

        if let mars = planets.first(where: { $0.name == "Mars" }) {
            let interpretation = interpretCompositeMars(mars)
            if mars.house == 1 || mars.house == 7 {
                challenges.append(interpretation)
            } else {
                strengths.append(interpretation)
            }
        }

        // Analyze aspects
        for aspect in aspects.prefix(5) {
            let interpretation = interpretAspect(aspect)
            if aspect.aspectType.nature == .harmonious {
                strengths.append(interpretation)
            } else if aspect.aspectType.nature == .challenging {
                challenges.append(interpretation)
            }
        }

        return CompositeInterpretation(
            themes: themes,
            strengths: strengths,
            challenges: challenges
        )
    }

    private func interpretAscendant(_ asc: CompositeAscendant) -> String {
        switch asc.sign {
        case .aries:
            return "This relationship is dynamic, pioneering, and action-oriented. You inspire each other to take initiative."
        case .taurus:
            return "This relationship values stability, sensuality, and building something lasting together."
        case .gemini:
            return "Communication and intellectual connection are central to this relationship."
        case .cancer:
            return "This relationship has a strong emotional foundation and nurturing quality."
        case .leo:
            return "This relationship is creative, expressive, and brings out each other's confidence."
        case .virgo:
            return "This relationship focuses on mutual improvement, service, and practical support."
        case .libra:
            return "Harmony, balance, and partnership are the core themes of this relationship."
        case .scorpio:
            return "This relationship is intense, transformative, and deeply emotional."
        case .sagittarius:
            return "Adventure, growth, and shared philosophy define this relationship."
        case .capricorn:
            return "This relationship is goal-oriented, responsible, and builds toward long-term success."
        case .aquarius:
            return "This relationship values independence, friendship, and shared ideals."
        case .pisces:
            return "This relationship has a spiritual, compassionate, and intuitive connection."
        }
    }

    private func interpretCompositeSun(_ sun: CompositePlanet) -> String {
        "The relationship's core identity expresses through \(sun.sign.rawValue) in the \(ordinal(sun.house)) house - \(sunHouseInterpretation(sun.house))"
    }

    private func interpretCompositeMoon(_ moon: CompositePlanet) -> String {
        "Emotional needs are expressed through \(moon.sign.rawValue) - \(moonSignInterpretation(moon.sign))"
    }

    private func interpretCompositeVenus(_ venus: CompositePlanet) -> String {
        "Love and affection flow easily in \(venus.sign.rawValue) matters, especially in the \(ordinal(venus.house)) house area."
    }

    private func interpretCompositeMars(_ mars: CompositePlanet) -> String {
        "Energy and passion are directed toward \(ordinal(mars.house)) house matters with \(mars.sign.rawValue) style."
    }

    private func interpretAspect(_ aspect: CompositeAspect) -> String {
        let nature = aspect.aspectType.nature == .harmonious ? "supports" : "challenges"
        return "\(aspect.planet1)-\(aspect.planet2) \(aspect.aspectType.rawValue) \(nature) the relationship's \(aspectDomain(aspect.planet1, aspect.planet2))."
    }

    private func sunHouseInterpretation(_ house: Int) -> String {
        let interpretations = [
            1: "the relationship has a strong sense of identity",
            2: "building resources together is important",
            3: "communication and learning together thrives",
            4: "home and family are central themes",
            5: "creativity and romance flourish",
            6: "daily routines and service matter",
            7: "partnership and balance are emphasized",
            8: "deep transformation and shared resources",
            9: "growth through travel and philosophy",
            10: "public recognition and shared goals",
            11: "friendship and shared ideals",
            12: "spiritual connection and privacy"
        ]
        return interpretations[house] ?? "expressing together authentically"
    }

    private func moonSignInterpretation(_ sign: ZodiacSign) -> String {
        switch sign {
        case .aries: return "you need excitement and action"
        case .taurus: return "you need security and comfort"
        case .gemini: return "you need mental stimulation"
        case .cancer: return "you need nurturing and care"
        case .leo: return "you need appreciation and warmth"
        case .virgo: return "you need practical support"
        case .libra: return "you need harmony and fairness"
        case .scorpio: return "you need deep emotional bonding"
        case .sagittarius: return "you need freedom and adventure"
        case .capricorn: return "you need structure and commitment"
        case .aquarius: return "you need intellectual connection"
        case .pisces: return "you need spiritual understanding"
        }
    }

    private func aspectDomain(_ planet1: String, _ planet2: String) -> String {
        let planets = Set([planet1.lowercased(), planet2.lowercased()])

        if planets.contains("sun") && planets.contains("moon") {
            return "emotional harmony and identity"
        } else if planets.contains("venus") && planets.contains("mars") {
            return "passion and attraction"
        } else if planets.contains("mercury") {
            return "communication"
        } else if planets.contains("saturn") {
            return "commitment and responsibility"
        } else if planets.contains("jupiter") {
            return "growth and expansion"
        }
        return "overall dynamics"
    }

    private func ordinal(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)th"
    }
}

// MARK: - Composite Chart Models

struct CompositeChart: Identifiable {
    let id = UUID()
    let kundli1Name: String
    let kundli2Name: String
    let planets: [CompositePlanet]
    let ascendant: CompositeAscendant
    let aspects: [CompositeAspect]
    let interpretation: CompositeInterpretation
    let calculatedAt: Date = Date()

    /// Get planets in a specific house
    func planetsInHouse(_ house: Int) -> [CompositePlanet] {
        planets.filter { $0.house == house }
    }

    /// Get a specific planet by name
    func planet(named name: String) -> CompositePlanet? {
        planets.first { $0.name.lowercased() == name.lowercased() }
    }
}

struct CompositePlanet: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    let sign: ZodiacSign
    let degree: Double
    let longitude: Double
    let nakshatra: Nakshatra
    let nakshatraPada: Int
    var house: Int

    var degreeString: String {
        String(format: "%.1f°", degree)
    }

    var fullPosition: String {
        "\(sign.rawValue) \(degreeString)"
    }
}

struct CompositeAscendant {
    let sign: ZodiacSign
    let degree: Double
    let longitude: Double
    let nakshatra: Nakshatra

    var degreeString: String {
        String(format: "%.1f°", degree)
    }
}

struct CompositeAspect: Identifiable {
    let id = UUID()
    let planet1: String
    let planet1Symbol: String
    let planet2: String
    let planet2Symbol: String
    let aspectType: TransitAspect
    let orb: Double

    var nature: AspectNature {
        aspectType.nature
    }

    var description: String {
        "\(planet1Symbol) \(aspectType.symbol) \(planet2Symbol)"
    }

    var detailedDescription: String {
        "\(planet1) \(aspectType.rawValue) \(planet2) (orb: \(String(format: "%.1f", orb))°)"
    }
}

struct CompositeInterpretation {
    let themes: [String]
    let strengths: [String]
    let challenges: [String]
}

// MARK: - TransitAspect Extension

extension TransitAspect {
    var symbol: String {
        switch self {
        case .conjunction: return "☌"
        case .opposition: return "☍"
        case .trine: return "△"
        case .square: return "□"
        case .sextile: return "⚹"
        case .quincunx: return "⚻"
        }
    }

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

    var nature: AspectNature {
        switch self {
        case .conjunction: return .neutral
        case .opposition: return .challenging
        case .trine: return .harmonious
        case .square: return .challenging
        case .sextile: return .harmonious
        case .quincunx: return .adjusting
        }
    }
}
