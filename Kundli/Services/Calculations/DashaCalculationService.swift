import Foundation

/// Service for calculating Vimshottari Dasha periods
/// Vimshottari Dasha is a 120-year cycle based on Moon's nakshatra at birth
final class DashaCalculationService {
    static let shared = DashaCalculationService()

    private let nakshatraService = NakshatraService.shared

    /// Total years in Vimshottari Dasha cycle
    static let totalDashaCycle: Double = 120.0

    private init() {}

    // MARK: - Main Dasha Calculation

    /// Calculate complete Vimshottari Dasha periods from Moon's position at birth
    func calculateDashaPeriods(
        moonLongitude: Double,
        birthDate: Date
    ) -> [DashaPeriod] {
        // Get the starting dasha planet and balance from Moon's nakshatra
        let (startingPlanet, remainingYears) = nakshatraService.dashaBalanceAtBirth(moonLongitude: moonLongitude)

        var periods: [DashaPeriod] = []
        var currentDate = birthDate
        var currentPlanet = startingPlanet
        var isFirstDasha = true

        // Generate dashas for a reasonable timespan (up to 120+ years from birth)
        let endDate = Calendar.current.date(byAdding: .year, value: 130, to: birthDate) ?? birthDate

        while currentDate < endDate {
            let yearsForThisDasha: Double
            if isFirstDasha {
                yearsForThisDasha = remainingYears
                isFirstDasha = false
            } else {
                yearsForThisDasha = Double(currentPlanet.dashaYears)
            }

            let dashaEndDate = addYears(yearsForThisDasha, to: currentDate)
            let now = Date()
            let isActive = now >= currentDate && now < dashaEndDate

            // Calculate Antar Dashas for this Maha Dasha
            let antarDashas = calculateAntarDashas(
                mahaDashaPlanet: currentPlanet,
                startDate: currentDate,
                endDate: dashaEndDate
            )

            let period = DashaPeriod(
                planet: currentPlanet.rawValue,
                vedName: currentPlanet.vedName,
                startDate: currentDate,
                endDate: dashaEndDate,
                isActive: isActive,
                subPeriods: antarDashas
            )
            periods.append(period)

            currentDate = dashaEndDate
            currentPlanet = currentPlanet.nextInVimshottari
        }

        return periods
    }

