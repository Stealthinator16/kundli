import Foundation

/// Service for calculating current planetary transits
final class TransitService {
    static let shared = TransitService()

    private let ephemeris = EphemerisService.shared
    private let nakshatraService = NakshatraService.shared

    private init() {}

    // MARK: - Current Transit Calculation

    /// Calculate current transit positions for all planets
    func calculateCurrentTransits(
        natalPositions: [VedicPlanetPosition],
        natalMoonSign: Int,
        ayanamsa: AyanamsaType = .lahiri
    ) -> TransitData {
        let now = Date()

        // Calculate current positions
        let transitPositions = calculateTransitPositions(date: now, ayanamsa: ayanamsa)

        // Find active transits over natal positions
        let activeTransits = findActiveTransits(
            transitPositions: transitPositions,
            natalPositions: natalPositions
        )

        // Calculate major transit periods
        let majorPeriods = calculateMajorTransitPeriods(
            transitPositions: transitPositions,
            natalMoonSign: natalMoonSign,
            currentDate: now
        )

        return TransitData(
            calculationDate: now,
            transitPositions: transitPositions,
            activeTransits: activeTransits,
            majorTransitPeriods: majorPeriods
        )
    }

    // MARK: - Transit Positions

    /// Calculate positions of all planets at a given date
    func calculateTransitPositions(date: Date, ayanamsa: AyanamsaType = .lahiri) -> [TransitPosition] {
        var positions: [TransitPosition] = []

        for planet in VedicPlanet.allCases {
            guard let position = ephemeris.siderealLongitude(planet: planet, date: date, ayanamsaType: ayanamsa) else {
                continue
            }

            let signIndex = position.signIndex
            let sign = ZodiacSign.allCases[signIndex]
            let nakshatraIndex = Int(position.longitude / 13.333333) % 27
            let nakshatra = Nakshatra.allCases[nakshatraIndex]
            let pada = Int((position.longitude.truncatingRemainder(dividingBy: 13.333333)) / 3.333333) + 1

            positions.append(TransitPosition(
                planet: planet.rawValue,
                vedName: planet.vedName,
                longitude: position.longitude,
                signIndex: signIndex,
                signName: sign.rawValue,
                degreeInSign: position.degreeInSign,
                nakshatra: nakshatra.rawValue,
                nakshatraPada: pada,
                isRetrograde: position.isRetrograde
            ))
        }

        return positions
    }

    // MARK: - Active Transit Detection

    /// Find all active transits over natal positions
    func findActiveTransits(
        transitPositions: [TransitPosition],
        natalPositions: [VedicPlanetPosition]
    ) -> [ActiveTransit] {
        var activeTransits: [ActiveTransit] = []

        // Focus on major planets for transits
        let majorTransitPlanets = ["Saturn", "Jupiter", "Mars", "Rahu", "Ketu"]

        for transitPos in transitPositions {
            guard majorTransitPlanets.contains(transitPos.planet) else { continue }

            for natalPos in natalPositions {
                // Check for aspects
                if let transit = checkTransitAspect(
                    transitPosition: transitPos,
                    natalPosition: natalPos
                ) {
                    activeTransits.append(transit)
                }
            }
        }

        return activeTransits.sorted { $0.orb < $1.orb }
    }

    private func checkTransitAspect(
        transitPosition: TransitPosition,
        natalPosition: VedicPlanetPosition
    ) -> ActiveTransit? {
        let natalLongitude = natalPosition.longitude

        // Check each aspect type
        for aspectType in TransitAspect.allCases {
            let targetLongitude = (transitPosition.longitude + aspectType.degrees).truncatingRemainder(dividingBy: 360)
            var orb = abs(targetLongitude - natalLongitude)
            if orb > 180 { orb = 360 - orb }

            if orb <= aspectType.orb {
                // Determine if applying or separating
                let isApplying = transitPosition.isRetrograde ?
                    (transitPosition.longitude > natalLongitude) :
                    (transitPosition.longitude < natalLongitude)

                let strength = determineTransitStrength(
                    transitPlanet: transitPosition.planet,
                    natalPlanet: natalPosition.planet.rawValue,
                    aspectType: aspectType,
                    orb: orb
                )

                let effects = generateTransitEffects(
                    transitPlanet: transitPosition.planet,
                    natalPlanet: natalPosition.planet.rawValue,
                    aspectType: aspectType
                )

                return ActiveTransit(
                    transitingPlanet: transitPosition.planet,
                    natalPlanet: natalPosition.planet.rawValue,
                    aspectType: aspectType,
                    orb: orb,
                    isApplying: isApplying,
                    strength: strength,
                    effects: effects
                )
            }
        }

        return nil
    }

