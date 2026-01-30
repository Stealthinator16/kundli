import Foundation

/// Service for calculating real Panchang (Hindu calendar) data
final class PanchangCalculationService {
    static let shared = PanchangCalculationService()

    private let ephemeris = EphemerisService.shared

    private init() {}

    // MARK: - Main Panchang Calculation

    /// Calculate complete Panchang for a given date and location
    func calculatePanchang(date: Date, latitude: Double, longitude: Double, timezone: TimeZone = .current) -> Panchang {
        // Calculate sunrise and sunset
        let sunrise = ephemeris.calculateSunrise(date: date, latitude: latitude, longitude: longitude, timezone: timezone) ?? defaultSunrise(for: date, timezone: timezone)
        let sunset = ephemeris.calculateSunset(date: date, latitude: latitude, longitude: longitude, timezone: timezone) ?? defaultSunset(for: date, timezone: timezone)

        // Get Sun and Moon positions at sunrise (traditional Panchang time)
        let sunPosition = ephemeris.siderealLongitude(planet: .sun, date: sunrise)
        let moonPosition = ephemeris.siderealLongitude(planet: .moon, date: sunrise)

        let sunLongitude = sunPosition?.longitude ?? 0
        let moonLongitude = moonPosition?.longitude ?? 0

        // Calculate Tithi
        let tithi = calculateTithi(sunLongitude: sunLongitude, moonLongitude: moonLongitude)

        // Calculate Nakshatra
        let nakshatra = calculateNakshatra(moonLongitude: moonLongitude)

        // Calculate Yoga (Panchang yoga, not astrological)
        let yoga = calculatePanchangYoga(sunLongitude: sunLongitude, moonLongitude: moonLongitude)

        // Calculate Karana
        let karana = calculateKarana(sunLongitude: sunLongitude, moonLongitude: moonLongitude)

        // Calculate Moon Phase
        let moonPhase = calculateMoonPhase(sunLongitude: sunLongitude, moonLongitude: moonLongitude)

        // Calculate Rahu Kaal
        let (rahuStart, rahuEnd) = calculateRahuKaal(sunrise: sunrise, sunset: sunset, weekday: Calendar.current.component(.weekday, from: date))

        return Panchang(
            date: date,
            tithi: tithi,
            nakshatra: nakshatra.rawValue,
            yoga: yoga.rawValue,
            karana: karana.rawValue,
            rahuKaalStart: rahuStart,
            rahuKaalEnd: rahuEnd,
            sunriseTime: sunrise,
            sunsetTime: sunset,
            moonPhase: moonPhase
        )
    }

    // MARK: - Tithi Calculation

    /// Calculate Tithi (lunar day)
    /// Tithi is based on the angular distance between Sun and Moon
    /// Each Tithi = 12 degrees of Moon-Sun separation
    func calculateTithi(sunLongitude: Double, moonLongitude: Double) -> Tithi {
        // Calculate Moon-Sun angular separation
        var lunarPhase = moonLongitude - sunLongitude
        if lunarPhase < 0 { lunarPhase += 360 }

        // Each tithi spans 12 degrees
        let tithiNumber = Int(lunarPhase / 12.0) + 1

        // Determine Paksha (fortnight)
        let paksha: Paksha = lunarPhase < 180 ? .shukla : .krishna

        // Adjust tithi number for Krishna Paksha (16-30 becomes 1-15)
        let adjustedNumber = paksha == .shukla ? tithiNumber : (tithiNumber > 15 ? tithiNumber - 15 : tithiNumber)
        let finalNumber = min(adjustedNumber, 15)

        let tithiName = tithiNames[finalNumber - 1]

        return Tithi(name: tithiName, paksha: paksha, number: finalNumber)
    }

    private let tithiNames = [
        "Pratipada", "Dwitiya", "Tritiya", "Chaturthi", "Panchami",
        "Shashthi", "Saptami", "Ashtami", "Navami", "Dashami",
        "Ekadashi", "Dwadashi", "Trayodashi", "Chaturdashi", "Purnima/Amavasya"
    ]

    // MARK: - Nakshatra Calculation

    /// Calculate Moon's Nakshatra
    /// Each Nakshatra spans 13°20' (13.333 degrees)
    func calculateNakshatra(moonLongitude: Double) -> Nakshatra {
        let nakshatraIndex = Int(moonLongitude / 13.333333) % 27
        return Nakshatra.allCases[nakshatraIndex]
    }

    /// Calculate Nakshatra Pada (quarter)
    /// Each Pada spans 3°20' (3.333 degrees)
    func calculateNakshatraPada(moonLongitude: Double) -> Int {
        let positionInNakshatra = moonLongitude.truncatingRemainder(dividingBy: 13.333333)
        return Int(positionInNakshatra / 3.333333) + 1
    }

    // MARK: - Panchang Yoga Calculation

