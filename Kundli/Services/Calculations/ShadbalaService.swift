import Foundation

/// Service for calculating Shadbala (Six-fold strength) of planets
final class ShadbalaService {
    static let shared = ShadbalaService()

    private let ephemeris = EphemerisService.shared

    private init() {}

    // MARK: - Main Calculation

    /// Calculate Shadbala for all planets
    func calculateShadbala(
        planetPositions: [VedicPlanetPosition],
        houseResult: HouseCalculationResult,
        birthDate: Date,
        birthTime: Date
    ) -> [PlanetaryStrength] {
        return planetPositions.compactMap { position in
            guard position.planet != .rahu && position.planet != .ketu else {
                return nil // Rahu/Ketu don't have traditional Shadbala
            }

            return calculatePlanetShadbala(
                planet: position,
                allPlanets: planetPositions,
                houseResult: houseResult,
                birthDate: birthDate,
                birthTime: birthTime
            )
        }
    }

    /// Calculate Shadbala for a single planet
    func calculatePlanetShadbala(
        planet: VedicPlanetPosition,
        allPlanets: [VedicPlanetPosition],
        houseResult: HouseCalculationResult,
        birthDate: Date,
        birthTime: Date
    ) -> PlanetaryStrength {
        // Calculate each component
        let sthanaBala = calculateSthanaBala(planet: planet, houseResult: houseResult)
        let dikBala = calculateDikBala(planet: planet, houseResult: houseResult)
        let kalaBala = calculateKalaBala(planet: planet, birthDate: birthDate, birthTime: birthTime)
        let chestaBala = calculateChestaBala(planet: planet)
        let naisargikaBala = calculateNaisargikaBala(planet: planet.planet)
        let drigBala = calculateDrigBala(planet: planet, allPlanets: allPlanets)

        let requiredStrength = PlanetaryStrength.requiredStrength(for: planet.planet.rawValue)

        return PlanetaryStrength(
            planet: planet.planet.rawValue,
            vedName: planet.planet.vedName,
            sthanaBala: sthanaBala,
            dikBala: dikBala,
            kalaBala: kalaBala,
            chestaBala: chestaBala,
            naisargikaBala: naisargikaBala,
            drigBala: drigBala,
            requiredStrength: requiredStrength
        )
    }

    // MARK: - 1. Sthana Bala (Positional Strength)

    /// Calculate Sthana Bala - strength from position in sign, house, etc.
    func calculateSthanaBala(planet: VedicPlanetPosition, houseResult: HouseCalculationResult) -> Double {
        var totalBala: Double = 0

        // a) Uchcha Bala (Exaltation strength) - max 60 Virupas
        totalBala += calculateUchchaBala(planet: planet)

        // b) Saptavargaja Bala (Strength from 7 divisional charts) - simplified
        totalBala += calculateSaptavargajaBala(planet: planet)

        // c) Ojhayugmarasyamsa Bala (Odd-even sign strength)
        totalBala += calculateOjhayugmaBala(planet: planet.planet)

        // d) Kendradi Bala (Angle house strength)
        let house = houseResult.house(for: planet.planet)
        totalBala += calculateKendradiBala(house: house)

        // e) Drekkana Bala (Decanate strength)
        totalBala += calculateDrekkanaBala(planet: planet)

        // Normalize to max 60 Virupas for this component
        return min(totalBala, 60)
    }

    private func calculateUchchaBala(planet: VedicPlanetPosition) -> Double {
        // Exaltation points for each planet
        let exaltationDegrees: [VedicPlanet: Double] = [
            .sun: 10,      // Aries 10°
            .moon: 33,     // Taurus 3°
            .mars: 298,    // Capricorn 28°
            .mercury: 165, // Virgo 15°
            .jupiter: 95,  // Cancer 5°
            .venus: 357,   // Pisces 27°
            .saturn: 200   // Libra 20°
        ]

        guard let exaltation = exaltationDegrees[planet.planet] else { return 15 }

        // Calculate distance from exaltation point
        var distance = abs(planet.longitude - exaltation)
        if distance > 180 { distance = 360 - distance }

        // Max 60 Virupas at exaltation, 0 at debilitation (180° away)
        return (180 - distance) / 3  // Scale to max 60
    }

    private func calculateSaptavargajaBala(planet: VedicPlanetPosition) -> Double {
        // Simplified calculation based on dignity in rashi
        var bala: Double = 0

        // Own sign bonus
        if planet.status == .ownSign {
            bala += 15
        }

        // Exalted bonus
        if planet.status == .exalted {
            bala += 20
        }

        // Debilitated penalty
        if planet.status == .debilitated {
            bala -= 10
        }

        return max(bala + 10, 0)  // Baseline of 10
    }