    private func determineTransitStrength(
        transitPlanet: String,
        natalPlanet: String,
        aspectType: TransitAspect,
        orb: Double
    ) -> TransitStrength {
        // Closer orb = stronger transit
        if orb < 2 {
            return .strong
        } else if orb < 5 {
            return .moderate
        } else {
            return .weak
        }
    }

    private func generateTransitEffects(
        transitPlanet: String,
        natalPlanet: String,
        aspectType: TransitAspect
    ) -> String {
        let nature = aspectType.nature

        switch (transitPlanet, natalPlanet, nature) {
        case ("Saturn", _, .challenging):
            return "Period of testing and restructuring. Patience and discipline needed."
        case ("Saturn", _, .harmonious):
            return "Building foundations and gaining stability through effort."
        case ("Jupiter", _, .harmonious):
            return "Expansion and opportunities in matters related to \(natalPlanet)."
        case ("Jupiter", _, .challenging):
            return "Growth through challenges, avoid overexpansion."
        case ("Mars", _, .challenging):
            return "Energy and potential conflict. Channel energy constructively."
        case ("Rahu", _, _):
            return "Unconventional experiences and desire for change."
        case ("Ketu", _, _):
            return "Spiritual insights and release of attachments."
        default:
            return "\(transitPlanet) influencing natal \(natalPlanet) matters."
        }
    }

    // MARK: - Major Transit Periods

    /// Calculate major ongoing transit periods
    func calculateMajorTransitPeriods(
        transitPositions: [TransitPosition],
        natalMoonSign: Int,
        currentDate: Date
    ) -> [MajorTransitPeriod] {
        var periods: [MajorTransitPeriod] = []

        // Check Saturn Sade-Sati
        if let saturnPos = transitPositions.first(where: { $0.planet == "Saturn" }) {
            if let sadeSati = checkSadeSati(
                saturnSignIndex: saturnPos.signIndex,
                natalMoonSign: natalMoonSign,
                currentDate: currentDate
            ) {
                periods.append(sadeSati)
            }
        }

        // Add other major transit periods
        // Jupiter Transit
        if let jupiterPos = transitPositions.first(where: { $0.planet == "Jupiter" }) {
            let jupiterPeriod = MajorTransitPeriod(
                type: .jupiterTransit,
                planet: "Jupiter",
                startDate: estimateTransitStart(signIndex: jupiterPos.signIndex, planet: .jupiter),
                endDate: estimateTransitEnd(signIndex: jupiterPos.signIndex, planet: .jupiter),
                houseNumber: (jupiterPos.signIndex - natalMoonSign + 12) % 12 + 1,
                signName: jupiterPos.signName,
                effects: "Jupiter brings expansion, wisdom and opportunities in \(jupiterPos.signName) matters."
            )
            periods.append(jupiterPeriod)
        }

        // Saturn Transit
        if let saturnPos = transitPositions.first(where: { $0.planet == "Saturn" }) {
            let saturnPeriod = MajorTransitPeriod(
                type: .saturnTransit,
                planet: "Saturn",
                startDate: estimateTransitStart(signIndex: saturnPos.signIndex, planet: .saturn),
                endDate: estimateTransitEnd(signIndex: saturnPos.signIndex, planet: .saturn),
                houseNumber: (saturnPos.signIndex - natalMoonSign + 12) % 12 + 1,
                signName: saturnPos.signName,
                effects: "Saturn brings lessons, structure and karmic tests in \(saturnPos.signName) matters."
            )
            periods.append(saturnPeriod)
        }

        // Rahu-Ketu Transit
        if let rahuPos = transitPositions.first(where: { $0.planet == "Rahu" }) {
            let rahuPeriod = MajorTransitPeriod(
                type: .rahuKetuTransit,
                planet: "Rahu-Ketu",
                startDate: estimateTransitStart(signIndex: rahuPos.signIndex, planet: .rahu),
                endDate: estimateTransitEnd(signIndex: rahuPos.signIndex, planet: .rahu),
                signName: rahuPos.signName,
                effects: "Rahu-Ketu axis brings destiny, desires and spiritual evolution."
            )
            periods.append(rahuPeriod)
        }

        return periods
    }

