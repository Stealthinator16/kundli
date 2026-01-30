import Foundation

/// Service for calculating Ashtottari Dasha (108-year cycle)
/// Ashtottari Dasha is applicable when Rahu is in Kendra or Trikona from Lagna Lord
final class AshtottariDashaService {
    static let shared = AshtottariDashaService()

    private let nakshatraService = NakshatraService.shared
    private let houseService = HouseCalculationService.shared

    private init() {}

    // MARK: - Planet Sequence

    struct AshtottariPlanetInfo {
        let planet: VedicPlanet
        let years: Int
        let startingNakshatras: [Nakshatra]

        var totalDays: Double {
            Double(years) * 365.25
        }
    }

    /// Ashtottari sequence (total 108 years)
    let planetSequence: [AshtottariPlanetInfo] = [
        AshtottariPlanetInfo(
            planet: .sun,
            years: 6,
            startingNakshatras: [.punarvasu, .uttarabhadrapada]
        ),
        AshtottariPlanetInfo(
            planet: .moon,
            years: 15,
            startingNakshatras: [.pushya, .revati]
        ),
        AshtottariPlanetInfo(
            planet: .mars,
            years: 8,
            startingNakshatras: [.ashlesha]
        ),
        AshtottariPlanetInfo(
            planet: .mercury,
            years: 17,
            startingNakshatras: [.magha, .ashwini]
        ),
        AshtottariPlanetInfo(
            planet: .saturn,
            years: 10,
            startingNakshatras: [.purvaphalguni, .bharani]
        ),
        AshtottariPlanetInfo(
            planet: .jupiter,
            years: 19,
            startingNakshatras: [.uttaraphalguni, .krittika]
        ),
        AshtottariPlanetInfo(
            planet: .rahu,
            years: 12,
            startingNakshatras: [.hasta, .rohini]
        ),
        AshtottariPlanetInfo(
            planet: .venus,
            years: 21,
            startingNakshatras: [.chitra, .mrigashira]
        )
    ]

    /// Total cycle is 108 years
    var totalCycleYears: Int {
        planetSequence.reduce(0) { $0 + $1.years }
    }

    // MARK: - Applicability Check

    /// Check if Ashtottari Dasha is applicable for a chart
    /// Applicable when: Rahu in Kendra (1,4,7,10) or Trikona (5,9) from Lagna Lord
    func isAshtottariApplicable(
        planets: [VedicPlanetPosition],
        houses: HouseCalculationResult
    ) -> Bool {
        guard let rahu = planets.first(where: { $0.planet == .rahu }) else {
            return false
        }

        // Get Lagna lord
        let lagnaSign = houses.ascendant.sign
        guard let lagnaLord = VedicPlanet.allCases.first(where: { $0.owns(sign: lagnaSign) }) else {
            return false
        }

        guard let lagnaLordPosition = planets.first(where: { $0.planet == lagnaLord }) else {
            return false
        }

        // Calculate house of Rahu from Lagna Lord
        let rahuFromLagnaLord = (rahu.signIndex - lagnaLordPosition.signIndex + 12) % 12 + 1

        // Check if Rahu is in Kendra or Trikona from Lagna Lord
        let kendraHouses = [1, 4, 7, 10]
        let trikonaHouses = [1, 5, 9]

        return kendraHouses.contains(rahuFromLagnaLord) || trikonaHouses.contains(rahuFromLagnaLord)
    }

    // MARK: - Main Calculation

    /// Calculate Ashtottari Dasha periods
    func calculateAshtottariDasha(
        moonLongitude: Double,
        birthDate: Date
    ) -> [DashaPeriod] {
        // Get nakshatra info
        let nakshatraInfo = nakshatraService.nakshatra(fromSiderealLongitude: moonLongitude)
        let birthNakshatra = nakshatraInfo.nakshatra

        // Find starting planet based on nakshatra
        let startingPlanet = mapNakshatraToStartingPlanet(birthNakshatra)

        // Calculate dasha balance at birth
        let dashaBalance = calculateDashaBalance(
            nakshatraDegree: nakshatraInfo.degreeInNakshatra,
            planetInfo: startingPlanet
        )

        // Generate dasha periods
        return generateDashaPeriods(
            startingPlanet: startingPlanet,
            dashaBalance: dashaBalance,
            birthDate: birthDate
        )
    }

    // MARK: - Nakshatra to Planet Mapping

    /// Map nakshatra to starting Ashtottari planet
    func mapNakshatraToStartingPlanet(_ nakshatra: Nakshatra) -> AshtottariPlanetInfo {
        // Ashtottari uses 28 nakshatras (including Abhijit)
        // Mapping based on traditional rules
        let nakshatraIndex = Nakshatra.allCases.firstIndex(of: nakshatra) ?? 0

        // Group nakshatras into 8 groups (3-4 each)
        // This is a simplified mapping
        let planetIndex = nakshatraIndex % 8
        return planetSequence[planetIndex]
    }

