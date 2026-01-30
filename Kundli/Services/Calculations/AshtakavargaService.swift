import Foundation

/// Service for calculating Ashtakavarga (8-fold strength points)
final class AshtakavargaService {
    static let shared = AshtakavargaService()

    private init() {}

    // MARK: - Main Calculation

    /// Calculate complete Ashtakavarga for all planets
    func calculateAshtakavarga(
        planetPositions: [VedicPlanetPosition],
        ascendantSignIndex: Int = 0
    ) -> AshtakavargaData {
        var bhinnaAshtakavarga: [String: [Int]] = [:]

        // Calculate Bhinna Ashtakavarga for each planet (including Rahu/Ketu)
        for planet in [VedicPlanet.sun, .moon, .mars, .mercury, .jupiter, .venus, .saturn, .rahu, .ketu] {
            let points = calculateBhinnaAshtakavarga(
                for: planet,
                positions: planetPositions,
                ascendantSignIndex: ascendantSignIndex
            )
            bhinnaAshtakavarga[planet.rawValue] = points
        }

        // Calculate Sarva Ashtakavarga (sum all Bhinna points for each sign)
        var sarvaAshtakavarga = [Int](repeating: 0, count: 12)
        for points in bhinnaAshtakavarga.values {
            for (index, point) in points.enumerated() {
                sarvaAshtakavarga[index] += point
            }
        }

        // Calculate planet totals
        var planetTotals: [String: Int] = [:]
        for (planet, points) in bhinnaAshtakavarga {
            planetTotals[planet] = points.reduce(0, +)
        }

        // Create sign analysis
        let signNames = ZodiacSign.allCases.map { $0.rawValue }
        let signAnalysis = sarvaAshtakavarga.enumerated().map { index, points in
            SignStrengthAnalysis(
                signIndex: index,
                signName: signNames[index],
                sarvaPoints: points
            )
        }

        return AshtakavargaData(
            bhinnaAshtakavarga: bhinnaAshtakavarga,
            sarvaAshtakavarga: sarvaAshtakavarga,
            planetTotals: planetTotals,
            signAnalysis: signAnalysis
        )
    }

    // MARK: - Bhinna Ashtakavarga Calculation

    /// Calculate Bhinna Ashtakavarga for a specific planet
    /// Returns array of 12 values (0-8 points for each sign)
    func calculateBhinnaAshtakavarga(
        for planet: VedicPlanet,
        positions: [VedicPlanetPosition],
        ascendantSignIndex: Int = 0
    ) -> [Int] {
        var signPoints = [Int](repeating: 0, count: 12)

        // Get the benefic positions for this planet from each contributor
        let contributors: [VedicPlanet] = [.sun, .moon, .mars, .mercury, .jupiter, .venus, .saturn]

        for signIndex in 0..<12 {
            var points = 0

            // Each planet contributes points based on benefic house positions
            for contributor in contributors {
                guard let contributorPosition = positions.first(where: { $0.planet == contributor }) else {
                    continue
                }

                let contributorSign = contributorPosition.signIndex
                let beneficHouses = getBeneficHouses(for: planet, from: contributor)

                // Check if the target sign is in a benefic house from contributor
                let houseFromContributor = (signIndex - contributorSign + 12) % 12 + 1

                if beneficHouses.contains(houseFromContributor) {
                    points += 1
                }
            }

            // Add point from Lagna (proper calculation)
            let lagnaContribution = calculateLagnaContribution(
                signIndex: signIndex,
                ascendantSign: ascendantSignIndex,
                forPlanet: planet
            )
            points += lagnaContribution

            signPoints[signIndex] = min(points, 8) // Max 8 points per sign
        }

        return signPoints
    }

