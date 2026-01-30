import Foundation

/// Service for calculating divisional charts (Vargas)
/// Divisional charts are derived from the main birth chart by dividing signs
final class DivisionalChartService {
    static let shared = DivisionalChartService()

    private init() {}

    // MARK: - Main Calculation

    /// Calculate a specific divisional chart
    func calculateDivisionalChart(
        chartType: DivisionalChart,
        planets: [VedicPlanetPosition],
        ascendantLongitude: Double
    ) -> DivisionalChartData {
        let planetPositions = planets.map { planet in
            let divisionalLongitude = calculateDivisionalLongitude(
                longitude: planet.longitude,
                chart: chartType
            )
            let signIndex = Int(divisionalLongitude / 30.0) % 12
            let degreeInSign = divisionalLongitude.truncatingRemainder(dividingBy: 30.0)

            return DivisionalPlanetPosition(
                planet: planet.planet,
                signIndex: signIndex,
                degreeInSign: degreeInSign
            )
        }

        let ascDivisionalLong = calculateDivisionalLongitude(
            longitude: ascendantLongitude,
            chart: chartType
        )
        let ascSignIndex = Int(ascDivisionalLong / 30.0) % 12
        let ascDegree = ascDivisionalLong.truncatingRemainder(dividingBy: 30.0)

        return DivisionalChartData(
            chartType: chartType,
            ascendantSign: ascSignIndex,
            ascendantDegree: ascDegree,
            planetPositions: planetPositions
        )
    }

    /// Calculate all standard divisional charts
    func calculateAllDivisionalCharts(
        planets: [VedicPlanetPosition],
        ascendantLongitude: Double
    ) -> [DivisionalChartData] {
        DivisionalChart.allCases.map { chartType in
            calculateDivisionalChart(
                chartType: chartType,
                planets: planets,
                ascendantLongitude: ascendantLongitude
            )
        }
    }

    /// Calculate priority divisional charts (D1, D9, D10)
    func calculatePriorityCharts(
        planets: [VedicPlanetPosition],
        ascendantLongitude: Double
    ) -> [DivisionalChartData] {
        let priorityCharts: [DivisionalChart] = [.d1, .d9, .d10]
        return priorityCharts.map { chartType in
            calculateDivisionalChart(
                chartType: chartType,
                planets: planets,
                ascendantLongitude: ascendantLongitude
            )
        }
    }

    // MARK: - Divisional Longitude Calculation

    /// Calculate the longitude in a divisional chart
    func calculateDivisionalLongitude(longitude: Double, chart: DivisionalChart) -> Double {
        switch chart {
        case .d1:
            return longitude
        case .d2:
            return calculateD2Longitude(longitude)
        case .d3:
            return calculateD3Longitude(longitude)
        case .d4:
            return calculateD4Longitude(longitude)
        case .d7:
            return calculateD7Longitude(longitude)
        case .d9:
            return calculateD9Longitude(longitude)
        case .d10:
            return calculateD10Longitude(longitude)
        case .d12:
            return calculateD12Longitude(longitude)
        case .d16:
            return calculateD16Longitude(longitude)
        case .d20:
            return calculateD20Longitude(longitude)
        case .d24:
            return calculateD24Longitude(longitude)
        case .d27:
            return calculateD27Longitude(longitude)
        case .d30:
            return calculateD30Longitude(longitude)
        case .d40:
            return calculateD40Longitude(longitude)
        case .d45:
            return calculateD45Longitude(longitude)
        case .d60:
            return calculateD60Longitude(longitude)
        }
    }

    // MARK: - Individual Chart Calculations

    /// D-2 Hora: Wealth
    /// Sun rules odd signs, Moon rules even signs (2 divisions per sign)
    private func calculateD2Longitude(_ longitude: Double) -> Double {
        let signIndex = Int(longitude / 30.0)
        let degreeInSign = longitude.truncatingRemainder(dividingBy: 30.0)
        let isOddSign = (signIndex % 2) == 0  // Aries=0 is odd sign

        // First half (0-15°) and second half (15-30°)
        let halfIndex = Int(degreeInSign / 15.0)

        if isOddSign {
            // Odd signs: First half = Leo (4), Second half = Cancer (3)
            return Double(halfIndex == 0 ? 4 : 3) * 30.0 + (degreeInSign.truncatingRemainder(dividingBy: 15.0) * 2)
        } else {
            // Even signs: First half = Cancer (3), Second half = Leo (4)
            return Double(halfIndex == 0 ? 3 : 4) * 30.0 + (degreeInSign.truncatingRemainder(dividingBy: 15.0) * 2)
        }
    }

