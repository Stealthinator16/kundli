import Foundation

/// Service for calculating Hora (planetary hours)
/// Hora divides the day and night into planetary hours, each ruled by a specific planet
final class HoraService {
    static let shared = HoraService()

    private let panchangService = PanchangCalculationService.shared

    private init() {}

    /// Planetary rulers in Chaldean order (used for hora sequence)
    /// Starting from Saturn and going backwards: Saturn, Jupiter, Mars, Sun, Venus, Mercury, Moon
    private let chaldeanOrder: [HoraPlanet] = [
        .saturn, .jupiter, .mars, .sun, .venus, .mercury, .moon
    ]

    /// Day rulers for each weekday (Sunday = 1)
    private let dayRulers: [HoraPlanet] = [
        .sun,      // Sunday
        .moon,     // Monday
        .mars,     // Tuesday
        .mercury,  // Wednesday
        .jupiter,  // Thursday
        .venus,    // Friday
        .saturn    // Saturday
    ]

    // MARK: - Main Calculations

    /// Calculate all hora periods for a given date and location
    func calculateHoraPeriods(
        date: Date,
        latitude: Double,
        longitude: Double,
        timezone: TimeZone = .current
    ) -> HoraData {
        let panchang = panchangService.calculatePanchang(
            date: date,
            latitude: latitude,
            longitude: longitude,
            timezone: timezone
        )

        let sunrise = panchang.sunriseTime
        let sunset = panchang.sunsetTime

        // Calculate next day's sunrise for night horas
        let calendar = Calendar.current
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: date),
              let nextSunrise = calculateNextSunrise(date: nextDay, latitude: latitude, longitude: longitude, timezone: timezone) else {
            return HoraData(date: date, periods: [], currentPeriodIndex: nil)
        }

        // Calculate day and night durations
        let dayDuration = sunset.timeIntervalSince(sunrise)
        let nightDuration = nextSunrise.timeIntervalSince(sunset)

        // Each hora is 1/12th of day or night duration
        let dayHoraDuration = dayDuration / 12
        let nightHoraDuration = nightDuration / 12

        // Get the weekday to determine the starting planet
        let weekday = calendar.component(.weekday, from: date)
        let dayRuler = dayRulers[weekday - 1]
        let startIndex = chaldeanOrder.firstIndex(of: dayRuler) ?? 0

        var periods: [HoraPeriod] = []
        var currentTime = sunrise

        // Calculate 12 day horas
        for i in 0..<12 {
            let planetIndex = (startIndex + i) % 7
            let planet = chaldeanOrder[planetIndex]
            let endTime = currentTime.addingTimeInterval(dayHoraDuration)

            periods.append(HoraPeriod(
                planet: planet,
                startTime: currentTime,
                endTime: endTime,
                isDay: true,
                horaNumber: i + 1
            ))

            currentTime = endTime
        }

        // Calculate 12 night horas (continue from where day horas left off)
        for i in 0..<12 {
            let planetIndex = (startIndex + 12 + i) % 7
            let planet = chaldeanOrder[planetIndex]
            let endTime = currentTime.addingTimeInterval(nightHoraDuration)

            periods.append(HoraPeriod(
                planet: planet,
                startTime: currentTime,
                endTime: endTime,
                isDay: false,
                horaNumber: i + 13
            ))

            currentTime = endTime
        }

        // Find current period
        let now = Date()
        let currentIndex = periods.firstIndex { period in
            now >= period.startTime && now < period.endTime
        }

        return HoraData(
            date: date,
            periods: periods,
            currentPeriodIndex: currentIndex,
            sunrise: sunrise,
            sunset: sunset
        )
    }

    /// Get the current hora for a location
    func getCurrentHora(
        latitude: Double,
        longitude: Double,
        timezone: TimeZone = .current
    ) -> HoraPeriod? {
        let horaData = calculateHoraPeriods(
            date: Date(),
            latitude: latitude,
            longitude: longitude,
            timezone: timezone
        )

        if let index = horaData.currentPeriodIndex {
            return horaData.periods[index]
        }
        return nil
    }

    /// Calculate next sunrise for night hora calculations
    private func calculateNextSunrise(
        date: Date,
        latitude: Double,
        longitude: Double,
        timezone: TimeZone
    ) -> Date? {
        let panchang = panchangService.calculatePanchang(
            date: date,
            latitude: latitude,
            longitude: longitude,
            timezone: timezone
        )
        return panchang.sunriseTime
    }
}