    /// Calculate Lagna's contribution to Ashtakavarga
    /// Lagna contributes points based on its relationship to each sign
    private func calculateLagnaContribution(signIndex: Int, ascendantSign: Int, forPlanet: VedicPlanet) -> Int {
        let houseFromLagna = (signIndex - ascendantSign + 12) % 12 + 1

        // Lagna's benefic houses vary by planet (traditional values)
        let beneficHousesFromLagna: [Int]

        switch forPlanet {
        case .sun:
            beneficHousesFromLagna = [1, 2, 4, 7, 8, 9, 10, 11]
        case .moon:
            beneficHousesFromLagna = [3, 6, 10, 11]
        case .mars:
            beneficHousesFromLagna = [1, 3, 6, 10, 11]
        case .mercury:
            beneficHousesFromLagna = [1, 2, 4, 6, 8, 10, 11]
        case .jupiter:
            beneficHousesFromLagna = [1, 2, 4, 5, 6, 7, 9, 10, 11]
        case .venus:
            beneficHousesFromLagna = [1, 2, 3, 4, 5, 8, 9, 11]
        case .saturn:
            beneficHousesFromLagna = [3, 5, 6, 11]
        default:
            beneficHousesFromLagna = [1, 3, 6, 10, 11]  // Default
        }

        return beneficHousesFromLagna.contains(houseFromLagna) ? 1 : 0
    }

    /// Get houses where a planet receives benefic points from a contributor
    /// These are traditional Ashtakavarga house positions
    private func getBeneficHouses(for planet: VedicPlanet, from contributor: VedicPlanet) -> [Int] {
        // Traditional Ashtakavarga benefic positions
        // Format: Planet receiving -> Contributor -> Houses that give points

        switch (planet, contributor) {
        // Sun's Ashtakavarga
        case (.sun, .sun): return [1, 2, 4, 7, 8, 9, 10, 11]
        case (.sun, .moon): return [3, 6, 10, 11]
        case (.sun, .mars): return [1, 2, 4, 7, 8, 9, 10, 11]
        case (.sun, .mercury): return [3, 5, 6, 9, 10, 11, 12]
        case (.sun, .jupiter): return [5, 6, 9, 11]
        case (.sun, .venus): return [6, 7, 12]
        case (.sun, .saturn): return [1, 2, 4, 7, 8, 9, 10, 11]

        // Moon's Ashtakavarga
        case (.moon, .sun): return [3, 6, 7, 8, 10, 11]
        case (.moon, .moon): return [1, 3, 6, 7, 10, 11]
        case (.moon, .mars): return [2, 3, 5, 6, 9, 10, 11]
        case (.moon, .mercury): return [1, 3, 4, 5, 7, 8, 10, 11]
        case (.moon, .jupiter): return [1, 4, 7, 8, 10, 11, 12]
        case (.moon, .venus): return [3, 4, 5, 7, 9, 10, 11]
        case (.moon, .saturn): return [3, 5, 6, 11]

        // Mars' Ashtakavarga
        case (.mars, .sun): return [3, 5, 6, 10, 11]
        case (.mars, .moon): return [3, 6, 11]
        case (.mars, .mars): return [1, 2, 4, 7, 8, 10, 11]
        case (.mars, .mercury): return [3, 5, 6, 11]
        case (.mars, .jupiter): return [6, 10, 11, 12]
        case (.mars, .venus): return [6, 8, 11, 12]
        case (.mars, .saturn): return [1, 4, 7, 8, 9, 10, 11]

        // Mercury's Ashtakavarga
        case (.mercury, .sun): return [5, 6, 9, 11, 12]
        case (.mercury, .moon): return [2, 4, 6, 8, 10, 11]
        case (.mercury, .mars): return [1, 2, 4, 7, 8, 9, 10, 11]
        case (.mercury, .mercury): return [1, 3, 5, 6, 9, 10, 11, 12]
        case (.mercury, .jupiter): return [6, 8, 11, 12]
        case (.mercury, .venus): return [1, 2, 3, 4, 5, 8, 9, 11]
        case (.mercury, .saturn): return [1, 2, 4, 7, 8, 9, 10, 11]

        // Jupiter's Ashtakavarga
        case (.jupiter, .sun): return [1, 2, 3, 4, 7, 8, 9, 10, 11]
        case (.jupiter, .moon): return [2, 5, 7, 9, 11]
        case (.jupiter, .mars): return [1, 2, 4, 7, 8, 10, 11]
        case (.jupiter, .mercury): return [1, 2, 4, 5, 6, 9, 10, 11]
        case (.jupiter, .jupiter): return [1, 2, 3, 4, 7, 8, 10, 11]
        case (.jupiter, .venus): return [2, 5, 6, 9, 10, 11]
        case (.jupiter, .saturn): return [3, 5, 6, 12]

        // Venus' Ashtakavarga
        case (.venus, .sun): return [8, 11, 12]
        case (.venus, .moon): return [1, 2, 3, 4, 5, 8, 9, 11, 12]
        case (.venus, .mars): return [3, 5, 6, 9, 11, 12]
        case (.venus, .mercury): return [3, 5, 6, 9, 11]
        case (.venus, .jupiter): return [5, 8, 9, 10, 11]
        case (.venus, .venus): return [1, 2, 3, 4, 5, 8, 9, 10, 11]
        case (.venus, .saturn): return [3, 4, 5, 8, 9, 10, 11]

        // Saturn's Ashtakavarga
        case (.saturn, .sun): return [1, 2, 4, 7, 8, 10, 11]
        case (.saturn, .moon): return [3, 6, 11]
        case (.saturn, .mars): return [3, 5, 6, 10, 11, 12]
        case (.saturn, .mercury): return [6, 8, 9, 10, 11, 12]
        case (.saturn, .jupiter): return [5, 6, 11, 12]
        case (.saturn, .venus): return [6, 11, 12]
        case (.saturn, .saturn): return [3, 5, 6, 11]

        // Rahu's Ashtakavarga (Not traditional but useful for analysis)
        case (.rahu, .sun): return [3, 6, 10, 11]
        case (.rahu, .moon): return [3, 6, 11]
        case (.rahu, .mars): return [1, 3, 6, 10, 11]
        case (.rahu, .mercury): return [3, 5, 6, 11]
        case (.rahu, .jupiter): return [5, 6, 9, 11]
        case (.rahu, .venus): return [3, 4, 5, 9, 10, 11]
        case (.rahu, .saturn): return [3, 5, 6, 11]
        case (.rahu, .rahu): return [3, 6, 11]

        // Ketu's Ashtakavarga (Not traditional but useful for analysis)
        case (.ketu, .sun): return [3, 6, 9, 12]
        case (.ketu, .moon): return [3, 6, 9, 12]
        case (.ketu, .mars): return [3, 6, 9, 11, 12]
        case (.ketu, .mercury): return [3, 6, 9, 12]
        case (.ketu, .jupiter): return [3, 5, 6, 9, 12]
        case (.ketu, .venus): return [3, 5, 6, 9, 12]
        case (.ketu, .saturn): return [3, 6, 9, 11, 12]
        case (.ketu, .ketu): return [3, 6, 9, 12]

        default: return []
        }
    }

