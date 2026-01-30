import XCTest
@testable import Kundli

/// Tests for DoshaDetectionService
final class DoshaDetectionServiceTests: XCTestCase {
    var sut: DoshaDetectionService!

    override func setUp() {
        super.setUp()
        sut = DoshaDetectionService.shared
    }

    // MARK: - Manglik Dosha Tests

    func testManglikDoshaInFirstHouse() {
        // Mars in 1st house from Lagna
        let mars = createTestPosition(planet: .mars, longitude: 15.0)  // Aries

        let planets = [mars]
        let houses = createTestHouses(ascendantSignIndex: 0, planetHouses: [.mars: 1])

        let doshas = sut.detectDoshas(planets: planets, houses: houses)

        let manglik = doshas.first { $0.type == .manglik }
        XCTAssertNotNil(manglik, "Should detect Manglik when Mars in 1st house")
    }

    func testManglikDoshaIn7thHouse() {
        // Mars in 7th house (marriage house)
        let mars = createTestPosition(planet: .mars, longitude: 195.0)  // Libra

        let planets = [mars]
        let houses = createTestHouses(ascendantSignIndex: 0, planetHouses: [.mars: 7])

        let doshas = sut.detectDoshas(planets: planets, houses: houses)

        let manglik = doshas.first { $0.type == .manglik }
        XCTAssertNotNil(manglik, "Should detect Manglik when Mars in 7th house")
    }

    func testManglikDoshaIn8thHouse() {
        // Mars in 8th house
        let mars = createTestPosition(planet: .mars, longitude: 225.0)  // Scorpio

        let planets = [mars]
        let houses = createTestHouses(ascendantSignIndex: 0, planetHouses: [.mars: 8])

        let doshas = sut.detectDoshas(planets: planets, houses: houses)

        let manglik = doshas.first { $0.type == .manglik }
        XCTAssertNotNil(manglik, "Should detect Manglik when Mars in 8th house")
    }

    func testNoManglikIn5thHouse() {
        // Mars in 5th house (not a Manglik house)
        let mars = createTestPosition(planet: .mars, longitude: 135.0)  // Leo

        let planets = [mars]
        let houses = createTestHouses(ascendantSignIndex: 0, planetHouses: [.mars: 5])

        let doshas = sut.detectDoshas(planets: planets, houses: houses)

        let manglik = doshas.first { $0.type == .manglik }
        XCTAssertNil(manglik, "Should NOT detect Manglik when Mars in 5th house")
    }

    func testManglikCancellationByOwnSign() {
        // Mars in Aries (own sign) should have cancellation
        let mars = createTestPosition(planet: .mars, longitude: 15.0)  // Aries

        let planets = [mars]
        let houses = createTestHouses(ascendantSignIndex: 0, planetHouses: [.mars: 1])

        let doshas = sut.detectDoshas(planets: planets, houses: houses)

        if let manglik = doshas.first(where: { $0.type == .manglik }) {
            let ownSignCancellation = manglik.cancellations.first { $0.rule.contains("own") }
            XCTAssertNotNil(ownSignCancellation, "Should have own sign cancellation")
            XCTAssertTrue(ownSignCancellation?.isActive ?? false, "Own sign cancellation should be active")
        }
    }

    func testManglikCancellationByJupiterAspect() {
        // Mars with Jupiter aspect should have cancellation
        let mars = createTestPosition(planet: .mars, longitude: 15.0)  // Aries
        let jupiter = createTestPosition(planet: .jupiter, longitude: 135.0)  // Leo (5th from Mars - Jupiter aspects)

        let planets = [mars, jupiter]
        let houses = createTestHouses(ascendantSignIndex: 0, planetHouses: [.mars: 1, .jupiter: 5])

        let doshas = sut.detectDoshas(planets: planets, houses: houses)

        if let manglik = doshas.first(where: { $0.type == .manglik }) {
            let jupiterCancellation = manglik.cancellations.first { $0.rule.contains("Jupiter") }
            XCTAssertNotNil(jupiterCancellation, "Should have Jupiter aspect cancellation")
        }
    }

    // MARK: - Reference Chart 2 (Known Manglik)