    private func checkSadeSati(
        saturnSignIndex: Int,
        natalMoonSign: Int,
        currentDate: Date
    ) -> MajorTransitPeriod? {
        // Sade-Sati: Saturn in 12th, 1st, or 2nd from Moon
        let houseFromMoon = (saturnSignIndex - natalMoonSign + 12) % 12

        let phase: SadeSatiPhase?
        switch houseFromMoon {
        case 11: // 12th from Moon (0-indexed 11)
            phase = .rising
        case 0:  // Over Moon
            phase = .peak
        case 1:  // 2nd from Moon
            phase = .setting
        default:
            phase = nil
        }

        guard let sadeSatiPhase = phase else { return nil }

        let signName = ZodiacSign.allCases[saturnSignIndex].rawValue

        return MajorTransitPeriod(
            type: .sadeSati,
            planet: "Saturn",
            startDate: estimateSadeSatiStart(phase: sadeSatiPhase, currentDate: currentDate),
            endDate: estimateSadeSatiEnd(phase: sadeSatiPhase, currentDate: currentDate),
            signName: signName,
            effects: sadeSatiPhase.description,
            sadeSatiPhase: sadeSatiPhase
        )
    }

    // MARK: - Transit Timeline

    /// Generate transit timeline for next 12 months
    func generateTransitTimeline(
        fromDate: Date,
        months: Int = 12,
        ayanamsa: AyanamsaType = .lahiri
    ) -> [TransitTimelineEvent] {
        var events: [TransitTimelineEvent] = []
        var currentDate = fromDate
        let calendar = Calendar.current

        // Sample positions monthly
        for _ in 0..<months {
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentDate) else {
                break
            }

            let currentPositions = calculateTransitPositions(date: currentDate, ayanamsa: ayanamsa)
            let nextPositions = calculateTransitPositions(date: nextMonth, ayanamsa: ayanamsa)

            // Check for sign changes
            for (current, next) in zip(currentPositions, nextPositions) {
                if current.signIndex != next.signIndex {
                    events.append(TransitTimelineEvent(
                        date: nextMonth,
                        planet: current.planet,
                        eventType: .signEntry,
                        fromSign: current.signName,
                        toSign: next.signName,
                        description: "\(current.planet) enters \(next.signName)"
                    ))
                }

                // Check retrograde changes
                if current.isRetrograde != next.isRetrograde {
                    let eventType: TransitEventType = next.isRetrograde ? .retrogradeStart : .retrogradeEnd
                    events.append(TransitTimelineEvent(
                        date: nextMonth,
                        planet: current.planet,
                        eventType: eventType,
                        fromSign: nil,
                        toSign: nil,
                        description: "\(current.planet) \(next.isRetrograde ? "turns retrograde" : "turns direct")"
                    ))
                }
            }

            currentDate = nextMonth
        }

        return events.sorted { $0.date < $1.date }
    }

    // MARK: - Helper Methods

    private func estimateTransitStart(signIndex: Int, planet: VedicPlanet) -> Date {
        // Simplified estimation - would need ephemeris for accuracy
        let calendar = Calendar.current
        let daysPerSign: Int
        switch planet {
        case .jupiter: daysPerSign = 365  // ~1 year per sign
        case .saturn: daysPerSign = 912   // ~2.5 years per sign
        case .rahu, .ketu: daysPerSign = 547  // ~1.5 years per sign
        default: daysPerSign = 30
        }

        // Estimate we're in the middle of the transit
        return calendar.date(byAdding: .day, value: -daysPerSign / 2, to: Date()) ?? Date()
    }

    private func estimateTransitEnd(signIndex: Int, planet: VedicPlanet) -> Date {
        let calendar = Calendar.current
        let daysPerSign: Int
        switch planet {
        case .jupiter: daysPerSign = 365
        case .saturn: daysPerSign = 912
        case .rahu, .ketu: daysPerSign = 547
        default: daysPerSign = 30
        }

        return calendar.date(byAdding: .day, value: daysPerSign / 2, to: Date()) ?? Date()
    }

    private func estimateSadeSatiStart(phase: SadeSatiPhase, currentDate: Date) -> Date {
        let calendar = Calendar.current
        switch phase {
        case .rising:
            return calendar.date(byAdding: .year, value: -1, to: currentDate) ?? currentDate
        case .peak:
            return calendar.date(byAdding: .month, value: -15, to: currentDate) ?? currentDate
        case .setting:
            return calendar.date(byAdding: .year, value: -5, to: currentDate) ?? currentDate
        }
    }

    private func estimateSadeSatiEnd(phase: SadeSatiPhase, currentDate: Date) -> Date {
        let calendar = Calendar.current
        switch phase {
        case .rising:
            return calendar.date(byAdding: .month, value: 15, to: currentDate) ?? currentDate
        case .peak:
            return calendar.date(byAdding: .month, value: 15, to: currentDate) ?? currentDate
        case .setting:
            return calendar.date(byAdding: .month, value: 15, to: currentDate) ?? currentDate
        }
    }
}

