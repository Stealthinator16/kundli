import Foundation

/// Service for calculating auspicious times (Muhurtas)
final class MuhurtaService {
    static let shared = MuhurtaService()

    private let ephemeris = EphemerisService.shared
    private let panchangService = PanchangCalculationService.shared

    private init() {}

    // MARK: - Muhurta Calculations

    /// Calculate Abhijit Muhurta (most auspicious time of day)
    /// Abhijit is the 8th muhurta of the day, occurring around solar noon
    func calculateAbhijitMuhurta(sunrise: Date, sunset: Date) -> (start: Date, end: Date)? {
        let dayDuration = sunset.timeIntervalSince(sunrise)

        // Day is divided into 15 muhurtas (each ~48 minutes)
        let muhurtaDuration = dayDuration / 15

        // Abhijit is the 8th muhurta (index 7)
        let abhijitStart = sunrise.addingTimeInterval(7 * muhurtaDuration)
        let abhijitEnd = abhijitStart.addingTimeInterval(muhurtaDuration)

        return (abhijitStart, abhijitEnd)
    }

    /// Calculate Brahma Muhurta (most auspicious for spiritual activities)
    /// Brahma Muhurta is approximately 1.5 hours before sunrise
    func calculateBrahmaMuhurta(sunrise: Date) -> (start: Date, end: Date) {
        // Brahma Muhurta is traditionally 2 muhurtas before sunrise
        // Each muhurta is approximately 48 minutes
        let muhurtaDuration: TimeInterval = 48 * 60  // 48 minutes

        let brahmaEnd = sunrise.addingTimeInterval(-muhurtaDuration)
        let brahmaStart = brahmaEnd.addingTimeInterval(-muhurtaDuration)

        return (brahmaStart, brahmaEnd)
    }

    /// Calculate all 15 daytime muhurtas
    func calculateDayMuhurtas(sunrise: Date, sunset: Date) -> [Muhurta] {
        let dayDuration = sunset.timeIntervalSince(sunrise)
        let muhurtaDuration = dayDuration / 15

        return (0..<15).map { index in
            let start = sunrise.addingTimeInterval(Double(index) * muhurtaDuration)
            let end = start.addingTimeInterval(muhurtaDuration)
            let name = dayMuhurtaNames[index]
            let isAuspicious = dayMuhurtaAuspicious[index]

            return Muhurta(
                name: name,
                startTime: start,
                endTime: end,
                isAuspicious: isAuspicious,
                type: .day
            )
        }
    }

    /// Calculate all 15 nighttime muhurtas
    func calculateNightMuhurtas(sunset: Date, nextSunrise: Date) -> [Muhurta] {
        let nightDuration = nextSunrise.timeIntervalSince(sunset)
        let muhurtaDuration = nightDuration / 15

        return (0..<15).map { index in
            let start = sunset.addingTimeInterval(Double(index) * muhurtaDuration)
            let end = start.addingTimeInterval(muhurtaDuration)
            let name = nightMuhurtaNames[index]
            let isAuspicious = nightMuhurtaAuspicious[index]

            return Muhurta(
                name: name,
                startTime: start,
                endTime: end,
                isAuspicious: isAuspicious,
                type: .night
            )
        }
    }

    // MARK: - Muhurta Names

    private let dayMuhurtaNames = [
        "Rudra", "Ahi", "Mitra", "Pitru", "Vasu",
        "Vara", "Vishwadeva", "Abhijit", "Vidhi", "Satmukhi",
        "Puruhuta", "Vahini", "Naktanakara", "Varuna", "Aryama"
    ]

    private let dayMuhurtaAuspicious = [
        false, false, true, false, true,   // 1-5
        true, true, true, true, true,      // 6-10
        true, false, false, true, true     // 11-15
    ]

    private let nightMuhurtaNames = [
        "Shiva", "Siddhi", "Sankata", "Mahadeva", "Dhvankshya",
        "Brahma", "Jiva", "Yama", "Varuna", "Pracheta",
        "Rudra", "Chandra", "Ashvini", "Yama", "Agni"
    ]

    private let nightMuhurtaAuspicious = [
        true, true, false, true, false,    // 1-5
        true, true, false, true, true,     // 6-10
        false, true, true, false, true     // 11-15
    ]

    // MARK: - Comprehensive Muhurta Analysis

    /// Get current muhurta for a given time
    func getCurrentMuhurta(at date: Date, sunrise: Date, sunset: Date, nextSunrise: Date) -> Muhurta? {
        let dayMuhurtas = calculateDayMuhurtas(sunrise: sunrise, sunset: sunset)
        let nightMuhurtas = calculateNightMuhurtas(sunset: sunset, nextSunrise: nextSunrise)

        let allMuhurtas = dayMuhurtas + nightMuhurtas

        return allMuhurtas.first { muhurta in
            date >= muhurta.startTime && date < muhurta.endTime
        }
    }

    /// Find next auspicious muhurta after a given time
    func findNextAuspiciousMuhurta(after date: Date, sunrise: Date, sunset: Date, nextSunrise: Date) -> Muhurta? {
        let dayMuhurtas = calculateDayMuhurtas(sunrise: sunrise, sunset: sunset)
        let nightMuhurtas = calculateNightMuhurtas(sunset: sunset, nextSunrise: nextSunrise)

        let allMuhurtas = dayMuhurtas + nightMuhurtas

        return allMuhurtas.first { muhurta in
            muhurta.startTime > date && muhurta.isAuspicious
        }
    }

    // MARK: - Activity-based Muhurta Recommendations