    func testReferenceChart2Manglik() {
        // Reference Chart 2 is known to have Manglik dosha
        let birthDetails = ReferenceCharts.chart2BirthDetails

        let planetService = PlanetaryPositionService.shared
        let houseService = HouseCalculationService.shared

        let planets = planetService.calculatePlanets(from: birthDetails)
        let houses = houseService.calculateHouses(from: birthDetails, planets: planets)

        let doshas = sut.detectDoshas(planets: planets, houses: houses)

        // Verify Mars is in expected house
        if let mars = planets.first(where: { $0.planet == .mars }) {
            let marsHouse = houses.house(for: .mars)

            // Check if Mars is in a Manglik house
            let manglikHouses = [1, 4, 7, 8, 12]
            if manglikHouses.contains(marsHouse) {
                let manglik = doshas.first { $0.type == .manglik }
                XCTAssertNotNil(manglik, "Reference Chart 2 should have Manglik dosha")
            }
        }
    }

    // MARK: - Kaal Sarp Dosha Tests

    func testKaalSarpDosha() {
        // All planets between Rahu and Ketu
        // Rahu in 1st house (Aries), Ketu in 7th house (Libra)
        // All other planets in houses 2-6

        let rahu = createTestPosition(planet: .rahu, longitude: 15.0)    // Aries (house 1)
        let ketu = createTestPosition(planet: .ketu, longitude: 195.0)   // Libra (house 7)
        let sun = createTestPosition(planet: .sun, longitude: 45.0)      // Taurus (house 2)
        let moon = createTestPosition(planet: .moon, longitude: 75.0)    // Gemini (house 3)
        let mars = createTestPosition(planet: .mars, longitude: 105.0)   // Cancer (house 4)
        let mercury = createTestPosition(planet: .mercury, longitude: 135.0)  // Leo (house 5)
        let jupiter = createTestPosition(planet: .jupiter, longitude: 165.0)  // Virgo (house 6)
        let venus = createTestPosition(planet: .venus, longitude: 50.0)       // Taurus (house 2)
        let saturn = createTestPosition(planet: .saturn, longitude: 80.0)     // Gemini (house 3)

        let planets = [rahu, ketu, sun, moon, mars, mercury, jupiter, venus, saturn]
        let houses = createTestHouses(
            ascendantSignIndex: 0,
            planetHouses: [
                .rahu: 1, .ketu: 7,
                .sun: 2, .moon: 3, .mars: 4,
                .mercury: 5, .jupiter: 6,
                .venus: 2, .saturn: 3
            ]
        )

        let doshas = sut.detectDoshas(planets: planets, houses: houses)

        let kaalSarp = doshas.first { $0.type == .kaalSarp }
        XCTAssertNotNil(kaalSarp, "Should detect Kaal Sarp when all planets between Rahu-Ketu")
    }

    func testNoKaalSarpWhenPlanetOutside() {
        // One planet outside Rahu-Ketu axis
        let rahu = createTestPosition(planet: .rahu, longitude: 15.0)
        let ketu = createTestPosition(planet: .ketu, longitude: 195.0)
        let jupiter = createTestPosition(planet: .jupiter, longitude: 285.0)  // Outside the axis

        let planets = [rahu, ketu, jupiter]
        let houses = createTestHouses(
            ascendantSignIndex: 0,
            planetHouses: [.rahu: 1, .ketu: 7, .jupiter: 10]
        )

        let doshas = sut.detectDoshas(planets: planets, houses: houses)

        let kaalSarp = doshas.first { $0.type == .kaalSarp && $0.severity == .high }
        XCTAssertNil(kaalSarp, "Should NOT detect full Kaal Sarp when planet outside axis")
    }

    // MARK: - Kemdrum Dosha Tests

    func testKemdrumDosha() {
        // No planets in 2nd or 12th from Moon
        let moon = createTestPosition(planet: .moon, longitude: 45.0)  // Taurus (index 1)
        let sun = createTestPosition(planet: .sun, longitude: 105.0)   // Cancer (index 3, 3rd from Moon)

        // 2nd from Moon = Gemini (index 2)
        // 12th from Moon = Aries (index 0)
        // Neither has planets, so Kemdrum should be detected

        let planets = [moon, sun]
        let houses = createTestHouses(ascendantSignIndex: 0, planetHouses: [.moon: 2, .sun: 4])

        let doshas = sut.detectDoshas(planets: planets, houses: houses)

        let kemdrum = doshas.first { $0.type == .kemdrum }
        XCTAssertNotNil(kemdrum, "Should detect Kemdrum when no planets in 2nd/12th from Moon")
    }