    /// Calculate from birth details
    func calculateDashaPeriods(
        from birthDetails: BirthDetails,
        moonPosition: VedicPlanetPosition
    ) -> [DashaPeriod] {
        // Combine date and time
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: birthDetails.dateOfBirth)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: birthDetails.timeOfBirth)

        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        combined.second = timeComponents.second
        combined.timeZone = TimeZone(identifier: birthDetails.timezone)

        guard let birthDateTime = calendar.date(from: combined) else {
            return []
        }

        return calculateDashaPeriods(
            moonLongitude: moonPosition.longitude,
            birthDate: birthDateTime
        )
    }

    // MARK: - Antar Dasha (Sub-period) Calculation

    /// Calculate Antar Dashas within a Maha Dasha
    func calculateAntarDashas(
        mahaDashaPlanet: VedicPlanet,
        startDate: Date,
        endDate: Date
    ) -> [AntarDasha] {
        var antarDashas: [AntarDasha] = []
        let mahaDashaYears = Double(mahaDashaPlanet.dashaYears)
        var currentDate = startDate
        var currentPlanet = mahaDashaPlanet  // Antar Dasha starts with Maha Dasha lord

        let sequence = VedicPlanet.vimshottariSequence
        guard let startIndex = sequence.firstIndex(of: mahaDashaPlanet) else {
            return []
        }

        for i in 0..<9 {
            let planetIndex = (startIndex + i) % 9
            currentPlanet = sequence[planetIndex]

            // Antar Dasha duration = (Maha Dasha years × Antar Dasha planet years) / 120
            let antarYears = (mahaDashaYears * Double(currentPlanet.dashaYears)) / 120.0
            let antarEndDate = addYears(antarYears, to: currentDate)

            let now = Date()
            let isActive = now >= currentDate && now < antarEndDate

            let antarDasha = AntarDasha(
                planet: currentPlanet.rawValue,
                vedName: currentPlanet.vedName,
                startDate: currentDate,
                endDate: antarEndDate,
                isActive: isActive
            )
            antarDashas.append(antarDasha)

            currentDate = antarEndDate
        }

        return antarDashas
    }

    // MARK: - Pratyantar Dasha (Sub-sub-period) Calculation

    /// Calculate Pratyantar Dashas within an Antar Dasha
    func calculatePratyantarDashas(
        mahaDashaPlanet: VedicPlanet,
        antarDashaPlanet: VedicPlanet,
        startDate: Date,
        endDate: Date
    ) -> [PratyantarDasha] {
        var pratyantarDashas: [PratyantarDasha] = []
        let mahaDashaYears = Double(mahaDashaPlanet.dashaYears)
        let antarDashaYears = Double(antarDashaPlanet.dashaYears)
        var currentDate = startDate

        let sequence = VedicPlanet.vimshottariSequence
        guard let startIndex = sequence.firstIndex(of: antarDashaPlanet) else {
            return []
        }

        for i in 0..<9 {
            let planetIndex = (startIndex + i) % 9
            let pratyantarPlanet = sequence[planetIndex]

            // Pratyantar Dasha duration = (Maha × Antar × Pratyantar) / (120 × 120)
            let pratyantarYears = (mahaDashaYears * antarDashaYears * Double(pratyantarPlanet.dashaYears)) / 14400.0
            let pratyantarEndDate = addYears(pratyantarYears, to: currentDate)

            let now = Date()
            let isActive = now >= currentDate && now < pratyantarEndDate

            let pratyantarDasha = PratyantarDasha(
                planet: pratyantarPlanet.rawValue,
                vedName: pratyantarPlanet.vedName,
                startDate: currentDate,
                endDate: pratyantarEndDate,
                isActive: isActive
            )
            pratyantarDashas.append(pratyantarDasha)

            currentDate = pratyantarEndDate
        }

        return pratyantarDashas
    }

    // MARK: - Current Dasha Query

    /// Get the current active Maha Dasha, Antar Dasha, and Pratyantar Dasha
    func currentDasha(from periods: [DashaPeriod]) -> CurrentDashaInfo? {
        let now = Date()

        guard let activeMaha = periods.first(where: { $0.isActive }) else {
            return nil
        }

        guard let activeAntar = activeMaha.subPeriods.first(where: { $0.isActive }) else {
            return CurrentDashaInfo(
                mahaDasha: activeMaha.planet,
                antarDasha: nil,
                pratyantarDasha: nil
            )
        }

        // Calculate Pratyantar for current Antar
        guard let mahaPlanet = VedicPlanet.from(nakshatraLord: activeMaha.planet),
              let antarPlanet = VedicPlanet.from(nakshatraLord: activeAntar.planet) else {
            return CurrentDashaInfo(
                mahaDasha: activeMaha.planet,
                antarDasha: activeAntar.planet,
                pratyantarDasha: nil
            )
        }

        let pratyantars = calculatePratyantarDashas(
            mahaDashaPlanet: mahaPlanet,
            antarDashaPlanet: antarPlanet,
            startDate: activeAntar.startDate,
            endDate: activeAntar.endDate
        )

        let activePratyantar = pratyantars.first { now >= $0.startDate && now < $0.endDate }

        return CurrentDashaInfo(
            mahaDasha: activeMaha.planet,
            antarDasha: activeAntar.planet,
            pratyantarDasha: activePratyantar?.planet
        )
    }

    // MARK: - Helpers

    /// Add fractional years to a date
    private func addYears(_ years: Double, to date: Date) -> Date {
        let calendar = Calendar.current
        let days = Int(years * 365.25)
        return calendar.date(byAdding: .day, value: days, to: date) ?? date
    }

    /// Calculate dasha balance percentage at a given date
    func dashaBalance(for period: DashaPeriod, at date: Date) -> Double {
        let totalSeconds = period.endDate.timeIntervalSince(period.startDate)
        let elapsedSeconds = date.timeIntervalSince(period.startDate)

        guard totalSeconds > 0 else { return 0 }

        let remaining = 1.0 - (elapsedSeconds / totalSeconds)
        return max(0, min(1, remaining)) * 100
    }
}

// MARK: - Supporting Types

/// Current dasha information
struct CurrentDashaInfo {
    let mahaDasha: String
    let antarDasha: String?
    let pratyantarDasha: String?

    var formatted: String {
        var result = mahaDasha
        if let antar = antarDasha {
            result += " / \(antar)"
        }
        if let pratyantar = pratyantarDasha {
            result += " / \(pratyantar)"
        }
        return result
    }
}

// MARK: - Vimshottari Dasha Reference

/*
 Vimshottari Dasha System (120-year cycle):

 | Planet  | Years | Nakshatra Lords                      |
 |---------|-------|--------------------------------------|
 | Ketu    | 7     | Ashwini, Magha, Mula                 |
 | Venus   | 20    | Bharani, P.Phalguni, P.Ashadha       |
 | Sun     | 6     | Krittika, U.Phalguni, U.Ashadha      |
 | Moon    | 10    | Rohini, Hasta, Shravana              |
 | Mars    | 7     | Mrigashira, Chitra, Dhanishta        |
 | Rahu    | 18    | Ardra, Swati, Shatabhisha            |
 | Jupiter | 16    | Punarvasu, Vishakha, P.Bhadrapada    |
 | Saturn  | 19    | Pushya, Anuradha, U.Bhadrapada       |
 | Mercury | 17    | Ashlesha, Jyeshtha, Revati           |
 | Total   | 120   |                                      |

 Algorithm for Dasha Balance at Birth:
 1. Find Moon's nakshatra and pada at birth time
 2. The nakshatra lord becomes the starting Maha Dasha
 3. Calculate remaining percentage of nakshatra traversed
 4. Dasha balance = (remaining %) × (total dasha years)
 5. Subsequent dashas follow the fixed sequence above
*/
