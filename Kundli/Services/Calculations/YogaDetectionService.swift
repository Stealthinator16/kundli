import Foundation

/// Service for detecting Yogas (planetary combinations) in a birth chart
final class YogaDetectionService {
    static let shared = YogaDetectionService()

    private let houseService = HouseCalculationService.shared

    private init() {}

    // MARK: - Main Detection

    /// Detect all yogas in a chart
    func detectYogas(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> [Yoga] {
        var yogas: [Yoga] = []

        // Panch Mahapurusha Yogas
        yogas.append(contentsOf: detectMahapurushaYogas(planets: planets, houses: houses))

        // Gaja Kesari Yoga
        if let gajaKesari = detectGajaKesariYoga(planets: planets, houses: houses) {
            yogas.append(gajaKesari)
        }

        // Budhaditya Yoga
        if let budhaditya = detectBudhadityaYoga(planets: planets, houses: houses) {
            yogas.append(budhaditya)
        }

        // Raja Yogas
        yogas.append(contentsOf: detectRajaYogas(planets: planets, houses: houses))

        // Lunar Yogas
        yogas.append(contentsOf: detectLunarYogas(planets: planets, houses: houses))

        // Wealth Yogas
        yogas.append(contentsOf: detectWealthYogas(planets: planets, houses: houses))

        // Raja Yoga Variations
        yogas.append(contentsOf: detectRajaYogaVariations(planets: planets, houses: houses))

        // Special Yogas
        yogas.append(contentsOf: detectSpecialYogas(planets: planets, houses: houses))

        return yogas
    }

    // MARK: - Panch Mahapurusha Yogas

    /// Detect the five Mahapurusha Yogas (Ruchaka, Bhadra, Hamsa, Malavya, Sasa)
    func detectMahapurushaYogas(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> [Yoga] {
        var yogas: [Yoga] = []

        // Check Mars for Ruchaka Yoga
        if let mars = planets.first(where: { $0.planet == .mars }) {
            let house = houses.house(for: .mars)
            if houseService.isKendra(house) && isInOwnOrExaltedSign(planet: .mars, position: mars) {
                let strength = determineYogaStrength(planet: mars, house: house)
                yogas.append(.ruchaka(strength: strength, formingPlanets: ["Mars"]))
            }
        }

        // Check Mercury for Bhadra Yoga
        if let mercury = planets.first(where: { $0.planet == .mercury }) {
            let house = houses.house(for: .mercury)
            if houseService.isKendra(house) && isInOwnOrExaltedSign(planet: .mercury, position: mercury) {
                let strength = determineYogaStrength(planet: mercury, house: house)
                yogas.append(.bhadra(strength: strength, formingPlanets: ["Mercury"]))
            }
        }

        // Check Jupiter for Hamsa Yoga
        if let jupiter = planets.first(where: { $0.planet == .jupiter }) {
            let house = houses.house(for: .jupiter)
            if houseService.isKendra(house) && isInOwnOrExaltedSign(planet: .jupiter, position: jupiter) {
                let strength = determineYogaStrength(planet: jupiter, house: house)
                yogas.append(.hamsa(strength: strength, formingPlanets: ["Jupiter"]))
            }
        }

        // Check Venus for Malavya Yoga
        if let venus = planets.first(where: { $0.planet == .venus }) {
            let house = houses.house(for: .venus)
            if houseService.isKendra(house) && isInOwnOrExaltedSign(planet: .venus, position: venus) {
                let strength = determineYogaStrength(planet: venus, house: house)
                yogas.append(.malavya(strength: strength, formingPlanets: ["Venus"]))
            }
        }

        // Check Saturn for Sasa Yoga
        if let saturn = planets.first(where: { $0.planet == .saturn }) {
            let house = houses.house(for: .saturn)
            if houseService.isKendra(house) && isInOwnOrExaltedSign(planet: .saturn, position: saturn) {
                let strength = determineYogaStrength(planet: saturn, house: house)
                yogas.append(.sasa(strength: strength, formingPlanets: ["Saturn"]))
            }
        }

        return yogas
    }

    // MARK: - Gaja Kesari Yoga

    /// Detect Gaja Kesari Yoga - Jupiter in kendra from Moon
    func detectGajaKesariYoga(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> Yoga? {
        guard let moon = planets.first(where: { $0.planet == .moon }),
              let jupiter = planets.first(where: { $0.planet == .jupiter }) else {
            return nil
        }

        // Calculate house distance from Moon to Jupiter
        let moonSign = moon.signIndex
        let jupiterSign = jupiter.signIndex
        let distance = (jupiterSign - moonSign + 12) % 12

        // Jupiter should be in 1st, 4th, 7th, or 10th from Moon
        let isInKendraFromMoon = [0, 3, 6, 9].contains(distance)

        if isInKendraFromMoon {
            // Determine strength
            var strength: YogaStrength = .moderate

            // Stronger if Jupiter is in own/exalted sign
            if isInOwnOrExaltedSign(planet: .jupiter, position: jupiter) {
                strength = .strong
            }

            // Weaker if Jupiter is debilitated or retrograde
            if jupiter.status == .debilitated || jupiter.isRetrograde {
                strength = .weak
            }

            return .gajaKesari(
                strength: strength,
                formingPlanets: ["Moon", "Jupiter"]
            )
        }

        return nil
    }

    // MARK: - Budhaditya Yoga

    /// Detect Budhaditya Yoga - Sun and Mercury conjunction
    func detectBudhadityaYoga(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> Yoga? {
        guard let sun = planets.first(where: { $0.planet == .sun }),
              let mercury = planets.first(where: { $0.planet == .mercury }) else {
            return nil
        }

        // Check if Sun and Mercury are in the same sign
        if sun.signIndex == mercury.signIndex {
            var strength: YogaStrength = .moderate

            // Stronger if both are in good houses (not dusthana)
            let sunHouse = houses.house(for: .sun)
            if !houseService.dusthanaHouses.contains(sunHouse) {
                if sun.status == .exalted || mercury.status == .exalted {
                    strength = .strong
                }
            } else {
                strength = .weak
            }

            // Combust Mercury weakens the yoga
            let distance = abs(sun.degreeInSign - mercury.degreeInSign)
            if distance < 3 {  // Mercury combust within 3°
                strength = .weak
            }

            return .budhaditya(
                strength: strength,
                formingPlanets: ["Sun", "Mercury"]
            )
        }

        return nil
    }

    // MARK: - Raja Yogas

    /// Detect Raja Yogas - Kendra lord + Trikona lord connection
    func detectRajaYogas(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> [Yoga] {
        var yogas: [Yoga] = []

        // Get lords of Kendra houses (1, 4, 7, 10)
        let kendraLords = houseService.kendraHouses.compactMap { house -> String? in
            houses.houses.first { $0.number == house }?.lord
        }

        // Get lords of Trikona houses (5, 9) - excluding 1st which is both
        let trikonaLords = [5, 9].compactMap { house -> String? in
            houses.houses.first { $0.number == house }?.lord
        }

        // Check for conjunctions or mutual aspects between Kendra and Trikona lords
        for kendraLord in kendraLords {
            for trikonaLord in trikonaLords {
                guard kendraLord != trikonaLord else { continue }

                guard let kendraPosition = planets.first(where: { $0.planet.rawValue == kendraLord }),
                      let trikonaPosition = planets.first(where: { $0.planet.rawValue == trikonaLord }) else {
                    continue
                }

                // Check for conjunction (same sign)
                if kendraPosition.signIndex == trikonaPosition.signIndex {
                    let description = "\(kendraLord) (Kendra lord) conjunct with \(trikonaLord) (Trikona lord)"
                    let strength = determineRajaYogaStrength(
                        kendraPosition: kendraPosition,
                        trikonaPosition: trikonaPosition
                    )

                    yogas.append(.raja(
                        strength: strength,
                        formingPlanets: [kendraLord, trikonaLord],
                        description: description
                    ))
                }

                // Check for mutual aspect (7th house aspect)
                let signDiff = abs(kendraPosition.signIndex - trikonaPosition.signIndex)
                if signDiff == 6 || signDiff == 0 {  // Opposition or conjunction
                    let description = "\(kendraLord) (Kendra lord) aspects \(trikonaLord) (Trikona lord)"
                    yogas.append(.raja(
                        strength: .moderate,
                        formingPlanets: [kendraLord, trikonaLord],
                        description: description
                    ))
                }
            }
        }

        return yogas
    }

    // MARK: - Lunar Yogas

    /// Detect all lunar yogas
    func detectLunarYogas(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> [Yoga] {
        var yogas: [Yoga] = []

        guard let moon = planets.first(where: { $0.planet == .moon }) else {
            return yogas
        }

        // Sunapha Yoga
        if let sunapha = detectSunaphaYoga(planets: planets, moon: moon) {
            yogas.append(sunapha)
        }

        // Anapha Yoga
        if let anapha = detectAnaphaYoga(planets: planets, moon: moon) {
            yogas.append(anapha)
        }

        // Durudhara Yoga
        if let durudhara = detectDurudharaYoga(planets: planets, moon: moon) {
            yogas.append(durudhara)
        }

        // Adhi Yoga
        if let adhiYoga = detectAdhiYoga(planets: planets, moon: moon) {
            yogas.append(adhiYoga)
        }

        return yogas
    }

    /// Sunapha Yoga - Planet (not Sun/Rahu/Ketu) in 2nd from Moon
    func detectSunaphaYoga(planets: [VedicPlanetPosition], moon: VedicPlanetPosition) -> Yoga? {
        let excludedPlanets: [VedicPlanet] = [.sun, .moon, .rahu, .ketu]
        let secondFromMoon = (moon.signIndex + 1) % 12

        let planetsIn2nd = planets.filter { planet in
            !excludedPlanets.contains(planet.planet) && planet.signIndex == secondFromMoon
        }

        guard !planetsIn2nd.isEmpty else { return nil }

        let formingPlanets = planetsIn2nd.map { $0.planet.rawValue }
        let strength = determineYogaStrengthFromPlanets(planetsIn2nd)

        return .sunapha(formingPlanets: formingPlanets, strength: strength)
    }

    /// Anapha Yoga - Planet (not Sun/Rahu/Ketu) in 12th from Moon
    func detectAnaphaYoga(planets: [VedicPlanetPosition], moon: VedicPlanetPosition) -> Yoga? {
        let excludedPlanets: [VedicPlanet] = [.sun, .moon, .rahu, .ketu]
        let twelfthFromMoon = (moon.signIndex + 11) % 12

        let planetsIn12th = planets.filter { planet in
            !excludedPlanets.contains(planet.planet) && planet.signIndex == twelfthFromMoon
        }

        guard !planetsIn12th.isEmpty else { return nil }

        let formingPlanets = planetsIn12th.map { $0.planet.rawValue }
        let strength = determineYogaStrengthFromPlanets(planetsIn12th)

        return .anapha(formingPlanets: formingPlanets, strength: strength)
    }

    /// Durudhara Yoga - Planets in BOTH 2nd AND 12th from Moon
    func detectDurudharaYoga(planets: [VedicPlanetPosition], moon: VedicPlanetPosition) -> Yoga? {
        let excludedPlanets: [VedicPlanet] = [.sun, .moon, .rahu, .ketu]
        let secondFromMoon = (moon.signIndex + 1) % 12
        let twelfthFromMoon = (moon.signIndex + 11) % 12

        let planetsIn2nd = planets.filter { planet in
            !excludedPlanets.contains(planet.planet) && planet.signIndex == secondFromMoon
        }

        let planetsIn12th = planets.filter { planet in
            !excludedPlanets.contains(planet.planet) && planet.signIndex == twelfthFromMoon
        }

        guard !planetsIn2nd.isEmpty && !planetsIn12th.isEmpty else { return nil }

        let formingPlanets = (planetsIn2nd + planetsIn12th).map { $0.planet.rawValue }
        let allPlanets = planetsIn2nd + planetsIn12th
        let strength = determineYogaStrengthFromPlanets(allPlanets)

        return .durudhara(formingPlanets: formingPlanets, strength: strength)
    }

    /// Adhi Yoga - Jupiter/Venus/Mercury in 6th, 7th, or 8th from Moon
    func detectAdhiYoga(planets: [VedicPlanetPosition], moon: VedicPlanetPosition) -> Yoga? {
        let adhiPlanets: [VedicPlanet] = [.jupiter, .venus, .mercury]
        let adhiHouses = [5, 6, 7]  // 6th, 7th, 8th from Moon (0-indexed: 5, 6, 7)

        var foundPlanets: [VedicPlanetPosition] = []

        for house in adhiHouses {
            let signIndex = (moon.signIndex + house) % 12
            let planetsInHouse = planets.filter { planet in
                adhiPlanets.contains(planet.planet) && planet.signIndex == signIndex
            }
            foundPlanets.append(contentsOf: planetsInHouse)
        }

        guard !foundPlanets.isEmpty else { return nil }

        let formingPlanets = foundPlanets.map { $0.planet.rawValue }
        var strength: YogaStrength = .weak

        // Stronger based on number of benefics involved
        if foundPlanets.count >= 3 {
            strength = .strong
        } else if foundPlanets.count == 2 {
            strength = .moderate
        }

        return .adhiYoga(formingPlanets: formingPlanets, strength: strength)
    }

    // MARK: - Wealth Yogas

    /// Detect all wealth yogas
    func detectWealthYogas(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> [Yoga] {
        var yogas: [Yoga] = []

        // Dhana Yoga variations
        yogas.append(contentsOf: detectDhanaYoga(planets: planets, houses: houses))

        // Lakshmi Yoga
        if let lakshmi = detectLakshmiYoga(planets: planets, houses: houses) {
            yogas.append(lakshmi)
        }

        // Chandra-Mangal Yoga
        if let chandraMangal = detectChandraMangalYoga(planets: planets) {
            yogas.append(chandraMangal)
        }

        // Shubh Kartari Yoga
        yogas.append(contentsOf: detectShubhKartariYoga(planets: planets, houses: houses))

        return yogas
    }

    /// Dhana Yoga - 2nd lord + 11th lord connection
    func detectDhanaYoga(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> [Yoga] {
        var yogas: [Yoga] = []

        guard let house2 = houses.houses.first(where: { $0.number == 2 }),
              let house11 = houses.houses.first(where: { $0.number == 11 }) else {
            return yogas
        }

        let lord2Name = house2.lord
        let lord11Name = house11.lord

        guard let lord2 = planets.first(where: { $0.planet.rawValue == lord2Name }),
              let lord11 = planets.first(where: { $0.planet.rawValue == lord11Name }) else {
            return yogas
        }

        let house2Lord = houses.house(for: lord2.planet)
        let house11Lord = houses.house(for: lord11.planet)

        // Variation 1: 2nd lord in 11th OR 11th lord in 2nd
        if house2Lord == 11 || house11Lord == 2 {
            let strength = determineYogaStrengthFromPlanets([lord2, lord11])
            yogas.append(.dhanaYoga(variation: 1, formingPlanets: [lord2Name, lord11Name], strength: strength))
        }

        // Variation 2: 2nd lord conjunct 11th lord
        if lord2.signIndex == lord11.signIndex && lord2Name != lord11Name {
            let strength = determineYogaStrengthFromPlanets([lord2, lord11])
            yogas.append(.dhanaYoga(variation: 2, formingPlanets: [lord2Name, lord11Name], strength: strength))
        }

        // Variation 3: Jupiter aspects 2nd or 11th house
        if let jupiter = planets.first(where: { $0.planet == .jupiter }) {
            let jupiterSign = jupiter.signIndex
            let house2Sign = house2.sign
            let house11Sign = house11.sign

            let jupiterAspects2nd = hasVedicAspect(from: jupiter, toSignIndex: ZodiacSign.allCases.firstIndex(of: house2Sign) ?? 0)
            let jupiterAspects11th = hasVedicAspect(from: jupiter, toSignIndex: ZodiacSign.allCases.firstIndex(of: house11Sign) ?? 0)

            if jupiterAspects2nd || jupiterAspects11th {
                yogas.append(.dhanaYoga(variation: 3, formingPlanets: ["Jupiter"], strength: .moderate))
            }
        }

        return yogas
    }

    /// Lakshmi Yoga - 9th lord in Kendra with strong Venus
    func detectLakshmiYoga(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> Yoga? {
        guard let house9 = houses.houses.first(where: { $0.number == 9 }),
              let venus = planets.first(where: { $0.planet == .venus }) else {
            return nil
        }

        let lord9Name = house9.lord
        guard let lord9 = planets.first(where: { $0.planet.rawValue == lord9Name }) else {
            return nil
        }

        let lord9House = houses.house(for: lord9.planet)
        let isLord9InKendra = houseService.isKendra(lord9House)
        let isVenusStrong = venus.status == .ownSign || venus.status == .exalted

        guard isLord9InKendra && isVenusStrong else { return nil }

        var strength: YogaStrength = .moderate
        if lord9.status == .exalted || lord9.status == .ownSign {
            strength = .strong
        }

        return .lakshmiYoga(formingPlanets: [lord9Name, "Venus"], strength: strength)
    }

    /// Chandra-Mangal Yoga - Moon-Mars conjunction
    func detectChandraMangalYoga(planets: [VedicPlanetPosition]) -> Yoga? {
        guard let moon = planets.first(where: { $0.planet == .moon }),
              let mars = planets.first(where: { $0.planet == .mars }) else {
            return nil
        }

        guard moon.signIndex == mars.signIndex else { return nil }

        var strength: YogaStrength = .moderate
        if moon.status == .exalted || mars.status == .exalted {
            strength = .strong
        } else if moon.status == .debilitated || mars.status == .debilitated {
            strength = .weak
        }

        return .chandraMangalYoga(strength: strength)
    }

    /// Shubh Kartari Yoga - Benefics on both sides of a house
    func detectShubhKartariYoga(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> [Yoga] {
        var yogas: [Yoga] = []
        let benefics: [VedicPlanet] = [.jupiter, .venus, .mercury]

        // Check important houses (1, 2, 7, 10)
        let housesToCheck = [1, 2, 7, 10]

        for houseNum in housesToCheck {
            let prevSignIndex = (houses.houses[houseNum - 1].sign.number - 2 + 12) % 12
            let nextSignIndex = houses.houses[houseNum - 1].sign.number % 12

            let beneficInPrev = planets.filter { benefics.contains($0.planet) && $0.signIndex == prevSignIndex }
            let beneficInNext = planets.filter { benefics.contains($0.planet) && $0.signIndex == nextSignIndex }

            if !beneficInPrev.isEmpty && !beneficInNext.isEmpty {
                let formingPlanets = (beneficInPrev + beneficInNext).map { $0.planet.rawValue }
                yogas.append(.shubhKartariYoga(protectedHouse: houseNum, formingPlanets: formingPlanets))
            }
        }

        return yogas
    }

    // MARK: - Raja Yoga Variations

    /// Detect Raja Yoga variations
    func detectRajaYogaVariations(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> [Yoga] {
        var yogas: [Yoga] = []

        // Viparita Raja Yoga
        if let viparita = detectViparitaRajaYoga(planets: planets, houses: houses) {
            yogas.append(viparita)
        }

        // Neecha Bhanga Raja Yoga
        yogas.append(contentsOf: detectNeechaBhangaRajaYoga(planets: planets, houses: houses))

        return yogas
    }

    /// Viparita Raja Yoga - Lords of 6th, 8th, 12th mutually connected
    func detectViparitaRajaYoga(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> Yoga? {
        let dusthanaHouses = [6, 8, 12]
        var dusthanaLords: [VedicPlanetPosition] = []

        for houseNum in dusthanaHouses {
            guard let house = houses.houses.first(where: { $0.number == houseNum }),
                  let lord = planets.first(where: { $0.planet.rawValue == house.lord }) else {
                continue
            }
            dusthanaLords.append(lord)
        }

        guard dusthanaLords.count >= 2 else { return nil }

        // Check for conjunction (same sign)
        var foundConnection = false
        var formingLords: [String] = []

        for i in 0..<dusthanaLords.count {
            for j in (i + 1)..<dusthanaLords.count {
                if dusthanaLords[i].signIndex == dusthanaLords[j].signIndex {
                    foundConnection = true
                    formingLords.append(dusthanaLords[i].planet.rawValue)
                    formingLords.append(dusthanaLords[j].planet.rawValue)
                }
            }
        }

        guard foundConnection else { return nil }

        let strength = determineYogaStrengthFromPlanets(dusthanaLords)
        return .viparitaRajaYoga(formingPlanets: Array(Set(formingLords)), strength: strength)
    }

    /// Neecha Bhanga Raja Yoga - Debilitated planet's lord in Kendra/Trikona
    func detectNeechaBhangaRajaYoga(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> [Yoga] {
        var yogas: [Yoga] = []

        let debilitatedPlanets = planets.filter { $0.status == .debilitated }

        for debilitated in debilitatedPlanets {
            // Find the lord of the sign where the planet is debilitated
            let debSign = debilitated.sign
            let signLordPlanet = VedicPlanet.allCases.first { $0.owns(sign: debSign) }

            guard let signLord = signLordPlanet,
                  let signLordPosition = planets.first(where: { $0.planet == signLord }) else {
                continue
            }

            let signLordHouse = houses.house(for: signLord)

            // Check if sign lord is in Kendra or Trikona
            let isInKendra = houseService.isKendra(signLordHouse)
            let isInTrikona = houseService.isTrikona(signLordHouse)

            if isInKendra || isInTrikona {
                var strength: YogaStrength = .moderate
                if signLordPosition.status == .exalted || signLordPosition.status == .ownSign {
                    strength = .strong
                }
                yogas.append(.neechaBhangaRajaYoga(
                    debilitatedPlanet: debilitated.planet.rawValue,
                    strength: strength
                ))
            }
        }

        return yogas
    }

    // MARK: - Special Yogas

    /// Detect special yogas
    func detectSpecialYogas(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> [Yoga] {
        var yogas: [Yoga] = []

        // Parivartana Yoga (Exchange)
        yogas.append(contentsOf: detectParivartanaYoga(planets: planets, houses: houses))

        // Solar yogas
        yogas.append(contentsOf: detectSolarYogas(planets: planets, houses: houses))

        // Amala Yoga
        if let amala = detectAmalaYoga(planets: planets, houses: houses) {
            yogas.append(amala)
        }

        // Parvata Yoga
        if let parvata = detectParvataYoga(planets: planets, houses: houses) {
            yogas.append(parvata)
        }

        // Kahala Yoga
        if let kahala = detectKahalaYoga(planets: planets, houses: houses) {
            yogas.append(kahala)
        }

        // Chamara Yoga
        if let chamara = detectChamaraYoga(planets: planets, houses: houses) {
            yogas.append(chamara)
        }

        return yogas
    }

    /// Parivartana Yoga - Two planets exchange signs
    func detectParivartanaYoga(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> [Yoga] {
        var yogas: [Yoga] = []

        // Check all planet pairs for exchange
        for i in 0..<planets.count {
            for j in (i + 1)..<planets.count {
                let planet1 = planets[i]
                let planet2 = planets[j]

                // Skip Rahu/Ketu
                if planet1.planet == .rahu || planet1.planet == .ketu ||
                   planet2.planet == .rahu || planet2.planet == .ketu {
                    continue
                }

                // Check if planet1 is in planet2's sign AND planet2 is in planet1's sign
                let planet1InPlanet2Sign = planet2.planet.owns(sign: planet1.sign)
                let planet2InPlanet1Sign = planet1.planet.owns(sign: planet2.sign)

                if planet1InPlanet2Sign && planet2InPlanet1Sign {
                    var strength: YogaStrength = .moderate
                    if (planet1.status == .exalted || planet1.status == .ownSign) &&
                       (planet2.status == .exalted || planet2.status == .ownSign) {
                        strength = .strong
                    }
                    yogas.append(.parivartanaYoga(
                        planet1: planet1.planet.rawValue,
                        planet2: planet2.planet.rawValue,
                        strength: strength
                    ))
                }
            }
        }

        return yogas
    }

    /// Detect solar yogas (Vesi, Vosi, Ubhayachari)
    func detectSolarYogas(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> [Yoga] {
        var yogas: [Yoga] = []

        guard let sun = planets.first(where: { $0.planet == .sun }) else {
            return yogas
        }

        let excludedPlanets: [VedicPlanet] = [.sun, .moon, .rahu, .ketu]
        let secondFromSun = (sun.signIndex + 1) % 12
        let twelfthFromSun = (sun.signIndex + 11) % 12

        let planetsIn2nd = planets.filter { planet in
            !excludedPlanets.contains(planet.planet) && planet.signIndex == secondFromSun
        }

        let planetsIn12th = planets.filter { planet in
            !excludedPlanets.contains(planet.planet) && planet.signIndex == twelfthFromSun
        }

        // Ubhayachari Yoga - planets in BOTH 2nd AND 12th from Sun
        if !planetsIn2nd.isEmpty && !planetsIn12th.isEmpty {
            let formingPlanets = (planetsIn2nd + planetsIn12th).map { $0.planet.rawValue }
            let strength = determineYogaStrengthFromPlanets(planetsIn2nd + planetsIn12th)
            yogas.append(.ubhayachariYoga(formingPlanets: formingPlanets, strength: strength))
        } else {
            // Vesi Yoga - planet in 2nd from Sun only
            if !planetsIn2nd.isEmpty {
                let formingPlanets = planetsIn2nd.map { $0.planet.rawValue }
                let strength = determineYogaStrengthFromPlanets(planetsIn2nd)
                yogas.append(.vesiYoga(formingPlanets: formingPlanets, strength: strength))
            }

            // Vosi Yoga - planet in 12th from Sun only
            if !planetsIn12th.isEmpty {
                let formingPlanets = planetsIn12th.map { $0.planet.rawValue }
                let strength = determineYogaStrengthFromPlanets(planetsIn12th)
                yogas.append(.vosiYoga(formingPlanets: formingPlanets, strength: strength))
            }
        }

        return yogas
    }

    /// Amala Yoga - Benefic in 10th from Lagna/Moon
    func detectAmalaYoga(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> Yoga? {
        let benefics: [VedicPlanet] = [.jupiter, .venus, .mercury]

        // Check 10th house from Lagna
        let house10 = houses.houses.first { $0.number == 10 }
        guard let house10Sign = house10?.sign else { return nil }

        let house10SignIndex = ZodiacSign.allCases.firstIndex(of: house10Sign) ?? 0

        let beneficIn10th = planets.first { planet in
            benefics.contains(planet.planet) && planet.signIndex == house10SignIndex
        }

        guard let benefic = beneficIn10th else { return nil }

        var strength: YogaStrength = .moderate
        if benefic.status == .exalted || benefic.status == .ownSign {
            strength = .strong
        }

        return .amalaYoga(formingPlanet: benefic.planet.rawValue, strength: strength)
    }

    /// Parvata Yoga - Benefics in Kendras, 6th/8th empty
    func detectParvataYoga(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> Yoga? {
        let benefics: [VedicPlanet] = [.jupiter, .venus]

        // Check if benefics are in Kendras
        var beneficsInKendra = false
        for planet in planets where benefics.contains(planet.planet) {
            let house = houses.house(for: planet.planet)
            if houseService.isKendra(house) {
                beneficsInKendra = true
                break
            }
        }

        guard beneficsInKendra else { return nil }

        // Check if 6th and 8th houses are empty
        let house6Planets = houses.planets(in: 6)
        let house8Planets = houses.planets(in: 8)

        guard house6Planets.isEmpty && house8Planets.isEmpty else { return nil }

        return .parvataYoga(strength: .moderate)
    }

    /// Kahala Yoga - 4th and 9th lords in mutual Kendras
    func detectKahalaYoga(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> Yoga? {
        guard let house4 = houses.houses.first(where: { $0.number == 4 }),
              let house9 = houses.houses.first(where: { $0.number == 9 }) else {
            return nil
        }

        let lord4Name = house4.lord
        let lord9Name = house9.lord

        guard let lord4 = planets.first(where: { $0.planet.rawValue == lord4Name }),
              let lord9 = planets.first(where: { $0.planet.rawValue == lord9Name }) else {
            return nil
        }

        let lord4House = houses.house(for: lord4.planet)
        let lord9House = houses.house(for: lord9.planet)

        // Both should be in Kendras
        guard houseService.isKendra(lord4House) && houseService.isKendra(lord9House) else {
            return nil
        }

        let strength = determineYogaStrengthFromPlanets([lord4, lord9])
        return .kahalaYoga(formingPlanets: [lord4Name, lord9Name], strength: strength)
    }

    /// Chamara Yoga - Exalted Lagna lord in Kendra aspected by Jupiter
    func detectChamaraYoga(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> Yoga? {
        let lagnaSign = houses.ascendant.sign
        let lagnaLordPlanet = VedicPlanet.allCases.first { $0.owns(sign: lagnaSign) }

        guard let lagnaLord = lagnaLordPlanet,
              let lagnaLordPosition = planets.first(where: { $0.planet == lagnaLord }) else {
            return nil
        }

        // Check if lagna lord is exalted
        guard lagnaLordPosition.status == .exalted else { return nil }

        // Check if lagna lord is in Kendra
        let lagnaLordHouse = houses.house(for: lagnaLord)
        guard houseService.isKendra(lagnaLordHouse) else { return nil }

        // Check if Jupiter aspects the lagna lord
        guard let jupiter = planets.first(where: { $0.planet == .jupiter }) else {
            return nil
        }

        let jupiterAspects = hasVedicAspect(from: jupiter, toSignIndex: lagnaLordPosition.signIndex)
        guard jupiterAspects else { return nil }

        return .chamaraYoga(formingPlanets: [lagnaLord.rawValue, "Jupiter"], strength: .strong)
    }

    // MARK: - Helper Methods

    /// Check if a planet has Vedic aspect to a sign index
    private func hasVedicAspect(from planet: VedicPlanetPosition, toSignIndex: Int) -> Bool {
        let signDiff = (toSignIndex - planet.signIndex + 12) % 12

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

    /// Determine yoga strength based on involved planets
    private func determineYogaStrengthFromPlanets(_ planets: [VedicPlanetPosition]) -> YogaStrength {
        let hasExalted = planets.contains { $0.status == .exalted }
        let hasOwnSign = planets.contains { $0.status == .ownSign }
        let hasDebilitated = planets.contains { $0.status == .debilitated }
        let hasRetrograde = planets.contains { $0.isRetrograde }

        if hasExalted && !hasDebilitated {
            return .strong
        } else if hasDebilitated {
            return .weak
        } else if hasOwnSign || !hasRetrograde {
            return .moderate
        } else {
            return .weak
        }
    }

    /// Check if a planet is in its own or exalted sign
    private func isInOwnOrExaltedSign(planet: VedicPlanet, position: VedicPlanetPosition) -> Bool {
        position.status == .exalted || position.status == .ownSign ||
        planet.owns(sign: position.sign) || planet.isExalted(in: position.sign)
    }

    /// Determine yoga strength based on planet and house position
    private func determineYogaStrength(planet: VedicPlanetPosition, house: Int) -> YogaStrength {
        // Strong if exalted and in best kendra (1st or 10th)
        if planet.status == .exalted && (house == 1 || house == 10) {
            return .strong
        }

        // Moderate if in own sign or good kendra
        if planet.status == .ownSign || house == 1 || house == 10 {
            return .moderate
        }

        // Weak if retrograde
        if planet.isRetrograde {
            return .weak
        }

        return .moderate
    }

    /// Determine Raja Yoga strength
    private func determineRajaYogaStrength(
        kendraPosition: VedicPlanetPosition,
        trikonaPosition: VedicPlanetPosition
    ) -> YogaStrength {
        // Strong if both planets are well-placed
        let bothStrong = (kendraPosition.status == .exalted || kendraPosition.status == .ownSign) &&
                         (trikonaPosition.status == .exalted || trikonaPosition.status == .ownSign)

        if bothStrong { return .strong }

        // Weak if either is debilitated
        if kendraPosition.status == .debilitated || trikonaPosition.status == .debilitated {
            return .weak
        }

        return .moderate
    }
}
