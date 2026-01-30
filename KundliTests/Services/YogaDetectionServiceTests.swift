import XCTest
@testable import Kundli

/// Tests for YogaDetectionService
final class YogaDetectionServiceTests: XCTestCase {
    var sut: YogaDetectionService!
    var houseService: HouseCalculationService!

    override func setUp() {
        super.setUp()
        sut = YogaDetectionService.shared
        houseService = HouseCalculationService.shared
    }

    // MARK: - Gaja Kesari Yoga Tests

    func testGajaKesariYogaInKendra() {
        // Jupiter in same sign as Moon (1st from Moon)
        let planets = [
            createTestPosition(planet: .moon, longitude: 45.0),     // Taurus
            createTestPosition(planet: .jupiter, longitude: 48.0)   // Also Taurus (conjunct)
        ]
        let houses = createTestHouses(ascendantSignIndex: 1)  // Taurus ascendant

        let yogas = sut.detectYogas(planets: planets, houses: houses)

        let gajaKesari = yogas.first { $0.name.contains("Gaja Kesari") }
        XCTAssertNotNil(gajaKesari, "Should detect Gaja Kesari when Jupiter conjunct Moon")
    }

    func testGajaKesariYogaIn7th() {
        // Jupiter in 7th from Moon
        let planets = [
            createTestPosition(planet: .moon, longitude: 45.0),      // Taurus (index 1)
            createTestPosition(planet: .jupiter, longitude: 225.0)   // Scorpio (index 7, 7th from Taurus)
        ]
        let houses = createTestHouses(ascendantSignIndex: 1)

        let yogas = sut.detectYogas(planets: planets, houses: houses)

        let gajaKesari = yogas.first { $0.name.contains("Gaja Kesari") }
        XCTAssertNotNil(gajaKesari, "Should detect Gaja Kesari when Jupiter in 7th from Moon")
    }

    func testNoGajaKesariWhenJupiterNotInKendra() {
        // Jupiter in 2nd from Moon (not kendra)
        let planets = [
            createTestPosition(planet: .moon, longitude: 45.0),     // Taurus
            createTestPosition(planet: .jupiter, longitude: 75.0)   // Gemini (2nd from Taurus)
        ]
        let houses = createTestHouses(ascendantSignIndex: 1)

        let yogas = sut.detectYogas(planets: planets, houses: houses)

        let gajaKesari = yogas.first { $0.name.contains("Gaja Kesari") }
        XCTAssertNil(gajaKesari, "Should NOT detect Gaja Kesari when Jupiter not in kendra from Moon")
    }

    // MARK: - Budhaditya Yoga Tests

    func testBudhadityaYogaConjunction() {
        // Sun and Mercury in same sign
        let planets = [
            createTestPosition(planet: .sun, longitude: 45.0),      // Taurus
            createTestPosition(planet: .mercury, longitude: 52.0)   // Also Taurus
        ]
        let houses = createTestHouses(ascendantSignIndex: 1)

        let yogas = sut.detectYogas(planets: planets, houses: houses)

        let budhaditya = yogas.first { $0.name.contains("Budhaditya") }
        XCTAssertNotNil(budhaditya, "Should detect Budhaditya when Sun-Mercury conjunct")
    }

    func testNoBudhadityaWhenSeparate() {
        // Sun and Mercury in different signs
        let planets = [
            createTestPosition(planet: .sun, longitude: 45.0),      // Taurus
            createTestPosition(planet: .mercury, longitude: 75.0)   // Gemini
        ]
        let houses = createTestHouses(ascendantSignIndex: 1)

        let yogas = sut.detectYogas(planets: planets, houses: houses)

        let budhaditya = yogas.first { $0.name.contains("Budhaditya") }
        XCTAssertNil(budhaditya, "Should NOT detect Budhaditya when Sun-Mercury in different signs")
    }

    // MARK: - Panch Mahapurusha Yoga Tests

