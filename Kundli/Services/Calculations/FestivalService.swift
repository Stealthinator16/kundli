import Foundation

/// Service for calculating Hindu festival dates
final class FestivalService {
    static let shared = FestivalService()

    private let panchangService = PanchangCalculationService.shared

    private init() {}

    // MARK: - Festival Data

    /// All Hindu festivals
    let allFestivals: [Festival] = [
        // Major Festivals
        Festival(
            name: "Diwali",
            vedName: "Deepavali",
            description: "Festival of Lights celebrating the victory of light over darkness",
            category: .major,
            deity: "Lakshmi, Ganesha",
            significance: "Celebrates Lord Rama's return to Ayodhya, worship of Goddess Lakshmi",
            traditions: ["Lighting diyas", "Rangoli", "Fireworks", "Lakshmi Puja", "Exchanging gifts"],
            tithi: "Amavasya",
            paksha: .krishna,
            lunarMonth: .kartik
        ),
        Festival(
            name: "Holi",
            vedName: "Holika Dahan",
            description: "Festival of Colors celebrating spring and the triumph of good over evil",
            category: .major,
            deity: "Vishnu, Prahlad",
            significance: "Victory of devotee Prahlad over demoness Holika",
            traditions: ["Playing with colors", "Holika bonfire", "Thandai", "Gujiya sweets"],
            tithi: "Purnima",
            paksha: .shukla,
            lunarMonth: .phalguna
        ),
        Festival(
            name: "Dussehra",
            vedName: "Vijayadashami",
            description: "Victory of Lord Rama over Ravana",
            category: .major,
            deity: "Rama, Durga",
            significance: "Triumph of good over evil, end of Navratri",
            traditions: ["Ramlila", "Burning Ravana effigy", "Weapon worship", "Shami Puja"],
            tithi: "Dashami",
            paksha: .shukla,
            lunarMonth: .ashwin
        ),
        Festival(
            name: "Ganesh Chaturthi",
            vedName: "Vinayaka Chaturthi",
            description: "Birthday of Lord Ganesha",
            category: .major,
            deity: "Ganesha",
            significance: "Celebration of the birth of the elephant-headed god",
            traditions: ["Installing Ganesha idols", "Modak offerings", "Visarjan"],
            tithi: "Chaturthi",
            paksha: .shukla,
            lunarMonth: .bhadrapada
        ),
        Festival(
            name: "Navratri",
            vedName: "Sharad Navratri",
            description: "Nine nights dedicated to Goddess Durga",
            category: .major,
            deity: "Durga",
            significance: "Worship of nine forms of Goddess Durga",
            traditions: ["Fasting", "Garba/Dandiya", "Durga Puja", "Kanya Puja"],
            tithi: "Pratipada",
            paksha: .shukla,
            lunarMonth: .ashwin
        ),
        Festival(
            name: "Janmashtami",
            vedName: "Krishna Janmashtami",
            description: "Birthday of Lord Krishna",
            category: .major,
            deity: "Krishna",
            significance: "Celebrates the birth of Lord Krishna at midnight",
            traditions: ["Fasting until midnight", "Dahi Handi", "Krishna temples decoration"],
            tithi: "Ashtami",
            paksha: .krishna,
            lunarMonth: .bhadrapada
        ),

        // Religious Festivals
        Festival(
            name: "Maha Shivaratri",
            vedName: "Shivaratri",
            description: "The Great Night of Lord Shiva",
            category: .religious,
            deity: "Shiva",
            significance: "Night when Lord Shiva performed the cosmic dance",
            traditions: ["All-night vigil", "Fasting", "Shiva Puja", "Bel leaves offering"],
            tithi: "Chaturdashi",
            paksha: .krishna,
            lunarMonth: .magha
        ),
        Festival(
            name: "Rama Navami",
            vedName: "Rama Navami",
            description: "Birthday of Lord Rama",
            category: .religious,
            deity: "Rama",
            significance: "Birth anniversary of Lord Rama",
            traditions: ["Reading Ramayana", "Temple visits", "Fasting", "Kalyanotsavam"],
            tithi: "Navami",
            paksha: .shukla,
            lunarMonth: .chaitra
        ),
        Festival(
            name: "Hanuman Jayanti",
            vedName: "Hanuman Jayanti",
            description: "Birthday of Lord Hanuman",
            category: .religious,
            deity: "Hanuman",
            significance: "Celebrates the birth of the monkey god",
            traditions: ["Hanuman Chalisa recitation", "Temple visits", "Fasting"],
            tithi: "Purnima",
            paksha: .shukla,
            lunarMonth: .chaitra
        ),
        Festival(
            name: "Raksha Bandhan",
            vedName: "Rakhi Purnima",
            description: "Festival celebrating the bond between brothers and sisters",
            category: .religious,
            significance: "Sisters tie rakhi on brothers' wrists for protection",
            traditions: ["Tying Rakhi", "Exchanging gifts", "Family gathering"],
            tithi: "Purnima",
            paksha: .shukla,
            lunarMonth: .shravana
        ),
        Festival(
            name: "Guru Purnima",
            vedName: "Vyasa Purnima",
            description: "Day to honor spiritual and academic teachers",
            category: .religious,
            deity: "Vyasa",
            significance: "Birthday of Sage Vyasa, author of Mahabharata",
            traditions: ["Guru worship", "Offerings to teachers", "Spiritual discourses"],
            tithi: "Purnima",
            paksha: .shukla,
            lunarMonth: .ashadha
        ),

        // Fasting Days
        Festival(
            name: "Karva Chauth",
            vedName: "Karaka Chaturthi",
            description: "Day of fasting by married women for their husbands",
            category: .fasting,
            significance: "Wives fast for longevity of their husbands",
            traditions: ["Day-long fast", "Moon sighting", "Sargi"],
            tithi: "Chaturthi",
            paksha: .krishna,
            lunarMonth: .kartik
        ),
        Festival(
            name: "Ekadashi",
            vedName: "Ekadashi Vrat",
            description: "Eleventh day fasting for Lord Vishnu",
            category: .fasting,
            deity: "Vishnu",
            significance: "Auspicious fasting day for spiritual growth",
            traditions: ["Complete or partial fast", "Vishnu worship", "Night vigil"],
            tithi: "Ekadashi",
            paksha: .shukla
        ),
        Festival(
            name: "Pradosh Vrat",
            vedName: "Pradosha",
            description: "Fasting day for Lord Shiva on Trayodashi",
            category: .fasting,
            deity: "Shiva",
            significance: "Evening worship of Lord Shiva",
            traditions: ["Evening puja", "Fasting", "Shiva temple visit"],
            tithi: "Trayodashi"
        ),

        // Auspicious Days
        Festival(
            name: "Akshaya Tritiya",
            vedName: "Akha Teej",
            description: "One of the most auspicious days in Hindu calendar",
            category: .auspicious,
            significance: "Day of never-diminishing prosperity",
            traditions: ["Buying gold", "Starting new ventures", "Charity"],
            tithi: "Tritiya",
            paksha: .shukla,
            lunarMonth: .vaishakha
        ),
        Festival(
            name: "Basant Panchami",
            vedName: "Vasant Panchami",
            description: "Festival welcoming spring, dedicated to Goddess Saraswati",
            category: .auspicious,
            deity: "Saraswati",
            significance: "Worship of the goddess of knowledge and arts",
            traditions: ["Wearing yellow", "Saraswati Puja", "Flying kites"],
            tithi: "Panchami",
            paksha: .shukla,
            lunarMonth: .magha
        ),
        Festival(
            name: "Dhanteras",
            vedName: "Dhanatrayodashi",
            description: "Festival of wealth, marks beginning of Diwali celebrations",
            category: .auspicious,
            deity: "Dhanvantari, Lakshmi",
            significance: "Auspicious for buying gold, silver, and utensils",
            traditions: ["Buying metals", "Dhanvantari puja", "Lighting diyas"],
            tithi: "Trayodashi",
            paksha: .krishna,
            lunarMonth: .kartik
        ),

        // New Year Celebrations
        Festival(
            name: "Hindu New Year",
            vedName: "Chaitra Shukla Pratipada",
            description: "Beginning of new Hindu lunar year",
            category: .newYear,
            significance: "Start of new year in Hindu calendar",
            traditions: ["New beginnings", "Temple visits", "Gudi Padwa/Ugadi celebrations"],
            tithi: "Pratipada",
            paksha: .shukla,
            lunarMonth: .chaitra
        ),
        Festival(
            name: "Makar Sankranti",
            vedName: "Uttarayana",
            description: "Sun's transition into Capricorn, harvest festival",
            category: .newYear,
            deity: "Surya",
            significance: "Beginning of sun's northward journey",
            traditions: ["Flying kites", "Til-gur sweets", "Holy bath", "Charity"],
            solarMonth: 1,
            solarDay: 14,
            isVariableDate: false
        ),

        // Additional Important Festivals
        Festival(
            name: "Onam",
            vedName: "Thiruvonam",
            description: "Harvest festival of Kerala celebrating King Mahabali",
            category: .regional,
            significance: "Return of mythical King Mahabali to Kerala",
            traditions: ["Onam Sadya feast", "Pookalam", "Boat races", "Kathakali"],
            lunarMonth: .bhadrapada
        ),
        Festival(
            name: "Pongal",
            vedName: "Thai Pongal",
            description: "Tamil harvest festival",
            category: .regional,
            deity: "Surya",
            significance: "Thanksgiving to Sun God for harvest",
            traditions: ["Cooking Pongal dish", "Kolam", "Jallikattu"],
            solarMonth: 1,
            solarDay: 15,
            isVariableDate: false
        ),
        Festival(
            name: "Bhai Dooj",
            vedName: "Bhai Phonta",
            description: "Celebration of brother-sister bond after Diwali",
            category: .religious,
            significance: "Sisters pray for brothers' long life",
            traditions: ["Tilak ceremony", "Gift exchange", "Special meal"],
            tithi: "Dwitiya",
            paksha: .shukla,
            lunarMonth: .kartik
        ),
        Festival(
            name: "Chhath Puja",
            vedName: "Surya Shashthi",
            description: "Ancient festival dedicated to Sun God",
            category: .religious,
            deity: "Surya, Chhathi Maiya",
            significance: "Worship of Sun and his wife Usha",
            traditions: ["Standing in water", "Offering Arghya", "Fasting"],
            tithi: "Shashthi",
            paksha: .shukla,
            lunarMonth: .kartik
        ),
        Festival(
            name: "Durga Ashtami",
            vedName: "Maha Ashtami",
            description: "Eighth day of Navratri, major worship day",
            category: .religious,
            deity: "Durga",
            significance: "Most important day of Durga Puja",
            traditions: ["Sandhi Puja", "Kumari Puja", "Pushpanjali"],
            tithi: "Ashtami",
            paksha: .shukla,
            lunarMonth: .ashwin
        ),
    ]