    /// Calculate Panchang Yoga (not astrological yoga)
    /// Yoga = (Sun longitude + Moon longitude) / 13.333
    func calculatePanchangYoga(sunLongitude: Double, moonLongitude: Double) -> PanchangYoga {
        var yogaValue = sunLongitude + moonLongitude
        if yogaValue >= 360 { yogaValue -= 360 }

        let yogaIndex = Int(yogaValue / 13.333333) % 27
        return PanchangYoga.allCases[yogaIndex]
    }

    // MARK: - Karana Calculation

    /// Calculate Karana (half-tithi)
    /// There are 11 Karanas, 4 fixed and 7 repeating
    func calculateKarana(sunLongitude: Double, moonLongitude: Double) -> Karana {
        var lunarPhase = moonLongitude - sunLongitude
        if lunarPhase < 0 { lunarPhase += 360 }

        // Each karana spans 6 degrees (half of a tithi)
        let karanaNumber = Int(lunarPhase / 6.0) % 60

        // Map karana number to karana type
        return karanaFromNumber(karanaNumber)
    }

    private func karanaFromNumber(_ number: Int) -> Karana {
        // First half of Shukla Pratipada is Kimstughna (fixed)
        if number == 0 { return .kimstughna }

        // Karanas 1-56 are the 7 repeating karanas, cycling 8 times
        let repeatingIndex = (number - 1) % 7
        let repeatingKaranas: [Karana] = [.bava, .balava, .kaulava, .taitila, .gara, .vanija, .vishti]

        if number <= 56 {
            return repeatingKaranas[repeatingIndex]
        }

        // Last 3 karanas are fixed
        switch number {
        case 57: return .shakuni
        case 58: return .chatushpada
        case 59: return .nagava
        default: return .bava
        }
    }

    // MARK: - Moon Phase Calculation

    func calculateMoonPhase(sunLongitude: Double, moonLongitude: Double) -> MoonPhase {
        var lunarPhase = moonLongitude - sunLongitude
        if lunarPhase < 0 { lunarPhase += 360 }

        switch lunarPhase {
        case 0..<22.5: return .newMoon
        case 22.5..<67.5: return .waxingCrescent
        case 67.5..<112.5: return .firstQuarter
        case 112.5..<157.5: return .waxingGibbous
        case 157.5..<202.5: return .fullMoon
        case 202.5..<247.5: return .waningGibbous
        case 247.5..<292.5: return .lastQuarter
        case 292.5..<337.5: return .waningCrescent
        default: return .newMoon
        }
    }

    // MARK: - Rahu Kaal Calculation

    /// Calculate Rahu Kaal for a given day
    /// Rahu Kaal is 1/8th of the day, occurring at different times based on weekday
    func calculateRahuKaal(sunrise: Date, sunset: Date, weekday: Int) -> (start: Date, end: Date) {
        let dayDuration = sunset.timeIntervalSince(sunrise)
        let rahuKaalDuration = dayDuration / 8

        // Rahu Kaal sequence (1 = Sunday, 7 = Saturday)
        // Order: Mon(2), Sat(7), Fri(6), Wed(4), Thu(5), Tue(3), Sun(1)
        // Each day's Rahu Kaal starts at different 1/8th portion
        let rahuKaalPeriod: Int
        switch weekday {
        case 1: rahuKaalPeriod = 8  // Sunday: 8th period (4:30-6:00 PM approx)
        case 2: rahuKaalPeriod = 2  // Monday: 2nd period (7:30-9:00 AM approx)
        case 3: rahuKaalPeriod = 7  // Tuesday: 7th period (3:00-4:30 PM approx)
        case 4: rahuKaalPeriod = 5  // Wednesday: 5th period (12:00-1:30 PM approx)
        case 5: rahuKaalPeriod = 6  // Thursday: 6th period (1:30-3:00 PM approx)
        case 6: rahuKaalPeriod = 4  // Friday: 4th period (10:30-12:00 PM approx)
        case 7: rahuKaalPeriod = 3  // Saturday: 3rd period (9:00-10:30 AM approx)
        default: rahuKaalPeriod = 1
        }

        let startOffset = Double(rahuKaalPeriod - 1) * rahuKaalDuration
        let rahuStart = sunrise.addingTimeInterval(startOffset)
        let rahuEnd = rahuStart.addingTimeInterval(rahuKaalDuration)

        return (rahuStart, rahuEnd)
    }

    /// Calculate Yamagandam (inauspicious period)
    func calculateYamagandam(sunrise: Date, sunset: Date, weekday: Int) -> (start: Date, end: Date) {
        let dayDuration = sunset.timeIntervalSince(sunrise)
        let periodDuration = dayDuration / 8

        // Yamagandam sequence
        let yamagandamPeriod: Int
        switch weekday {
        case 1: yamagandamPeriod = 5  // Sunday
        case 2: yamagandamPeriod = 4  // Monday
        case 3: yamagandamPeriod = 3  // Tuesday
        case 4: yamagandamPeriod = 2  // Wednesday
        case 5: yamagandamPeriod = 1  // Thursday
        case 6: yamagandamPeriod = 7  // Friday
        case 7: yamagandamPeriod = 6  // Saturday
        default: yamagandamPeriod = 1
        }

        let startOffset = Double(yamagandamPeriod - 1) * periodDuration
        let start = sunrise.addingTimeInterval(startOffset)
        let end = start.addingTimeInterval(periodDuration)

        return (start, end)
    }

