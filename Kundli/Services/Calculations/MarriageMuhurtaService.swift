import Foundation

/// Service for calculating auspicious marriage (Vivah) muhurtas
/// Marriage muhurta selection is based on multiple factors including
/// nakshatra, tithi, yoga, karana, weekday, and lunar month
final class MarriageMuhurtaService {
    static let shared = MarriageMuhurtaService()

    private let panchangService = PanchangCalculationService.shared
    private let muhurtaService = MuhurtaService.shared

    private init() {}

    // MARK: - Auspicious Criteria for Marriage

    /// Nakshatras considered most auspicious for marriage
    /// These are called "Vivah Nakshatra"
    private let auspiciousNakshatras: [Nakshatra] = [
        .rohini,          // Excellent - Moon's own nakshatra
        .mrigashira,      // Good for love marriage
        .magha,           // Royal, good for prestigious families
        .uttaraphalguni,  // Excellent - ruled by Aryaman (god of marriage)
        .hasta,           // Good for skillful union
        .swati,           // Independent partnership
        .anuradha,        // Excellent for devotion and friendship
        .mula,            // Good with proper muhurta
        .uttaraashadha,   // Victory and success
        .shravana,        // Good for harmony
        .dhanishta,       // Wealth in marriage
        .uttarabhadrapada,// Wisdom and prosperity
        .revati           // Nourishing relationship
    ]

    /// Nakshatras to avoid for marriage
    private let avoidNakshatras: [Nakshatra] = [
        .bharani,         // Ruled by Yama
        .ardra,           // Ruled by Rudra (tears)
        .ashlesha,        // Serpent nakshatra
        .jyeshtha,        // Elder problems
        .moola            // Root destruction (some traditions)
    ]

    /// Tithis considered auspicious for marriage
    private let auspiciousTithis: [Int] = [2, 3, 5, 7, 10, 11, 12, 13]

    /// Tithis to avoid (Rikta tithis)
    private let avoidTithis: [Int] = [4, 9, 14]

    /// Weekdays favorable for marriage (1=Sunday, 2=Monday, etc.)
    /// Monday, Wednesday, Thursday, Friday are good
    private let auspiciousWeekdays: [Int] = [2, 4, 5, 6]  // Mon, Wed, Thu, Fri

    /// Lunar months favorable for marriage
    private let auspiciousLunarMonths: [LunarMonth] = [
        .magha,        // Jan-Feb
        .phalguna,     // Feb-Mar
        .vaishakha,    // Apr-May
        .jyeshtha,     // May-Jun
        .margashirsha, // Nov-Dec
        .kartik        // Oct-Nov (after Dussehra)
    ]

    /// Months to avoid (Adhik Maas, Shunya Maas)
    private let avoidLunarMonths: [LunarMonth] = [
        .ashadha,      // Rainy season
        .bhadrapada,   // Pitru Paksha period
        .ashwin        // Navaratri/Shraddha period
    ]

    // MARK: - Main Calculation

    /// Get auspicious marriage dates for a given year
    func getMarriageMuhurtas(for year: Int, limit: Int = 10) -> [MarriageMuhurta] {
        var auspiciousDates: [MarriageMuhurta] = []
        let calendar = Calendar.current

        // Define the favorable months to search
        let favorableMonthNumbers: [Int] = [1, 2, 3, 4, 5, 11, 12]

        for month in favorableMonthNumbers {
            let datesInMonth = findAuspiciousDatesInMonth(year: year, month: month)
            auspiciousDates.append(contentsOf: datesInMonth)
        }

        // Sort by quality score
        auspiciousDates.sort { $0.qualityScore > $1.qualityScore }

        return Array(auspiciousDates.prefix(limit))
    }

    /// Get upcoming marriage muhurtas from current date
    func getUpcomingMarriageMuhurtas(limit: Int = 6) -> [MarriageMuhurta] {
        let calendar = Calendar.current
        let today = Date()
        let currentYear = calendar.component(.year, from: today)

        var dates = getMarriageMuhurtas(for: currentYear, limit: limit * 2)

        // Add next year's dates if needed
        if dates.filter({ $0.date >= today }).count < limit {
            dates.append(contentsOf: getMarriageMuhurtas(for: currentYear + 1, limit: limit))
        }

        return dates
            .filter { $0.date >= today }
            .sorted { $0.date < $1.date }
            .prefix(limit)
            .map { $0 }
    }

    /// Find auspicious marriage dates in a specific month
    private func findAuspiciousDatesInMonth(year: Int, month: Int) -> [MarriageMuhurta] {
        var dates: [MarriageMuhurta] = []
        let calendar = Calendar.current

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1

        guard let startOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            return dates
        }

        for day in range {
            components.day = day
            guard let date = calendar.date(from: components) else { continue }

            // Check weekday
            let weekday = calendar.component(.weekday, from: date)
            if !auspiciousWeekdays.contains(weekday) {
                continue
            }

            // Calculate Panchang for this date (using default Delhi location)
            let panchang = panchangService.calculatePanchang(
                date: date,
                latitude: 28.6139,
                longitude: 77.2090,
                timezone: TimeZone(identifier: "Asia/Kolkata")!
            )

            // Evaluate the date
            let evaluation = evaluateDate(date: date, panchang: panchang)

            // Only include if meets minimum criteria (score >= 5)
            if evaluation.score >= 5 {
                let muhurta = MarriageMuhurta(
                    date: date,
                    nakshatra: panchang.nakshatra,
                    tithi: panchang.tithi.fullName,
                    yoga: panchang.yoga,
                    qualityScore: evaluation.score,
                    qualityRating: evaluation.rating,
                    auspiciousFactors: evaluation.positiveFactors,
                    cautionFactors: evaluation.cautionFactors,
                    bestTimeOfDay: evaluation.bestTime
                )
                dates.append(muhurta)
            }
        }