    // MARK: - Date Calculations

    /// Get festivals for a specific year with calculated dates
    /// Note: This uses simplified date approximations. For accurate dates,
    /// integration with a proper Panchang calculation would be needed.
    func getFestivalsForYear(_ year: Int) -> [FestivalInstance] {
        var instances: [FestivalInstance] = []

        for festival in allFestivals {
            if let date = approximateFestivalDate(festival, year: year) {
                instances.append(FestivalInstance(festival: festival, date: date, year: year))
            }
        }

        return instances.sorted { $0.date < $1.date }
    }

    /// Get upcoming festivals from current date
    func getUpcomingFestivals(limit: Int = 10) -> [FestivalInstance] {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let nextYear = currentYear + 1

        var allInstances: [FestivalInstance] = []
        allInstances.append(contentsOf: getFestivalsForYear(currentYear))
        allInstances.append(contentsOf: getFestivalsForYear(nextYear))

        return allInstances
            .filter { $0.date >= Date() }
            .sorted { $0.date < $1.date }
            .prefix(limit)
            .map { $0 }
    }

    /// Get festivals for a specific month
    func getFestivalsForMonth(month: Int, year: Int) -> [FestivalInstance] {
        let calendar = Calendar.current
        return getFestivalsForYear(year).filter { instance in
            calendar.component(.month, from: instance.date) == month
        }
    }