    /// Get recommended nakshatras for specific activities
    func getAuspiciousNakshatras(for activity: ActivityType) -> [Nakshatra] {
        switch activity {
        case .marriage:
            return [.rohini, .mrigashira, .magha, .uttaraphalguni, .hasta, .swati, .anuradha, .mula, .uttaraashadha, .uttarabhadrapada, .revati]
        case .travel:
            return [.ashwini, .mrigashira, .punarvasu, .pushya, .hasta, .anuradha, .shravana, .revati]
        case .business:
            return [.ashwini, .rohini, .mrigashira, .pushya, .uttaraphalguni, .hasta, .swati, .anuradha, .shravana, .dhanishta, .revati]
        case .education:
            return [.ashwini, .punarvasu, .pushya, .hasta, .swati, .shravana, .dhanishta, .shatabhisha, .revati]
        case .property:
            return [.rohini, .mrigashira, .uttaraphalguni, .hasta, .swati, .anuradha, .uttaraashadha, .shravana, .uttarabhadrapada]
        case .medical:
            return [.ashwini, .rohini, .mrigashira, .punarvasu, .pushya, .hasta, .anuradha, .shravana, .revati]
        case .spiritual:
            return [.ashwini, .ardra, .punarvasu, .pushya, .ashlesha, .magha, .purvaphalguni, .uttaraphalguni, .hasta, .chitra, .swati, .vishakha, .anuradha, .jyeshtha, .mula, .shravana, .shatabhisha, .purvabhadrapada, .uttarabhadrapada, .revati]
        case .haircut:
            return [.ashwini, .mrigashira, .punarvasu, .pushya, .hasta, .chitra, .swati, .jyeshtha, .shravana, .dhanishta, .shatabhisha, .revati]
        }
    }

    /// Check if current time is good for a specific activity
    func isGoodTimeFor(activity: ActivityType, date: Date, panchang: Panchang) -> MuhurtaRecommendation {
        var score: Int = 0
        var reasons: [String] = []
        var warnings: [String] = []

        // Check Nakshatra
        if let nakshatra = Nakshatra(rawValue: panchang.nakshatra) {
            let auspiciousNakshatras = getAuspiciousNakshatras(for: activity)
            if auspiciousNakshatras.contains(nakshatra) {
                score += 2
                reasons.append("\(nakshatra.rawValue) is favorable for \(activity.rawValue)")
            } else {
                warnings.append("\(nakshatra.rawValue) is not ideal for \(activity.rawValue)")
            }
        }

        // Check Tithi
        if isTithiAuspicious(panchang.tithi, for: activity) {
            score += 2
            reasons.append("\(panchang.tithi.fullName) is auspicious")
        }

        // Check Panchang Yoga
        if let yoga = PanchangYoga(rawValue: panchang.yoga), yoga.isAuspicious {
            score += 1
            reasons.append("\(yoga.rawValue) yoga is favorable")
        } else {
            warnings.append("Current yoga is not auspicious")
        }

        // Check Karana
        if let karana = Karana(rawValue: panchang.karana), karana.isAuspicious {
            score += 1
            reasons.append("\(karana.rawValue) karana is good")
        } else {
            warnings.append("Current karana is not favorable")
        }

        // Check Rahu Kaal
        if panchang.isRahuKaalActive {
            score -= 3
            warnings.append("Rahu Kaal is active - avoid important activities")
        }

        let recommendation: RecommendationLevel
        switch score {
        case 5...6: recommendation = .excellent
        case 3...4: recommendation = .good
        case 1...2: recommendation = .fair
        default: recommendation = .avoid
        }

        return MuhurtaRecommendation(
            level: recommendation,
            score: score,
            reasons: reasons,
            warnings: warnings
        )
    }

    private func isTithiAuspicious(_ tithi: Tithi, for activity: ActivityType) -> Bool {
        // Generally avoid 4th, 9th, 14th tithis and Amavasya for new beginnings
        let avoidTithis = [4, 9, 14, 15]

        if tithi.paksha == .krishna && tithi.number == 15 { // Amavasya
            return activity == .spiritual // Good for spiritual activities
        }

        if avoidTithis.contains(tithi.number) {
            return false
        }

        // Specific tithi recommendations
        switch activity {
        case .marriage:
            return [2, 3, 5, 7, 10, 11, 12, 13].contains(tithi.number) && tithi.paksha == .shukla
        case .travel:
            return [2, 3, 5, 7, 10, 11, 13].contains(tithi.number)
        case .business:
            return [2, 3, 5, 6, 7, 10, 11, 12, 13].contains(tithi.number)
        case .spiritual:
            return [5, 8, 11, 14, 15].contains(tithi.number)  // Panchami, Ashtami, Ekadashi, etc.
        default:
            return !avoidTithis.contains(tithi.number)
        }
    }
}

// MARK: - Supporting Models

struct Muhurta: Identifiable {
    let id = UUID()
    let name: String
    let startTime: Date
    let endTime: Date
    let isAuspicious: Bool
    let type: MuhurtaType

    var duration: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }

    var isCurrentlyActive: Bool {
        let now = Date()
        return now >= startTime && now < endTime
    }
}

enum MuhurtaType: String, Codable {
    case day = "Day"
    case night = "Night"
}

enum ActivityType: String, CaseIterable {
    case marriage = "Marriage"
    case travel = "Travel"
    case business = "Business"
    case education = "Education"
    case property = "Property"
    case medical = "Medical"
    case spiritual = "Spiritual"
    case haircut = "Haircut"
}

struct MuhurtaRecommendation {
    let level: RecommendationLevel
    let score: Int
    let reasons: [String]
    let warnings: [String]
}

enum RecommendationLevel: String {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case avoid = "Avoid"

    var color: String {
        switch self {
        case .excellent: return "green"
        case .good: return "blue"
        case .fair: return "orange"
        case .avoid: return "red"
        }
    }
}
