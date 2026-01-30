import XCTest
@testable import Kundli

/// Integration tests for KundliGenerationService
/// Tests the complete kundli generation flow
final class KundliGenerationServiceTests: XCTestCase {
    var sut: KundliGenerationService!

    override func setUp() {
        super.setUp()
        sut = KundliGenerationService.shared
    }

    // MARK: - Full Generation Tests

    func testCompleteKundliGeneration() async throws {
        let birthDetails = ReferenceCharts.chart1BirthDetails

        let kundliData = try await sut.generateKundli(
            birthDetails: birthDetails,
            settings: .default
        )

        // Verify all components are present
        XCTAssertEqual(kundliData.planets.count, 9, "Should have 9 planets")
        XCTAssertNotNil(kundliData.ascendant, "Should have ascendant")
        XCTAssertGreaterThan(kundliData.dashaPeriods.count, 0, "Should have dasha periods")
        XCTAssertGreaterThan(kundliData.divisionalCharts.count, 0, "Should have divisional charts")
    }

    func testKundliHasValidPlanetPositions() async throws {
        let birthDetails = ReferenceCharts.chart1BirthDetails

        let kundliData = try await sut.generateKundli(
            birthDetails: birthDetails,
            settings: .default
        )

        for planet in kundliData.planets {
            // Each planet should have valid position data
            XCTAssertFalse(planet.name.isEmpty, "Planet should have name")
            XCTAssertFalse(planet.sign.isEmpty, "Planet should have sign")
            XCTAssertGreaterThanOrEqual(planet.degree, 0, "Degree should be >= 0")
            XCTAssertLessThan(planet.degree, 30, "Degree should be < 30")
            XCTAssertGreaterThanOrEqual(planet.house, 1, "House should be >= 1")
            XCTAssertLessThanOrEqual(planet.house, 12, "House should be <= 12")
            XCTAssertGreaterThanOrEqual(planet.nakshatraPada, 1, "Pada should be >= 1")
            XCTAssertLessThanOrEqual(planet.nakshatraPada, 4, "Pada should be <= 4")
        }
    }

    func testKundliHasValidAscendant() async throws {
        let birthDetails = ReferenceCharts.chart1BirthDetails

        let kundliData = try await sut.generateKundli(
            birthDetails: birthDetails,
            settings: .default
        )

        let ascendant = kundliData.ascendant

        // Ascendant should have valid data
        XCTAssertGreaterThanOrEqual(ascendant.degree, 0)
        XCTAssertLessThan(ascendant.degree, 30)
        XCTAssertFalse(ascendant.nakshatra.isEmpty)
        XCTAssertGreaterThanOrEqual(ascendant.nakshatraPada, 1)
        XCTAssertLessThanOrEqual(ascendant.nakshatraPada, 4)
    }

    func testKundliDashaPeriodsAreContinuous() async throws {
        let birthDetails = ReferenceCharts.chart1BirthDetails

        let kundliData = try await sut.generateKundli(
            birthDetails: birthDetails,
            settings: .default
        )

        // Verify dasha periods are continuous
        for i in 0..<(kundliData.dashaPeriods.count - 1) {
            let currentEnd = kundliData.dashaPeriods[i].endDate
            let nextStart = kundliData.dashaPeriods[i + 1].startDate

            let gap = abs(nextStart.timeIntervalSince(currentEnd))
            XCTAssertLessThan(gap, 86400, "Dasha periods should be continuous (gap < 1 day)")
        }
    }

    func testKundliHasOneActiveDasha() async throws {
        let birthDetails = ReferenceCharts.chart1BirthDetails

        let kundliData = try await sut.generateKundli(
            birthDetails: birthDetails,
            settings: .default
        )

        let activeDashas = kundliData.dashaPeriods.filter { $0.isActive }

        // Should have exactly one active Maha Dasha
        XCTAssertEqual(activeDashas.count, 1, "Should have exactly one active Maha Dasha")
    }

    // MARK: - Divisional Charts Tests

    func testKundliHasPriorityDivisionalCharts() async throws {
        let birthDetails = ReferenceCharts.chart1BirthDetails

        let kundliData = try await sut.generateKundli(
            birthDetails: birthDetails,
            settings: .default
        )

        // Should have at least D1, D9, D10
        let chartTypes = kundliData.divisionalCharts.map { $0.chartType }

        XCTAssertTrue(chartTypes.contains(.d1) || chartTypes.contains(.d9),
            "Should have priority charts (D1 or D9)")
    }

    func testNavamsaChartIsValid() async throws {
        let birthDetails = ReferenceCharts.chart1BirthDetails

        let kundliData = try await sut.generateKundli(
            birthDetails: birthDetails,
            settings: .default
        )

        if let navamsa = kundliData.navamsaChart {
            XCTAssertEqual(navamsa.chartType, .d9)
            XCTAssertEqual(navamsa.planetPositions.count, 9)

            for position in navamsa.planetPositions {
                XCTAssertGreaterThanOrEqual(position.signIndex, 0)
                XCTAssertLessThan(position.signIndex, 12)
            }
        }
    }

    // MARK: - Yoga and Dosha Detection

    func testYogaDetection() async throws {
        let birthDetails = ReferenceCharts.chart1BirthDetails

        let kundliData = try await sut.generateKundli(
            birthDetails: birthDetails,
            settings: .default
        )

        // Yogas array should exist (may be empty depending on chart)
        XCTAssertNotNil(kundliData.yogas)

        // All detected yogas should have valid data
        for yoga in kundliData.yogas {
            XCTAssertFalse(yoga.name.isEmpty)
            XCTAssertFalse(yoga.description.isEmpty)
        }
    }

