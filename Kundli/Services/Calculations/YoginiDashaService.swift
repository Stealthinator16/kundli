import Foundation

/// Service for calculating Yogini Dasha (36-year cycle)
/// Yogini Dasha is based on 8 Yoginis, each associated with a planet
final class YoginiDashaService {
    static let shared = YoginiDashaService()

    private let nakshatraService = NakshatraService.shared

    private init() {}

    // MARK: - Yogini Information

    struct YoginiInfo {
        let name: String
        let planet: VedicPlanet
        let years: Int
        let nakshatras: [Nakshatra]

        var totalDays: Double {
            Double(years) * 365.25
        }
    }

    /// The 8 Yoginis in sequence (total 36 years)
    let yoginiSequence: [YoginiInfo] = [
        YoginiInfo(
            name: "Mangala",
            planet: .moon,
            years: 1,
            nakshatras: [.ashwini, .magha, .mula]
        ),
        YoginiInfo(
            name: "Pingala",
            planet: .sun,
            years: 2,
            nakshatras: [.bharani, .purvaphalguni, .purvaashadha]
        ),
        YoginiInfo(
            name: "Dhanya",
            planet: .jupiter,
            years: 3,
            nakshatras: [.krittika, .uttaraphalguni, .uttaraashadha]
        ),
        YoginiInfo(
            name: "Bhramari",
            planet: .mars,
            years: 4,
            nakshatras: [.rohini, .hasta, .shravana]
        ),
        YoginiInfo(
            name: "Bhadrika",
            planet: .mercury,
            years: 5,
            nakshatras: [.mrigashira, .chitra, .dhanishta]
        ),
        YoginiInfo(
            name: "Ulka",
            planet: .saturn,
            years: 6,
            nakshatras: [.ardra, .swati, .shatabhisha]
        ),
        YoginiInfo(
            name: "Siddha",
            planet: .venus,
            years: 7,
            nakshatras: [.punarvasu, .vishakha, .purvabhadrapada]
        ),
        YoginiInfo(
            name: "Sankata",
            planet: .rahu,
            years: 8,
            nakshatras: [.pushya, .anuradha, .uttarabhadrapada]
        )
    ]

    // MARK: - Total Cycle Length

    /// Total Yogini Dasha cycle is 36 years
    var totalCycleYears: Int {
        yoginiSequence.reduce(0) { $0 + $1.years }
    }

    // MARK: - Main Calculation

    /// Calculate Yogini Dasha periods from birth details
    func calculateYoginiDasha(
        moonLongitude: Double,
        birthDate: Date
    ) -> [DashaPeriod] {
        // Get nakshatra info
        let nakshatraInfo = nakshatraService.nakshatra(fromSiderealLongitude: moonLongitude)
        let birthNakshatra = nakshatraInfo.nakshatra

        // Find starting Yogini based on nakshatra
        guard let startingYogini = findYoginiFromNakshatra(birthNakshatra) else {
            return []
        }

        // Calculate dasha balance at birth
        let dashaBalance = calculateDashaBalance(
            nakshatraDegree: nakshatraInfo.degreeInNakshatra,
            yogini: startingYogini
        )

        // Generate dasha periods
        return generateDashaPeriods(
            startingYogini: startingYogini,
            dashaBalance: dashaBalance,
            birthDate: birthDate
        )
    }

    // MARK: - Find Yogini from Nakshatra

    /// Find which Yogini rules the given nakshatra
    func findYoginiFromNakshatra(_ nakshatra: Nakshatra) -> YoginiInfo? {
        yoginiSequence.first { yogini in
            yogini.nakshatras.contains(nakshatra)
        }
    }

    // MARK: - Dasha Balance Calculation

    /// Calculate remaining dasha balance at birth based on position in nakshatra
    func calculateDashaBalance(nakshatraDegree: Double, yogini: YoginiInfo) -> Double {
        // Each nakshatra is 13.333... degrees
        let nakshatraDegrees = NakshatraService.nakshatraDegrees
        let percentageRemaining = (nakshatraDegrees - nakshatraDegree) / nakshatraDegrees
        return Double(yogini.years) * percentageRemaining
    }

    // MARK: - Generate Dasha Periods

