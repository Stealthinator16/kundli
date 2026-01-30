import XCTest
@testable import Kundli

/// Tests for PlanetaryPositionService
final class PlanetaryPositionServiceTests: XCTestCase {
    var sut: PlanetaryPositionService!

    override func setUp() {
        super.setUp()
        sut = PlanetaryPositionService.shared
    }

    // MARK: - Basic Position Tests

    func testCalculateAllPlanets() {
        let date = createDate(year: 2000, month: 1, day: 1, hour: 12, minute: 0)
        let timezone = TimeZone(identifier: "Asia/Kolkata")!

        let positions = sut.calculateAllPlanets(date: date, timezone: timezone)

        XCTAssertEqual(positions.count, 9, "Should calculate all 9 Vedic planets")

        // Check all planets are present
        let planetNames = positions.map { $0.planet }
        for planet in VedicPlanet.allCases {
            XCTAssertTrue(planetNames.contains(planet), "Should have \(planet.rawValue)")
        }
    }

    func testPositionsHaveValidRanges() {
        let date = createDate(year: 2000, month: 1, day: 1, hour: 12, minute: 0)
        let timezone = TimeZone(identifier: "Asia/Kolkata")!

        let positions = sut.calculateAllPlanets(date: date, timezone: timezone)

        for position in positions {
            // Longitude should be 0-360
            XCTAssertGreaterThanOrEqual(position.longitude, 0, "\(position.planet.rawValue) longitude >= 0")
            XCTAssertLessThan(position.longitude, 360, "\(position.planet.rawValue) longitude < 360")

            // Degree in sign should be 0-30
            XCTAssertGreaterThanOrEqual(position.degreeInSign, 0, "\(position.planet.rawValue) degree >= 0")
            XCTAssertLessThan(position.degreeInSign, 30, "\(position.planet.rawValue) degree < 30")

            // Sign index should be 0-11
            XCTAssertGreaterThanOrEqual(position.signIndex, 0, "\(position.planet.rawValue) signIndex >= 0")
            XCTAssertLessThan(position.signIndex, 12, "\(position.planet.rawValue) signIndex < 12")

            // Nakshatra pada should be 1-4
            XCTAssertGreaterThanOrEqual(position.nakshatraPada, 1, "\(position.planet.rawValue) pada >= 1")
            XCTAssertLessThanOrEqual(position.nakshatraPada, 4, "\(position.planet.rawValue) pada <= 4")
        }
    }

    // MARK: - Dignity Status Tests

    func testExaltedSunInAries() {
        // Create a date when Sun is in Aries (around April in sidereal)
        // Sun enters sidereal Aries around mid-April
        let date = createDate(year: 2000, month: 4, day: 20, hour: 12, minute: 0)
        let timezone = TimeZone(identifier: "Asia/Kolkata")!

        let positions = sut.calculateAllPlanets(date: date, timezone: timezone)
        guard let sun = positions.first(where: { $0.planet == .sun }) else {
            XCTFail("Should have Sun position")
            return
        }

        if sun.sign == .aries {
            // Sun should be exalted in Aries
            XCTAssertEqual(sun.status, .exalted, "Sun should be exalted in Aries")
        }
    }

    func testDebilitatedSunInLibra() {
        // Create a date when Sun is in Libra (around October-November in sidereal)
        let date = createDate(year: 2000, month: 10, day: 25, hour: 12, minute: 0)
        let timezone = TimeZone(identifier: "Asia/Kolkata")!

        let positions = sut.calculateAllPlanets(date: date, timezone: timezone)
        guard let sun = positions.first(where: { $0.planet == .sun }) else {
            XCTFail("Should have Sun position")
            return
        }

        if sun.sign == .libra {
            XCTAssertEqual(sun.status, .debilitated, "Sun should be debilitated in Libra")
        }
    }

