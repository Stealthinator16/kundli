import XCTest
@testable import Kundli

/// Tests for DivisionalChartService
final class DivisionalChartServiceTests: XCTestCase {
    var sut: DivisionalChartService!

    override func setUp() {
        super.setUp()
        sut = DivisionalChartService.shared
    }

    // MARK: - D-9 Navamsa Tests

    func testNavamsaAt0Degrees() {
        // 0° Aries should give Aries navamsa
        let longitude = sut.calculateDivisionalLongitude(longitude: 0.0, chart: .d9)
        let signIndex = Int(longitude / 30.0) % 12

        XCTAssertEqual(signIndex, 0, "0° Aries -> Aries navamsa")
    }

    func testNavamsaAt3_33Degrees() {
        // 3.33° Aries (end of first navamsa) should give Taurus navamsa
        let longitude = sut.calculateDivisionalLongitude(longitude: 3.333, chart: .d9)
        let signIndex = Int(longitude / 30.0) % 12

        XCTAssertEqual(signIndex, 1, "3.33° Aries -> Taurus navamsa")
    }

    func testNavamsaForTaurusSign() {
        // 0° Taurus (30°) should give Capricorn navamsa (Earth sign starts from Capricorn)
        let longitude = sut.calculateDivisionalLongitude(longitude: 30.0, chart: .d9)
        let signIndex = Int(longitude / 30.0) % 12

        XCTAssertEqual(signIndex, 9, "0° Taurus -> Capricorn navamsa")
    }

    func testNavamsaForLibraSign() {
        // 0° Libra (180°) should give Libra navamsa (Air sign starts from Libra)
        let longitude = sut.calculateDivisionalLongitude(longitude: 180.0, chart: .d9)
        let signIndex = Int(longitude / 30.0) % 12

        XCTAssertEqual(signIndex, 6, "0° Libra -> Libra navamsa")
    }

    func testNavamsaForCancerSign() {
        // 0° Cancer (90°) should give Cancer navamsa (Water sign starts from Cancer)
        let longitude = sut.calculateDivisionalLongitude(longitude: 90.0, chart: .d9)
        let signIndex = Int(longitude / 30.0) % 12

        XCTAssertEqual(signIndex, 3, "0° Cancer -> Cancer navamsa")
    }

    func testNavamsaReferenceTestCases() {
        for testCase in ReferenceCharts.d9TestCases {
            let longitude = sut.calculateDivisionalLongitude(longitude: testCase.longitude, chart: .d9)
            let signIndex = Int(longitude / 30.0) % 12

            XCTAssertEqual(signIndex, testCase.expectedSignIndex,
                "D9 at \(testCase.longitude)° expected sign \(testCase.expectedSignIndex), got \(signIndex)")
        }
    }

    // MARK: - D-10 Dasamsa Tests

    func testDasamsaAt0DegreesAries() {
        // 0° Aries (odd sign) should give Aries dasamsa
        let longitude = sut.calculateDivisionalLongitude(longitude: 0.0, chart: .d10)
        let signIndex = Int(longitude / 30.0) % 12

        XCTAssertEqual(signIndex, 0, "0° Aries -> Aries dasamsa")
    }

    func testDasamsaAt3DegreesAries() {
        // 3° Aries should give Taurus dasamsa
        let longitude = sut.calculateDivisionalLongitude(longitude: 3.0, chart: .d10)
        let signIndex = Int(longitude / 30.0) % 12

        XCTAssertEqual(signIndex, 1, "3° Aries -> Taurus dasamsa")
    }

    func testDasamsaForTaurusSign() {
        // 0° Taurus (even sign) should give different starting point
        let longitude = sut.calculateDivisionalLongitude(longitude: 30.0, chart: .d10)
        let signIndex = Int(longitude / 30.0) % 12

        // Even signs start from 9th sign from itself
        XCTAssertEqual(signIndex, 8, "0° Taurus -> Sagittarius dasamsa")
    }

    func testDasamsaReferenceTestCases() {
        for testCase in ReferenceCharts.d10TestCases {
            let longitude = sut.calculateDivisionalLongitude(longitude: testCase.longitude, chart: .d10)
            let signIndex = Int(longitude / 30.0) % 12

            XCTAssertEqual(signIndex, testCase.expectedSignIndex,
                "D10 at \(testCase.longitude)° expected sign \(testCase.expectedSignIndex), got \(signIndex)")
        }
    }

    // MARK: - D-12 Dwadasamsa Tests

    func testDwadasamsaAt0Degrees() {
        // 0° Aries should give Aries dwadasamsa (starts from same sign)
        let longitude = sut.calculateDivisionalLongitude(longitude: 0.0, chart: .d12)
        let signIndex = Int(longitude / 30.0) % 12

        XCTAssertEqual(signIndex, 0, "0° Aries -> Aries dwadasamsa")
    }

    func testDwadasamsaCycles() {
        // Each 2.5° should advance one sign in D12
        let long1 = sut.calculateDivisionalLongitude(longitude: 0.0, chart: .d12)
        let long2 = sut.calculateDivisionalLongitude(longitude: 2.5, chart: .d12)

        let sign1 = Int(long1 / 30.0) % 12
        let sign2 = Int(long2 / 30.0) % 12

        XCTAssertEqual((sign2 - sign1 + 12) % 12, 1, "2.5° should advance one sign in D12")
    }

