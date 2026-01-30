import Foundation

/// Service for calculating Chara Dasha (Jaimini System)
/// Chara Dasha is based on signs (rashis) rather than nakshatras
/// Each sign's dasha period depends on its lord's position
final class CharaDashaService {
    static let shared = CharaDashaService()

    private let houseService = HouseCalculationService.shared

    private init() {}

    // MARK: - Sign Types

    enum SignType: String {
        case movable = "Movable"    // Aries, Cancer, Libra, Capricorn
        case fixed = "Fixed"        // Taurus, Leo, Scorpio, Aquarius
        case dual = "Dual"          // Gemini, Virgo, Sagittarius, Pisces
    }

    /// Get sign type
    func getSignType(_ sign: ZodiacSign) -> SignType {
        switch sign {
        case .aries, .cancer, .libra, .capricorn:
            return .movable
        case .taurus, .leo, .scorpio, .aquarius:
            return .fixed
        case .gemini, .virgo, .sagittarius, .pisces:
            return .dual
        }
    }

    // MARK: - Main Calculation

    /// Calculate Chara Dasha periods
    func calculateCharaDasha(
        ascendantSign: ZodiacSign,
        planets: [VedicPlanetPosition]
    ) -> [DashaPeriod] {
        var periods: [DashaPeriod] = []
        let now = Date()
        var currentDate = Date()  // Should use birth date in real implementation

        // Get starting sign sequence based on ascendant
        let signSequence = getSignSequence(startSign: ascendantSign)

        for sign in signSequence {
            // Calculate years for this sign
            let years = calculateSignYears(sign: sign, planets: planets)
            let periodDays = Double(years) * 365.25

            let endDate = Calendar.current.date(byAdding: .day, value: Int(periodDays), to: currentDate) ?? currentDate

            let period = DashaPeriod(
                planet: sign.rawValue,  // Using sign name as "planet" for Chara
                vedName: sign.vedName,
                startDate: currentDate,
                endDate: endDate,
                isActive: now >= currentDate && now < endDate,
                subPeriods: generateAntarDashas(
                    mahadashSign: sign,
                    planets: planets,
                    startDate: currentDate,
                    endDate: endDate
                )
            )
            periods.append(period)

            currentDate = endDate
        }

        return periods
    }

    /// Calculate Chara Dasha from birth details
    func calculateCharaDasha(
        houses: HouseCalculationResult,
        planets: [VedicPlanetPosition],
        birthDate: Date
    ) -> [DashaPeriod] {
        var periods: [DashaPeriod] = []
        let now = Date()
        var currentDate = birthDate

        let ascendantSign = houses.ascendant.sign

        // Get starting sign sequence based on ascendant
        let signSequence = getSignSequence(startSign: ascendantSign)

        for sign in signSequence {
            // Calculate years for this sign
            let years = calculateSignYears(sign: sign, planets: planets)
            let periodDays = Double(years) * 365.25

            let endDate = Calendar.current.date(byAdding: .day, value: Int(periodDays), to: currentDate) ?? currentDate

            let period = DashaPeriod(
                planet: sign.rawValue,
                vedName: sign.vedName,
                startDate: currentDate,
                endDate: endDate,
                isActive: now >= currentDate && now < endDate,
                subPeriods: generateAntarDashas(
                    mahadashSign: sign,
                    planets: planets,
                    startDate: currentDate,
                    endDate: endDate
                )
            )
            periods.append(period)

            currentDate = endDate
        }

        return periods
    }

    // MARK: - Sign Years Calculation

    /// Calculate the number of years for a sign's Chara Dasha
    /// Based on the distance of sign lord from the sign
    func calculateSignYears(sign: ZodiacSign, planets: [VedicPlanetPosition]) -> Int {
        // Get sign lord
        guard let signLord = VedicPlanet.allCases.first(where: { $0.owns(sign: sign) }) else {
            return 1  // Default minimum
        }

        // Find lord's position
        guard let lordPosition = planets.first(where: { $0.planet == signLord }) else {
            return 1
        }

        // Calculate distance from sign to lord's position
        let signIndex = ZodiacSign.allCases.firstIndex(of: sign) ?? 0
        let lordSignIndex = lordPosition.signIndex

        // Distance calculation depends on sign type
        let signType = getSignType(sign)
        var distance: Int

        switch signType {
        case .movable:
            // Count from sign to lord's sign (forward)
            distance = (lordSignIndex - signIndex + 12) % 12
        case .fixed:
            // Count from lord's sign to sign (backward)
            distance = (signIndex - lordSignIndex + 12) % 12
        case .dual:
            // Take shorter of forward/backward
            let forward = (lordSignIndex - signIndex + 12) % 12
            let backward = (signIndex - lordSignIndex + 12) % 12
            distance = min(forward, backward)
        }

        // Add 1 (lord in own sign = 1 year, etc.)
        // Max is typically 12 years
        return max(1, min(distance + 1, 12))
    }