    func testOwnSignStatus() {
        // Test that Mars in Aries or Scorpio is marked as own sign
        let status = sut.determineStatus(planet: .mars, sign: .aries, degree: 15, isRetrograde: false)
        XCTAssertEqual(status, .ownSign, "Mars in Aries should be own sign")

        let status2 = sut.determineStatus(planet: .mars, sign: .scorpio, degree: 15, isRetrograde: false)
        XCTAssertEqual(status2, .ownSign, "Mars in Scorpio should be own sign")
    }

    func testRetrogradeOverridesOther() {
        // Retrograde status takes precedence for outer planets
        let status = sut.determineStatus(planet: .saturn, sign: .libra, degree: 20, isRetrograde: true)
        XCTAssertEqual(status, .retrograde, "Retrograde should override exaltation for Saturn")
    }

    func testSunMoonNeverRetrograde() {
        // Sun and Moon can never be retrograde
        let sunStatus = sut.determineStatus(planet: .sun, sign: .leo, degree: 15, isRetrograde: true)
        XCTAssertNotEqual(sunStatus, .retrograde, "Sun should not be marked retrograde")

        let moonStatus = sut.determineStatus(planet: .moon, sign: .cancer, degree: 15, isRetrograde: true)
        XCTAssertNotEqual(moonStatus, .retrograde, "Moon should not be marked retrograde")
    }

    // MARK: - Dignity Table Verification

    func testAllExaltationSigns() {
        XCTAssertEqual(VedicPlanet.sun.exaltationSign, .aries)
        XCTAssertEqual(VedicPlanet.moon.exaltationSign, .taurus)
        XCTAssertEqual(VedicPlanet.mars.exaltationSign, .capricorn)
        XCTAssertEqual(VedicPlanet.mercury.exaltationSign, .virgo)
        XCTAssertEqual(VedicPlanet.jupiter.exaltationSign, .cancer)
        XCTAssertEqual(VedicPlanet.venus.exaltationSign, .pisces)
        XCTAssertEqual(VedicPlanet.saturn.exaltationSign, .libra)
    }

    func testAllDebilitationSigns() {
        XCTAssertEqual(VedicPlanet.sun.debilitationSign, .libra)
        XCTAssertEqual(VedicPlanet.moon.debilitationSign, .scorpio)
        XCTAssertEqual(VedicPlanet.mars.debilitationSign, .cancer)
        XCTAssertEqual(VedicPlanet.mercury.debilitationSign, .pisces)
        XCTAssertEqual(VedicPlanet.jupiter.debilitationSign, .capricorn)
        XCTAssertEqual(VedicPlanet.venus.debilitationSign, .virgo)
        XCTAssertEqual(VedicPlanet.saturn.debilitationSign, .aries)
    }

    func testAllOwnSigns() {
        XCTAssertEqual(VedicPlanet.sun.ownSigns, [.leo])
        XCTAssertEqual(VedicPlanet.moon.ownSigns, [.cancer])
        XCTAssertEqual(VedicPlanet.mars.ownSigns, [.aries, .scorpio])
        XCTAssertEqual(VedicPlanet.mercury.ownSigns, [.gemini, .virgo])
        XCTAssertEqual(VedicPlanet.jupiter.ownSigns, [.sagittarius, .pisces])
        XCTAssertEqual(VedicPlanet.venus.ownSigns, [.taurus, .libra])
        XCTAssertEqual(VedicPlanet.saturn.ownSigns, [.capricorn, .aquarius])
    }

    // MARK: - Aspect Tests

    func testConjunctionDetection() {
        let position1 = createTestPosition(planet: .sun, longitude: 45.0)
        let position2 = createTestPosition(planet: .mercury, longitude: 48.0)

        XCTAssertTrue(sut.areInConjunction(planet1: position1, planet2: position2),
            "Planets within 10° should be in conjunction")
    }

    func testOppositionAspect() {
        let position1 = createTestPosition(planet: .sun, longitude: 45.0)
        let position2 = createTestPosition(planet: .saturn, longitude: 225.0)  // 180° apart

        XCTAssertTrue(sut.hasAspect(from: position1, to: position2),
            "All planets aspect 7th house (180°)")
    }