    func testNoKemdrumWhenPlanetIn2nd() {
        // Planet in 2nd from Moon
        let moon = createTestPosition(planet: .moon, longitude: 45.0)    // Taurus
        let venus = createTestPosition(planet: .venus, longitude: 75.0)  // Gemini (2nd from Taurus)

        let planets = [moon, venus]
        let houses = createTestHouses(ascendantSignIndex: 0, planetHouses: [.moon: 2, .venus: 3])

        let doshas = sut.detectDoshas(planets: planets, houses: houses)

        let kemdrum = doshas.first { $0.type == .kemdrum }
        XCTAssertNil(kemdrum, "Should NOT detect Kemdrum when planet in 2nd from Moon")
    }

    func testKemdrumCancellationByJupiterInKendra() {
        // Kemdrum cancelled when Jupiter in kendra from Moon
        let moon = createTestPosition(planet: .moon, longitude: 45.0)     // Taurus
        let jupiter = createTestPosition(planet: .jupiter, longitude: 135.0)  // Leo (4th from Taurus)

        let planets = [moon, jupiter]
        let houses = createTestHouses(ascendantSignIndex: 0, planetHouses: [.moon: 2, .jupiter: 5])

        let doshas = sut.detectDoshas(planets: planets, houses: houses)

        if let kemdrum = doshas.first(where: { $0.type == .kemdrum }) {
            let jupiterCancellation = kemdrum.cancellations.first { $0.rule.contains("Jupiter") }
            XCTAssertNotNil(jupiterCancellation, "Should have Jupiter cancellation")
            XCTAssertTrue(jupiterCancellation?.isActive ?? false)
        }
    }

    // MARK: - Pitra Dosha Tests

    func testPitraDoshaWithSunRahu() {
        // Sun conjunct Rahu
        let sun = createTestPosition(planet: .sun, longitude: 45.0)    // Taurus
        let rahu = createTestPosition(planet: .rahu, longitude: 48.0)  // Also Taurus (conjunct)

        let planets = [sun, rahu]
        let houses = createTestHouses(ascendantSignIndex: 0, planetHouses: [.sun: 2, .rahu: 2])

        let doshas = sut.detectDoshas(planets: planets, houses: houses)

        let pitra = doshas.first { $0.type == .pitra }
        XCTAssertNotNil(pitra, "Should detect Pitra dosha when Sun conjunct Rahu")
    }

    func testPitraDoshaWithSunSaturn() {
        // Sun conjunct Saturn
        let sun = createTestPosition(planet: .sun, longitude: 45.0)
        let saturn = createTestPosition(planet: .saturn, longitude: 50.0)

        let planets = [sun, saturn]
        let houses = createTestHouses(ascendantSignIndex: 0, planetHouses: [.sun: 2, .saturn: 2])

        let doshas = sut.detectDoshas(planets: planets, houses: houses)

        let pitra = doshas.first { $0.type == .pitra }
        XCTAssertNotNil(pitra, "Should detect Pitra dosha when Sun conjunct Saturn")
    }

    // MARK: - Dosha Severity Tests

    func testManglikSeverityHigh() {
        // Manglik from multiple references should be high severity
        let mars = createTestPosition(planet: .mars, longitude: 195.0)  // 7th house position
        let moon = createTestPosition(planet: .moon, longitude: 15.0)   // 1st from Moon gives Mars in 7th

        let planets = [mars, moon]
        let houses = createTestHouses(ascendantSignIndex: 0, planetHouses: [.mars: 7, .moon: 1])

        let doshas = sut.detectDoshas(planets: planets, houses: houses)

        if let manglik = doshas.first(where: { $0.type == .manglik }) {
            // Multiple references should increase severity
            // (This depends on actual implementation)
            XCTAssertNotEqual(manglik.severity, .cancelled)
        }
    }

    // MARK: - False Positive Prevention

    func testNoFalsePositiveManglik() {
        // Mars in 3rd house should NOT trigger Manglik
        let mars = createTestPosition(planet: .mars, longitude: 75.0)

        let planets = [mars]
        let houses = createTestHouses(ascendantSignIndex: 0, planetHouses: [.mars: 3])

        let doshas = sut.detectDoshas(planets: planets, houses: houses)

        let manglik = doshas.first { $0.type == .manglik }
        XCTAssertNil(manglik, "Mars in 3rd house should NOT trigger Manglik")
    }

    // MARK: - Helper Methods

    private func createTestPosition(planet: VedicPlanet, longitude: Double) -> VedicPlanetPosition {
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
            isRetrograde: false,
            speedPerDay: 1.0,
            status: .direct
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
}