    // MARK: - Sign Sequence

    /// Get the sequence of signs for Chara Dasha
    /// Direction depends on whether ascendant is odd or even sign
    func getSignSequence(startSign: ZodiacSign) -> [ZodiacSign] {
        let allSigns = ZodiacSign.allCases
        guard let startIndex = allSigns.firstIndex(of: startSign) else {
            return allSigns
        }

        let signType = getSignType(startSign)
        var sequence: [ZodiacSign] = []

        // Direction based on sign type
        // Movable (Chara): forward
        // Fixed (Sthira): backward
        // Dual (Dwiswabhava): alternating

        switch signType {
        case .movable:
            // Forward direction
            for i in 0..<12 {
                sequence.append(allSigns[(startIndex + i) % 12])
            }
        case .fixed:
            // Backward direction
            for i in 0..<12 {
                sequence.append(allSigns[(startIndex - i + 12) % 12])
            }
        case .dual:
            // Alternate forward-backward pattern
            var forward = true
            var currentIndex = startIndex
            for _ in 0..<12 {
                sequence.append(allSigns[currentIndex])
                if forward {
                    currentIndex = (currentIndex + 1) % 12
                } else {
                    currentIndex = (currentIndex - 1 + 12) % 12
                }
                forward.toggle()
            }
        }

        return sequence
    }

    // MARK: - Antar Dasha Generation

    /// Generate Antar Dasha (sub-periods) for a Chara Mahadasha
    private func generateAntarDashas(
        mahadashSign: ZodiacSign,
        planets: [VedicPlanetPosition],
        startDate: Date,
        endDate: Date
    ) -> [AntarDasha] {
        var antarDashas: [AntarDasha] = []
        let calendar = Calendar.current
        let now = Date()

        // Total days in mahadasha
        let totalDays = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0

        var currentDate = startDate

        // Get sign sequence for antar dashas (starting from mahadasha sign)
        let signSequence = getSignSequence(startSign: mahadashSign)

        // Calculate total years for proportioning
        var totalYears = 0
        var signYears: [Int] = []
        for sign in signSequence {
            let years = calculateSignYears(sign: sign, planets: planets)
            signYears.append(years)
            totalYears += years
        }

        // Generate antar dashas
        for (index, sign) in signSequence.enumerated() {
            let proportion = Double(signYears[index]) / Double(totalYears)
            let antarDays = Int(Double(totalDays) * proportion)

            let antarEndDate = calendar.date(byAdding: .day, value: antarDays, to: currentDate) ?? currentDate

            let antarDasha = AntarDasha(
                planet: sign.rawValue,
                vedName: sign.vedName,
                startDate: currentDate,
                endDate: antarEndDate,
                isActive: now >= currentDate && now < antarEndDate,
                pratyantarDashas: []
            )
            antarDashas.append(antarDasha)

            currentDate = antarEndDate
        }

        return antarDashas
    }

    // MARK: - Current Dasha

    /// Get current Chara Mahadasha
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

    // MARK: - Jaimini Karakas (Optional Enhancement)

    /// Jaimini system uses different karaka (significator) scheme
    /// This calculates Atmakaraka (soul significator) - planet with highest degree
    func calculateAtmakaraka(planets: [VedicPlanetPosition]) -> VedicPlanet? {
        // Exclude Rahu and Ketu
        let eligiblePlanets = planets.filter { $0.planet != .rahu && $0.planet != .ketu }

        // Find planet with highest degree in its sign
        let atmakaraka = eligiblePlanets.max { $0.degreeInSign < $1.degreeInSign }

        return atmakaraka?.planet
    }

    /// Calculate all Jaimini Karakas
    func calculateKarakas(planets: [VedicPlanetPosition]) -> [String: VedicPlanet] {
        // Sort planets by degree (highest first), excluding Rahu/Ketu
        let eligiblePlanets = planets
            .filter { $0.planet != .rahu && $0.planet != .ketu }
            .sorted { $0.degreeInSign > $1.degreeInSign }

        var karakas: [String: VedicPlanet] = [:]

        let karakaNames = [
            "Atmakaraka",       // Soul
            "Amatyakaraka",     // Career
            "Bhratrukaraka",    // Siblings
            "Matrukaraka",      // Mother
            "Putrakaraka",      // Children
            "Gnatikaraka",      // Relatives
            "Darakaraka"        // Spouse
        ]

        for (index, name) in karakaNames.enumerated() {
            if index < eligiblePlanets.count {
                karakas[name] = eligiblePlanets[index].planet
            }
        }

        return karakas
    }
}