    // MARK: - D-1 Rashi Tests

    func testD1IsIdentity() {
        // D-1 should return the same longitude
        for testLong in stride(from: 0.0, to: 360.0, by: 30.0) {
            let result = sut.calculateDivisionalLongitude(longitude: testLong, chart: .d1)
            XCTAssertEqual(result, testLong, accuracy: 0.001, "D1 should be identity")
        }
    }

    // MARK: - Edge Case Tests

    func testEdgeCaseAt29_99Degrees() {
        // Test at edge of sign (29.99°)
        let navamsa = sut.calculateDivisionalLongitude(longitude: 29.99, chart: .d9)
        let signIndex = Int(navamsa / 30.0) % 12

        // Last navamsa of Aries (fire sign) should be Sagittarius (8)
        // 29.99° / 3.333 ≈ 9th navamsa
        XCTAssertEqual(signIndex, 8, "Last navamsa of Aries should be Sagittarius")
    }

    func testEdgeCaseAt360Degrees() {
        // 360° should wrap to 0°
        let navamsa = sut.calculateDivisionalLongitude(longitude: 360.0, chart: .d9)
        let signIndex = Int(navamsa / 30.0) % 12

        // Should be same as 0°
        XCTAssertEqual(signIndex, 0, "360° should wrap to Aries")
    }

    func testNegativeLongitude() {
        // Negative longitudes should be handled (wrap around)
        // -10° = 350° (should be in Pisces range)
        let input = -10.0
        let normalized = (input + 360).truncatingRemainder(dividingBy: 360)

        let navamsa = sut.calculateDivisionalLongitude(longitude: normalized, chart: .d9)
        XCTAssertGreaterThanOrEqual(navamsa, 0, "Should handle normalized negative values")
        XCTAssertLessThan(navamsa, 360, "Should be valid range")
    }

    // MARK: - Full Chart Calculation Tests

    func testCalculateDivisionalChart() {
        // Create sample planet positions
        let planets = createSamplePlanetPositions()
        let ascendantLong = 45.0  // 15° Taurus

        let d9Chart = sut.calculateDivisionalChart(
            chartType: .d9,
            planets: planets,
            ascendantLongitude: ascendantLong
        )

        XCTAssertEqual(d9Chart.chartType, .d9)
        XCTAssertEqual(d9Chart.planetPositions.count, planets.count)
    }

    func testCalculateAllDivisionalCharts() {
        let planets = createSamplePlanetPositions()
        let ascendantLong = 45.0

        let allCharts = sut.calculateAllDivisionalCharts(
            planets: planets,
            ascendantLongitude: ascendantLong
        )

        XCTAssertEqual(allCharts.count, DivisionalChart.allCases.count,
            "Should calculate all divisional charts")
    }

    func testCalculatePriorityCharts() {
        let planets = createSamplePlanetPositions()
        let ascendantLong = 45.0

        let priorityCharts = sut.calculatePriorityCharts(
            planets: planets,
            ascendantLongitude: ascendantLong
        )

        XCTAssertEqual(priorityCharts.count, 3, "Should have D1, D9, D10")

        let chartTypes = priorityCharts.map { $0.chartType }
        XCTAssertTrue(chartTypes.contains(.d1), "Should include D1")
        XCTAssertTrue(chartTypes.contains(.d9), "Should include D9")
        XCTAssertTrue(chartTypes.contains(.d10), "Should include D10")
    }

    // MARK: - D-30 Trimshamsa Tests

    func testTrimshamsaUnequalDivisions() {
        // D-30 has unequal divisions: 5°, 5°, 8°, 7°, 5° for odd signs
        // First 5° of Aries should go to Mars (Aries)
        let long1 = sut.calculateDivisionalLongitude(longitude: 2.0, chart: .d30)
        let sign1 = Int(long1 / 30.0) % 12
        XCTAssertEqual(sign1, 0, "First 5° of Aries -> Aries (Mars)")

        // 5-10° should go to Saturn (Aquarius)
        let long2 = sut.calculateDivisionalLongitude(longitude: 7.0, chart: .d30)
        let sign2 = Int(long2 / 30.0) % 12
        XCTAssertEqual(sign2, 6, "5-10° of Aries -> Aquarius (Saturn)")
    }

    // MARK: - Performance Tests

    func testDivisionalChartPerformance() {
        let planets = createSamplePlanetPositions()
        let ascendantLong = 45.0

        measure {
            for _ in 0..<1000 {
                _ = sut.calculateDivisionalChart(chartType: .d9, planets: planets, ascendantLongitude: ascendantLong)
            }
        }
    }

    // MARK: - Helper Methods

    private func createSamplePlanetPositions() -> [VedicPlanetPosition] {
        return VedicPlanet.allCases.map { planet in
            let randomLong = Double(planet.swissEphemerisId) * 30.0 + 15.0  // Spread planets across signs
            return createTestPosition(planet: planet, longitude: randomLong)
        }
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
}