    private func calculateOjhayugmaBala(planet: VedicPlanet) -> Double {
        // Sun, Mars, Jupiter gain strength in odd signs
        // Moon, Venus gain strength in even signs
        // Mercury and Saturn neutral

        switch planet {
        case .sun, .mars, .jupiter: return 7.5
        case .moon, .venus: return 7.5
        default: return 7.5
        }
    }

    private func calculateKendradiBala(house: Int) -> Double {
        // Planets in Kendra (1,4,7,10) = 60 Virupas
        // Panaphara (2,5,8,11) = 30 Virupas
        // Apoklima (3,6,9,12) = 15 Virupas
        switch house {
        case 1, 4, 7, 10: return 15  // Kendra
        case 2, 5, 8, 11: return 7.5 // Panaphara
        default: return 3.75         // Apoklima
        }
    }

    private func calculateDrekkanaBala(planet: VedicPlanetPosition) -> Double {
        // Male planets strong in 1st drekkana, female in 3rd, neutral in 2nd
        let degreeInSign = planet.longitude.truncatingRemainder(dividingBy: 30)
        let drekkana: Int
        if degreeInSign < 10 { drekkana = 1 }
        else if degreeInSign < 20 { drekkana = 2 }
        else { drekkana = 3 }

        switch planet.planet {
        case .sun, .mars, .jupiter: // Male planets
            return drekkana == 1 ? 7.5 : (drekkana == 2 ? 3.75 : 0)
        case .moon, .venus: // Female planets
            return drekkana == 3 ? 7.5 : (drekkana == 2 ? 3.75 : 0)
        default: // Neutral
            return drekkana == 2 ? 7.5 : 3.75
        }
    }

    // MARK: - 2. Dik Bala (Directional Strength)

    /// Calculate Dik Bala - directional strength based on house position
    func calculateDikBala(planet: VedicPlanetPosition, houseResult: HouseCalculationResult) -> Double {
        let house = houseResult.house(for: planet.planet)

        // Each planet is strong in a specific direction (house)
        // Jupiter/Mercury strong in 1st (East)
        // Sun/Mars strong in 10th (South)
        // Saturn strong in 7th (West)
        // Moon/Venus strong in 4th (North)

        let optimalHouse: Int
        switch planet.planet {
        case .jupiter, .mercury: optimalHouse = 1
        case .sun, .mars: optimalHouse = 10
        case .saturn: optimalHouse = 7
        case .moon, .venus: optimalHouse = 4
        default: optimalHouse = 1
        }

        // Calculate distance from optimal house (0-6 houses away)
        var distance = abs(house - optimalHouse)
        if distance > 6 { distance = 12 - distance }

        // Max 60 Virupas at optimal, decreasing with distance
        return 60 - (Double(distance) * 10)
    }

    // MARK: - 3. Kala Bala (Temporal Strength)

    /// Calculate Kala Bala - strength from time factors
    func calculateKalaBala(planet: VedicPlanetPosition, birthDate: Date, birthTime: Date) -> Double {
        var totalBala: Double = 0

        // a) Nathonnatha Bala (Day/Night strength)
        totalBala += calculateNathonathaBala(planet: planet.planet, birthTime: birthTime)

        // b) Paksha Bala (Lunar fortnight strength)
        totalBala += calculatePakshaBala(planet: planet.planet, birthDate: birthDate)

        // c) Tribhaga Bala (Three-part day strength)
        totalBala += calculateTribhagaBala(planet: planet.planet, birthTime: birthTime)

        // d) Hora Bala (Planetary hour strength)
        totalBala += calculateHoraBala(planet: planet.planet, birthDate: birthDate, birthTime: birthTime)

        // e) Masa Bala (Monthly strength)
        totalBala += calculateMasaBala(planet: planet.planet, birthDate: birthDate)

        // f) Varsha Bala (Annual strength)
        totalBala += calculateVarshaBala(planet: planet.planet, birthDate: birthDate)

        // g) Ayana Bala (Half-yearly strength)
        totalBala += calculateAyanaBala(planet: planet.planet, birthDate: birthDate)

        return min(totalBala, 60)
    }

    /// Calculate Masa Bala (Monthly strength)
    /// Planets have favorable months based on their ruling signs
    private func calculateMasaBala(planet: VedicPlanet, birthDate: Date) -> Double {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: birthDate)