// MARK: - Hora Data Model

struct HoraData {
    let date: Date
    let periods: [HoraPeriod]
    let currentPeriodIndex: Int?
    var sunrise: Date?
    var sunset: Date?

    var currentPeriod: HoraPeriod? {
        guard let index = currentPeriodIndex else { return nil }
        return periods[index]
    }

    var dayPeriods: [HoraPeriod] {
        periods.filter { $0.isDay }
    }

    var nightPeriods: [HoraPeriod] {
        periods.filter { !$0.isDay }
    }
}

// MARK: - Hora Period Model

struct HoraPeriod: Identifiable {
    let id = UUID()
    let planet: HoraPlanet
    let startTime: Date
    let endTime: Date
    let isDay: Bool
    let horaNumber: Int

    var isActive: Bool {
        let now = Date()
        return now >= startTime && now < endTime
    }

    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }

    var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }

    var progress: Double {
        guard isActive else { return isCompleted ? 1.0 : 0.0 }
        let now = Date()
        let elapsed = now.timeIntervalSince(startTime)
        return min(elapsed / duration, 1.0)
    }

    var isCompleted: Bool {
        Date() >= endTime
    }

    var remainingTime: String? {
        guard isActive else { return nil }
        let now = Date()
        let remaining = endTime.timeIntervalSince(now)
        let minutes = Int(remaining / 60)
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return "\(hours)h \(mins)m left"
        }
        return "\(minutes)m left"
    }
}

// MARK: - Hora Planet

enum HoraPlanet: String, CaseIterable {
    case sun = "Sun"
    case moon = "Moon"
    case mars = "Mars"
    case mercury = "Mercury"
    case jupiter = "Jupiter"
    case venus = "Venus"
    case saturn = "Saturn"

    var symbol: String {
        switch self {
        case .sun: return "Su"
        case .moon: return "Mo"
        case .mars: return "Ma"
        case .mercury: return "Me"
        case .jupiter: return "Ju"
        case .venus: return "Ve"
        case .saturn: return "Sa"
        }
    }

    var vedName: String {
        switch self {
        case .sun: return "Surya"
        case .moon: return "Chandra"
        case .mars: return "Mangal"
        case .mercury: return "Budh"
        case .jupiter: return "Guru"
        case .venus: return "Shukra"
        case .saturn: return "Shani"
        }
    }

    var icon: String {
        switch self {
        case .sun: return "sun.max.fill"
        case .moon: return "moon.fill"
        case .mars: return "flame.fill"
        case .mercury: return "wind"
        case .jupiter: return "sparkles"
        case .venus: return "heart.fill"
        case .saturn: return "clock.fill"
        }
    }

    var nature: HoraNature {
        switch self {
        case .sun, .jupiter: return .benefic
        case .moon, .venus: return .benefic
        case .mercury: return .neutral
        case .mars, .saturn: return .malefic
        }
    }

    var auspiciousFor: [String] {
        switch self {
        case .sun:
            return ["Government work", "Authority matters", "Health", "Father-related"]
        case .moon:
            return ["Travel", "New beginnings", "Water-related", "Mother-related"]
        case .mars:
            return ["Property", "Surgery", "Conflict resolution", "Courage"]
        case .mercury:
            return ["Business", "Communication", "Learning", "Writing"]
        case .jupiter:
            return ["Spiritual activities", "Education", "Marriage", "Finance"]
        case .venus:
            return ["Romance", "Art", "Luxury purchases", "Entertainment"]
        case .saturn:
            return ["Labor work", "Real estate", "Iron/Oil business", "Agriculture"]
        }
    }
}

enum HoraNature: String {
    case benefic = "Benefic"
    case malefic = "Malefic"
    case neutral = "Neutral"

    var colorName: String {
        switch self {
        case .benefic: return "green"
        case .malefic: return "red"
        case .neutral: return "blue"
        }
    }
}
