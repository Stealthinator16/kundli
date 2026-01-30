import XCTest
@testable import Kundli

/// Tests for DashaCalculationService
final class DashaCalculationServiceTests: XCTestCase {
    var sut: DashaCalculationService!

    override func setUp() {
        super.setUp()
        sut = DashaCalculationService.shared
    }

    // MARK: - Vimshottari Total Tests

    func testTotalDashaYearsEquals120() {
        var total = 0
        for planet in VedicPlanet.vimshottariSequence {
            total += planet.dashaYears
        }

        XCTAssertEqual(total, 120, "Total Vimshottari cycle should be 120 years")
    }

    func testVimshottariSequenceOrder() {
        let expectedOrder: [VedicPlanet] = [.ketu, .venus, .sun, .moon, .mars, .rahu, .jupiter, .saturn, .mercury]
        XCTAssertEqual(VedicPlanet.vimshottariSequence, expectedOrder, "Vimshottari sequence should match")
    }

    func testNextInVimshottariSequence() {
        XCTAssertEqual(VedicPlanet.ketu.nextInVimshottari, .venus)
        XCTAssertEqual(VedicPlanet.venus.nextInVimshottari, .sun)
        XCTAssertEqual(VedicPlanet.sun.nextInVimshottari, .moon)
        XCTAssertEqual(VedicPlanet.moon.nextInVimshottari, .mars)
        XCTAssertEqual(VedicPlanet.mars.nextInVimshottari, .rahu)
        XCTAssertEqual(VedicPlanet.rahu.nextInVimshottari, .jupiter)
        XCTAssertEqual(VedicPlanet.jupiter.nextInVimshottari, .saturn)
        XCTAssertEqual(VedicPlanet.saturn.nextInVimshottari, .mercury)
        XCTAssertEqual(VedicPlanet.mercury.nextInVimshottari, .ketu)  // Cycle back
    }

    // MARK: - Dasha Period Calculation Tests

    func testDashaPeriodCalculation() {
        // Moon at 0° (Ashwini) starts Ketu dasha with full balance
        let birthDate = createDate(year: 2000, month: 1, day: 1)
        let periods = sut.calculateDashaPeriods(moonLongitude: 0.0, birthDate: birthDate)

        XCTAssertGreaterThan(periods.count, 0, "Should calculate dasha periods")

        // First period should be Ketu
        if let firstDasha = periods.first {
            XCTAssertEqual(firstDasha.planet, "Ketu", "First dasha should be Ketu for Ashwini")
        }
    }

    func testDashaBalanceAtMoonPosition() {
        // Moon at middle of Ashwini (6.66°) should have ~50% Ketu balance
        let birthDate = createDate(year: 2000, month: 1, day: 1)
        let periods = sut.calculateDashaPeriods(moonLongitude: 6.666, birthDate: birthDate)

        if let firstDasha = periods.first {
            XCTAssertEqual(firstDasha.planet, "Ketu")

            let ketuTotalYears = 7.0
            let expectedYears = ketuTotalYears / 2  // About 3.5 years

            // Calculate actual duration
            let actualYears = firstDasha.endDate.timeIntervalSince(firstDasha.startDate) / (365.25 * 24 * 3600)

            XCTAssertEqual(actualYears, expectedYears, accuracy: 0.5, "First dasha balance should be ~3.5 years")
        }
    }

    func testDashaSequenceContinuity() {
        // Verify that dasha periods are continuous (no gaps)
        let birthDate = createDate(year: 2000, month: 1, day: 1)
        let periods = sut.calculateDashaPeriods(moonLongitude: 0.0, birthDate: birthDate)

        for i in 0..<(periods.count - 1) {
            let currentEnd = periods[i].endDate
            let nextStart = periods[i + 1].startDate

            // Should be within 1 day of each other
            let gap = abs(nextStart.timeIntervalSince(currentEnd))
            XCTAssertLessThan(gap, 86400, "Dasha periods should be continuous")
        }
    }

    // MARK: - Antar Dasha Tests

    func testAntarDashaCalculation() {
        let mahaDashaStart = createDate(year: 2000, month: 1, day: 1)
        let mahaDashaEnd = Calendar.current.date(byAdding: .year, value: 7, to: mahaDashaStart)!

        let antarDashas = sut.calculateAntarDashas(
            mahaDashaPlanet: .ketu,
            startDate: mahaDashaStart,
            endDate: mahaDashaEnd
        )

        XCTAssertEqual(antarDashas.count, 9, "Should have 9 Antar Dashas")

        // First Antar Dasha should be same as Maha Dasha lord
        if let firstAntar = antarDashas.first {
            XCTAssertEqual(firstAntar.planet, "Ketu", "First Antar should match Maha Dasha")
        }
    }

    func testAntarDashaTotalEqualsMMahaDasha() {
        let mahaDashaStart = createDate(year: 2000, month: 1, day: 1)
        let ketuYears = 7.0
        let mahaDashaEnd = Calendar.current.date(byAdding: .day, value: Int(ketuYears * 365.25), to: mahaDashaStart)!

        let antarDashas = sut.calculateAntarDashas(
            mahaDashaPlanet: .ketu,
            startDate: mahaDashaStart,
            endDate: mahaDashaEnd
        )

        // Sum of all Antar Dasha durations should equal Maha Dasha duration
        var totalAntarDays = 0.0
        for antar in antarDashas {
            totalAntarDays += antar.endDate.timeIntervalSince(antar.startDate) / 86400
        }

        let mahaDashaDays = ketuYears * 365.25
        XCTAssertEqual(totalAntarDays, mahaDashaDays, accuracy: 2, "Antar Dashas should sum to Maha Dasha")
    }

