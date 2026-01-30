import Foundation

/// Represents a Hindu festival or auspicious day
struct Festival: Identifiable, Equatable {
    let id: UUID
    let name: String
    let vedName: String
    let description: String
    let category: FestivalCategory
    let deity: String?
    let significance: String
    let traditions: [String]

    /// Lunar date (if applicable)
    let tithi: String?
    let paksha: Paksha?
    let lunarMonth: LunarMonth?

    /// Solar date (for solar festivals)
    let solarMonth: Int?
    let solarDay: Int?

    /// Variable dates
    let isVariableDate: Bool

    init(
        id: UUID = UUID(),
        name: String,
        vedName: String = "",
        description: String,
        category: FestivalCategory,
        deity: String? = nil,
        significance: String = "",
        traditions: [String] = [],
        tithi: String? = nil,
        paksha: Paksha? = nil,
        lunarMonth: LunarMonth? = nil,
        solarMonth: Int? = nil,
        solarDay: Int? = nil,
        isVariableDate: Bool = true
    ) {
        self.id = id
        self.name = name
        self.vedName = vedName.isEmpty ? name : vedName
        self.description = description
        self.category = category
        self.deity = deity
        self.significance = significance
        self.traditions = traditions
        self.tithi = tithi
        self.paksha = paksha
        self.lunarMonth = lunarMonth
        self.solarMonth = solarMonth
        self.solarDay = solarDay
        self.isVariableDate = isVariableDate
    }

    var icon: String {
        category.icon
    }

    var colorName: String {
        category.colorName
    }
}

// MARK: - Festival Category

enum FestivalCategory: String, CaseIterable, Codable {
    case major = "Major Festival"
    case religious = "Religious"
    case fasting = "Fasting Day"
    case auspicious = "Auspicious Day"
    case regional = "Regional"
    case newYear = "New Year"
    case grahaPravesh = "Graha Pravesh"

    var icon: String {
        switch self {
        case .major: return "star.fill"
        case .religious: return "hands.sparkles.fill"
        case .fasting: return "leaf.fill"
        case .auspicious: return "sparkles"
        case .regional: return "map.fill"
        case .newYear: return "calendar.badge.plus"
        case .grahaPravesh: return "house.fill"
        }
    }

    var colorName: String {
        switch self {
        case .major: return "gold"
        case .religious: return "orange"
        case .fasting: return "green"
        case .auspicious: return "blue"
        case .regional: return "purple"
        case .newYear: return "red"
        case .grahaPravesh: return "teal"
        }
    }
}

// MARK: - Lunar Month

enum LunarMonth: String, CaseIterable, Codable {
    case chaitra = "Chaitra"
    case vaishakha = "Vaishakha"
    case jyeshtha = "Jyeshtha"
    case ashadha = "Ashadha"
    case shravana = "Shravana"
    case bhadrapada = "Bhadrapada"
    case ashwin = "Ashwin"
    case kartik = "Kartik"
    case margashirsha = "Margashirsha"
    case pausha = "Pausha"
    case magha = "Magha"
    case phalguna = "Phalguna"

    var number: Int {
        switch self {
        case .chaitra: return 1
        case .vaishakha: return 2
        case .jyeshtha: return 3
        case .ashadha: return 4
        case .shravana: return 5
        case .bhadrapada: return 6
        case .ashwin: return 7
        case .kartik: return 8
        case .margashirsha: return 9
        case .pausha: return 10
        case .magha: return 11
        case .phalguna: return 12
        }
    }
}

// MARK: - Festival Instance (with calculated date)

struct FestivalInstance: Identifiable {
    let id = UUID()
    let festival: Festival
    let date: Date
    let year: Int

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var isPast: Bool {
        date < Date() && !isToday
    }

    var isUpcoming: Bool {
        date > Date()
    }

    var daysUntil: Int? {
        guard isUpcoming else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: date).day
    }

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
}