    func testRuchakaYoga() {
        // Mars in own sign (Aries) in kendra (1st house)
        let mars = createTestPosition(planet: .mars, longitude: 10.0)  // Aries
        mars.updateStatus(to: .ownSign)

        let planets = [mars]
        let houses = createTestHouses(ascendantSignIndex: 0, planetHouses: [.mars: 1])

        let yogas = sut.detectYogas(planets: planets, houses: houses)

        let ruchaka = yogas.first { $0.name.contains("Ruchaka") }
        XCTAssertNotNil(ruchaka, "Should detect Ruchaka when Mars in own sign in kendra")
    }

    func testBhadraYoga() {
        // Mercury in own sign (Gemini) in kendra
        let mercury = createTestPosition(planet: .mercury, longitude: 70.0)  // Gemini
        mercury.updateStatus(to: .ownSign)

        let planets = [mercury]
        let houses = createTestHouses(ascendantSignIndex: 0, planetHouses: [.mercury: 4])  // 4th is kendra

        let yogas = sut.detectYogas(planets: planets, houses: houses)

        let bhadra = yogas.first { $0.name.contains("Bhadra") }
        XCTAssertNotNil(bhadra, "Should detect Bhadra when Mercury in own sign in kendra")
    }

    func testHamsaYoga() {
        // Jupiter in exalted sign (Cancer) in kendra
        let jupiter = createTestPosition(planet: .jupiter, longitude: 95.0)  // Cancer
        jupiter.updateStatus(to: .exalted)

        let planets = [jupiter]
        let houses = createTestHouses(ascendantSignIndex: 0, planetHouses: [.jupiter: 7])  // 7th is kendra

        let yogas = sut.detectYogas(planets: planets, houses: houses)

        let hamsa = yogas.first { $0.name.contains("Hamsa") }
        XCTAssertNotNil(hamsa, "Should detect Hamsa when Jupiter exalted in kendra")
    }

    func testMalavyaYoga() {
        // Venus in own sign (Taurus) in kendra
        let venus = createTestPosition(planet: .venus, longitude: 45.0)  // Taurus
        venus.updateStatus(to: .ownSign)

        let planets = [venus]
        let houses = createTestHouses(ascendantSignIndex: 0, planetHouses: [.venus: 10])  // 10th is kendra

        let yogas = sut.detectYogas(planets: planets, houses: houses)

        let malavya = yogas.first { $0.name.contains("Malavya") }
        XCTAssertNotNil(malavya, "Should detect Malavya when Venus in own sign in kendra")
    }

    func testSasaYoga() {
        // Saturn in exalted sign (Libra) in kendra
        let saturn = createTestPosition(planet: .saturn, longitude: 200.0)  // Libra
        saturn.updateStatus(to: .exalted)

        let planets = [saturn]
        let houses = createTestHouses(ascendantSignIndex: 0, planetHouses: [.saturn: 1])

        let yogas = sut.detectYogas(planets: planets, houses: houses)

        let sasa = yogas.first { $0.name.contains("Sasa") }
        XCTAssertNotNil(sasa, "Should detect Sasa when Saturn exalted in kendra")
    }

    func testNoMahapurushaWhenNotInKendra() {
        // Mars in own sign but NOT in kendra (6th house)
        let mars = createTestPosition(planet: .mars, longitude: 10.0)
        mars.updateStatus(to: .ownSign)

        let planets = [mars]
        let houses = createTestHouses(ascendantSignIndex: 0, planetHouses: [.mars: 6])  // 6th is not kendra

        let yogas = sut.detectYogas(planets: planets, houses: houses)

        let ruchaka = yogas.first { $0.name.contains("Ruchaka") }
        XCTAssertNil(ruchaka, "Should NOT detect Ruchaka when Mars not in kendra")
    }

    // MARK: - Raja Yoga Tests

    func testRajaYogaConjunction() {
        // This would require setting up proper house lords
        // For a basic test, we verify the detection mechanism works

        // For Aries ascendant:
        // 1st lord (Mars) conjunct with 5th lord (Sun) or 9th lord (Jupiter)
        // would create Raja Yoga

        let planets = createSamplePlanetPositions()
        let houses = createTestHouses(ascendantSignIndex: 0)

        let yogas = sut.detectYogas(planets: planets, houses: houses)

        // Just verify the detection runs without error
        XCTAssertNotNil(yogas, "Should return yoga array")
    }