    /// Generate all Mahadasha periods for Yogini Dasha
    private func generateDashaPeriods(
        startingYogini: YoginiInfo,
        dashaBalance: Double,
        birthDate: Date
    ) -> [DashaPeriod] {
        var periods: [DashaPeriod] = []
        let calendar = Calendar.current
        var currentDate = birthDate
        let now = Date()

        // Find starting index
        guard let startIndex = yoginiSequence.firstIndex(where: { $0.name == startingYogini.name }) else {
            return []
        }

        // First period - balance period
        let balanceDays = dashaBalance * 365.25
        let firstEndDate = calendar.date(byAdding: .day, value: Int(balanceDays), to: currentDate) ?? currentDate

        let firstPeriod = DashaPeriod(
            planet: startingYogini.planet.rawValue,
            vedName: "\(startingYogini.name) (\(startingYogini.planet.vedName))",
            startDate: currentDate,
            endDate: firstEndDate,
            isActive: now >= currentDate && now < firstEndDate,
            subPeriods: generateAntarDashas(
                mahadashaPlanet: startingYogini,
                startDate: currentDate,
                endDate: firstEndDate
            )
        )
        periods.append(firstPeriod)
        currentDate = firstEndDate

        // Generate subsequent full periods (multiple cycles if needed)
        var currentIndex = (startIndex + 1) % yoginiSequence.count
        let maxPeriods = 36  // Generate enough periods for 100+ years

        for _ in 0..<maxPeriods {
            let yogini = yoginiSequence[currentIndex]
            let periodDays = Double(yogini.years) * 365.25
            let endDate = calendar.date(byAdding: .day, value: Int(periodDays), to: currentDate) ?? currentDate

            let period = DashaPeriod(
                planet: yogini.planet.rawValue,
                vedName: "\(yogini.name) (\(yogini.planet.vedName))",
                startDate: currentDate,
                endDate: endDate,
                isActive: now >= currentDate && now < endDate,
                subPeriods: generateAntarDashas(
                    mahadashaPlanet: yogini,
                    startDate: currentDate,
                    endDate: endDate
                )
            )
            periods.append(period)

            currentDate = endDate
            currentIndex = (currentIndex + 1) % yoginiSequence.count
        }

        return periods
    }

    // MARK: - Antar Dasha Generation

    /// Generate Antar Dasha (sub-periods) for a Yogini Mahadasha
    private func generateAntarDashas(
        mahadashaPlanet: YoginiInfo,
        startDate: Date,
        endDate: Date
    ) -> [AntarDasha] {
        var antarDashas: [AntarDasha] = []
        let calendar = Calendar.current
        let now = Date()

        // Total days in mahadasha
        let totalDays = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        let totalYoginiYears = Double(totalCycleYears)

        var currentDate = startDate

        // Find starting index for antar dasha (same as mahadasha planet)
        guard let startIndex = yoginiSequence.firstIndex(where: { $0.name == mahadashaPlanet.name }) else {
            return []
        }

        // Generate antar dashas in Yogini sequence starting from mahadasha lord
        for i in 0..<yoginiSequence.count {
            let yogini = yoginiSequence[(startIndex + i) % yoginiSequence.count]

            // Proportion of time = (yogini years / total cycle years) * mahadasha days
            let proportion = Double(yogini.years) / totalYoginiYears
            let antarDays = Double(totalDays) * proportion

            let antarEndDate = calendar.date(byAdding: .day, value: Int(antarDays), to: currentDate) ?? currentDate

            let antarDasha = AntarDasha(
                planet: yogini.planet.rawValue,
                vedName: "\(yogini.name) (\(yogini.planet.vedName))",
                startDate: currentDate,
                endDate: antarEndDate,
                isActive: now >= currentDate && now < antarEndDate,
                pratyantarDashas: []  // Yogini doesn't traditionally have pratyantara
            )
            antarDashas.append(antarDasha)

            currentDate = antarEndDate
        }

        return antarDashas
    }

    // MARK: - Current Dasha

    /// Get current Yogini Mahadasha
    func getCurrentMahadasha(periods: [DashaPeriod]) -> DashaPeriod? {
        periods.first { $0.isActive }
    }

    /// Get current Antar Dasha
    func getCurrentAntarDasha(periods: [DashaPeriod]) -> AntarDasha? {
        guard let mahadasha = getCurrentMahadasha(periods: periods) else {
            return nil
        }
        return mahadasha.subPeriods.first { $0.isActive }
    }
}
