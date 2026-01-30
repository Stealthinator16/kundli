import XCTest
@testable import Kundli

/// Tests for EphemerisService
/// Verifies astronomical calculations against JPL Horizons reference data
final class EphemerisServiceTests: XCTestCase {
    var sut: EphemerisService!

    override func setUp() {
        super.setUp()
        sut = EphemerisService.shared
        sut.initialize()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Julian Day Tests

    func testJulianDayCalculation() {
        // January 1, 2000, 12:00 TT corresponds to JD 2451545.0
        let date = createDate(year: 2000, month: 1, day: 1, hour: 12, minute: 0)
        let timezone = TimeZone(identifier: "UTC")!

        let jd = sut.julianDay(for: date, timezone: timezone)

        // J2000.0 epoch should be approximately 2451545.0
        XCTAssertEqual(jd, 2451545.0, accuracy: 0.1, "Julian Day should be close to J2000.0 epoch")
    }

    func testJulianDayWithIndianTimezone() {
        // Jan 1, 2000, 12:00 IST = 06:30 UTC
        let date = createDate(year: 2000, month: 1, day: 1, hour: 12, minute: 0)
        let timezone = TimeZone(identifier: "Asia/Kolkata")!

        let jd = sut.julianDay(for: date, timezone: timezone)

        // Should be slightly less than noon UTC JD due to timezone offset
        XCTAssertLessThan(jd, 2451545.0, "Indian noon should be before UTC noon in JD")
    }

    // MARK: - Planet Position Tests

    func testSunTropicalPosition() {
        // Sun's tropical longitude on Jan 1, 2000 should be around 280° (Capricorn)
        let date = createDate(year: 2000, month: 1, day: 1, hour: 12, minute: 0)
        let timezone = TimeZone(identifier: "UTC")!
        let jd = sut.julianDay(for: date, timezone: timezone)

        let position = sut.tropicalLongitude(planet: .sun, julianDay: jd)

        XCTAssertNotNil(position, "Should calculate Sun position")
        if let pos = position {
            // Sun should be around 280° (10° Capricorn) tropically
            XCTAssertEqual(pos.longitude, 280.0, accuracy: 2.0, "Sun tropical longitude")
        }
    }

    func testSunSiderealPosition() {
        // Test sidereal position with Lahiri ayanamsa
        let date = createDate(year: 2000, month: 1, day: 1, hour: 12, minute: 0)
        let timezone = TimeZone(identifier: "UTC")!
        let jd = sut.julianDay(for: date, timezone: timezone)

        let position = sut.siderealLongitude(planet: .sun, julianDay: jd, ayanamsa: .lahiri)

        XCTAssertNotNil(position, "Should calculate sidereal Sun position")
        if let pos = position {
            // Sidereal should be about 23.85° less than tropical
            XCTAssertEqual(pos.longitude, 256.0, accuracy: 3.0, "Sun sidereal longitude (~16° Sagittarius)")
        }
    }

    func testMoonPosition() {
        // Moon moves about 13° per day
        let date = createDate(year: 2000, month: 1, day: 1, hour: 12, minute: 0)
        let timezone = TimeZone(identifier: "UTC")!
        let jd = sut.julianDay(for: date, timezone: timezone)

        let position = sut.tropicalLongitude(planet: .moon, julianDay: jd)

        XCTAssertNotNil(position, "Should calculate Moon position")
        if let pos = position {
            // Moon should have significant daily motion
            XCTAssertGreaterThan(abs(pos.speedLongitude), 10.0, "Moon should have fast daily motion")
        }
    }

    func testRahuKetuOpposition() {
        // Rahu and Ketu should always be exactly 180° apart
        let date = createDate(year: 2000, month: 1, day: 1, hour: 12, minute: 0)
        let timezone = TimeZone(identifier: "UTC")!
        let jd = sut.julianDay(for: date, timezone: timezone)

        let rahuPos = sut.tropicalLongitude(planet: .rahu, julianDay: jd)
        let ketuPos = sut.tropicalLongitude(planet: .ketu, julianDay: jd)

        XCTAssertNotNil(rahuPos, "Should calculate Rahu position")
        XCTAssertNotNil(ketuPos, "Should calculate Ketu position")

        if let rahu = rahuPos, let ketu = ketuPos {
            var diff = abs(rahu.longitude - ketu.longitude)
            if diff > 180 { diff = 360 - diff }
            XCTAssertEqual(diff, 180.0, accuracy: 0.1, "Rahu-Ketu should be 180° apart")
        }
    }

    func testAllPlanetsCalculate() {
        let date = createDate(year: 2000, month: 1, day: 1, hour: 12, minute: 0)
        let timezone = TimeZone(identifier: "UTC")!
        let jd = sut.julianDay(for: date, timezone: timezone)

        for planet in VedicPlanet.allCases {
            let position = sut.tropicalLongitude(planet: planet, julianDay: jd)
            XCTAssertNotNil(position, "Should calculate \(planet.rawValue) position")

            if let pos = position {
                XCTAssertGreaterThanOrEqual(pos.longitude, 0, "\(planet.rawValue) longitude >= 0")
                XCTAssertLessThan(pos.longitude, 360, "\(planet.rawValue) longitude < 360")
            }
        }
    }

    // MARK: - Retrograde Detection Tests

    func testSaturnCanBeRetrograde() {
        // Saturn is retrograde for about 140 days per year
        // Check multiple dates to find a retrograde period
        var foundRetrograde = false

        for dayOffset in stride(from: 0, to: 365, by: 30) {
            let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: createDate(year: 2000, month: 1, day: 1, hour: 12, minute: 0))!
            let timezone = TimeZone(identifier: "UTC")!
            let jd = sut.julianDay(for: date, timezone: timezone)

            if let position = sut.tropicalLongitude(planet: .saturn, julianDay: jd) {
                if position.isRetrograde {
                    foundRetrograde = true
                    break
                }
            }
        }

        XCTAssertTrue(foundRetrograde, "Saturn should be retrograde at some point in 2000")
    }

