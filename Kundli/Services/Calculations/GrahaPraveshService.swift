import Foundation
import SwiftUI

/// Service for calculating auspicious Graha Pravesh (house-warming) dates
/// Graha Pravesh is an important ceremony for moving into a new home
final class GrahaPraveshService {
    static let shared = GrahaPraveshService()

    private let panchangService = PanchangCalculationService.shared

    private init() {}

    // MARK: - Auspicious Criteria

    /// Nakshatras considered auspicious for Graha Pravesh
    private let auspiciousNakshatras: [Nakshatra] = [
        .rohini,         // Excellent for home
        .mrigashira,     // Good for settling
        .punarvasu,      // Prosperity
        .pushya,         // Most auspicious
        .uttaraphalguni, // Stability
        .hasta,          // Skill in household
        .swati,          // Independence
        .anuradha,       // Friendship
        .uttaraashadha,  // Victory
        .shravana,       // Learning
        .dhanishta,      // Wealth
        .uttarabhadrapada, // Wisdom
        .revati          // Nourishment
    ]

    /// Tithis considered auspicious for Graha Pravesh
    private let auspiciousTithis: [Int] = [2, 3, 5, 6, 7, 10, 11, 12, 13]

    /// Days of the week to avoid (0 = Sunday, 1 = Monday, etc.)
    /// Generally avoid Tuesday (2) and Saturday (5)
    private let avoidWeekdays: [Int] = [2, 5]

    /// Solar months when Sun enters fixed signs (approximate Gregorian months)
    /// Taurus (April-May), Leo (July-Aug), Scorpio (Oct-Nov), Aquarius (Jan-Feb)
    private let fixedSignIngresses: [(month: Int, day: Int, sign: String)] = [
        (4, 14, "Taurus"),   // Sun enters Taurus around April 14
        (7, 17, "Leo"),      // Sun enters Leo around July 17
        (10, 17, "Scorpio"), // Sun enters Scorpio around October 17
        (1, 14, "Aquarius")  // Sun enters Aquarius around January 14
    ]

    // MARK: - Date Calculations

    /// Get auspicious Graha Pravesh dates for a given year
    /// Returns dates that meet the astrological criteria for house-warming
    func getGrahaPraveshDates(
        for year: Int,
        latitude: Double = 28.6139,
        longitude: Double = 77.2090,
        timezone: TimeZone = TimeZone(identifier: "Asia/Kolkata") ?? .current,
        limit: Int = 12
    ) -> [GrahaPraveshDate] {
        var auspiciousDates: [GrahaPraveshDate] = []

        // Search through each month
        for month in 1...12 {
            let datesInMonth = findAuspiciousDatesInMonth(
                year: year, month: month,
                latitude: latitude, longitude: longitude, timezone: timezone
            )
            auspiciousDates.append(contentsOf: datesInMonth)

            // Limit total results
            if auspiciousDates.count >= limit * 2 {
                break
            }
        }

        // Sort by quality score and then by date
        auspiciousDates.sort { date1, date2 in
            if date1.qualityScore != date2.qualityScore {
                return date1.qualityScore > date2.qualityScore
            }
            return date1.date < date2.date
        }

        return Array(auspiciousDates.prefix(limit))
    }

    /// Get upcoming Graha Pravesh dates from current date
    func getUpcomingGrahaPraveshDates(
        latitude: Double = 28.6139,
        longitude: Double = 77.2090,
        timezone: TimeZone = TimeZone(identifier: "Asia/Kolkata") ?? .current,
        limit: Int = 6
    ) -> [GrahaPraveshDate] {
        let calendar = Calendar.current
        let today = Date()
        let currentYear = calendar.component(.year, from: today)

        var dates = getGrahaPraveshDates(for: currentYear, latitude: latitude, longitude: longitude, timezone: timezone, limit: limit * 2)

        // Add next year's dates if needed
        if dates.filter({ $0.date >= today }).count < limit {
            dates.append(contentsOf: getGrahaPraveshDates(for: currentYear + 1, latitude: latitude, longitude: longitude, timezone: timezone, limit: limit))
        }

        return dates
            .filter { $0.date >= today }
            .sorted { $0.date < $1.date }
            .prefix(limit)
            .map { $0 }
    }

    /// Find auspicious dates in a specific month
    private func findAuspiciousDatesInMonth(
        year: Int, month: Int,
        latitude: Double, longitude: Double, timezone: TimeZone
    ) -> [GrahaPraveshDate] {
        var dates: [GrahaPraveshDate] = []
        let calendar = Calendar.current

        // Get the range of days in this month
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1

        guard let startOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            return dates
        }

        // Check each day
        for day in range {
            components.day = day
            guard let date = calendar.date(from: components) else { continue }

            // Skip weekends if avoiding Tuesday/Saturday
            let weekday = calendar.component(.weekday, from: date) - 1 // Convert to 0-based
            if avoidWeekdays.contains(weekday) {
                continue
            }

            // Calculate Panchang for this date
            let panchang = panchangService.calculatePanchang(
                date: date,
                latitude: latitude,
                longitude: longitude,
                timezone: timezone
            )

            // Check if nakshatra is auspicious
            let nakshatraMatch = checkNakshatra(panchang.nakshatra)

            // Check if tithi is auspicious
            let tithiMatch = checkTithi(panchang.tithi)

            // Check if it's during a fixed sign ingress period
            let ingressBonus = checkSolarIngress(month: month, day: day)

            // Calculate quality score
            let qualityScore = calculateQualityScore(
                nakshatraMatch: nakshatraMatch,
                tithiMatch: tithiMatch,
                ingressBonus: ingressBonus,
                panchang: panchang
            )

            // Only include if meets minimum criteria
            if qualityScore >= 3 {
                let grahaPraveshDate = GrahaPraveshDate(
                    date: date,
                    nakshatra: panchang.nakshatra,
                    tithi: panchang.tithi.fullName,
                    qualityScore: qualityScore,
                    qualityRating: qualityRating(for: qualityScore),
                    reasons: buildReasons(
                        nakshatraMatch: nakshatraMatch,
                        tithiMatch: tithiMatch,
                        ingressBonus: ingressBonus,
                        panchang: panchang
                    )
                )
                dates.append(grahaPraveshDate)
            }
        }