    // MARK: - Transit Analysis

    /// Analyze transit quality using Ashtakavarga
    func analyzeTransit(
        planet: VedicPlanet,
        transitSignIndex: Int,
        ashtakavargaData: AshtakavargaData
    ) -> AshtakavargaTransitAnalysis {
        let points = ashtakavargaData.points(for: planet.rawValue, in: transitSignIndex)

        return AshtakavargaTransitAnalysis(
            planet: planet.rawValue,
            currentSignIndex: transitSignIndex,
            points: points
        )
    }

    // MARK: - Sign Recommendations

    /// Get recommended signs for transit based on Ashtakavarga
    func getRecommendedTransitSigns(
        for planet: VedicPlanet,
        ashtakavargaData: AshtakavargaData
    ) -> [(signIndex: Int, signName: String, points: Int)] {
        guard let planetPoints = ashtakavargaData.bhinnaAshtakavarga[planet.rawValue] else {
            return []
        }

        let signNames = ZodiacSign.allCases.map { $0.rawValue }

        return planetPoints.enumerated()
            .map { (signIndex: $0.offset, signName: signNames[$0.offset], points: $0.element) }
            .sorted { $0.points > $1.points }
    }
}

// MARK: - Extension for Grid Display
extension AshtakavargaService {
    /// Create grid data for display
    func createGridData(from ashtakavargaData: AshtakavargaData) -> [[AshtakavargaCell]] {
        let planets = ["Sun", "Moon", "Mars", "Mercury", "Jupiter", "Venus", "Saturn"]
        var grid: [[AshtakavargaCell]] = []

        for planet in planets {
            var row: [AshtakavargaCell] = []
            for signIndex in 0..<12 {
                let points = ashtakavargaData.points(for: planet, in: signIndex)
                row.append(AshtakavargaCell(planet: planet, signIndex: signIndex, points: points))
            }
            grid.append(row)
        }

        return grid
    }
}