    /// Get precise starting planet from nakshatra (traditional method)
    private func getStartingPlanetFromNakshatra(_ nakshatra: Nakshatra) -> AshtottariPlanetInfo {
        // Check each planet's starting nakshatras
        for planetInfo in planetSequence {
            if planetInfo.startingNakshatras.contains(nakshatra) {
                return planetInfo
            }
        }

        // Fallback to modulo method
        return mapNakshatraToStartingPlanet(nakshatra)
    }

    // MARK: - Dasha Balance Calculation

    /// Calculate remaining dasha balance at birth
    func calculateDashaBalance(nakshatraDegree: Double, planetInfo: AshtottariPlanetInfo) -> Double {
        let nakshatraDegrees = NakshatraService.nakshatraDegrees
        let percentageRemaining = (nakshatraDegrees - nakshatraDegree) / nakshatraDegrees
        return Double(planetInfo.years) * percentageRemaining
    }

    // MARK: - Generate Dasha Periods

    /// Generate all Mahadasha periods
    private func generateDashaPeriods(
        startingPlanet: AshtottariPlanetInfo,
        dashaBalance: Double,
        birthDate: Date
    ) -> [DashaPeriod] {
        var periods: [DashaPeriod] = []
        let calendar = Calendar.current
        var currentDate = birthDate
        let now = Date()

        // Find starting index
        guard let startIndex = planetSequence.firstIndex(where: { $0.planet == startingPlanet.planet }) else {
            return []
        }

        // First period - balance period
        let balanceDays = dashaBalance * 365.25
        let firstEndDate = calendar.date(byAdding: .day, value: Int(balanceDays), to: currentDate) ?? currentDate

        let firstPeriod = DashaPeriod(
            planet: startingPlanet.planet.rawValue,
            vedName: startingPlanet.planet.vedName,
            startDate: currentDate,
            endDate: firstEndDate,
            isActive: now >= currentDate && now < firstEndDate,
            subPeriods: generateAntarDashas(
                mahadashaPlanet: startingPlanet,
                startDate: currentDate,
                endDate: firstEndDate
            )
        )
        periods.append(firstPeriod)
        currentDate = firstEndDate

        // Generate subsequent full periods
        var currentIndex = (startIndex + 1) % planetSequence.count
        let maxPeriods = 24  // Generate enough periods for 100+ years

        for _ in 0..<maxPeriods {
            let planetInfo = planetSequence[currentIndex]
            let periodDays = Double(planetInfo.years) * 365.25
            let endDate = calendar.date(byAdding: .day, value: Int(periodDays), to: currentDate) ?? currentDate

            let period = DashaPeriod(
                planet: planetInfo.planet.rawValue,
                vedName: planetInfo.planet.vedName,
                startDate: currentDate,
                endDate: endDate,
                isActive: now >= currentDate && now < endDate,
                subPeriods: generateAntarDashas(
                    mahadashaPlanet: planetInfo,
                    startDate: currentDate,
                    endDate: endDate
                )
            )
            periods.append(period)

            currentDate = endDate
            currentIndex = (currentIndex + 1) % planetSequence.count
        }

        return periods
    }

    // MARK: - Antar Dasha Generation

    /// Generate Antar Dasha (sub-periods) for an Ashtottari Mahadasha
    private func generateAntarDashas(
        mahadashaPlanet: AshtottariPlanetInfo,
        startDate: Date,
        endDate: Date
    ) -> [AntarDasha] {
        var antarDashas: [AntarDasha] = []
        let calendar = Calendar.current
        let now = Date()

        // Total days in mahadasha
        let totalDays = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        let totalAshtottariYears = Double(totalCycleYears)

        var currentDate = startDate

        // Find starting index for antar dasha (same as mahadasha planet)
        guard let startIndex = planetSequence.firstIndex(where: { $0.planet == mahadashaPlanet.planet }) else {
            return []
        }

        // Generate antar dashas in Ashtottari sequence starting from mahadasha lord
        for i in 0..<planetSequence.count {
            let planetInfo = planetSequence[(startIndex + i) % planetSequence.count]

            // Proportion of time = (planet years / total cycle years) * mahadasha days
            let proportion = Double(planetInfo.years) / totalAshtottariYears
            let antarDays = Double(totalDays) * proportion

            let antarEndDate = calendar.date(byAdding: .day, value: Int(antarDays), to: currentDate) ?? currentDate

            let antarDasha = AntarDasha(
                planet: planetInfo.planet.rawValue,
                vedName: planetInfo.planet.vedName,
                startDate: currentDate,
                endDate: antarEndDate,
                isActive: now >= currentDate && now < antarEndDate,
                pratyantarDashas: []  // Pratyantara calculation similar
            )
            antarDashas.append(antarDasha)

            currentDate = antarEndDate
        }

        return antarDashas
    }

    // MARK: - Current Dasha

    /// Get current Ashtottari Mahadasha
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