    /// D-3 Drekkana: Siblings
    /// Each sign divided into 3 parts of 10° each
    private func calculateD3Longitude(_ longitude: Double) -> Double {
        let signIndex = Int(longitude / 30.0)
        let degreeInSign = longitude.truncatingRemainder(dividingBy: 30.0)
        let drekkanaIndex = Int(degreeInSign / 10.0)  // 0, 1, or 2

        // First drekkana = same sign, second = 5th from it, third = 9th from it
        let resultSign = (signIndex + (drekkanaIndex * 4)) % 12
        let resultDegree = (degreeInSign.truncatingRemainder(dividingBy: 10.0)) * 3

        return Double(resultSign) * 30.0 + resultDegree
    }

    /// D-4 Chaturthamsa: Fortune, Property
    /// Each sign divided into 4 parts of 7.5° each
    private func calculateD4Longitude(_ longitude: Double) -> Double {
        let signIndex = Int(longitude / 30.0)
        let degreeInSign = longitude.truncatingRemainder(dividingBy: 30.0)
        let chaturthamsaIndex = Int(degreeInSign / 7.5)  // 0, 1, 2, or 3

        // For odd signs: starts from same sign
        // For even signs: starts from 4th from it
        let isOddSign = (signIndex % 2) == 0
        let startSign = isOddSign ? signIndex : (signIndex + 3) % 12
        let resultSign = (startSign + chaturthamsaIndex) % 12
        let resultDegree = (degreeInSign.truncatingRemainder(dividingBy: 7.5)) * 4

        return Double(resultSign) * 30.0 + resultDegree
    }

    /// D-7 Saptamsa: Children
    /// Each sign divided into 7 parts of 4°17'8.57" each
    private func calculateD7Longitude(_ longitude: Double) -> Double {
        let signIndex = Int(longitude / 30.0)
        let degreeInSign = longitude.truncatingRemainder(dividingBy: 30.0)
        let saptamsaPart = 30.0 / 7.0  // ~4.2857°
        let saptamsaIndex = Int(degreeInSign / saptamsaPart)

        // Odd signs start from same sign, even signs start from 7th
        let isOddSign = (signIndex % 2) == 0
        let startSign = isOddSign ? signIndex : (signIndex + 6) % 12
        let resultSign = (startSign + saptamsaIndex) % 12
        let resultDegree = (degreeInSign.truncatingRemainder(dividingBy: saptamsaPart)) * 7

        return Double(resultSign) * 30.0 + resultDegree
    }

    /// D-9 Navamsa: Marriage, Dharma (Most important divisional chart)
    /// Each sign divided into 9 parts of 3°20' each
    private func calculateD9Longitude(_ longitude: Double) -> Double {
        let signIndex = Int(longitude / 30.0)
        let degreeInSign = longitude.truncatingRemainder(dividingBy: 30.0)
        let navamsaPart = 30.0 / 9.0  // 3.3333°
        let navamsaIndex = Int(degreeInSign / navamsaPart)

        // Fire signs (0,4,8) start from Aries
        // Earth signs (1,5,9) start from Capricorn
        // Air signs (2,6,10) start from Libra
        // Water signs (3,7,11) start from Cancer
        let element = signIndex % 4
        let startSign: Int
        switch element {
        case 0: startSign = 0   // Aries
        case 1: startSign = 9   // Capricorn
        case 2: startSign = 6   // Libra
        default: startSign = 3  // Cancer
        }

        let resultSign = (startSign + navamsaIndex) % 12
        let resultDegree = (degreeInSign.truncatingRemainder(dividingBy: navamsaPart)) * 9

        return Double(resultSign) * 30.0 + resultDegree
    }