// MARK: - TransitAspect CaseIterable
extension TransitAspect: CaseIterable {
    static var allCases: [TransitAspect] = [
        .conjunction, .opposition, .trine, .square, .sextile
    ]
}

// MARK: - Retrograde Period
struct RetrogradePeriod: Identifiable {
    let id = UUID()
    let planet: VedicPlanet
    let startDate: Date
    let endDate: Date
    let stationaryRetrograde: Date  // Date planet appears to stop before going retrograde
    let stationaryDirect: Date      // Date planet appears to stop before going direct

    var isCurrentlyActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }

    var durationDays: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
}

// MARK: - Transit Prediction
struct TransitPrediction: Identifiable {
    let id = UUID()
    let planet: VedicPlanet
    let event: TransitEvent
    let date: Date
    let natalHouseAffected: Int
    let description: String
    let intensity: TransitIntensity
}

enum TransitEvent: String {
    case ingress = "Sign Ingress"
    case retrograde = "Retrograde"
    case direct = "Direct"
    case conjunctionNatal = "Natal Conjunction"
    case aspectNatal = "Natal Aspect"
}

enum TransitIntensity: String {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
}

// MARK: - Transit Service Extensions
extension TransitService {

    // MARK: - All Planets Transit

    /// Get transit positions for ALL planets including inner planets
    func calculateAllTransitPositions(date: Date, ayanamsa: AyanamsaType = .lahiri) -> [TransitPosition] {
        var positions: [TransitPosition] = []

        for planet in VedicPlanet.allCases {
            guard let position = ephemeris.siderealLongitude(planet: planet, date: date, ayanamsaType: ayanamsa) else {
                continue
            }

            let signIndex = position.signIndex
            let sign = ZodiacSign.allCases[signIndex]
            let nakshatraIndex = Int(position.longitude / 13.333333) % 27
            let nakshatra = Nakshatra.allCases[nakshatraIndex]
            let pada = Int((position.longitude.truncatingRemainder(dividingBy: 13.333333)) / 3.333333) + 1

            positions.append(TransitPosition(
                planet: planet.rawValue,
                vedName: planet.vedName,
                longitude: position.longitude,
                signIndex: signIndex,
                signName: sign.rawValue,
                degreeInSign: position.degreeInSign,
                nakshatra: nakshatra.rawValue,
                nakshatraPada: pada,
                isRetrograde: position.isRetrograde
            ))
        }

        return positions
    }

    // MARK: - Precise Transit Date Calculation

    /// Calculate exact date when a planet enters a specific sign
    func calculateExactIngressDate(
        planet: VedicPlanet,
        targetSign: ZodiacSign,
        fromDate: Date,
        searchDays: Int = 730,
        ayanamsa: AyanamsaType = .lahiri
    ) -> Date? {
        let calendar = Calendar.current
        var currentDate = fromDate

        // Get current sign
        guard let currentPosition = ephemeris.siderealLongitude(planet: planet, date: currentDate, ayanamsaType: ayanamsa) else {
            return nil
        }

        let targetSignIndex = ZodiacSign.allCases.firstIndex(of: targetSign) ?? 0

        // If already in target sign, return nil
        if currentPosition.signIndex == targetSignIndex {
            return nil
        }

        // Binary search for ingress date
        var lowDate = fromDate
        var highDate = calendar.date(byAdding: .day, value: searchDays, to: fromDate) ?? fromDate

        // First, find rough date using daily steps
        var foundIngressWindow = false
        for day in 0..<searchDays {
            guard let checkDate = calendar.date(byAdding: .day, value: day, to: fromDate),
                  let pos = ephemeris.siderealLongitude(planet: planet, date: checkDate, ayanamsaType: ayanamsa) else {
                continue
            }

            if pos.signIndex == targetSignIndex {
                foundIngressWindow = true
                highDate = checkDate
                lowDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
                break
            }
        }

        guard foundIngressWindow else { return nil }

        // Binary search for exact time (within 1 hour precision)
        while calendar.dateComponents([.hour], from: lowDate, to: highDate).hour ?? 0 > 1 {
            let midDate = Date(timeIntervalSince1970: (lowDate.timeIntervalSince1970 + highDate.timeIntervalSince1970) / 2)

            guard let midPosition = ephemeris.siderealLongitude(planet: planet, date: midDate, ayanamsaType: ayanamsa) else {
                break
            }

            if midPosition.signIndex == targetSignIndex {
                highDate = midDate
            } else {
                lowDate = midDate
            }
        }

        return highDate
    }

