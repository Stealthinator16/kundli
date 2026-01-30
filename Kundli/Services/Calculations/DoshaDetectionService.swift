import Foundation

/// Service for detecting Doshas (afflictions) in a birth chart
final class DoshaDetectionService {
    static let shared = DoshaDetectionService()

    private let houseService = HouseCalculationService.shared

    private init() {}

    // MARK: - Main Detection

    /// Detect all doshas in a chart
    func detectDoshas(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> [Dosha] {
        var doshas: [Dosha] = []

        // Manglik Dosha
        if let manglik = detectManglikDosha(planets: planets, houses: houses) {
            doshas.append(manglik)
        }

        // Kaal Sarp Dosha
        if let kaalSarp = detectKaalSarpDosha(planets: planets, houses: houses) {
            doshas.append(kaalSarp)
        }

        // Kemdrum Dosha
        if let kemdrum = detectKemdrumDosha(planets: planets, houses: houses) {
            doshas.append(kemdrum)
        }

        // Pitra Dosha
        if let pitra = detectPitraDosha(planets: planets, houses: houses) {
            doshas.append(pitra)
        }

        // Grahan Dosha
        if let grahan = detectGrahanDosha(planets: planets, houses: houses) {
            doshas.append(grahan)
        }

        // Guru Chandal Dosha
        if let guruChandal = detectGuruChandalDosha(planets: planets, houses: houses) {
            doshas.append(guruChandal)
        }

        // Shrapit Dosha
        if let shrapit = detectShrapitDosha(planets: planets, houses: houses) {
            doshas.append(shrapit)
        }

        // Gandmool Dosha
        if let gandmool = detectGandmoolDosha(planets: planets, houses: houses) {
            doshas.append(gandmool)
        }

        return doshas
    }

    // MARK: - Manglik Dosha

    /// Detect Manglik (Mars) Dosha
    /// Mars in 1st, 4th, 7th, 8th, or 12th house from Lagna, Moon, or Venus
    func detectManglikDosha(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> Dosha? {
        guard let mars = planets.first(where: { $0.planet == .mars }) else {
            return nil
        }

        let manglikHouses = [1, 4, 7, 8, 12]
        let marsHouseFromLagna = houses.house(for: .mars)

        // Check from Lagna
        let fromLagna = manglikHouses.contains(marsHouseFromLagna)

        // Check from Moon
        var fromMoon = false
        if let moon = planets.first(where: { $0.planet == .moon }) {
            let marsHouseFromMoon = houseFromPlanet(mars: mars, from: moon)
            fromMoon = manglikHouses.contains(marsHouseFromMoon)
        }

        // Check from Venus
        var fromVenus = false
        if let venus = planets.first(where: { $0.planet == .venus }) {
            let marsHouseFromVenus = houseFromPlanet(mars: mars, from: venus)
            fromVenus = manglikHouses.contains(marsHouseFromVenus)
        }

        // If Mars is not in Manglik houses from any reference, no dosha
        if !fromLagna && !fromMoon && !fromVenus {
            return nil
        }

        // Check for cancellations
        var cancellations: [DoshaCancellation] = []

        // Cancellation 1: Mars in own sign (Aries, Scorpio) or exalted (Capricorn)
        let marsInOwnOrExalted = mars.status == .ownSign || mars.status == .exalted
        cancellations.append(DoshaCancellation(
            rule: "Mars in own or exalted sign",
            isActive: marsInOwnOrExalted,
            description: "Manglik dosha is cancelled when Mars is in Aries, Scorpio, or Capricorn"
        ))

        // Cancellation 2: Jupiter aspects Mars
        if let jupiter = planets.first(where: { $0.planet == .jupiter }) {
            let jupiterAspectsMars = hasAspect(from: jupiter, to: mars)
            cancellations.append(DoshaCancellation(
                rule: "Jupiter aspects Mars",
                isActive: jupiterAspectsMars,
                description: "Jupiter's benevolent aspect on Mars reduces the dosha's intensity"
            ))
        }

        // Cancellation 3: Mars in Cancer (though debilitated, some traditions cancel)
        let marsInCancer = mars.sign == .cancer
        cancellations.append(DoshaCancellation(
            rule: "Mars in Cancer (Moon's sign)",
            isActive: marsInCancer,
            description: "Some traditions consider Mars in Cancer as a cancellation"
        ))

        // Cancellation 4: Venus aspects Mars (for marriage-related dosha)
        if let venus = planets.first(where: { $0.planet == .venus }) {
            let venusAspectsMars = hasAspect(from: venus, to: mars)
            cancellations.append(DoshaCancellation(
                rule: "Venus aspects Mars",
                isActive: venusAspectsMars,
                description: "Venus aspect on Mars can mitigate marriage-related effects"
            ))
        }

        // Determine severity
        let severity: DoshaSeverity
        let activeCancellations = cancellations.filter { $0.isActive }

        if activeCancellations.count >= 2 {
            severity = .cancelled
        } else if activeCancellations.count == 1 {
            severity = .low
        } else {
            // Count how many references (Lagna, Moon, Venus) have Manglik
            let count = [fromLagna, fromMoon, fromVenus].filter { $0 }.count
            severity = count >= 2 ? .high : .medium
        }

        return .manglik(
            severity: severity,
            formingPlanets: ["Mars"],
            cancellations: cancellations,
            fromLagna: fromLagna,
            fromMoon: fromMoon,
            fromVenus: fromVenus
        )
    }

    // MARK: - Kaal Sarp Dosha

    /// Detect Kaal Sarp Dosha - All planets between Rahu and Ketu
    func detectKaalSarpDosha(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> Dosha? {
        guard let rahu = planets.first(where: { $0.planet == .rahu }),
              let ketu = planets.first(where: { $0.planet == .ketu }) else {
            return nil
        }

        let rahuHouse = houses.house(for: .rahu)
        let ketuHouse = houses.house(for: .ketu)

        // Get non-nodal planets
        let otherPlanets = planets.filter { $0.planet != .rahu && $0.planet != .ketu }

        // Check if all planets are on one side of the Rahu-Ketu axis
        var planetsWithRahu = 0
        var planetsWithKetu = 0
        var planetsOutside = 0

        for planet in otherPlanets {
            let planetHouse = houses.house(for: planet.planet)

            // Determine which side of the axis the planet is on
            if isHouseBetween(house: planetHouse, from: rahuHouse, to: ketuHouse) {
                planetsWithRahu += 1
            } else if isHouseBetween(house: planetHouse, from: ketuHouse, to: rahuHouse) {
                planetsWithKetu += 1
            } else {
                planetsOutside += 1
            }
        }

        // Check for Kaal Sarp
        let totalPlanets = otherPlanets.count
        let isFullKaalSarp = planetsWithRahu == totalPlanets || planetsWithKetu == totalPlanets
        let isPartialKaalSarp = planetsWithRahu >= 5 || planetsWithKetu >= 5

        if !isFullKaalSarp && !isPartialKaalSarp {
            return nil
        }

        // Determine the type of Kaal Sarp based on Rahu's house
        let kaalSarpType = KaalSarpType.from(rahuHouse: rahuHouse)

        // Determine severity
        let severity: DoshaSeverity
        if isFullKaalSarp {
            // Check if Rahu is in dusthana (6, 8, 12) - slightly less malefic
            if houseService.dusthanaHouses.contains(rahuHouse) {
                severity = .medium
            } else {
                severity = .high
            }
        } else {
            severity = .low
        }

        // Check for Kaal Sarp cancellations
        var cancellations: [DoshaCancellation] = []

        // Cancellation 1: Jupiter aspects Rahu or Ketu
        if let jupiter = planets.first(where: { $0.planet == .jupiter }) {
            let jupiterAspectsRahu = hasAspect(from: jupiter, to: rahu)
            let jupiterAspectsKetu = hasAspect(from: jupiter, to: ketu)
            if jupiterAspectsRahu || jupiterAspectsKetu {
                cancellations.append(DoshaCancellation(
                    rule: "Jupiter aspects Rahu/Ketu axis",
                    isActive: true,
                    description: "Jupiter's benevolent aspect on the nodal axis reduces Kaal Sarp effects"
                ))
            }
        }

        // Cancellation 2: Rahu in favorable sign (exalted or in Aquarius)
        let rahuExalted = rahu.status == .exalted
        let rahuInAquarius = rahu.sign == .aquarius
        if rahuExalted || rahuInAquarius {
            cancellations.append(DoshaCancellation(
                rule: "Rahu in favorable sign",
                isActive: true,
                description: "Rahu's placement in favorable dignity reduces dosha intensity"
            ))
        }

        // Cancellation 3: Gaja Kesari Yoga present (Moon conjunct Jupiter in Kendra)
        if let moon = planets.first(where: { $0.planet == .moon }),
           let jupiter = planets.first(where: { $0.planet == .jupiter }) {
            let moonJupiterDistance = (jupiter.signIndex - moon.signIndex + 12) % 12
            let gajaKesariPresent = [0, 3, 6, 9].contains(moonJupiterDistance)
            if gajaKesariPresent {
                cancellations.append(DoshaCancellation(
                    rule: "Gaja Kesari Yoga present",
                    isActive: true,
                    description: "Presence of Gaja Kesari Yoga mitigates Kaal Sarp effects"
                ))
            }
        }

        // Adjust severity based on cancellations
        let activeCancellations = cancellations.filter { $0.isActive }
        var finalSeverity = severity
        if activeCancellations.count >= 2 {
            finalSeverity = .cancelled
        } else if activeCancellations.count == 1 {
            finalSeverity = .low
        }

        return .kaalSarp(
            severity: finalSeverity,
            yogaType: kaalSarpType?.rawValue ?? "Unknown",
            formingPlanets: ["Rahu", "Ketu"],
            isPartial: isPartialKaalSarp && !isFullKaalSarp
        )
    }

    // MARK: - Kemdrum Dosha

    /// Detect Kemdrum Dosha - No planets in 2nd or 12th from Moon
    func detectKemdrumDosha(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> Dosha? {
        guard let moon = planets.first(where: { $0.planet == .moon }) else {
            return nil
        }

        let moonSignIndex = moon.signIndex

        // Get planets (excluding Rahu, Ketu, and Moon itself)
        let relevantPlanets = planets.filter {
            $0.planet != .moon && $0.planet != .rahu && $0.planet != .ketu
        }

        // Check 2nd house from Moon
        let secondHouseSign = (moonSignIndex + 1) % 12
        let planetsIn2nd = relevantPlanets.filter { $0.signIndex == secondHouseSign }

        // Check 12th house from Moon
        let twelfthHouseSign = (moonSignIndex + 11) % 12
        let planetsIn12th = relevantPlanets.filter { $0.signIndex == twelfthHouseSign }

        // If there are planets in either house, no Kemdrum
        if !planetsIn2nd.isEmpty || !planetsIn12th.isEmpty {
            return nil
        }

        // Check for cancellations
        var cancellations: [DoshaCancellation] = []

        // Cancellation 1: Jupiter or Venus in Kendra from Moon
        let kendraFromMoon = [0, 3, 6, 9]  // Same sign, 4th, 7th, 10th
        for planet in relevantPlanets where planet.planet == .jupiter || planet.planet == .venus {
            let distance = (planet.signIndex - moonSignIndex + 12) % 12
            if kendraFromMoon.contains(distance) {
                cancellations.append(DoshaCancellation(
                    rule: "\(planet.planet.rawValue) in Kendra from Moon",
                    isActive: true,
                    description: "Benefic in Kendra from Moon cancels Kemdrum"
                ))
            }
        }

        // Cancellation 2: Moon is Full (near Full Moon)
        // This would require additional calculation of lunar phase
        // For simplicity, check if Moon is in own sign or exalted
        if moon.status == .ownSign || moon.status == .exalted {
            cancellations.append(DoshaCancellation(
                rule: "Moon in own/exalted sign",
                isActive: true,
                description: "Strong Moon reduces Kemdrum effects"
            ))
        }

        // Cancellation 3: Moon in Kendra from Lagna
        let moonHouse = houses.house(for: .moon)
        if houseService.isKendra(moonHouse) {
            cancellations.append(DoshaCancellation(
                rule: "Moon in Kendra from Lagna",
                isActive: true,
                description: "Moon in angular house cancels Kemdrum"
            ))
        }

        // Determine severity
        let activeCancellations = cancellations.filter { $0.isActive }
        let severity: DoshaSeverity
        if activeCancellations.count >= 2 {
            severity = .cancelled
        } else if activeCancellations.count == 1 {
            severity = .low
        } else {
            severity = .medium
        }

        return .kemdrum(
            severity: severity,
            formingPlanets: ["Moon"],
            cancellations: cancellations
        )
    }

    // MARK: - Pitra Dosha

    /// Detect Pitra Dosha - Sun afflicted by Rahu/Saturn
    func detectPitraDosha(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> Dosha? {
        guard let sun = planets.first(where: { $0.planet == .sun }) else {
            return nil
        }

        var descriptions: [String] = []
        var formingPlanets: [String] = ["Sun"]
        var cancellations: [DoshaCancellation] = []

        // Check for Sun-Rahu conjunction
        if let rahu = planets.first(where: { $0.planet == .rahu }) {
            if sun.signIndex == rahu.signIndex {
                descriptions.append("Sun conjunct Rahu (Grahan Yoga)")
                formingPlanets.append("Rahu")
            }
        }

        // Check for Sun-Saturn conjunction or aspect
        if let saturn = planets.first(where: { $0.planet == .saturn }) {
            if sun.signIndex == saturn.signIndex {
                descriptions.append("Sun conjunct Saturn")
                formingPlanets.append("Saturn")
            } else if hasAspect(from: saturn, to: sun) {
                descriptions.append("Sun aspected by Saturn")
                if !formingPlanets.contains("Saturn") {
                    formingPlanets.append("Saturn")
                }
            }
        }

        // Check for Sun in 9th house with malefics
        let sunHouse = houses.house(for: .sun)
        if sunHouse == 9 {
            // Sun in 9th (house of father/ancestors) can indicate Pitra issues
            descriptions.append("Sun in 9th house (house of ancestors)")
        }

        if descriptions.isEmpty {
            return nil
        }

        // Pitra Dosha Cancellations
        // Cancellation 1: Jupiter aspects Sun
        if let jupiter = planets.first(where: { $0.planet == .jupiter }) {
            if hasAspect(from: jupiter, to: sun) {
                cancellations.append(DoshaCancellation(
                    rule: "Jupiter aspects afflicted Sun",
                    isActive: true,
                    description: "Jupiter's benevolent aspect on Sun reduces Pitra Dosha effects"
                ))
            }
        }

        // Cancellation 2: Sun in own sign (Leo) or exalted (Aries)
        if sun.status == .ownSign || sun.status == .exalted {
            cancellations.append(DoshaCancellation(
                rule: "Sun in favorable dignity",
                isActive: true,
                description: "Sun's strong placement reduces the intensity of affliction"
            ))
        }

        // Cancellation 3: Sun in Kendra with benefic aspect
        if houseService.isKendra(sunHouse) {
            if let venus = planets.first(where: { $0.planet == .venus }),
               hasAspect(from: venus, to: sun) {
                cancellations.append(DoshaCancellation(
                    rule: "Sun in Kendra with Venus aspect",
                    isActive: true,
                    description: "Beneficial placement mitigates Pitra Dosha"
                ))
            }
        }

        // Determine severity based on afflictions and cancellations
        let activeCancellations = cancellations.filter { $0.isActive }
        var severity: DoshaSeverity

        if activeCancellations.count >= 2 {
            severity = .cancelled
        } else if activeCancellations.count == 1 {
            severity = .low
        } else {
            switch descriptions.count {
            case 1: severity = .low
            case 2: severity = .medium
            default: severity = .high
            }
        }

        return .pitra(
            severity: severity,
            formingPlanets: formingPlanets,
            description: descriptions.joined(separator: "; ")
        )
    }

    // MARK: - Grahan Dosha

    /// Detect Grahan (Eclipse) Dosha - Rahu/Ketu conjunct Sun/Moon
    func detectGrahanDosha(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> Dosha? {
        guard let rahu = planets.first(where: { $0.planet == .rahu }),
              let ketu = planets.first(where: { $0.planet == .ketu }) else {
            return nil
        }

        let sun = planets.first(where: { $0.planet == .sun })
        let moon = planets.first(where: { $0.planet == .moon })

        var doshaType: String?
        var formingPlanets: [String] = []
        let orbDegrees: Double = 12.0  // Within 12 degrees

        // Check Surya Grahan (Sun-Rahu or Sun-Ketu)
        if let sun = sun {
            let sunRahuDistance = abs(sun.longitude - rahu.longitude)
            let sunKetuDistance = abs(sun.longitude - ketu.longitude)
            let normalizedSunRahu = min(sunRahuDistance, 360 - sunRahuDistance)
            let normalizedSunKetu = min(sunKetuDistance, 360 - sunKetuDistance)

            if normalizedSunRahu <= orbDegrees {
                doshaType = "Surya Grahan (Sun-Rahu)"
                formingPlanets = ["Sun", "Rahu"]
            } else if normalizedSunKetu <= orbDegrees {
                doshaType = "Surya Grahan (Sun-Ketu)"
                formingPlanets = ["Sun", "Ketu"]
            }
        }

        // Check Chandra Grahan (Moon-Rahu or Moon-Ketu)
        if let moon = moon, doshaType == nil {
            let moonRahuDistance = abs(moon.longitude - rahu.longitude)
            let moonKetuDistance = abs(moon.longitude - ketu.longitude)
            let normalizedMoonRahu = min(moonRahuDistance, 360 - moonRahuDistance)
            let normalizedMoonKetu = min(moonKetuDistance, 360 - moonKetuDistance)

            if normalizedMoonRahu <= orbDegrees {
                doshaType = "Chandra Grahan (Moon-Rahu)"
                formingPlanets = ["Moon", "Rahu"]
            } else if normalizedMoonKetu <= orbDegrees {
                doshaType = "Chandra Grahan (Moon-Ketu)"
                formingPlanets = ["Moon", "Ketu"]
            }
        }

        guard let type = doshaType else { return nil }

        // Check cancellations
        var cancellations: [DoshaCancellation] = []

        // Cancellation: Jupiter aspects the afflicted luminary
        if let jupiter = planets.first(where: { $0.planet == .jupiter }) {
            let affectedPlanet = formingPlanets.first == "Sun" ? sun : moon
            if let affected = affectedPlanet, hasAspect(from: jupiter, to: affected) {
                cancellations.append(DoshaCancellation(
                    rule: "Jupiter aspects afflicted luminary",
                    isActive: true,
                    description: "Jupiter's aspect provides protection from Grahan effects"
                ))
            }
        }

        let severity: DoshaSeverity = cancellations.isEmpty ? .medium : .low

        return .grahanDosha(
            type: type,
            severity: severity,
            formingPlanets: formingPlanets,
            cancellations: cancellations
        )
    }

    // MARK: - Guru Chandal Dosha

    /// Detect Guru Chandal Dosha - Jupiter conjunct/aspected by Rahu
    func detectGuruChandalDosha(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> Dosha? {
        guard let jupiter = planets.first(where: { $0.planet == .jupiter }),
              let rahu = planets.first(where: { $0.planet == .rahu }) else {
            return nil
        }

        let orbDegrees: Double = 10.0
        let jupiterRahuDistance = abs(jupiter.longitude - rahu.longitude)
        let normalizedDistance = min(jupiterRahuDistance, 360 - jupiterRahuDistance)

        // Check conjunction
        let isConjunct = normalizedDistance <= orbDegrees

        // Check if Rahu aspects Jupiter
        let rahuAspectsJupiter = hasAspect(from: rahu, to: jupiter)

        guard isConjunct || rahuAspectsJupiter else { return nil }

        var cancellations: [DoshaCancellation] = []

        // Cancellation: Jupiter in own sign or exalted
        if jupiter.status == .ownSign || jupiter.status == .exalted {
            cancellations.append(DoshaCancellation(
                rule: "Jupiter in favorable dignity",
                isActive: true,
                description: "Strong Jupiter reduces Guru Chandal effects"
            ))
        }

        // Cancellation: Jupiter in Kendra
        let jupiterHouse = houses.house(for: .jupiter)
        if houseService.isKendra(jupiterHouse) {
            cancellations.append(DoshaCancellation(
                rule: "Jupiter in Kendra house",
                isActive: true,
                description: "Angular placement strengthens Jupiter"
            ))
        }

        let activeCancellations = cancellations.filter { $0.isActive }
        var severity: DoshaSeverity = .medium
        if activeCancellations.count >= 2 {
            severity = .cancelled
        } else if activeCancellations.count == 1 {
            severity = .low
        }

        return .guruChandalDosha(
            severity: severity,
            formingPlanets: ["Jupiter", "Rahu"],
            cancellations: cancellations
        )
    }

    // MARK: - Shrapit Dosha

    /// Detect Shrapit Dosha - Saturn-Rahu conjunction
    func detectShrapitDosha(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> Dosha? {
        guard let saturn = planets.first(where: { $0.planet == .saturn }),
              let rahu = planets.first(where: { $0.planet == .rahu }) else {
            return nil
        }

        let orbDegrees: Double = 10.0
        let saturnRahuDistance = abs(saturn.longitude - rahu.longitude)
        let normalizedDistance = min(saturnRahuDistance, 360 - saturnRahuDistance)

        guard normalizedDistance <= orbDegrees else { return nil }

        var cancellations: [DoshaCancellation] = []

        // Cancellation: Jupiter aspects Saturn-Rahu
        if let jupiter = planets.first(where: { $0.planet == .jupiter }) {
            if hasAspect(from: jupiter, to: saturn) || hasAspect(from: jupiter, to: rahu) {
                cancellations.append(DoshaCancellation(
                    rule: "Jupiter aspects Saturn-Rahu",
                    isActive: true,
                    description: "Jupiter's aspect reduces Shrapit Dosha intensity"
                ))
            }
        }

        // Cancellation: Saturn in own sign
        if saturn.status == .ownSign || saturn.status == .exalted {
            cancellations.append(DoshaCancellation(
                rule: "Saturn in favorable dignity",
                isActive: true,
                description: "Strong Saturn placement mitigates the dosha"
            ))
        }

        let activeCancellations = cancellations.filter { $0.isActive }
        var severity: DoshaSeverity = .high
        if activeCancellations.count >= 2 {
            severity = .cancelled
        } else if activeCancellations.count == 1 {
            severity = .medium
        }

        return .shrapitDosha(
            severity: severity,
            formingPlanets: ["Saturn", "Rahu"],
            cancellations: cancellations
        )
    }

    // MARK: - Gandmool Dosha

    /// Detect Gandmool Dosha - Moon in specific nakshatras
    func detectGandmoolDosha(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> Dosha? {
        guard let moon = planets.first(where: { $0.planet == .moon }) else {
            return nil
        }

        // Gandmool nakshatras: Ashwini, Magha, Mula, Ashlesha, Jyeshtha, Revati
        let gandmoolNakshatras: [Nakshatra] = [
            .ashwini, .magha, .mula,
            .ashlesha, .jyeshtha, .revati
        ]

        guard gandmoolNakshatras.contains(moon.nakshatra) else { return nil }

        var cancellations: [DoshaCancellation] = []

        // Cancellation: Moon in own sign (Cancer) or exalted (Taurus)
        if moon.status == .ownSign || moon.status == .exalted {
            cancellations.append(DoshaCancellation(
                rule: "Moon in favorable dignity",
                isActive: true,
                description: "Strong Moon placement reduces Gandmool effects"
            ))
        }

        // Cancellation: Jupiter aspects Moon
        if let jupiter = planets.first(where: { $0.planet == .jupiter }) {
            if hasAspect(from: jupiter, to: moon) {
                cancellations.append(DoshaCancellation(
                    rule: "Jupiter aspects Moon",
                    isActive: true,
                    description: "Jupiter's benevolent aspect provides protection"
                ))
            }
        }

        // Determine severity based on nakshatra
        // Mula, Ashlesha, Jyeshtha are more severe
        let severNakshatras: [Nakshatra] = [.mula, .ashlesha, .jyeshtha]
        let isInSevereNakshatra = severNakshatras.contains(moon.nakshatra)

        let activeCancellations = cancellations.filter { $0.isActive }
        var severity: DoshaSeverity

        if activeCancellations.count >= 2 {
            severity = .cancelled
        } else if activeCancellations.count == 1 {
            severity = .low
        } else {
            severity = isInSevereNakshatra ? .medium : .low
        }

        return .gandmoolDosha(
            nakshatra: moon.nakshatra.rawValue,
            severity: severity,
            formingPlanets: ["Moon"],
            cancellations: cancellations
        )
    }

    // MARK: - Matching Doshas (for compatibility)

    /// Detect Nadi Dosha - Same Nadi in matching
    func detectNadiDosha(
        person1Moon: VedicPlanetPosition,
        person2Moon: VedicPlanetPosition
    ) -> Dosha? {
        let nadi1 = getNadiFromNakshatra(person1Moon.nakshatra)
        let nadi2 = getNadiFromNakshatra(person2Moon.nakshatra)

        guard nadi1 == nadi2 else { return nil }

        // Same nadi is a dosha
        let severity: DoshaSeverity = .high

        return .nadiDosha(
            nadi: nadi1,
            severity: severity,
            formingPlanets: ["Moon", "Moon"]
        )
    }

    /// Detect Bhakoot Dosha - 6-8 or 2-12 sign relationship
    func detectBhakootDosha(
        person1Moon: VedicPlanetPosition,
        person2Moon: VedicPlanetPosition
    ) -> Dosha? {
        let signDiff = abs(person1Moon.signIndex - person2Moon.signIndex)
        let normalizedDiff = min(signDiff, 12 - signDiff)

        var relationship: String?
        var severity: DoshaSeverity = .medium

        // 6-8 relationship (5 or 7 signs apart, 0-indexed)
        if normalizedDiff == 5 || normalizedDiff == 7 {
            relationship = "6-8"
            severity = .high
        }
        // 2-12 relationship (1 or 11 signs apart, 0-indexed)
        else if normalizedDiff == 1 || normalizedDiff == 11 {
            relationship = "2-12"
            severity = .medium
        }

        guard let rel = relationship else { return nil }

        return .bhakootDosha(
            relationship: rel,
            severity: severity,
            formingPlanets: ["Moon", "Moon"]
        )
    }

    /// Detect Gana Dosha - Incompatible Gana types
    func detectGanaDosha(
        person1Moon: VedicPlanetPosition,
        person2Moon: VedicPlanetPosition
    ) -> Dosha? {
        let gana1 = getGanaFromNakshatra(person1Moon.nakshatra)
        let gana2 = getGanaFromNakshatra(person2Moon.nakshatra)

        // Deva-Rakshasa is major dosha
        // Manushya-Rakshasa is minor dosha
        // Same gana or Deva-Manushya is okay

        var severity: DoshaSeverity?

        if (gana1 == "Deva" && gana2 == "Rakshasa") ||
           (gana1 == "Rakshasa" && gana2 == "Deva") {
            severity = .high
        } else if (gana1 == "Manushya" && gana2 == "Rakshasa") ||
                  (gana1 == "Rakshasa" && gana2 == "Manushya") {
            severity = .medium
        }

        guard let sev = severity else { return nil }

        return .ganaDosha(
            gana1: gana1,
            gana2: gana2,
            severity: sev,
            formingPlanets: ["Moon", "Moon"]
        )
    }

    // MARK: - Nadi and Gana Helpers

    /// Get Nadi from Nakshatra
    private func getNadiFromNakshatra(_ nakshatra: Nakshatra) -> String {
        // Adi (Vata) Nadi
        let adiNakshatras: [Nakshatra] = [
            .ashwini, .ardra, .punarvasu, .uttaraphalguni, .hasta, .jyeshtha,
            .mula, .shatabhisha, .purvabhadrapada
        ]
        // Madhya (Pitta) Nadi
        let madhyaNakshatras: [Nakshatra] = [
            .bharani, .mrigashira, .pushya, .purvaphalguni, .chitra, .anuradha,
            .purvaashadha, .dhanishta, .uttarabhadrapada
        ]
        // Antya (Kapha) Nadi
        let antyaNakshatras: [Nakshatra] = [
            .krittika, .rohini, .ashlesha, .magha, .swati, .vishakha,
            .uttaraashadha, .shravana, .revati
        ]

        if adiNakshatras.contains(nakshatra) {
            return "Adi"
        } else if madhyaNakshatras.contains(nakshatra) {
            return "Madhya"
        } else if antyaNakshatras.contains(nakshatra) {
            return "Antya"
        }
        return "Unknown"
    }

    /// Get Gana from Nakshatra
    private func getGanaFromNakshatra(_ nakshatra: Nakshatra) -> String {
        // Deva Gana
        let devaNakshatras: [Nakshatra] = [
            .ashwini, .mrigashira, .punarvasu, .pushya, .hasta, .swati,
            .anuradha, .shravana, .revati
        ]
        // Manushya Gana
        let manushyaNakshatras: [Nakshatra] = [
            .bharani, .rohini, .ardra, .purvaphalguni, .uttaraphalguni, .purvabhadrapada,
            .uttarabhadrapada, .purvaashadha, .uttaraashadha
        ]
        // Rakshasa Gana
        let rakshasaNakshatras: [Nakshatra] = [
            .krittika, .ashlesha, .magha, .chitra, .vishakha, .jyeshtha,
            .mula, .dhanishta, .shatabhisha
        ]

        if devaNakshatras.contains(nakshatra) {
            return "Deva"
        } else if manushyaNakshatras.contains(nakshatra) {
            return "Manushya"
        } else if rakshasaNakshatras.contains(nakshatra) {
            return "Rakshasa"
        }
        return "Unknown"
    }

    // MARK: - Helper Methods

    /// Calculate house of Mars from another planet's position
    private func houseFromPlanet(mars: VedicPlanetPosition, from planet: VedicPlanetPosition) -> Int {
        let signDiff = (mars.signIndex - planet.signIndex + 12) % 12
        return signDiff + 1  // Houses are 1-indexed
    }

    /// Check if a planet aspects another (simplified Vedic aspects)
    private func hasAspect(from planet: VedicPlanetPosition, to target: VedicPlanetPosition) -> Bool {
        let signDiff = (target.signIndex - planet.signIndex + 12) % 12

        // All planets aspect 7th
        if signDiff == 6 { return true }

        // Special aspects
        switch planet.planet {
        case .mars:
            return signDiff == 3 || signDiff == 7  // 4th and 8th
        case .jupiter:
            return signDiff == 4 || signDiff == 8  // 5th and 9th
        case .saturn:
            return signDiff == 2 || signDiff == 9  // 3rd and 10th
        default:
            return false
        }
    }

    /// Check if a house is between two houses (going clockwise)
    private func isHouseBetween(house: Int, from start: Int, to end: Int) -> Bool {
        if start < end {
            return house > start && house < end
        } else {
            // Crosses 12-1 boundary
            return house > start || house < end
        }
    }
}