    func testAntarDashaProportions() {
        // Antar Dasha duration = (Maha years × Antar years) / 120
        let mahaDashaStart = createDate(year: 2000, month: 1, day: 1)
        let venusYears = 20.0
        let mahaDashaEnd = Calendar.current.date(byAdding: .day, value: Int(venusYears * 365.25), to: mahaDashaStart)!

        let antarDashas = sut.calculateAntarDashas(
            mahaDashaPlanet: .venus,
            startDate: mahaDashaStart,
            endDate: mahaDashaEnd
        )

        // Venus-Venus antar = (20 × 20) / 120 = 3.33 years
        if let venusAntar = antarDashas.first {
            XCTAssertEqual(venusAntar.planet, "Venus")
            let durationYears = venusAntar.endDate.timeIntervalSince(venusAntar.startDate) / (365.25 * 86400)
            XCTAssertEqual(durationYears, 3.33, accuracy: 0.1, "Venus-Venus should be ~3.33 years")
        }
    }

    // MARK: - Pratyantar Dasha Tests

    func testPratyantarDashaCalculation() {
        let antarStart = createDate(year: 2000, month: 1, day: 1)
        // Venus-Venus antar = (20 × 20) / 120 = 3.33 years
        let antarEnd = Calendar.current.date(byAdding: .day, value: 1217, to: antarStart)!  // ~3.33 years

        let pratyantars = sut.calculatePratyantarDashas(
            mahaDashaPlanet: .venus,
            antarDashaPlanet: .venus,
            startDate: antarStart,
            endDate: antarEnd
        )

        XCTAssertEqual(pratyantars.count, 9, "Should have 9 Pratyantar Dashas")
    }

    // MARK: - Current Dasha Tests

    func testCurrentDashaDetection() {
        // Create periods with one active
        let birthDate = createDate(year: 2000, month: 1, day: 1)
        let periods = sut.calculateDashaPeriods(moonLongitude: 0.0, birthDate: birthDate)

        let currentInfo = sut.currentDasha(from: periods)

        XCTAssertNotNil(currentInfo, "Should detect current dasha")
        if let info = currentInfo {
            XCTAssertFalse(info.mahaDasha.isEmpty, "Should have Maha Dasha")
        }
    }

    // MARK: - Different Nakshatra Starting Points

    func testDashaFromBharaniNakshatra() {
        // Bharani lord is Venus (20 years)
        // Moon at 15° (middle of Bharani)
        let birthDate = createDate(year: 2000, month: 1, day: 1)
        let periods = sut.calculateDashaPeriods(moonLongitude: 15.0, birthDate: birthDate)

        if let firstDasha = periods.first {
            XCTAssertEqual(firstDasha.planet, "Venus", "Bharani starts Venus dasha")
        }
    }

    func testDashaFromRohiniNakshatra() {
        // Rohini lord is Moon (10 years)
        // Rohini starts at 40° (end of Krittika at ~40°)
        let birthDate = createDate(year: 2000, month: 1, day: 1)
        let periods = sut.calculateDashaPeriods(moonLongitude: 45.0, birthDate: birthDate)

        if let firstDasha = periods.first {
            XCTAssertEqual(firstDasha.planet, "Moon", "Rohini starts Moon dasha")
        }
    }

    // MARK: - Birth Details Integration

    func testCalculateFromBirthDetails() {
        let birthDetails = ReferenceCharts.chart1BirthDetails

        // First calculate Moon position
        let planetService = PlanetaryPositionService.shared
        let positions = planetService.calculatePlanets(from: birthDetails)

        guard let moon = positions.first(where: { $0.planet == .moon }) else {
            XCTFail("Should calculate Moon position")
            return
        }

        let periods = sut.calculateDashaPeriods(
            from: birthDetails,
            moonPosition: moon
        )

        XCTAssertGreaterThan(periods.count, 0, "Should calculate dasha periods")
    }

    // MARK: - Dasha Balance Calculation

    func testDashaBalancePercentage() {
        let startDate = createDate(year: 2000, month: 1, day: 1)
        let endDate = Calendar.current.date(byAdding: .year, value: 7, to: startDate)!

        let period = DashaPeriod(
            planet: "Ketu",
            vedName: "Ketu",
            startDate: startDate,
            endDate: endDate,
            isActive: true
        )

        // At start, balance should be 100%
        let balanceAtStart = sut.dashaBalance(for: period, at: startDate)
        XCTAssertEqual(balanceAtStart, 100.0, accuracy: 1.0, "Balance at start should be 100%")

        // At middle, balance should be ~50%
        let middleDate = Calendar.current.date(byAdding: .day, value: Int(3.5 * 365.25), to: startDate)!
        let balanceAtMiddle = sut.dashaBalance(for: period, at: middleDate)
        XCTAssertEqual(balanceAtMiddle, 50.0, accuracy: 5.0, "Balance at middle should be ~50%")

        // At end, balance should be ~0%
        let balanceAtEnd = sut.dashaBalance(for: period, at: endDate)
        XCTAssertEqual(balanceAtEnd, 0.0, accuracy: 1.0, "Balance at end should be ~0%")
    }

    // MARK: - Performance Tests

    func testDashaCalculationPerformance() {
        let birthDate = createDate(year: 2000, month: 1, day: 1)

        measure {
            for _ in 0..<100 {
                _ = sut.calculateDashaPeriods(moonLongitude: Double.random(in: 0..<360), birthDate: birthDate)
            }
        }
    }

    // MARK: - Helper Methods

    private func createDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 12
        components.minute = 0
        components.timeZone = TimeZone(identifier: "Asia/Kolkata")
        return Calendar.current.date(from: components) ?? Date()
    }
}