        return dates
    }

    // MARK: - Validation Methods

    private func checkNakshatra(_ nakshatraName: String) -> Bool {
        if let nakshatra = Nakshatra(rawValue: nakshatraName) {
            return auspiciousNakshatras.contains(nakshatra)
        }
        return false
    }

    private func checkTithi(_ tithi: Tithi) -> Bool {
        // Check if it's an auspicious tithi and Shukla Paksha (bright half)
        return auspiciousTithis.contains(tithi.number) && tithi.paksha == .shukla
    }

    private func checkSolarIngress(month: Int, day: Int) -> Bool {
        // Check if date is within 10 days of a fixed sign ingress
        for ingress in fixedSignIngresses {
            if month == ingress.month && abs(day - ingress.day) <= 10 {
                return true
            }
        }
        return false
    }

    private func calculateQualityScore(
        nakshatraMatch: Bool,
        tithiMatch: Bool,
        ingressBonus: Bool,
        panchang: Panchang
    ) -> Int {
        var score = 0

        // Nakshatra (most important) - 3 points
        if nakshatraMatch { score += 3 }

        // Tithi - 2 points
        if tithiMatch { score += 2 }

        // Solar ingress period - 2 points
        if ingressBonus { score += 2 }

        // Auspicious yoga - 1 point
        if let yoga = PanchangYoga(rawValue: panchang.yoga), yoga.isAuspicious {
            score += 1
        }

        // Not during Rahu Kaal - 1 point
        if !panchang.isRahuKaalActive {
            score += 1
        }

        // Pushya nakshatra (considered best) - bonus 2 points
        if panchang.nakshatra == "Pushya" {
            score += 2
        }

        return score
    }

    private func qualityRating(for score: Int) -> GrahaPraveshQuality {
        switch score {
        case 8...: return .excellent
        case 6...7: return .veryGood
        case 4...5: return .good
        default: return .fair
        }
    }

    private func buildReasons(
        nakshatraMatch: Bool,
        tithiMatch: Bool,
        ingressBonus: Bool,
        panchang: Panchang
    ) -> [String] {
        var reasons: [String] = []

        if nakshatraMatch {
            reasons.append("\(panchang.nakshatra) nakshatra is auspicious for Graha Pravesh")
        }

        if tithiMatch {
            reasons.append("\(panchang.tithi.fullName) is favorable for moving")
        }

        if ingressBonus {
            reasons.append("Sun is transiting a fixed sign - good for stability")
        }

        if let yoga = PanchangYoga(rawValue: panchang.yoga), yoga.isAuspicious {
            reasons.append("\(yoga.rawValue) yoga adds positive energy")
        }

        if panchang.nakshatra == "Pushya" {
            reasons.append("Pushya nakshatra is considered the best for Graha Pravesh")
        }

        return reasons
    }

    // MARK: - Festival Integration

    /// Convert Graha Pravesh dates to Festival instances for calendar display
    func getGrahaPraveshFestivals(for year: Int) -> [FestivalInstance] {
        let dates = getGrahaPraveshDates(for: year, limit: 8)

        return dates.enumerated().map { index, gpDate in
            let festival = Festival(
                name: "Graha Pravesh Muhurta",
                vedName: "Griha Pravesh",
                description: "Auspicious date for house-warming ceremony",
                category: .grahaPravesh,
                deity: "Vastu Purusha, Ganesha",
                significance: gpDate.qualityRating.description,
                traditions: [
                    "Puja and Havan",
                    "Boiling milk ceremony",
                    "Lighting lamp at threshold",
                    "Entering with right foot first"
                ],
                tithi: gpDate.tithi
            )

            return FestivalInstance(
                festival: festival,
                date: gpDate.date,
                year: year
            )
        }
    }
}

// MARK: - Supporting Models

struct GrahaPraveshDate: Identifiable {
    let id = UUID()
    let date: Date
    let nakshatra: String
    let tithi: String
    let qualityScore: Int
    let qualityRating: GrahaPraveshQuality
    let reasons: [String]

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }

    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    var weekday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}

enum GrahaPraveshQuality: String {
    case excellent = "Excellent"
    case veryGood = "Very Good"
    case good = "Good"
    case fair = "Fair"

    var description: String {
        switch self {
        case .excellent:
            return "Highly auspicious date with multiple favorable factors"
        case .veryGood:
            return "Very favorable date for house-warming"
        case .good:
            return "Good auspicious date for Graha Pravesh"
        case .fair:
            return "Acceptable date with basic auspicious factors"
        }
    }

    var color: Color {
        switch self {
        case .excellent: return .kundliPrimary
        case .veryGood: return .kundliSuccess
        case .good: return .kundliInfo
        case .fair: return .kundliTextSecondary
        }
    }
}
