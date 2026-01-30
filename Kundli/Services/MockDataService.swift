import Foundation

class MockDataService {
    static let shared = MockDataService()

    private init() {}

    // MARK: - Sample Cities
    let cities: [City] = [
        City(name: "Mumbai", state: "Maharashtra", country: "India", latitude: 19.0760, longitude: 72.8777, timezone: "IST"),
        City(name: "Delhi", state: "Delhi", country: "India", latitude: 28.6139, longitude: 77.2090, timezone: "IST"),
        City(name: "Bangalore", state: "Karnataka", country: "India", latitude: 12.9716, longitude: 77.5946, timezone: "IST"),
        City(name: "Chennai", state: "Tamil Nadu", country: "India", latitude: 13.0827, longitude: 80.2707, timezone: "IST"),
        City(name: "Kolkata", state: "West Bengal", country: "India", latitude: 22.5726, longitude: 88.3639, timezone: "IST"),
        City(name: "Hyderabad", state: "Telangana", country: "India", latitude: 17.3850, longitude: 78.4867, timezone: "IST"),
        City(name: "Pune", state: "Maharashtra", country: "India", latitude: 18.5204, longitude: 73.8567, timezone: "IST"),
        City(name: "Ahmedabad", state: "Gujarat", country: "India", latitude: 23.0225, longitude: 72.5714, timezone: "IST"),
        City(name: "Jaipur", state: "Rajasthan", country: "India", latitude: 26.9124, longitude: 75.7873, timezone: "IST"),
        City(name: "Lucknow", state: "Uttar Pradesh", country: "India", latitude: 26.8467, longitude: 80.9462, timezone: "IST"),
        City(name: "Varanasi", state: "Uttar Pradesh", country: "India", latitude: 25.3176, longitude: 82.9739, timezone: "IST"),
        City(name: "Surat", state: "Gujarat", country: "India", latitude: 21.1702, longitude: 72.8311, timezone: "IST"),
    ]

    func searchCities(query: String) -> [City] {
        guard !query.isEmpty else { return cities }
        return cities.filter {
            $0.name.lowercased().contains(query.lowercased()) ||
            $0.state.lowercased().contains(query.lowercased())
        }
    }

    // MARK: - Sample Birth Details
    func sampleBirthDetails() -> BirthDetails {
        let calendar = Calendar.current
        var dobComponents = DateComponents()
        dobComponents.year = 1988
        dobComponents.month = 10
        dobComponents.day = 24

        var timeComponents = DateComponents()
        timeComponents.hour = 8
        timeComponents.minute = 45

        return BirthDetails(
            name: "Arjun Sharma",
            dateOfBirth: calendar.date(from: dobComponents) ?? Date(),
            timeOfBirth: calendar.date(from: timeComponents) ?? Date(),
            birthCity: "Mumbai, Maharashtra, India",
            latitude: 19.0760,
            longitude: 72.8777,
            timezone: "IST",
            gender: .male
        )
    }

    // MARK: - Sample Planets
    func samplePlanets() -> [Planet] {
        [
            Planet(
                name: "Sun", vedName: "Surya",
                sign: "Libra", vedSign: "Tula",
                nakshatra: "Swati", nakshatraPada: 3,
                degree: 7, minutes: 23, seconds: 45,
                house: 12, status: .direct,
                symbol: "Su", lord: "Rahu"
            ),
            Planet(
                name: "Moon", vedName: "Chandra",
                sign: "Aries", vedSign: "Mesha",
                nakshatra: "Ashwini", nakshatraPada: 2,
                degree: 15, minutes: 42, seconds: 18,
                house: 6, status: .direct,
                symbol: "Mo", lord: "Ketu"
            ),
            Planet(
                name: "Mars", vedName: "Mangal",
                sign: "Aries", vedSign: "Mesha",
                nakshatra: "Bharani", nakshatraPada: 1,
                degree: 22, minutes: 15, seconds: 30,
                house: 6, status: .ownSign,
                symbol: "Ma", lord: "Venus"
            ),
            Planet(
                name: "Mercury", vedName: "Budha",
                sign: "Virgo", vedSign: "Kanya",
                nakshatra: "Hasta", nakshatraPada: 4,
                degree: 28, minutes: 55, seconds: 12,
                house: 11, status: .exalted,
                symbol: "Me", lord: "Moon"
            ),
            Planet(
                name: "Jupiter", vedName: "Guru",
                sign: "Taurus", vedSign: "Vrishabha",
                nakshatra: "Rohini", nakshatraPada: 2,
                degree: 12, minutes: 33, seconds: 28,
                house: 7, status: .direct,
                symbol: "Ju", lord: "Moon"
            ),
            Planet(
                name: "Venus", vedName: "Shukra",
                sign: "Scorpio", vedSign: "Vrishchika",
                nakshatra: "Anuradha", nakshatraPada: 3,
                degree: 18, minutes: 12, seconds: 45,
                house: 1, status: .debilitated,
                symbol: "Ve", lord: "Saturn"
            ),
            Planet(
                name: "Saturn", vedName: "Shani",
                sign: "Sagittarius", vedSign: "Dhanu",
                nakshatra: "Mula", nakshatraPada: 1,
                degree: 3, minutes: 48, seconds: 22,
                house: 2, status: .retrograde,
                symbol: "Sa", lord: "Ketu"
            ),
            Planet(
                name: "Rahu", vedName: "Rahu",
                sign: "Pisces", vedSign: "Meena",
                nakshatra: "Uttara Bhadrapada", nakshatraPada: 4,
                degree: 25, minutes: 18, seconds: 33,
                house: 5, status: .direct,
                symbol: "Ra", lord: "Saturn"
            ),
            Planet(
                name: "Ketu", vedName: "Ketu",
                sign: "Virgo", vedSign: "Kanya",
                nakshatra: "Chitra", nakshatraPada: 1,
                degree: 25, minutes: 18, seconds: 33,
                house: 11, status: .direct,
                symbol: "Ke", lord: "Mars"
            )
        ]
    }

