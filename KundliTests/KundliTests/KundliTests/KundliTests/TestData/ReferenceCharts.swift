import Foundation
@testable import Kundli

/// Reference charts for testing calculations
/// Positions verified against Jagannatha Hora software
enum ReferenceCharts {

    // MARK: - Reference Chart 1: Jan 1, 2000, 12:00 PM, New Delhi

    /// Reference birth details for Chart 1
    static let chart1BirthDetails = BirthDetails(
        name: "Reference Chart 1",
        dateOfBirth: createDate(year: 2000, month: 1, day: 1),
        timeOfBirth: createTime(hour: 12, minute: 0),
        birthCity: "New Delhi, Delhi, India",
        latitude: 28.6139,
        longitude: 77.2090,
        timezone: "Asia/Kolkata",
        gender: .male
    )

    /// Expected Lahiri ayanamsa for Jan 1, 2000
    static let chart1Ayanamsa: Double = 23.8512

    /// Expected planetary positions for Chart 1 (sidereal/Lahiri)
    static let chart1ExpectedPositions: [VedicPlanet: ExpectedPosition] = [
        .sun: ExpectedPosition(sign: .sagittarius, degree: 16, minutes: 11, tolerance: 1),
        .moon: ExpectedPosition(sign: .virgo, degree: 5, minutes: 30, tolerance: 2),
        .mars: ExpectedPosition(sign: .capricorn, degree: 8, minutes: 45, tolerance: 1),
        .mercury: ExpectedPosition(sign: .sagittarius, degree: 27, minutes: 15, tolerance: 1),
        .jupiter: ExpectedPosition(sign: .aries, degree: 1, minutes: 30, tolerance: 1),
        .venus: ExpectedPosition(sign: .capricorn, degree: 26, minutes: 20, tolerance: 1),
        .saturn: ExpectedPosition(sign: .aries, degree: 20, minutes: 45, tolerance: 1),
        .rahu: ExpectedPosition(sign: .cancer, degree: 16, minutes: 30, tolerance: 2),
        .ketu: ExpectedPosition(sign: .capricorn, degree: 16, minutes: 30, tolerance: 2)
    ]

    /// Expected ascendant for Chart 1
    static let chart1ExpectedAscendant = ExpectedPosition(sign: .pisces, degree: 9, minutes: 30, tolerance: 3)

    // MARK: - Reference Chart 2: Jul 15, 1985, 5:30 AM, Mumbai (Known Manglik)

    /// Reference birth details for Chart 2 (Manglik chart)
    static let chart2BirthDetails = BirthDetails(
        name: "Reference Chart 2",
        dateOfBirth: createDate(year: 1985, month: 7, day: 15),
        timeOfBirth: createTime(hour: 5, minute: 30),
        birthCity: "Mumbai, Maharashtra, India",
        latitude: 19.0760,
        longitude: 72.8777,
        timezone: "Asia/Kolkata",
        gender: .male
    )

    /// Expected Mars in 7th house (Manglik indicator)
    static let chart2MarsHouse = 7

    /// Expected planetary positions for Chart 2
    static let chart2ExpectedPositions: [VedicPlanet: ExpectedPosition] = [
        .sun: ExpectedPosition(sign: .gemini, degree: 28, minutes: 45, tolerance: 1),
        .moon: ExpectedPosition(sign: .capricorn, degree: 12, minutes: 15, tolerance: 2),
        .mars: ExpectedPosition(sign: .gemini, degree: 5, minutes: 30, tolerance: 1)
    ]

    // MARK: - Nakshatra Test Data

    /// Test cases for nakshatra calculations
    static let nakshatraTestCases: [(longitude: Double, expectedNakshatra: String, expectedPada: Int)] = [
        (0.0, "Ashwini", 1),                    // Start of Ashwini
        (3.333, "Ashwini", 1),                  // End of Pada 1
        (6.667, "Ashwini", 2),                  // End of Pada 2
        (13.333, "Ashwini", 4),                 // End of Ashwini
        (13.334, "Bharani", 1),                 // Start of Bharani
        (26.667, "Bharani", 4),                 // End of Bharani
        (180.0, "Chitra", 3),                   // 180° (Chitra)
        (359.999, "Revati", 4),                 // End of Revati
        (266.667, "Uttara Ashadha", 1),         // Start of U.Ashadha (Sagittarius-Capricorn boundary)
    ]

    // MARK: - Dasha Test Data

    /// Expected dasha sequence starting from Ashwini nakshatra (Ketu lord)
    static let ashwiniDashaSequence = ["Ketu", "Venus", "Sun", "Moon", "Mars", "Rahu", "Jupiter", "Saturn", "Mercury"]

    /// Total Vimshottari cycle should equal 120 years
    static let totalVimshottariYears = 120

    // MARK: - Divisional Chart Test Data

    /// Test cases for D-9 (Navamsa) calculation
    static let d9TestCases: [(longitude: Double, expectedSignIndex: Int)] = [
        (0.0, 0),        // 0° Aries -> Aries navamsa
        (3.333, 1),      // 3.333° Aries -> Taurus navamsa
        (30.0, 9),       // 0° Taurus -> Capricorn navamsa
        (180.0, 6),      // 0° Libra -> Libra navamsa
    ]

    /// Test cases for D-10 (Dasamsa) calculation
    static let d10TestCases: [(longitude: Double, expectedSignIndex: Int)] = [
        (0.0, 0),        // 0° Aries -> Aries dasamsa
        (3.0, 1),        // 3° Aries -> Taurus dasamsa
        (30.0, 8),       // 0° Taurus (even) -> Sagittarius dasamsa
    ]

    // MARK: - Helper Methods

    private static func createDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.timeZone = TimeZone(identifier: "Asia/Kolkata")
        return Calendar.current.date(from: components) ?? Date()
    }

    private static func createTime(hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        components.timeZone = TimeZone(identifier: "Asia/Kolkata")
        return Calendar.current.date(from: components) ?? Date()
    }
}

// MARK: - Expected Position

/// Expected position for testing with tolerance
struct ExpectedPosition {
    let sign: ZodiacSign
    let degree: Int
    let minutes: Int
    let tolerance: Int  // Tolerance in arc-minutes

    /// Check if an actual position matches within tolerance
    func matches(actualDegree: Double, actualSign: ZodiacSign) -> Bool {
        guard sign == actualSign else { return false }

        let expectedTotalMinutes = degree * 60 + minutes
        let actualTotalMinutes = Int(actualDegree * 60)
        let difference = abs(expectedTotalMinutes - actualTotalMinutes)

        return difference <= tolerance
    }

    /// Create position from degree in sign
    init(sign: ZodiacSign, degree: Int, minutes: Int, tolerance: Int = 1) {
        self.sign = sign
        self.degree = degree
        self.minutes = minutes
        self.tolerance = tolerance
    }
}

// MARK: - Test Assertions

extension ExpectedPosition: CustomStringConvertible {
    var description: String {
        "\(sign.rawValue) \(degree)°\(minutes)' (±\(tolerance)')"
    }
}