        // Each planet rules specific months through sign rulership
        // Sun rules Leo (Aug), Moon rules Cancer (July), etc.
        let favorableMonths: [VedicPlanet: [Int]] = [
            .sun: [7, 8],           // Leo season (July-Aug)
            .moon: [6, 7],          // Cancer season (June-July)
            .mars: [3, 4, 10, 11],  // Aries (March-April) and Scorpio (Oct-Nov)
            .mercury: [5, 6, 8, 9], // Gemini (May-June) and Virgo (Aug-Sept)
            .jupiter: [11, 12, 2, 3], // Sagittarius (Nov-Dec) and Pisces (Feb-March)
            .venus: [4, 5, 9, 10],  // Taurus (April-May) and Libra (Sept-Oct)
            .saturn: [12, 1, 1, 2]  // Capricorn (Dec-Jan) and Aquarius (Jan-Feb)
        ]

        // Check if birth month is favorable for this planet
        if let months = favorableMonths[planet], months.contains(month) {
            return 15.0
        }

        // Neutral months
        return 7.5
    }

    /// Calculate Varsha Bala (Annual strength)
    /// Based on the year lord calculation
    private func calculateVarshaBala(planet: VedicPlanet, birthDate: Date) -> Double {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: birthDate)

        // Calculate the day of the week for Jan 1 of the birth year
        var components = DateComponents()
        components.year = year
        components.month = 1
        components.day = 1

        guard let janFirst = calendar.date(from: components) else {
            return 7.5
        }

        let weekday = calendar.component(.weekday, from: janFirst)

        // Day rulers in Vedic sequence (Sunday = 1)
        let dayRulers: [VedicPlanet] = [.sun, .moon, .mars, .mercury, .jupiter, .venus, .saturn]
        let yearLord = dayRulers[(weekday - 1) % 7]

        // Planet gets strength if it's the year lord or friends with year lord
        if planet == yearLord {
            return 15.0
        }

        // Check if planet is friend of year lord
        if areFriends(planet1: planet, planet2: yearLord) {
            return 10.0
        }

        return 5.0
    }

    /// Calculate Ayana Bala (Half-yearly/declination strength)
    /// Based on Uttarayana (northern course) vs Dakshinayana (southern course)
    private func calculateAyanaBala(planet: VedicPlanet, birthDate: Date) -> Double {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: birthDate)

        // Uttarayana: Jan-June (months 1-6), Sun moving north
        // Dakshinayana: July-Dec (months 7-12), Sun moving south
        let isUttarayana = month >= 1 && month <= 6

        // Different planets favor different ayanas
        // Sun, Mars, Jupiter favor Uttarayana (northern)
        // Moon, Venus, Saturn favor Dakshinayana (southern)
        // Mercury is neutral

        switch planet {
        case .sun, .mars, .jupiter:
            return isUttarayana ? 15.0 : 5.0
        case .moon, .venus, .saturn:
            return isUttarayana ? 5.0 : 15.0
        case .mercury:
            return 10.0  // Neutral
        default:
            return 7.5
        }
    }

    /// Check if two planets are friends (natural friendship)
    private func areFriends(planet1: VedicPlanet, planet2: VedicPlanet) -> Bool {
        let friendships: [VedicPlanet: [VedicPlanet]] = [
            .sun: [.moon, .mars, .jupiter],
            .moon: [.sun, .mercury],
            .mars: [.sun, .moon, .jupiter],
            .mercury: [.sun, .venus],
            .jupiter: [.sun, .moon, .mars],
            .venus: [.mercury, .saturn],
            .saturn: [.mercury, .venus]
        ]

        return friendships[planet1]?.contains(planet2) ?? false
    }

    private func calculateNathonathaBala(planet: VedicPlanet, birthTime: Date) -> Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: birthTime)
        let isDaytime = hour >= 6 && hour < 18

        // Sun, Jupiter, Venus strong during day
        // Moon, Mars, Saturn strong during night
        // Mercury always strong

        switch planet {
        case .sun, .jupiter, .venus:
            return isDaytime ? 15 : 0
        case .moon, .mars, .saturn:
            return isDaytime ? 0 : 15
        case .mercury:
            return 15
        default:
            return 7.5
        }
    }

    private func calculatePakshaBala(planet: VedicPlanet, birthDate: Date) -> Double {
        // Benefics strong in Shukla Paksha, Malefics in Krishna Paksha
        // Simplified - would need actual lunar phase calculation

        switch planet {
        case .jupiter, .venus, .moon, .mercury:
            return 10  // Benefics
        case .sun, .mars, .saturn:
            return 5   // Malefics
        default:
            return 7.5
        }
    }

    private func calculateTribhagaBala(planet: VedicPlanet, birthTime: Date) -> Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: birthTime)

        // Day divided into 3 parts: Mercury (sunrise-10am), Sun (10am-2pm), Saturn (2pm-sunset)
        // Night: Moon (sunset-10pm), Venus (10pm-2am), Mars (2am-sunrise)

        let isDaytime = hour >= 6 && hour < 18

        if isDaytime {
            if hour < 10 {
                return planet == .mercury ? 10 : 0
            } else if hour < 14 {
                return planet == .sun ? 10 : 0
            } else {
                return planet == .saturn ? 10 : 0
            }
        } else {
            if hour >= 18 && hour < 22 {
                return planet == .moon ? 10 : 0
            } else if hour >= 22 || hour < 2 {
                return planet == .venus ? 10 : 0
            } else {
                return planet == .mars ? 10 : 0
            }
        }
    }

    private func calculateHoraBala(planet: VedicPlanet, birthDate: Date, birthTime: Date) -> Double {
        // Planetary hour calculation - simplified
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: birthTime)
        let weekday = calendar.component(.weekday, from: birthDate)

        // Hora sequence based on weekday and hour
        // Simplified: give bonus if planet rules the day
        let dayRulers: [VedicPlanet] = [.sun, .moon, .mars, .mercury, .jupiter, .venus, .saturn]
        let dayRuler = dayRulers[(weekday - 1) % 7]

        return planet == dayRuler ? 10 : 2.5
    }

    // MARK: - 4. Chesta Bala (Motional Strength)

    /// Calculate Chesta Bala - strength from planetary motion and velocity
    func calculateChestaBala(planet: VedicPlanetPosition) -> Double {
        // Sun and Moon don't have traditional Chesta Bala
        if planet.planet == .sun || planet.planet == .moon {
            return 30  // Given average value
        }

        // Retrograde planets have maximum Chesta Bala (60 Virupas)
        if planet.isRetrograde {
            return 60.0
        }

        // Calculate based on velocity relative to average daily motion
        let averageDailyMotion = getAverageDailyMotion(planet: planet.planet)
        let actualSpeed = abs(planet.speedPerDay)

        // Ratio of actual speed to average speed
        let speedRatio = actualSpeed / averageDailyMotion

        // Stationary planets (very slow) get high Chesta Bala
        if speedRatio < 0.1 {
            return 55.0  // Nearly stationary
        }

        // Faster than average motion = moderate Chesta Bala
        // Slower than average = higher Chesta Bala (approaching station)
        if speedRatio > 1.0 {
            // Fast motion - moderate strength
            return min(45.0, 30.0 + (speedRatio * 5))
        } else {
            // Slow motion - higher strength (planet gaining power before station)
            return min(55.0, 30.0 + ((1 / speedRatio) * 10))
        }
    }

    /// Get average daily motion for a planet
    private func getAverageDailyMotion(planet: VedicPlanet) -> Double {
        switch planet {
        case .sun: return 0.9856  // ~1 degree per day
        case .moon: return 13.176 // ~13 degrees per day
        case .mars: return 0.524  // ~0.5 degrees per day
        case .mercury: return 1.383  // Variable, up to 2 degrees
        case .jupiter: return 0.083  // ~5 arc-minutes per day
        case .venus: return 1.2  // ~1.2 degrees per day
        case .saturn: return 0.033  // ~2 arc-minutes per day
        case .rahu, .ketu: return 0.053  // ~3 arc-minutes per day (retrograde)
        }
    }

    // MARK: - 5. Naisargika Bala (Natural Strength)

    /// Calculate Naisargika Bala - inherent planetary strength
    /// This is fixed for each planet
    func calculateNaisargikaBala(planet: VedicPlanet) -> Double {
        switch planet {
        case .sun: return 60
        case .moon: return 51.43
        case .venus: return 42.86
        case .jupiter: return 34.29
        case .mercury: return 25.71
        case .mars: return 17.14
        case .saturn: return 8.57
        default: return 0
        }
    }

    // MARK: - 6. Drig Bala (Aspectual Strength)

    /// Calculate Drig Bala - strength from aspects received
    /// Drig Bala considers both the aspecting planet's nature and aspect type
    func calculateDrigBala(planet: VedicPlanetPosition, allPlanets: [VedicPlanetPosition]) -> Double {
        var totalBala: Double = 0

        for otherPlanet in allPlanets {
            guard otherPlanet.planet != planet.planet else { continue }

            // Calculate aspect type and strength
            let aspectInfo = calculateDetailedAspect(
                from: otherPlanet,
                to: planet
            )

            guard let aspect = aspectInfo else { continue }

            // Base aspect strength
            var aspectStrength = aspect.strength

            // Modify by aspecting planet's nature
            let planetNature = getPlanetNature(otherPlanet.planet)

            switch (aspect.type, planetNature) {
            case (.conjunction, .benefic):
                totalBala += aspectStrength
            case (.conjunction, .malefic):
                totalBala -= aspectStrength * 0.5
            case (.opposition, .benefic):
                totalBala += aspectStrength * 0.5
            case (.opposition, .malefic):
                totalBala -= aspectStrength
            case (.trine, .benefic):
                totalBala += aspectStrength
            case (.trine, .malefic):
                totalBala -= aspectStrength * 0.25
            case (.square, .benefic):
                totalBala -= aspectStrength * 0.25
            case (.square, .malefic):
                totalBala -= aspectStrength * 0.75
            case (.sextile, .benefic):
                totalBala += aspectStrength * 0.5
            case (.sextile, .malefic):
                totalBala -= aspectStrength * 0.25
            default:
                break
            }

            // Special Vedic aspects (Mars 4th/8th, Jupiter 5th/9th, Saturn 3rd/10th)
            let specialAspectStrength = calculateSpecialVedicAspect(from: otherPlanet, to: planet)
            if specialAspectStrength > 0 {
                if planetNature == .benefic {
                    totalBala += specialAspectStrength
                } else {
                    totalBala -= specialAspectStrength * 0.5
                }
            }
        }

        // Normalize to range 0-60 with baseline of 30
        return max(min(totalBala + 30, 60), 0)
    }

    /// Aspect type for Drig Bala calculation
    private enum AspectType {
        case conjunction
        case opposition
        case trine
        case square
        case sextile
    }

    /// Planet nature for aspect calculation
    private enum PlanetNature {
        case benefic
        case malefic
        case neutral
    }

    /// Detailed aspect information
    private struct AspectDetail {
        let type: AspectType
        let strength: Double
    }

    /// Calculate detailed aspect between two planets
    private func calculateDetailedAspect(
        from: VedicPlanetPosition,
        to: VedicPlanetPosition
    ) -> AspectDetail? {
        var distance = abs(from.longitude - to.longitude)
        if distance > 180 { distance = 360 - distance }

        // Check each aspect type with orbs
        if distance < 10 {
            return AspectDetail(type: .conjunction, strength: 15.0 - distance)
        }
        if abs(distance - 60) < 6 {
            return AspectDetail(type: .sextile, strength: 7.5 - abs(distance - 60))
        }
        if abs(distance - 90) < 8 {
            return AspectDetail(type: .square, strength: 10.0 - abs(distance - 90))
        }
        if abs(distance - 120) < 8 {
            return AspectDetail(type: .trine, strength: 15.0 - abs(distance - 120))
        }
        if abs(distance - 180) < 10 {
            return AspectDetail(type: .opposition, strength: 15.0 - abs(distance - 180))
        }

        return nil
    }

    /// Calculate special Vedic aspects (Mars/Jupiter/Saturn special aspects)
    private func calculateSpecialVedicAspect(
        from: VedicPlanetPosition,
        to: VedicPlanetPosition
    ) -> Double {
        let signDiff = (to.signIndex - from.signIndex + 12) % 12

        switch from.planet {
        case .mars:
            // Mars aspects 4th and 8th houses with full strength
            if signDiff == 3 || signDiff == 7 {
                return 10.0
            }
        case .jupiter:
            // Jupiter aspects 5th and 9th houses with full strength
            if signDiff == 4 || signDiff == 8 {
                return 10.0
            }
        case .saturn:
            // Saturn aspects 3rd and 10th houses with full strength
            if signDiff == 2 || signDiff == 9 {
                return 10.0
            }
        case .rahu, .ketu:
            // Nodes aspect 5th and 9th like Jupiter (some traditions)
            if signDiff == 4 || signDiff == 8 {
                return 7.5
            }
        default:
            break
        }

        return 0
    }

    /// Get planet nature (benefic/malefic)
    private func getPlanetNature(_ planet: VedicPlanet) -> PlanetNature {
        switch planet {
        case .jupiter, .venus:
            return .benefic
        case .sun, .mars, .saturn, .rahu, .ketu:
            return .malefic
        case .moon:
            // Moon's nature depends on phase (simplified to neutral)
            return .neutral
        case .mercury:
            // Mercury's nature depends on associations (simplified to neutral)
            return .neutral
        }
    }

    private func isBenefic(_ planet: VedicPlanet) -> Bool {
        switch planet {
        case .jupiter, .venus: return true
        case .moon, .mercury: return true  // Contextually benefic
        default: return false
        }
    }
}