    func testSunNeverRetrograde() {
        // Sun (from Earth's perspective) never appears retrograde
        for dayOffset in stride(from: 0, to: 365, by: 30) {
            let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: createDate(year: 2000, month: 1, day: 1, hour: 12, minute: 0))!
            let timezone = TimeZone(identifier: "UTC")!
            let jd = sut.julianDay(for: date, timezone: timezone)

            if let position = sut.tropicalLongitude(planet: .sun, julianDay: jd) {
                XCTAssertFalse(position.isRetrograde, "Sun should never be retrograde")
            }
        }
    }

    // MARK: - Ayanamsa Tests

    func testLahiriAyanamsaForY2K() {
        let date = createDate(year: 2000, month: 1, day: 1, hour: 0, minute: 0)
        let timezone = TimeZone(identifier: "UTC")!
        let jd = sut.julianDay(for: date, timezone: timezone)

        let ayanamsa = sut.ayanamsaValue(julianDay: jd, ayanamsa: .lahiri)

        // Lahiri ayanamsa on Jan 1, 2000 is approximately 23°51'
        XCTAssertEqual(ayanamsa, 23.85, accuracy: 0.1, "Lahiri ayanamsa for Y2K")
    }

    func testAyanamsaIncreases() {
        // Ayanamsa increases over time (precession of equinoxes)
        let timezone = TimeZone(identifier: "UTC")!

        let date1 = createDate(year: 2000, month: 1, day: 1, hour: 0, minute: 0)
        let date2 = createDate(year: 2020, month: 1, day: 1, hour: 0, minute: 0)

        let jd1 = sut.julianDay(for: date1, timezone: timezone)
        let jd2 = sut.julianDay(for: date2, timezone: timezone)

        let ayanamsa1 = sut.ayanamsaValue(julianDay: jd1, ayanamsa: .lahiri)
        let ayanamsa2 = sut.ayanamsaValue(julianDay: jd2, ayanamsa: .lahiri)

        XCTAssertGreaterThan(ayanamsa2, ayanamsa1, "Ayanamsa should increase over time")

        // Should increase by about 50 arcseconds per year = ~0.28° over 20 years
        let expectedIncrease = 20 * 50.3 / 3600.0
        let actualIncrease = ayanamsa2 - ayanamsa1
        XCTAssertEqual(actualIncrease, expectedIncrease, accuracy: 0.05, "Annual precession rate")
    }

    // MARK: - House Calculation Tests

    func testHouseCalculation() {
        let date = createDate(year: 2000, month: 1, day: 1, hour: 12, minute: 0)
        let timezone = TimeZone(identifier: "Asia/Kolkata")!
        let jd = sut.julianDay(for: date, timezone: timezone)

        let location = GeoLocation.newDelhi
        let houses = sut.calculateHouses(julianDay: jd, location: location, houseSystem: .equal)

        XCTAssertNotNil(houses, "Should calculate houses")
        if let h = houses {
            XCTAssertEqual(h.cusps.count, 12, "Should have 12 house cusps")
            XCTAssertGreaterThanOrEqual(h.ascendant, 0, "Ascendant >= 0")
            XCTAssertLessThan(h.ascendant, 360, "Ascendant < 360")
        }
    }

    func testSiderealHouseCalculation() {
        let date = createDate(year: 2000, month: 1, day: 1, hour: 12, minute: 0)
        let timezone = TimeZone(identifier: "Asia/Kolkata")!
        let jd = sut.julianDay(for: date, timezone: timezone)

        let location = GeoLocation.newDelhi
        let siderealHouses = sut.calculateSiderealHouses(
            julianDay: jd,
            location: location,
            houseSystem: .equal,
            ayanamsa: .lahiri
        )

        let tropicalHouses = sut.calculateHouses(julianDay: jd, location: location, houseSystem: .equal)

        XCTAssertNotNil(siderealHouses, "Should calculate sidereal houses")
        XCTAssertNotNil(tropicalHouses, "Should calculate tropical houses")

        if let sid = siderealHouses, let trop = tropicalHouses {
            // Sidereal ascendant should be about 23.85° less than tropical
            var diff = trop.ascendant - sid.ascendant
            if diff < 0 { diff += 360 }
            XCTAssertEqual(diff, 23.85, accuracy: 1.0, "Sidereal-tropical ascendant difference")
        }
    }

    // MARK: - Reference Chart Verification

    func testReferenceChart1Positions() {
        // Verify against known positions from Jagannatha Hora
        let details = ReferenceCharts.chart1BirthDetails
        let timezone = TimeZone(identifier: details.timezone)!

        // Combine date and time
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: details.dateOfBirth)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: details.timeOfBirth)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        components.timeZone = timezone

        guard let birthDateTime = calendar.date(from: components) else {
            XCTFail("Could not create birth date time")
            return
        }

        let jd = sut.julianDay(for: birthDateTime, timezone: timezone)

        for (planet, expected) in ReferenceCharts.chart1ExpectedPositions {
            let position = sut.siderealLongitude(planet: planet, julianDay: jd, ayanamsa: .lahiri)

            XCTAssertNotNil(position, "Should calculate \(planet.rawValue) position")
            if let pos = position {
                let matches = expected.matches(actualDegree: pos.degreeInSign, actualSign: pos.sign)
                XCTAssertTrue(matches,
                    "\(planet.rawValue) expected \(expected), got \(pos.sign.rawValue) \(String(format: "%.1f", pos.degreeInSign))°"
                )
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
        components.second = 0
        components.timeZone = TimeZone(identifier: "UTC")
        return Calendar.current.date(from: components) ?? Date()
    }
}
