import Foundation

/// Service for calculating synastry (chart comparison) aspects
final class SynastryService {
    static let shared = SynastryService()

    private init() {}

    /// Aspect orbs for synastry calculations
    private let aspectOrbs: [TransitAspect: Double] = [
        .conjunction: 8,
        .opposition: 8,
        .trine: 7,
        .square: 7,
        .sextile: 5,
        .quincunx: 3
    ]

    /// Planet weights for scoring
    private let planetWeights: [String: Double] = [
        "sun": 10,
        "moon": 10,
        "venus": 9,
        "mars": 8,
        "mercury": 6,
        "jupiter": 7,
        "saturn": 7,
        "rahu": 4,
        "ketu": 4
    ]

    // MARK: - Main Calculation

    /// Calculate synastry between two kundlis
    func calculateSynastry(kundli1: Kundli, kundli2: Kundli) -> ChartComparison {
        var synastryAspects: [SynastryAspect] = []

        // Compare each planet in chart 1 with each planet in chart 2
        for planet1 in kundli1.planets {
            for planet2 in kundli2.planets {
                if let aspect = calculateAspect(planet1: planet1, planet2: planet2) {
                    synastryAspects.append(aspect)
                }
            }
        }

        // Sort by importance (personal planets first, then by orb tightness)
        synastryAspects.sort { aspect1, aspect2 in
            let weight1 = (planetWeights[aspect1.planet1Name.lowercased()] ?? 0) +
                          (planetWeights[aspect1.planet2Name.lowercased()] ?? 0)
            let weight2 = (planetWeights[aspect2.planet1Name.lowercased()] ?? 0) +
                          (planetWeights[aspect2.planet2Name.lowercased()] ?? 0)

            if weight1 != weight2 {
                return weight1 > weight2
            }
            return aspect1.orb < aspect2.orb
        }

        // Calculate composite score
        let score = calculateCompositeScore(aspects: synastryAspects)

        return ChartComparison(
            kundli1: kundli1,
            kundli2: kundli2,
            synastryAspects: synastryAspects,
            compositeScore: score
        )
    }

    // MARK: - Aspect Calculation

    /// Get total ecliptic longitude (0-360) from planet's sign and degree
    private func totalLongitude(for planet: Planet) -> Double {
        // Map sign name to index (0-11)
        let signIndex: Int
        switch planet.sign.lowercased() {
        case "aries", "mesha": signIndex = 0
        case "taurus", "vrishabha": signIndex = 1
        case "gemini", "mithuna": signIndex = 2
        case "cancer", "karka": signIndex = 3
        case "leo", "simha": signIndex = 4
        case "virgo", "kanya": signIndex = 5
        case "libra", "tula": signIndex = 6
        case "scorpio", "vrishchika": signIndex = 7
        case "sagittarius", "dhanu": signIndex = 8
        case "capricorn", "makara": signIndex = 9
        case "aquarius", "kumbha": signIndex = 10
        case "pisces", "meena": signIndex = 11
        default: signIndex = 0
        }
        return Double(signIndex * 30) + planet.degree + Double(planet.minutes) / 60.0 + Double(planet.seconds) / 3600.0
    }

    private func calculateAspect(planet1: Planet, planet2: Planet) -> SynastryAspect? {
        let long1 = totalLongitude(for: planet1)
        let long2 = totalLongitude(for: planet2)

        var distance = abs(long1 - long2)
        if distance > 180 { distance = 360 - distance }

        // Check each aspect type
        for (aspectType, orb) in aspectOrbs {
            if abs(distance - aspectType.degrees) <= orb {
                let exactOrb = abs(distance - aspectType.degrees)
                return SynastryAspect(
                    planet1Name: planet1.name,
                    planet1Symbol: planet1.symbol,
                    planet2Name: planet2.name,
                    planet2Symbol: planet2.symbol,
                    aspectType: aspectType,
                    orb: exactOrb
                )
            }
        }

        return nil
    }

    // MARK: - Score Calculation

    private func calculateCompositeScore(aspects: [SynastryAspect]) -> Double {
        guard !aspects.isEmpty else { return 50 }

        var totalScore: Double = 50  // Start at neutral
        var totalWeight: Double = 0

        for aspect in aspects {
            let planetWeight = (planetWeights[aspect.planet1Name.lowercased()] ?? 5) +
                               (planetWeights[aspect.planet2Name.lowercased()] ?? 5)

            // Orb factor (tighter orbs count more)
            let maxOrb = aspectOrbs[aspect.aspectType] ?? 8
            let orbFactor = 1 - (aspect.orb / maxOrb)

            // Aspect value
            let aspectValue: Double
            switch aspect.nature {
            case .harmonious:
                aspectValue = 10 * orbFactor
            case .challenging:
                aspectValue = -8 * orbFactor
            case .neutral:
                aspectValue = 3 * orbFactor
            case .adjusting:
                aspectValue = -2 * orbFactor
            }

            totalScore += aspectValue * (planetWeight / 10)
            totalWeight += planetWeight
        }

        // Normalize to 0-100 range
        let normalizedScore = min(max(totalScore, 0), 100)

        return normalizedScore
    }

    // MARK: - Analysis Methods

    /// Get key aspects (most important connections)
    func getKeyAspects(from comparison: ChartComparison, limit: Int = 5) -> [SynastryAspect] {
        Array(comparison.synastryAspects.prefix(limit))
    }

    /// Get aspects by category
    func getAspectsByNature(from comparison: ChartComparison) -> [AspectNature: [SynastryAspect]] {
        Dictionary(grouping: comparison.synastryAspects) { $0.nature }
    }

    /// Get romantic compatibility indicators (Venus/Mars/Moon aspects)
    func getRomanticIndicators(from comparison: ChartComparison) -> [SynastryAspect] {
        let romanticPlanets = ["venus", "mars", "moon"]
        return comparison.synastryAspects.filter { aspect in
            romanticPlanets.contains(aspect.planet1Name.lowercased()) ||
            romanticPlanets.contains(aspect.planet2Name.lowercased())
        }
    }

    /// Get communication indicators (Mercury aspects)
    func getCommunicationIndicators(from comparison: ChartComparison) -> [SynastryAspect] {
        return comparison.synastryAspects.filter { aspect in
            aspect.planet1Name.lowercased() == "mercury" ||
            aspect.planet2Name.lowercased() == "mercury"
        }
    }

    /// Get stability indicators (Saturn aspects)
    func getStabilityIndicators(from comparison: ChartComparison) -> [SynastryAspect] {
        return comparison.synastryAspects.filter { aspect in
            aspect.planet1Name.lowercased() == "saturn" ||
            aspect.planet2Name.lowercased() == "saturn"
        }
    }
}