    /// D-10 Dasamsa: Career
    /// Each sign divided into 10 parts of 3° each
    private func calculateD10Longitude(_ longitude: Double) -> Double {
        let signIndex = Int(longitude / 30.0)
        let degreeInSign = longitude.truncatingRemainder(dividingBy: 30.0)
        let dasamsaIndex = Int(degreeInSign / 3.0)

        // Odd signs start from same sign, even signs start from 9th
        let isOddSign = (signIndex % 2) == 0
        let startSign = isOddSign ? signIndex : (signIndex + 8) % 12
        let resultSign = (startSign + dasamsaIndex) % 12
        let resultDegree = (degreeInSign.truncatingRemainder(dividingBy: 3.0)) * 10

        return Double(resultSign) * 30.0 + resultDegree
    }

    /// D-12 Dwadasamsa: Parents
    /// Each sign divided into 12 parts of 2.5° each
    private func calculateD12Longitude(_ longitude: Double) -> Double {
        let signIndex = Int(longitude / 30.0)
        let degreeInSign = longitude.truncatingRemainder(dividingBy: 30.0)
        let dwadasamsaIndex = Int(degreeInSign / 2.5)

        // Starts from same sign
        let resultSign = (signIndex + dwadasamsaIndex) % 12
        let resultDegree = (degreeInSign.truncatingRemainder(dividingBy: 2.5)) * 12

        return Double(resultSign) * 30.0 + resultDegree
    }

    /// D-16 Shodasamsa: Vehicles, Luxuries
    private func calculateD16Longitude(_ longitude: Double) -> Double {
        let signIndex = Int(longitude / 30.0)
        let degreeInSign = longitude.truncatingRemainder(dividingBy: 30.0)
        let part = 30.0 / 16.0
        let partIndex = Int(degreeInSign / part)

        // Movable signs start from Aries, Fixed from Leo, Dual from Sagittarius
        let signType = signIndex % 3
        let startSign: Int
        switch signType {
        case 0: startSign = 0   // Movable - Aries
        case 1: startSign = 4   // Fixed - Leo
        default: startSign = 8  // Dual - Sagittarius
        }

        let resultSign = (startSign + partIndex) % 12
        let resultDegree = (degreeInSign.truncatingRemainder(dividingBy: part)) * 16

        return Double(resultSign) * 30.0 + resultDegree
    }

    /// D-20 Vimshamsa: Spiritual progress
    private func calculateD20Longitude(_ longitude: Double) -> Double {
        let signIndex = Int(longitude / 30.0)
        let degreeInSign = longitude.truncatingRemainder(dividingBy: 30.0)
        let part = 30.0 / 20.0
        let partIndex = Int(degreeInSign / part)

        // Movable signs start from Aries, Fixed from Sagittarius, Dual from Leo
        let signType = signIndex % 3
        let startSign: Int
        switch signType {
        case 0: startSign = 0   // Movable - Aries
        case 1: startSign = 8   // Fixed - Sagittarius
        default: startSign = 4  // Dual - Leo
        }

        let resultSign = (startSign + partIndex) % 12
        let resultDegree = (degreeInSign.truncatingRemainder(dividingBy: part)) * 20

        return Double(resultSign) * 30.0 + resultDegree
    }

    /// D-24 Chaturvimshamsa: Education
    private func calculateD24Longitude(_ longitude: Double) -> Double {
        let signIndex = Int(longitude / 30.0)
        let degreeInSign = longitude.truncatingRemainder(dividingBy: 30.0)
        let part = 30.0 / 24.0
        let partIndex = Int(degreeInSign / part)

        // Odd signs start from Leo, even signs start from Cancer
        let isOddSign = (signIndex % 2) == 0
        let startSign = isOddSign ? 4 : 3  // Leo or Cancer

        let resultSign = (startSign + partIndex) % 12
        let resultDegree = (degreeInSign.truncatingRemainder(dividingBy: part)) * 24

        return Double(resultSign) * 30.0 + resultDegree
    }