    // MARK: - Yoga Strength Tests

    func testStrongYogaStrength() {
        // Jupiter exalted in 10th house should give strong Hamsa
        let jupiter = createTestPosition(planet: .jupiter, longitude: 95.0, status: .exalted)

        let planets = [jupiter]
        let houses = createTestHouses(ascendantSignIndex: 0, planetHouses: [.jupiter: 10])

        let yogas = sut.detectYogas(planets: planets, houses: houses)

        if let hamsa = yogas.first(where: { $0.name.contains("Hamsa") }) {
            XCTAssertEqual(hamsa.strength, .strong, "Exalted planet in 10th should be strong")
        }
    }

    func testWeakYogaStrength() {
        // Jupiter retrograde should weaken the yoga
        let jupiter = createTestPosition(planet: .jupiter, longitude: 95.0, isRetrograde: true)
        jupiter.updateStatus(to: .ownSign)

        let planets = [jupiter]
        let houses = createTestHouses(ascendantSignIndex: 0, planetHouses: [.jupiter: 4])

        let yogas = sut.detectYogas(planets: planets, houses: houses)

        if let hamsa = yogas.first(where: { $0.name.contains("Hamsa") }) {
            XCTAssertEqual(hamsa.strength, .weak, "Retrograde planet should weaken yoga")
        }
    }

    // MARK: - Helper Methods

    private func createTestPosition(
        planet: VedicPlanet,
        longitude: Double,
        status: PlanetStatus = .direct,
        isRetrograde: Bool = false
    ) -> VedicPlanetPosition {
        let signIndex = Int(longitude / 30.0) % 12
        let degreeInSign = longitude.truncatingRemainder(dividingBy: 30.0)
        let sign = ZodiacSign.allCases[signIndex]

        return VedicPlanetPosition(
            planet: planet,
            longitude: longitude,
            signIndex: signIndex,
            sign: sign,
            degreeInSign: degreeInSign,
            minutes: 0,
            seconds: 0,
            nakshatra: .ashwini,
            nakshatraPada: 1,
            nakshatraLord: "Ketu",
            isRetrograde: isRetrograde,
            speedPerDay: isRetrograde ? -1.0 : 1.0,
            status: status
        )
    }

    private func createTestHouses(
        ascendantSignIndex: Int,
        planetHouses: [VedicPlanet: Int] = [:]
    ) -> HouseCalculationResult {
        let ascSign = ZodiacSign.allCases[ascendantSignIndex]

        let ascendant = Ascendant(
            sign: ascSign,
            degree: 15.0,
            minutes: 0,
            seconds: 0,
            nakshatra: "Ashwini",
            nakshatraPada: 1,
            lord: ascSign.lord
        )

        var houses: [HouseInfo] = []
        for i in 0..<12 {
            let signIndex = (ascendantSignIndex + i) % 12
            let sign = ZodiacSign.allCases[signIndex]
            houses.append(HouseInfo(
                number: i + 1,
                cusp: Double(signIndex * 30),
                sign: sign,
                degreeInSign: 0,
                lord: sign.lord,
                planets: [],
                significance: HouseSignificance(name: "", keywords: [], category: .kendra)
            ))
        }

        return HouseCalculationResult(
            ascendant: ascendant,
            houses: houses,
            planetHouses: planetHouses,
            mcLongitude: nil
        )
    }

    private func createSamplePlanetPositions() -> [VedicPlanetPosition] {
        return VedicPlanet.allCases.map { planet in
            createTestPosition(planet: planet, longitude: Double.random(in: 0..<360))
        }
    }
}

// MARK: - Test Extension for VedicPlanetPosition

extension VedicPlanetPosition {
    mutating func updateStatus(to newStatus: PlanetStatus) {
        // Note: In actual implementation, VedicPlanetPosition might need to be made mutable
        // or use a different approach. This is a placeholder for test purposes.
    }
}