    func testMarsSpecialAspects() {
        // Mars aspects 4th, 7th, 8th
        let mars = createTestPosition(planet: .mars, longitude: 0.0)  // Aries

        // 4th aspect (90° = Cancer)
        let target4th = createTestPosition(planet: .sun, longitude: 93.0)
        XCTAssertTrue(sut.hasAspect(from: mars, to: target4th), "Mars should aspect 4th house")

        // 8th aspect (210° = Scorpio)
        let target8th = createTestPosition(planet: .sun, longitude: 213.0)
        XCTAssertTrue(sut.hasAspect(from: mars, to: target8th), "Mars should aspect 8th house")
    }

    func testJupiterSpecialAspects() {
        // Jupiter aspects 5th, 7th, 9th
        let jupiter = createTestPosition(planet: .jupiter, longitude: 0.0)

        // 5th aspect (120° = Leo)
        let target5th = createTestPosition(planet: .sun, longitude: 123.0)
        XCTAssertTrue(sut.hasAspect(from: jupiter, to: target5th), "Jupiter should aspect 5th house")

        // 9th aspect (240° = Sagittarius)
        let target9th = createTestPosition(planet: .sun, longitude: 243.0)
        XCTAssertTrue(sut.hasAspect(from: jupiter, to: target9th), "Jupiter should aspect 9th house")
    }

    func testSaturnSpecialAspects() {
        // Saturn aspects 3rd, 7th, 10th
        let saturn = createTestPosition(planet: .saturn, longitude: 0.0)

        // 3rd aspect (60° = Gemini)
        let target3rd = createTestPosition(planet: .sun, longitude: 63.0)
        XCTAssertTrue(sut.hasAspect(from: saturn, to: target3rd), "Saturn should aspect 3rd house")

        // 10th aspect (270° = Capricorn)
        let target10th = createTestPosition(planet: .sun, longitude: 273.0)
        XCTAssertTrue(sut.hasAspect(from: saturn, to: target10th), "Saturn should aspect 10th house")
    }

    // MARK: - Birth Details Integration Test

    func testCalculateFromBirthDetails() {
        let birthDetails = ReferenceCharts.chart1BirthDetails
        let positions = sut.calculatePlanets(from: birthDetails)

        XCTAssertEqual(positions.count, 9, "Should calculate all 9 planets")
    }

    // MARK: - Reference Chart Verification

    func testReferenceChart1Planets() {
        let birthDetails = ReferenceCharts.chart1BirthDetails
        let positions = sut.calculatePlanets(from: birthDetails)

        for (planet, expected) in ReferenceCharts.chart1ExpectedPositions {
            guard let position = positions.first(where: { $0.planet == planet }) else {
                XCTFail("Should have \(planet.rawValue) position")
                continue
            }

            let matches = expected.matches(actualDegree: position.degreeInSign, actualSign: position.sign)
            XCTAssertTrue(matches,
                "\(planet.rawValue) expected \(expected), got \(position.sign.rawValue) \(String(format: "%.1f", position.degreeInSign))°"
            )
        }
    }

    // MARK: - Performance Tests

    func testAllPlanetsCalculationPerformance() {
        let date = createDate(year: 2000, month: 1, day: 1, hour: 12, minute: 0)
        let timezone = TimeZone(identifier: "Asia/Kolkata")!

        measure {
            for _ in 0..<100 {
                _ = sut.calculateAllPlanets(date: date, timezone: timezone)
            }
        }
    }

    // MARK: - Helper Methods

    private func createDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.timeZone = TimeZone(identifier: "Asia/Kolkata")
        return Calendar.current.date(from: components) ?? Date()
    }

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
            minutes: Int((degreeInSign - Double(Int(degreeInSign))) * 60),
            seconds: 0,
            nakshatra: .ashwini,
            nakshatraPada: 1,
            nakshatraLord: "Ketu",
            isRetrograde: false,
            speedPerDay: 1.0,
            status: .direct
        )
    }
}
