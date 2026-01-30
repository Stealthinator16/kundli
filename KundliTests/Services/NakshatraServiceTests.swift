import XCTest
@testable import Kundli

/// Tests for NakshatraService
/// Verifies nakshatra calculations at boundaries
final class NakshatraServiceTests: XCTestCase {
    var sut: NakshatraService!

    override func setUp() {
        super.setUp()
        sut = NakshatraService.shared
    }

    // MARK: - Basic Nakshatra Tests

    func testNakshatraAtZeroDegrees() {
        // 0° should be Ashwini Pada 1
        let info = sut.nakshatra(fromSiderealLongitude: 0.0)

        XCTAssertEqual(info.nakshatra, .ashwini, "0° should be Ashwini")
        XCTAssertEqual(info.pada, 1, "0° should be Pada 1")
        XCTAssertEqual(info.lord, "Ketu", "Ashwini lord is Ketu")
    }

    func testNakshatraAt360Degrees() {
        // 360° (= 0°) should also be Ashwini Pada 1
        let info = sut.nakshatra(fromSiderealLongitude: 360.0)

        XCTAssertEqual(info.nakshatra, .ashwini, "360° should wrap to Ashwini")
        XCTAssertEqual(info.pada, 1, "Should be Pada 1")
    }

    func testNakshatraNegativeLongitude() {
        // -10° should be equivalent to 350° (Revati)
        let info = sut.nakshatra(fromSiderealLongitude: -10.0)

        XCTAssertEqual(info.nakshatra, .revati, "Negative should wrap correctly")
    }

    // MARK: - Boundary Tests

    func testFirstNakshatraBoundary() {
        // 13°20' = 13.3333° is the end of Ashwini
        // Just before boundary
        let beforeInfo = sut.nakshatra(fromSiderealLongitude: 13.33)
        XCTAssertEqual(beforeInfo.nakshatra, .ashwini, "13.33° should still be Ashwini")
        XCTAssertEqual(beforeInfo.pada, 4, "13.33° should be Pada 4")

        // Just after boundary
        let afterInfo = sut.nakshatra(fromSiderealLongitude: 13.34)
        XCTAssertEqual(afterInfo.nakshatra, .bharani, "13.34° should be Bharani")
        XCTAssertEqual(afterInfo.pada, 1, "13.34° should be Pada 1")
    }

    func testPadaBoundaries() {
        // Each pada is 3°20' = 3.3333°
        // Pada 1: 0° - 3°20'
        let pada1 = sut.nakshatra(fromSiderealLongitude: 1.0)
        XCTAssertEqual(pada1.pada, 1, "1° should be Pada 1")

        // Pada 2: 3°20' - 6°40'
        let pada2 = sut.nakshatra(fromSiderealLongitude: 5.0)
        XCTAssertEqual(pada2.pada, 2, "5° should be Pada 2")

        // Pada 3: 6°40' - 10°
        let pada3 = sut.nakshatra(fromSiderealLongitude: 8.0)
        XCTAssertEqual(pada3.pada, 3, "8° should be Pada 3")

        // Pada 4: 10° - 13°20'
        let pada4 = sut.nakshatra(fromSiderealLongitude: 12.0)
        XCTAssertEqual(pada4.pada, 4, "12° should be Pada 4")
    }

    func testLastNakshatraBoundary() {
        // Revati is the 27th nakshatra (index 26)
        // Starts at 346°40' (26 * 13.3333)
        let revatiStart = sut.nakshatra(fromSiderealLongitude: 346.67)
        XCTAssertEqual(revatiStart.nakshatra, .revati, "346.67° should be Revati")

        // End of Revati = 360°
        let revatiEnd = sut.nakshatra(fromSiderealLongitude: 359.99)
        XCTAssertEqual(revatiEnd.nakshatra, .revati, "359.99° should be Revati")
        XCTAssertEqual(revatiEnd.pada, 4, "359.99° should be Pada 4")
    }

    // MARK: - Nakshatra Lord Tests

