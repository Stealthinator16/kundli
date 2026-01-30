import Foundation

/// Service for Ayanamsa (precession) calculations
/// Ayanamsa is the angular difference between tropical and sidereal zodiac
final class AyanamsaService {
    static let shared = AyanamsaService()

    private let ephemeris = EphemerisService.shared

    private init() {}

    // MARK: - Ayanamsa Calculation

    /// Get the ayanamsa value for a given date
    /// Returns the angular difference in degrees
    func ayanamsaValue(
        for date: Date,
        timezone: TimeZone,
        ayanamsa: Ayanamsa = .lahiri
    ) -> Double {
        // Convert Ayanamsa from CalculationSettings to internal AyanamsaType
        let ayanamsaType: AyanamsaType
        switch ayanamsa {
        case .lahiri, .trueChitra, .fagan:
            ayanamsaType = .lahiri
        case .raman:
            ayanamsaType = .raman
        case .krishnamurti:
            ayanamsaType = .krishnamurti
        }
        return ephemeris.ayanamsa(for: date, type: ayanamsaType)
    }

    /// Convert tropical longitude to sidereal longitude
    func tropicalToSidereal(
        tropicalLongitude: Double,
        date: Date,
        timezone: TimeZone,
        ayanamsa: Ayanamsa = .lahiri
    ) -> Double {
        let ayanamsaVal = ayanamsaValue(for: date, timezone: timezone, ayanamsa: ayanamsa)
        var sidereal = tropicalLongitude - ayanamsaVal

        // Normalize to 0-360
        while sidereal < 0 {
            sidereal += 360.0
        }
        while sidereal >= 360.0 {
            sidereal -= 360.0
        }

        return sidereal
    }

    /// Convert sidereal longitude to tropical longitude
    func siderealToTropical(
        siderealLongitude: Double,
        date: Date,
        timezone: TimeZone,
        ayanamsa: Ayanamsa = .lahiri
    ) -> Double {
        let ayanamsaVal = ayanamsaValue(for: date, timezone: timezone, ayanamsa: ayanamsa)
        var tropical = siderealLongitude + ayanamsaVal

        // Normalize to 0-360
        while tropical < 0 {
            tropical += 360.0
        }
        while tropical >= 360.0 {
            tropical -= 360.0
        }

        return tropical
    }

    // MARK: - Ayanamsa Information

    /// Get detailed information about ayanamsa value for a date
    func ayanamsaDetails(
        for date: Date,
        timezone: TimeZone,
        ayanamsa: Ayanamsa = .lahiri
    ) -> AyanamsaInfo {
        let value = ayanamsaValue(for: date, timezone: timezone, ayanamsa: ayanamsa)
        let degrees = Int(value)
        let minutesFraction = (value - Double(degrees)) * 60
        let minutes = Int(minutesFraction)
        let seconds = Int((minutesFraction - Double(minutes)) * 60)

        return AyanamsaInfo(
            ayanamsa: ayanamsa,
            date: date,
            totalDegrees: value,
            degrees: degrees,
            minutes: minutes,
            seconds: seconds
        )
    }

    /// Get ayanamsa values for all supported systems
    func allAyanamsaValues(
        for date: Date,
        timezone: TimeZone
    ) -> [Ayanamsa: Double] {
        var values: [Ayanamsa: Double] = [:]
        for ayanamsa in Ayanamsa.allCases {
            values[ayanamsa] = ayanamsaValue(for: date, timezone: timezone, ayanamsa: ayanamsa)
        }
        return values
    }

    // MARK: - Reference Values

    /// Approximate Lahiri ayanamsa for common reference years
    /// Useful for quick estimation without ephemeris calculation
    static let lahiriReferenceValues: [Int: Double] = [
        1900: 22.4602,
        1950: 23.1296,
        2000: 23.8512,
        2025: 24.1832,
        2050: 24.5167
    ]

    /// Estimate Lahiri ayanamsa using linear interpolation
    /// Use this only as a fallback when ephemeris is unavailable
    func estimateLahiriAyanamsa(for year: Int) -> Double {
        // Ayanamsa increases approximately 50.3 arc-seconds per year
        let annualPrecession = 50.3 / 3600.0  // Convert to degrees

        // Use year 2000 as reference point
        let referenceYear = 2000
        let referenceValue = 23.8512  // Lahiri ayanamsa for 2000

        return referenceValue + Double(year - referenceYear) * annualPrecession
    }
}

// MARK: - Supporting Types

/// Detailed ayanamsa information
struct AyanamsaInfo {
    let ayanamsa: Ayanamsa
    let date: Date
    let totalDegrees: Double
    let degrees: Int
    let minutes: Int
    let seconds: Int

    var formatted: String {
        String(format: "%d°%02d'%02d\"", degrees, minutes, seconds)
    }

    var description: String {
        "\(ayanamsa.rawValue): \(formatted)"
    }
}