    // MARK: - Retrograde Detection

    /// Detect retrograde periods for a planet within a date range
    func detectRetrogradePeriods(
        planet: VedicPlanet,
        fromDate: Date,
        toDate: Date,
        ayanamsa: AyanamsaType = .lahiri
    ) -> [RetrogradePeriod] {
        // Sun and Moon don't go retrograde
        guard planet != .sun && planet != .moon else { return [] }

        var periods: [RetrogradePeriod] = []
        let calendar = Calendar.current
        var currentDate = fromDate
        var wasRetrograde = false
        var retroStartDate: Date?

        // Check daily
        while currentDate < toDate {
            guard let position = ephemeris.siderealLongitude(planet: planet, date: currentDate, ayanamsaType: ayanamsa) else {
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
                continue
            }

            let isRetrograde = position.isRetrograde

            if isRetrograde && !wasRetrograde {
                // Start of retrograde
                retroStartDate = currentDate
            } else if !isRetrograde && wasRetrograde {
                // End of retrograde
                if let startDate = retroStartDate {
                    let period = RetrogradePeriod(
                        planet: planet,
                        startDate: startDate,
                        endDate: currentDate,
                        stationaryRetrograde: startDate,  // Simplified
                        stationaryDirect: currentDate
                    )
                    periods.append(period)
                }
                retroStartDate = nil
            }

            wasRetrograde = isRetrograde
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return periods
    }

    // MARK: - Triple Pass Transit Detection

    /// Check if a transit is a triple pass (direct -> retrograde -> direct over natal point)
    func isTriplePassTransit(
        transitPlanet: VedicPlanet,
        natalLongitude: Double,
        fromDate: Date,
        months: Int = 12,
        ayanamsa: AyanamsaType = .lahiri
    ) -> Bool {
        let calendar = Calendar.current
        let orbDegrees = 3.0  // Orb for exact conjunction
        var passCount = 0
        var wasConjunct = false

        for month in 0..<months {
            guard let checkDate = calendar.date(byAdding: .month, value: month, to: fromDate),
                  let position = ephemeris.siderealLongitude(planet: transitPlanet, date: checkDate, ayanamsaType: ayanamsa) else {
                continue
            }

            var distance = abs(position.longitude - natalLongitude)
            if distance > 180 { distance = 360 - distance }

            let isConjunct = distance <= orbDegrees

            if isConjunct && !wasConjunct {
                passCount += 1
            }

            wasConjunct = isConjunct
        }

        return passCount >= 3
    }

    // MARK: - Transit Predictions

    /// Generate transit predictions for the next N months
    func generateTransitPredictions(
        natalPositions: [VedicPlanetPosition],
        natalMoonSign: Int,
        months: Int = 12,
        ayanamsa: AyanamsaType = .lahiri
    ) -> [TransitPrediction] {
        var predictions: [TransitPrediction] = []
        let calendar = Calendar.current
        let now = Date()

        // Major transit planets
        let majorPlanets: [VedicPlanet] = [.saturn, .jupiter, .mars, .rahu, .ketu]

        for planet in majorPlanets {
            // Check for sign ingresses
            for month in 0..<months {
                guard let checkDate = calendar.date(byAdding: .month, value: month, to: now),
                      let position = ephemeris.siderealLongitude(planet: planet, date: checkDate, ayanamsaType: ayanamsa) else {
                    continue
                }

                // Check for natal conjunctions
                for natalPos in natalPositions {
                    var distance = abs(position.longitude - natalPos.longitude)
                    if distance > 180 { distance = 360 - distance }

                    if distance <= 5.0 {  // Within 5 degree orb
                        let houseAffected = (position.signIndex - natalMoonSign + 12) % 12 + 1
                        let intensity = determineTransitIntensity(
                            transitPlanet: planet,
                            natalPlanet: natalPos.planet,
                            distance: distance
                        )

                        predictions.append(TransitPrediction(
                            planet: planet,
                            event: .conjunctionNatal,
                            date: checkDate,
                            natalHouseAffected: houseAffected,
                            description: "\(planet.rawValue) transits over natal \(natalPos.planet.rawValue)",
                            intensity: intensity
                        ))
                    }
                }
            }
        }

        return predictions.sorted { $0.date < $1.date }
    }

    /// Determine transit intensity
    private func determineTransitIntensity(
        transitPlanet: VedicPlanet,
        natalPlanet: VedicPlanet,
        distance: Double
    ) -> TransitIntensity {
        // Saturn/Rahu transits are more intense
        let isMajorTransiter = transitPlanet == .saturn || transitPlanet == .rahu

        // Transits over Sun/Moon are more significant
        let isSensitiveNatal = natalPlanet == .sun || natalPlanet == .moon

        // Close orb is more intense
        let isCloseOrb = distance < 2.0

        if (isMajorTransiter && isSensitiveNatal) || (isMajorTransiter && isCloseOrb) {
            return .high
        } else if isMajorTransiter || isSensitiveNatal || isCloseOrb {
            return .medium
        } else {
            return .low
        }
    }

    // MARK: - Inner Planet Transits

    /// Calculate fast-moving planet transits (Sun, Moon, Mercury, Venus)
    func calculateInnerPlanetTransits(
        date: Date,
        natalMoonSign: Int,
        ayanamsa: AyanamsaType = .lahiri
    ) -> [MajorTransitPeriod] {
        var periods: [MajorTransitPeriod] = []
        let calendar = Calendar.current

        let innerPlanets: [VedicPlanet] = [.sun, .moon, .mercury, .venus]

        for planet in innerPlanets {
            guard let position = ephemeris.siderealLongitude(planet: planet, date: date, ayanamsaType: ayanamsa) else {
                continue
            }

            let signIndex = position.signIndex
            let sign = ZodiacSign.allCases[signIndex]
            let houseFromMoon = (signIndex - natalMoonSign + 12) % 12 + 1

            // Estimate transit duration
            let daysInSign: Int
            switch planet {
            case .sun: daysInSign = 30
            case .moon: daysInSign = 3  // 2.5 days actually
            case .mercury: daysInSign = 25  // Variable due to retrograde
            case .venus: daysInSign = 30
            default: daysInSign = 30
            }

            let degreeInSign = position.degreeInSign
            let percentRemaining = (30.0 - degreeInSign) / 30.0
            let daysRemaining = Int(Double(daysInSign) * percentRemaining)

            let startDate = calendar.date(byAdding: .day, value: -Int(Double(daysInSign) * (1 - percentRemaining)), to: date) ?? date
            let endDate = calendar.date(byAdding: .day, value: daysRemaining, to: date) ?? date

            let effect = generateInnerPlanetEffect(planet: planet, house: houseFromMoon)

            periods.append(MajorTransitPeriod(
                type: planet == .sun ? .saturnTransit : .jupiterTransit,  // Using existing types
                planet: planet.rawValue,
                startDate: startDate,
                endDate: endDate,
                houseNumber: houseFromMoon,
                signName: sign.rawValue,
                effects: effect
            ))
        }

        return periods
    }

    /// Generate effect description for inner planet transit
    private func generateInnerPlanetEffect(planet: VedicPlanet, house: Int) -> String {
        switch planet {
        case .sun:
            return "Sun illuminates house \(house) matters. Focus on \(houseKeyword(house))."
        case .moon:
            return "Moon brings emotional focus to house \(house). Sensitivity around \(houseKeyword(house))."
        case .mercury:
            return "Mercury activates communication and thinking about \(houseKeyword(house))."
        case .venus:
            return "Venus brings pleasure and harmony to \(houseKeyword(house)) matters."
        default:
            return "Transit affecting house \(house)."
        }
    }

    /// Get house keyword
    private func houseKeyword(_ house: Int) -> String {
        switch house {
        case 1: return "self and personality"
        case 2: return "finances and family"
        case 3: return "siblings and communication"
        case 4: return "home and mother"
        case 5: return "children and creativity"
        case 6: return "health and service"
        case 7: return "partnerships and marriage"
        case 8: return "transformation and inheritance"
        case 9: return "luck and higher learning"
        case 10: return "career and status"
        case 11: return "gains and friendships"
        case 12: return "spirituality and losses"
        default: return "life matters"
        }
    }
}