    /// D-27 Bhamsa: Strengths
    private func calculateD27Longitude(_ longitude: Double) -> Double {
        let signIndex = Int(longitude / 30.0)
        let degreeInSign = longitude.truncatingRemainder(dividingBy: 30.0)
        let part = 30.0 / 27.0
        let partIndex = Int(degreeInSign / part)

        // Fire signs start from Aries, Earth from Cancer, Air from Libra, Water from Capricorn
        let element = signIndex % 4
        let startSign: Int
        switch element {
        case 0: startSign = 0   // Fire - Aries
        case 1: startSign = 3   // Earth - Cancer
        case 2: startSign = 6   // Air - Libra
        default: startSign = 9  // Water - Capricorn
        }

        let resultSign = (startSign + partIndex) % 12
        let resultDegree = (degreeInSign.truncatingRemainder(dividingBy: part)) * 27

        return Double(resultSign) * 30.0 + resultDegree
    }

    /// D-30 Trimshamsa: Misfortunes (uses special Parashari rules)
    private func calculateD30Longitude(_ longitude: Double) -> Double {
        let signIndex = Int(longitude / 30.0)
        let degreeInSign = longitude.truncatingRemainder(dividingBy: 30.0)
        let isOddSign = (signIndex % 2) == 0

        // Trimshamsa divisions are unequal: 5°, 5°, 8°, 7°, 5° for odd signs
        // And reversed for even signs
        var trimsamsa: Int
        if isOddSign {
            if degreeInSign < 5 { trimsamsa = 0 }       // Mars (Aries)
            else if degreeInSign < 10 { trimsamsa = 6 } // Saturn (Aquarius)
            else if degreeInSign < 18 { trimsamsa = 5 } // Jupiter (Sagittarius)
            else if degreeInSign < 25 { trimsamsa = 2 } // Mercury (Gemini)
            else { trimsamsa = 1 }                      // Venus (Taurus)
        } else {
            if degreeInSign < 5 { trimsamsa = 1 }       // Venus
            else if degreeInSign < 12 { trimsamsa = 2 } // Mercury
            else if degreeInSign < 20 { trimsamsa = 5 } // Jupiter
            else if degreeInSign < 25 { trimsamsa = 6 } // Saturn
            else { trimsamsa = 0 }                      // Mars
        }

        return Double(trimsamsa) * 30.0 + degreeInSign
    }

    /// D-40 Khavedamsa
    private func calculateD40Longitude(_ longitude: Double) -> Double {
        let signIndex = Int(longitude / 30.0)
        let degreeInSign = longitude.truncatingRemainder(dividingBy: 30.0)
        let part = 30.0 / 40.0
        let partIndex = Int(degreeInSign / part)

        // Odd signs start from Aries, even from Libra
        let isOddSign = (signIndex % 2) == 0
        let startSign = isOddSign ? 0 : 6

        let resultSign = (startSign + partIndex) % 12
        let resultDegree = (degreeInSign.truncatingRemainder(dividingBy: part)) * 40

        return Double(resultSign) * 30.0 + resultDegree
    }

    /// D-45 Akshavedamsa
    private func calculateD45Longitude(_ longitude: Double) -> Double {
        let signIndex = Int(longitude / 30.0)
        let degreeInSign = longitude.truncatingRemainder(dividingBy: 30.0)
        let part = 30.0 / 45.0
        let partIndex = Int(degreeInSign / part)

        // Movable signs start from Aries, Fixed from Leo, Dual from Sagittarius
        let signType = signIndex % 3
        let startSign: Int
        switch signType {
        case 0: startSign = 0
        case 1: startSign = 4
        default: startSign = 8
        }

        let resultSign = (startSign + partIndex) % 12
        let resultDegree = (degreeInSign.truncatingRemainder(dividingBy: part)) * 45

        return Double(resultSign) * 30.0 + resultDegree
    }

    /// D-60 Shashtiamsa: Destiny
    private func calculateD60Longitude(_ longitude: Double) -> Double {
        let signIndex = Int(longitude / 30.0)
        let degreeInSign = longitude.truncatingRemainder(dividingBy: 30.0)
        let part = 30.0 / 60.0  // 0.5°
        let partIndex = Int(degreeInSign / part)

        // Starts from same sign
        let resultSign = (signIndex + (partIndex / 5)) % 12
        let resultDegree = (degreeInSign.truncatingRemainder(dividingBy: part)) * 60

        return Double(resultSign) * 30.0 + resultDegree
    }
}