    /// Get today's festivals
    func getTodaysFestivals() -> [FestivalInstance] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        return getFestivalsForYear(year).filter { $0.isToday }
    }

    // MARK: - Private Methods

    /// Approximate festival date based on lunar/solar calendar
    /// This is a simplified approximation - accurate dates require full Panchang calculation
    private func approximateFestivalDate(_ festival: Festival, year: Int) -> Date? {
        let calendar = Calendar.current

        // For fixed solar date festivals
        if !festival.isVariableDate, let month = festival.solarMonth, let day = festival.solarDay {
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            return calendar.date(from: components)
        }

        // For lunar calendar festivals, use approximations based on typical dates
        // These are rough approximations and would need proper Panchang calculation for accuracy
        guard let lunarMonth = festival.lunarMonth else {
            return nil
        }

        let approximateMonth = lunarMonthToGregorianMonth(lunarMonth)
        let approximateDay = tithiToApproximateDay(festival.tithi, paksha: festival.paksha)

        var components = DateComponents()
        components.year = year
        components.month = approximateMonth
        components.day = approximateDay

        return calendar.date(from: components)
    }

    private func lunarMonthToGregorianMonth(_ lunarMonth: LunarMonth) -> Int {
        // Approximate mapping of lunar months to Gregorian months
        switch lunarMonth {
        case .chaitra: return 4       // March-April
        case .vaishakha: return 5     // April-May
        case .jyeshtha: return 6      // May-June
        case .ashadha: return 7       // June-July
        case .shravana: return 8      // July-August
        case .bhadrapada: return 9    // August-September
        case .ashwin: return 10       // September-October
        case .kartik: return 11       // October-November
        case .margashirsha: return 12 // November-December
        case .pausha: return 1        // December-January
        case .magha: return 2         // January-February
        case .phalguna: return 3      // February-March
        }
    }

    private func tithiToApproximateDay(_ tithi: String?, paksha: Paksha?) -> Int {
        guard let tithi = tithi else { return 15 }

        let baseDay: Int
        switch tithi {
        case "Pratipada": baseDay = 1
        case "Dwitiya": baseDay = 2
        case "Tritiya": baseDay = 3
        case "Chaturthi": baseDay = 4
        case "Panchami": baseDay = 5
        case "Shashthi": baseDay = 6
        case "Saptami": baseDay = 7
        case "Ashtami": baseDay = 8
        case "Navami": baseDay = 9
        case "Dashami": baseDay = 10
        case "Ekadashi": baseDay = 11
        case "Dwadashi": baseDay = 12
        case "Trayodashi": baseDay = 13
        case "Chaturdashi": baseDay = 14
        case "Purnima": baseDay = 15
        case "Amavasya": baseDay = 30
        default: baseDay = 15
        }

        // Adjust for paksha
        if paksha == .krishna {
            return min(baseDay + 15, 30)
        }

        return baseDay
    }
}