    /// Calculate Gulika Kalam (inauspicious period)
    func calculateGulikaKalam(sunrise: Date, sunset: Date, weekday: Int) -> (start: Date, end: Date) {
        let dayDuration = sunset.timeIntervalSince(sunrise)
        let periodDuration = dayDuration / 8

        // Gulika Kalam sequence
        let gulikaPeriod: Int
        switch weekday {
        case 1: gulikaPeriod = 7  // Sunday
        case 2: gulikaPeriod = 6  // Monday
        case 3: gulikaPeriod = 5  // Tuesday
        case 4: gulikaPeriod = 4  // Wednesday
        case 5: gulikaPeriod = 3  // Thursday
        case 6: gulikaPeriod = 2  // Friday
        case 7: gulikaPeriod = 1  // Saturday
        default: gulikaPeriod = 1
        }

        let startOffset = Double(gulikaPeriod - 1) * periodDuration
        let start = sunrise.addingTimeInterval(startOffset)
        let end = start.addingTimeInterval(periodDuration)

        return (start, end)
    }

    // MARK: - Helper Methods

    private func defaultSunrise(for date: Date, timezone: TimeZone) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = timezone
        return calendar.date(bySettingHour: 6, minute: 0, second: 0, of: date) ?? date
    }

    private func defaultSunset(for date: Date, timezone: TimeZone) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = timezone
        return calendar.date(bySettingHour: 18, minute: 0, second: 0, of: date) ?? date
    }
}

// MARK: - Panchang Yoga Enum (27 Yogas)
enum PanchangYoga: String, CaseIterable, Codable {
    case vishkumbha = "Vishkumbha"
    case preeti = "Preeti"
    case ayushman = "Ayushman"
    case saubhagya = "Saubhagya"
    case shobhana = "Shobhana"
    case atiganda = "Atiganda"
    case sukarma = "Sukarma"
    case dhriti = "Dhriti"
    case shoola = "Shoola"
    case ganda = "Ganda"
    case vriddhi = "Vriddhi"
    case dhruva = "Dhruva"
    case vyaghata = "Vyaghata"
    case harshana = "Harshana"
    case vajra = "Vajra"
    case siddhi = "Siddhi"
    case vyatipata = "Vyatipata"
    case variyan = "Variyan"
    case parigha = "Parigha"
    case shiva = "Shiva"
    case siddha = "Siddha"
    case sadhya = "Sadhya"
    case shubha = "Shubha"
    case shukla = "Shukla"
    case brahma = "Brahma"
    case indra = "Indra"
    case vaidhriti = "Vaidhriti"

    var isAuspicious: Bool {
        switch self {
        case .preeti, .ayushman, .saubhagya, .shobhana, .sukarma, .dhriti,
             .vriddhi, .dhruva, .harshana, .siddhi, .variyan, .shiva, .siddha,
             .sadhya, .shubha, .shukla, .brahma, .indra:
            return true
        default:
            return false
        }
    }
}

// MARK: - Karana Enum (11 Karanas)
enum Karana: String, CaseIterable, Codable {
    // 7 Repeating Karanas (Chara)
    case bava = "Bava"
    case balava = "Balava"
    case kaulava = "Kaulava"
    case taitila = "Taitila"
    case gara = "Gara"
    case vanija = "Vanija"
    case vishti = "Vishti"  // Bhadra - inauspicious

    // 4 Fixed Karanas (Sthira)
    case shakuni = "Shakuni"
    case chatushpada = "Chatushpada"
    case nagava = "Nagava"
    case kimstughna = "Kimstughna"

    var isAuspicious: Bool {
        switch self {
        case .vishti:
            return false  // Bhadra karana is inauspicious
        case .shakuni, .chatushpada, .nagava:
            return false  // Fixed karanas near Amavasya
        default:
            return true
        }
    }

    var description: String {
        switch self {
        case .bava: return "Good for starting new ventures"
        case .balava: return "Auspicious for ceremonies"
        case .kaulava: return "Good for friendship and relationships"
        case .taitila: return "Good for domestic activities"
        case .gara: return "Good for agriculture and farming"
        case .vanija: return "Good for trade and business"
        case .vishti: return "Bhadra - avoid important activities"
        case .shakuni: return "End of Krishna Paksha"
        case .chatushpada: return "Transition period"
        case .nagava: return "Beginning of Shukla Paksha"
        case .kimstughna: return "Start of lunar month"
        }
    }
}