        return dates
    }

    // MARK: - Date Evaluation

    private func evaluateDate(date: Date, panchang: Panchang) -> DateEvaluation {
        var score = 0
        var positiveFactors: [String] = []
        var cautionFactors: [String] = []
        var bestTime = "Morning (Shubh Muhurta)"

        // Check Nakshatra (most important - 4 points)
        if let nakshatra = Nakshatra(rawValue: panchang.nakshatra) {
            if auspiciousNakshatras.contains(nakshatra) {
                score += 4
                positiveFactors.append("\(nakshatra.rawValue) is highly auspicious for marriage")

                // Bonus for best nakshatras
                if [Nakshatra.rohini, .uttaraphalguni, .anuradha].contains(nakshatra) {
                    score += 2
                    positiveFactors.append("\(nakshatra.rawValue) is among the best for Vivah")
                }
            } else if avoidNakshatras.contains(nakshatra) {
                score -= 3
                cautionFactors.append("\(nakshatra.rawValue) is generally avoided for marriage")
            }
        }

        // Check Tithi (2 points)
        if auspiciousTithis.contains(panchang.tithi.number) && panchang.tithi.paksha == .shukla {
            score += 2
            positiveFactors.append("\(panchang.tithi.fullName) (Shukla Paksha) is favorable")
        } else if avoidTithis.contains(panchang.tithi.number) {
            score -= 2
            cautionFactors.append("Rikta tithi - considered inauspicious")
        }

        // Shukla Paksha bonus (1 point)
        if panchang.tithi.paksha == .shukla {
            score += 1
            if !positiveFactors.contains(where: { $0.contains("Shukla") }) {
                positiveFactors.append("Shukla Paksha (waxing moon) brings growth")
            }
        }

        // Check Yoga (1 point)
        if let yoga = PanchangYoga(rawValue: panchang.yoga), yoga.isAuspicious {
            score += 1
            positiveFactors.append("\(yoga.rawValue) yoga is favorable")
        }

        // Check Karana (1 point)
        if let karana = Karana(rawValue: panchang.karana), karana.isAuspicious {
            score += 1
        }

        // Weekday bonus (already filtered, but add factor)
        let weekdayName = weekdayString(from: date)
        positiveFactors.append("\(weekdayName) is auspicious for marriage")

        // Check lunar month
        let lunarMonth = approximateLunarMonth(from: date)
        if let month = lunarMonth {
            if auspiciousLunarMonths.contains(month) {
                score += 1
                positiveFactors.append("\(month.rawValue) month is favorable for weddings")
            } else if avoidLunarMonths.contains(month) {
                score -= 2
                cautionFactors.append("\(month.rawValue) is traditionally avoided")
            }
        }

        // Determine best time
        if let abhijit = muhurtaService.calculateAbhijitMuhurta(
            sunrise: panchang.sunriseTime,
            sunset: panchang.sunsetTime
        ) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            bestTime = "Abhijit Muhurta: \(formatter.string(from: abhijit.start)) - \(formatter.string(from: abhijit.end))"
        }

        // Determine rating
        let rating: MarriageMuhurtaQuality
        switch score {
        case 9...: rating = .excellent
        case 7...8: rating = .veryGood
        case 5...6: rating = .good
        default: rating = .fair
        }

        return DateEvaluation(
            score: score,
            rating: rating,
            positiveFactors: positiveFactors,
            cautionFactors: cautionFactors,
            bestTime: bestTime
        )
    }

    private func weekdayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    private func approximateLunarMonth(from date: Date) -> LunarMonth? {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)

        // Approximate mapping
        switch month {
        case 1: return .pausha
        case 2: return .magha
        case 3: return .phalguna
        case 4: return .chaitra
        case 5: return .vaishakha
        case 6: return .jyeshtha
        case 7: return .ashadha
        case 8: return .shravana
        case 9: return .bhadrapada
        case 10: return .ashwin
        case 11: return .kartik
        case 12: return .margashirsha
        default: return nil
        }
    }
}

// MARK: - Supporting Models

struct MarriageMuhurta: Identifiable {
    let id = UUID()
    let date: Date
    let nakshatra: String
    let tithi: String
    let yoga: String
    let qualityScore: Int
    let qualityRating: MarriageMuhurtaQuality
    let auspiciousFactors: [String]
    let cautionFactors: [String]
    let bestTimeOfDay: String

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

enum MarriageMuhurtaQuality: String {
    case excellent = "Excellent"
    case veryGood = "Very Good"
    case good = "Good"
    case fair = "Fair"

    var description: String {
        switch self {
        case .excellent:
            return "Highly auspicious - all major factors align perfectly"
        case .veryGood:
            return "Very favorable with strong positive indicators"
        case .good:
            return "Good muhurta with favorable planetary positions"
        case .fair:
            return "Acceptable with basic auspicious factors"
        }
    }

    var color: String {
        switch self {
        case .excellent: return "gold"
        case .veryGood: return "green"
        case .good: return "blue"
        case .fair: return "gray"
        }
    }
}

private struct DateEvaluation {
    let score: Int
    let rating: MarriageMuhurtaQuality
    let positiveFactors: [String]
    let cautionFactors: [String]
    let bestTime: String
}