    func testNakshatraLords() {
        // Ketu lords: Ashwini, Magha, Mula
        XCTAssertEqual(sut.lord(for: .ashwini), .ketu)
        XCTAssertEqual(sut.lord(for: .magha), .ketu)
        XCTAssertEqual(sut.lord(for: .mula), .ketu)

        // Venus lords: Bharani, P.Phalguni, P.Ashadha
        XCTAssertEqual(sut.lord(for: .bharani), .venus)
        XCTAssertEqual(sut.lord(for: .purvaphalguni), .venus)
        XCTAssertEqual(sut.lord(for: .purvaashadha), .venus)

        // Sun lords: Krittika, U.Phalguni, U.Ashadha
        XCTAssertEqual(sut.lord(for: .krittika), .sun)
        XCTAssertEqual(sut.lord(for: .uttaraphalguni), .sun)
        XCTAssertEqual(sut.lord(for: .uttaraashadha), .sun)

        // Moon lords: Rohini, Hasta, Shravana
        XCTAssertEqual(sut.lord(for: .rohini), .moon)
        XCTAssertEqual(sut.lord(for: .hasta), .moon)
        XCTAssertEqual(sut.lord(for: .shravana), .moon)

        // Mars lords: Mrigashira, Chitra, Dhanishta
        XCTAssertEqual(sut.lord(for: .mrigashira), .mars)
        XCTAssertEqual(sut.lord(for: .chitra), .mars)
        XCTAssertEqual(sut.lord(for: .dhanishta), .mars)

        // Rahu lords: Ardra, Swati, Shatabhisha
        XCTAssertEqual(sut.lord(for: .ardra), .rahu)
        XCTAssertEqual(sut.lord(for: .swati), .rahu)
        XCTAssertEqual(sut.lord(for: .shatabhisha), .rahu)

        // Jupiter lords: Punarvasu, Vishakha, P.Bhadrapada
        XCTAssertEqual(sut.lord(for: .punarvasu), .jupiter)
        XCTAssertEqual(sut.lord(for: .vishakha), .jupiter)
        XCTAssertEqual(sut.lord(for: .purvabhadrapada), .jupiter)

        // Saturn lords: Pushya, Anuradha, U.Bhadrapada
        XCTAssertEqual(sut.lord(for: .pushya), .saturn)
        XCTAssertEqual(sut.lord(for: .anuradha), .saturn)
        XCTAssertEqual(sut.lord(for: .uttarabhadrapada), .saturn)

        // Mercury lords: Ashlesha, Jyeshtha, Revati
        XCTAssertEqual(sut.lord(for: .ashlesha), .mercury)
        XCTAssertEqual(sut.lord(for: .jyeshtha), .mercury)
        XCTAssertEqual(sut.lord(for: .revati), .mercury)
    }

    // MARK: - All 27 Nakshatra Tests

    func testAll27Nakshatras() {
        let nakshatraSpan = 360.0 / 27.0  // 13.3333°

        for (index, nakshatra) in Nakshatra.allCases.enumerated() {
            let midpoint = Double(index) * nakshatraSpan + (nakshatraSpan / 2)
            let info = sut.nakshatra(fromSiderealLongitude: midpoint)

            XCTAssertEqual(info.nakshatra, nakshatra,
                "Nakshatra at \(midpoint)° should be \(nakshatra.rawValue)")
        }
    }

    // MARK: - Dasha Balance Tests

    func testDashaBalanceAtStart() {
        // At exactly 0° (start of Ashwini), balance should be 100%
        let (planet, years) = sut.dashaBalanceAtBirth(moonLongitude: 0.0)

        XCTAssertEqual(planet, .ketu, "Ashwini lord is Ketu")
        XCTAssertEqual(years, 7.0, accuracy: 0.01, "Full Ketu dasha is 7 years")
    }

    func testDashaBalanceAtMiddle() {
        // At 6.666° (middle of Ashwini), balance should be 50%
        let (planet, years) = sut.dashaBalanceAtBirth(moonLongitude: 6.666)

        XCTAssertEqual(planet, .ketu, "Still Ashwini (Ketu)")
        XCTAssertEqual(years, 3.5, accuracy: 0.1, "Half of 7 years")
    }

    func testDashaBalanceAtEnd() {
        // At 13.33° (end of Ashwini), balance should be near 0%
        let (planet, years) = sut.dashaBalanceAtBirth(moonLongitude: 13.32)

        XCTAssertEqual(planet, .ketu, "Still Ashwini")
        XCTAssertLessThan(years, 0.1, "Almost no Ketu dasha remaining")
    }

    // MARK: - Navamsa Sign Tests

    func testNavamsaSignCalculation() {
        // Ashwini Pada 1 -> Aries navamsa
        let navamsa1 = sut.navamsaSign(nakshatra: .ashwini, pada: 1)
        XCTAssertEqual(navamsa1, .aries, "Ashwini Pada 1 -> Aries")

        // Ashwini Pada 2 -> Taurus navamsa
        let navamsa2 = sut.navamsaSign(nakshatra: .ashwini, pada: 2)
        XCTAssertEqual(navamsa2, .taurus, "Ashwini Pada 2 -> Taurus")

        // Bharani Pada 1 -> Leo navamsa (5th from Aries)
        let navamsa5 = sut.navamsaSign(nakshatra: .bharani, pada: 1)
        XCTAssertEqual(navamsa5, .leo, "Bharani Pada 1 -> Leo")
    }

    // MARK: - Reference Test Cases

    func testReferenceNakshatraCases() {
        for testCase in ReferenceCharts.nakshatraTestCases {
            let info = sut.nakshatra(fromSiderealLongitude: testCase.longitude)

            XCTAssertEqual(info.nakshatra.rawValue, testCase.expectedNakshatra,
                "At \(testCase.longitude)° expected \(testCase.expectedNakshatra), got \(info.nakshatra.rawValue)")
            XCTAssertEqual(info.pada, testCase.expectedPada,
                "At \(testCase.longitude)° expected Pada \(testCase.expectedPada), got \(info.pada)")
        }
    }

    // MARK: - Performance Tests

    func testNakshatraCalculationPerformance() {
        measure {
            for _ in 0..<10000 {
                _ = sut.nakshatra(fromSiderealLongitude: Double.random(in: 0..<360))
            }
        }
    }
}