    // MARK: - Sample Ascendant
    func sampleAscendant() -> Ascendant {
        Ascendant(
            sign: .scorpio,
            degree: 14,
            minutes: 28,
            seconds: 15,
            nakshatra: "Anuradha",
            nakshatraPada: 1,
            lord: "Mars"
        )
    }

    // MARK: - Sample Kundli
    func sampleKundli() -> Kundli {
        Kundli(
            birthDetails: sampleBirthDetails(),
            planets: samplePlanets(),
            ascendant: sampleAscendant()
        )
    }

    // MARK: - Sample Panchang
    func todayPanchang() -> Panchang {
        let calendar = Calendar.current
        let now = Date()

        var rahuStart = calendar.dateComponents([.year, .month, .day], from: now)
        rahuStart.hour = 10
        rahuStart.minute = 30

        var rahuEnd = calendar.dateComponents([.year, .month, .day], from: now)
        rahuEnd.hour = 12
        rahuEnd.minute = 0

        var sunrise = calendar.dateComponents([.year, .month, .day], from: now)
        sunrise.hour = 6
        sunrise.minute = 15

        var sunset = calendar.dateComponents([.year, .month, .day], from: now)
        sunset.hour = 18
        sunset.minute = 32

        return Panchang(
            date: now,
            tithi: Tithi(name: "Navami", paksha: .shukla, number: 9),
            nakshatra: "Rohini",
            yoga: "Siddhi",
            karana: "Balava",
            rahuKaalStart: calendar.date(from: rahuStart) ?? now,
            rahuKaalEnd: calendar.date(from: rahuEnd) ?? now,
            sunriseTime: calendar.date(from: sunrise) ?? now,
            sunsetTime: calendar.date(from: sunset) ?? now,
            moonPhase: .waxingGibbous
        )
    }

    // MARK: - Sample Dasha Periods
    func sampleDashaPeriods() -> [DashaPeriod] {
        let calendar = Calendar.current
        let now = Date()

        // Calculate dates for dasha periods
        func dateByAdding(years: Int, to date: Date) -> Date {
            calendar.date(byAdding: .year, value: years, to: date) ?? date
        }

        let marsStart = calendar.date(byAdding: .year, value: -3, to: now) ?? now
        let marsEnd = dateByAdding(years: 4, to: marsStart)

        let rahuStart = marsEnd
        let rahuEnd = dateByAdding(years: 18, to: rahuStart)

        let jupiterStart = rahuEnd
        let jupiterEnd = dateByAdding(years: 16, to: jupiterStart)

        let saturnStart = jupiterEnd
        let saturnEnd = dateByAdding(years: 19, to: saturnStart)

        return [
            DashaPeriod(
                planet: "Mars",
                vedName: "Mangal",
                startDate: marsStart,
                endDate: marsEnd,
                isActive: true,
                subPeriods: [
                    AntarDasha(planet: "Saturn", vedName: "Shani",
                               startDate: calendar.date(byAdding: .month, value: -6, to: now) ?? now,
                               endDate: calendar.date(byAdding: .month, value: 5, to: now) ?? now,
                               isActive: true),
                    AntarDasha(planet: "Mercury", vedName: "Budha",
                               startDate: calendar.date(byAdding: .month, value: 5, to: now) ?? now,
                               endDate: calendar.date(byAdding: .month, value: 17, to: now) ?? now)
                ]
            ),
            DashaPeriod(
                planet: "Rahu",
                vedName: "Rahu",
                startDate: rahuStart,
                endDate: rahuEnd
            ),
            DashaPeriod(
                planet: "Jupiter",
                vedName: "Guru",
                startDate: jupiterStart,
                endDate: jupiterEnd
            ),
            DashaPeriod(
                planet: "Saturn",
                vedName: "Shani",
                startDate: saturnStart,
                endDate: saturnEnd
            )
        ]
    }

    // MARK: - Daily Horoscope
    func dailyHoroscope(for sign: ZodiacSign) -> DailyHoroscope {
        DailyHoroscope(
            sign: sign,
            date: Date(),
            overallRating: 4,
            loveRating: 3,
            careerRating: 5,
            healthRating: 4,
            prediction: "Today brings positive energy for career growth. Your ruling planet is well-positioned, indicating success in professional matters. However, be cautious in financial decisions.",
            luckyNumber: 7,
            luckyColor: "Gold"
        )
    }
}

// MARK: - Daily Horoscope Model
struct DailyHoroscope {
    let sign: ZodiacSign
    let date: Date
    let overallRating: Int    // 1-5
    let loveRating: Int
    let careerRating: Int
    let healthRating: Int
    let prediction: String
    let luckyNumber: Int
    let luckyColor: String
}
