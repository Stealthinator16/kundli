import Foundation

struct Panchang: Identifiable {
    let id: UUID
    let date: Date
    let tithi: Tithi
    let nakshatra: String
    let yoga: String
    let karana: String
    let rahuKaalStart: Date
    let rahuKaalEnd: Date
    let sunriseTime: Date
    let sunsetTime: Date
    let moonPhase: MoonPhase

    init(
        id: UUID = UUID(),
        date: Date,
        tithi: Tithi,
        nakshatra: String,
        yoga: String,
        karana: String,
        rahuKaalStart: Date,
        rahuKaalEnd: Date,
        sunriseTime: Date,
        sunsetTime: Date,
        moonPhase: MoonPhase
    ) {
        self.id = id
        self.date = date
        self.tithi = tithi
        self.nakshatra = nakshatra
        self.yoga = yoga
        self.karana = karana
        self.rahuKaalStart = rahuKaalStart
        self.rahuKaalEnd = rahuKaalEnd
        self.sunriseTime = sunriseTime
        self.sunsetTime = sunsetTime
        self.moonPhase = moonPhase
    }

    var formattedRahuKaal: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return "\(formatter.string(from: rahuKaalStart)) - \(formatter.string(from: rahuKaalEnd))"
    }

    var isRahuKaalActive: Bool {
        let now = Date()
        return now >= rahuKaalStart && now <= rahuKaalEnd
    }
}

// MARK: - Tithi
struct Tithi {
    let name: String
    let paksha: Paksha // Shukla or Krishna
    let number: Int    // 1-15

    var fullName: String {
        "\(paksha.rawValue) \(name)"
    }
}

enum Paksha: String {
    case shukla = "Shukla"
    case krishna = "Krishna"
}

// MARK: - Moon Phase
enum MoonPhase: String, CaseIterable {
    case newMoon = "New Moon"
    case waxingCrescent = "Waxing Crescent"
    case firstQuarter = "First Quarter"
    case waxingGibbous = "Waxing Gibbous"
    case fullMoon = "Full Moon"
    case waningGibbous = "Waning Gibbous"
    case lastQuarter = "Last Quarter"
    case waningCrescent = "Waning Crescent"

    var symbol: String {
        switch self {
        case .newMoon: return "🌑"
        case .waxingCrescent: return "🌒"
        case .firstQuarter: return "🌓"
        case .waxingGibbous: return "🌔"
        case .fullMoon: return "🌕"
        case .waningGibbous: return "🌖"
        case .lastQuarter: return "🌗"
        case .waningCrescent: return "🌘"
        }
    }
}

// MARK: - Nakshatra List
enum Nakshatra: String, CaseIterable {
    case ashwini = "Ashwini"
    case bharani = "Bharani"
    case krittika = "Krittika"
    case rohini = "Rohini"
    case mrigashira = "Mrigashira"
    case ardra = "Ardra"
    case punarvasu = "Punarvasu"
    case pushya = "Pushya"
    case ashlesha = "Ashlesha"
    case magha = "Magha"
    case purvaphalguni = "Purva Phalguni"
    case uttaraphalguni = "Uttara Phalguni"
    case hasta = "Hasta"
    case chitra = "Chitra"
    case swati = "Swati"
    case vishakha = "Vishakha"
    case anuradha = "Anuradha"
    case jyeshtha = "Jyeshtha"
    case mula = "Mula"
    case purvaashadha = "Purva Ashadha"
    case uttaraashadha = "Uttara Ashadha"
    case shravana = "Shravana"
    case dhanishta = "Dhanishta"
    case shatabhisha = "Shatabhisha"
    case purvabhadrapada = "Purva Bhadrapada"
    case uttarabhadrapada = "Uttara Bhadrapada"
    case revati = "Revati"

    var lord: String {
        switch self {
        case .ashwini, .magha, .mula: return "Ketu"
        case .bharani, .purvaphalguni, .purvaashadha: return "Venus"
        case .krittika, .uttaraphalguni, .uttaraashadha: return "Sun"
        case .rohini, .hasta, .shravana: return "Moon"
        case .mrigashira, .chitra, .dhanishta: return "Mars"
        case .ardra, .swati, .shatabhisha: return "Rahu"
        case .punarvasu, .vishakha, .purvabhadrapada: return "Jupiter"
        case .pushya, .anuradha, .uttarabhadrapada: return "Saturn"
        case .ashlesha, .jyeshtha, .revati: return "Mercury"
        }
    }
}