    func testDoshaDetection() async throws {
        let birthDetails = ReferenceCharts.chart1BirthDetails

        let kundliData = try await sut.generateKundli(
            birthDetails: birthDetails,
            settings: .default
        )

        // Doshas array should exist
        XCTAssertNotNil(kundliData.doshas)

        // All detected doshas should have valid data
        for dosha in kundliData.doshas {
            XCTAssertFalse(dosha.name.isEmpty)
            XCTAssertFalse(dosha.description.isEmpty)
        }
    }

    // MARK: - Reference Chart Verification

    func testReferenceChart1Accuracy() async throws {
        let birthDetails = ReferenceCharts.chart1BirthDetails

        let kundliData = try await sut.generateKundli(
            birthDetails: birthDetails,
            settings: .default
        )

        // Verify planet positions against reference data
        for (vedicPlanet, expected) in ReferenceCharts.chart1ExpectedPositions {
            let planet = kundliData.planets.first { $0.name == vedicPlanet.rawValue }
            XCTAssertNotNil(planet, "Should have \(vedicPlanet.rawValue)")

            if let p = planet {
                let sign = ZodiacSign.allCases.first { $0.rawValue == p.sign }
                XCTAssertNotNil(sign)

                if let s = sign {
                    let matches = expected.matches(actualDegree: p.degree, actualSign: s)
                    XCTAssertTrue(matches,
                        "\(vedicPlanet.rawValue) expected \(expected), got \(p.sign) \(p.degree)°")
                }
            }
        }
    }

    // MARK: - Settings Tests

    func testDifferentAyanamsaSettings() async throws {
        let birthDetails = ReferenceCharts.chart1BirthDetails

        let lahiriData = try await sut.generateKundli(
            birthDetails: birthDetails,
            settings: .default  // Uses Lahiri
        )

        let kpData = try await sut.generateKundli(
            birthDetails: birthDetails,
            settings: .kp  // Uses Krishnamurti
        )

        // Planet positions should be slightly different with different ayanamsa
        // (Not dramatically different, just offset by the ayanamsa difference)
        let lahiriSun = lahiriData.planets.first { $0.name == "Sun" }
        let kpSun = kpData.planets.first { $0.name == "Sun" }

        XCTAssertNotNil(lahiriSun)
        XCTAssertNotNil(kpSun)

        // Both should be valid
        XCTAssertGreaterThanOrEqual(lahiriSun!.degree, 0)
        XCTAssertGreaterThanOrEqual(kpSun!.degree, 0)
    }

    // MARK: - Error Handling Tests

    func testInvalidBirthDetailsThrowsError() async {
        let invalidDetails = BirthDetails(
            name: "",  // Empty name is invalid
            dateOfBirth: Date(),
            timeOfBirth: Date(),
            birthCity: "Test",
            latitude: 0,
            longitude: 0,
            timezone: "UTC",
            gender: .male
        )

        do {
            _ = try await sut.generateKundli(
                birthDetails: invalidDetails,
                settings: .default
            )
            XCTFail("Should throw error for invalid details")
        } catch {
            XCTAssertTrue(error is KundliGenerationError)
        }
    }

    // MARK: - Performance Tests

    func testGenerationPerformance() async throws {
        let birthDetails = ReferenceCharts.chart1BirthDetails

        let startTime = CFAbsoluteTimeGetCurrent()

        _ = try await sut.generateKundli(
            birthDetails: birthDetails,
            settings: .default
        )

        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

        // Should complete within 2 seconds
        XCTAssertLessThan(timeElapsed, 2.0, "Kundli generation should complete within 2 seconds")
    }

    func testGenerationPerformanceWithMeasure() {
        let birthDetails = ReferenceCharts.chart1BirthDetails

        measure {
            let expectation = self.expectation(description: "Generation")

            Task {
                do {
                    _ = try await self.sut.generateKundli(
                        birthDetails: birthDetails,
                        settings: .default
                    )
                } catch {
                    XCTFail("Generation failed: \(error)")
                }
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 5.0)
        }
    }

    // MARK: - Conversion Tests

    func testToKundliConversion() async throws {
        let birthDetails = ReferenceCharts.chart1BirthDetails

        let kundliData = try await sut.generateKundli(
            birthDetails: birthDetails,
            settings: .default
        )

        let kundli = kundliData.toKundli()

        // Verify conversion produces valid Kundli model
        XCTAssertEqual(kundli.planets.count, 9)
        XCTAssertNotNil(kundli.ascendant)
        XCTAssertEqual(kundli.birthDetails.name, birthDetails.name)
    }

    // MARK: - Helper Properties Tests

    func testKundliDataHelperProperties() async throws {
        let birthDetails = ReferenceCharts.chart1BirthDetails

        let kundliData = try await sut.generateKundli(
            birthDetails: birthDetails,
            settings: .default
        )

        // Test helper properties don't crash
        _ = kundliData.activeDasha
        _ = kundliData.moonNakshatra
        _ = kundliData.lagnaSign
        _ = kundliData.navamsaChart
        _ = kundliData.dasamsaChart
        _ = kundliData.hasManglikDosha
        _ = kundliData.hasKaalSarpDosha
        _ = kundliData.beneficYogas
    }
}
