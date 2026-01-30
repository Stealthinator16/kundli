import Foundation

/// Represents Ashtakavarga (8-fold strength points) calculation
struct AshtakavargaData: Codable {
    /// Bhinna Ashtakavarga - Individual planet contributions (9 planets x 12 signs)
    let bhinnaAshtakavarga: [String: [Int]]  // Planet name -> array of 12 sign points

    /// Sarva Ashtakavarga - Combined points for each sign (sum of all planets)
    let sarvaAshtakavarga: [Int]  // 12 values, one per sign (0-56 each)

    /// Planet-wise total points across all signs
    let planetTotals: [String: Int]

    /// Sign-wise analysis
    let signAnalysis: [SignStrengthAnalysis]

    init(
        bhinnaAshtakavarga: [String: [Int]],
        sarvaAshtakavarga: [Int],
        planetTotals: [String: Int],
        signAnalysis: [SignStrengthAnalysis]
    ) {
        self.bhinnaAshtakavarga = bhinnaAshtakavarga
        self.sarvaAshtakavarga = sarvaAshtakavarga
        self.planetTotals = planetTotals
        self.signAnalysis = signAnalysis
    }

    // MARK: - Helper Methods

    /// Get points for a specific planet in a specific sign
    func points(for planet: String, in signIndex: Int) -> Int {
        guard let planetPoints = bhinnaAshtakavarga[planet], signIndex < planetPoints.count else {
            return 0
        }
        return planetPoints[signIndex]
    }

    /// Get total Sarva Ashtakavarga points for a sign
    func sarvaPoints(for signIndex: Int) -> Int {
        guard signIndex < sarvaAshtakavarga.count else { return 0 }
        return sarvaAshtakavarga[signIndex]
    }

    /// Get signs with points below threshold (weak signs)
    func weakSigns(threshold: Int = 25) -> [Int] {
        sarvaAshtakavarga.enumerated()
            .filter { $0.element < threshold }
            .map { $0.offset }
    }

    /// Get signs with points above threshold (strong signs)
    func strongSigns(threshold: Int = 30) -> [Int] {
        sarvaAshtakavarga.enumerated()
            .filter { $0.element >= threshold }
            .map { $0.offset }
    }

    /// Get the strongest sign
    var strongestSign: (index: Int, points: Int)? {
        guard let maxPoints = sarvaAshtakavarga.max(),
              let index = sarvaAshtakavarga.firstIndex(of: maxPoints) else {
            return nil
        }
        return (index, maxPoints)
    }

    /// Get the weakest sign
    var weakestSign: (index: Int, points: Int)? {
        guard let minPoints = sarvaAshtakavarga.min(),
              let index = sarvaAshtakavarga.firstIndex(of: minPoints) else {
            return nil
        }
        return (index, minPoints)
    }

    /// Total Sarva Ashtakavarga points (should be 337 for standard calculation)
    var totalPoints: Int {
        sarvaAshtakavarga.reduce(0, +)
    }
}

// MARK: - Sign Strength Analysis
struct SignStrengthAnalysis: Codable, Identifiable {
    let id: UUID
    let signIndex: Int
    let signName: String
    let sarvaPoints: Int
    let strength: SignStrength
    let recommendation: String

    init(
        id: UUID = UUID(),
        signIndex: Int,
        signName: String,
        sarvaPoints: Int
    ) {
        self.id = id
        self.signIndex = signIndex
        self.signName = signName
        self.sarvaPoints = sarvaPoints

        // Determine strength level
        if sarvaPoints >= 30 {
            self.strength = .strong
            self.recommendation = "Favorable for matters related to this sign/house"
        } else if sarvaPoints >= 25 {
            self.strength = .moderate
            self.recommendation = "Average results expected"
        } else {
            self.strength = .weak
            self.recommendation = "May need remedies or caution in related matters"
        }
    }
}

enum SignStrength: String, Codable {
    case strong = "Strong"
    case moderate = "Moderate"
    case weak = "Weak"

    var colorName: String {
        switch self {
        case .strong: return "green"
        case .moderate: return "yellow"
        case .weak: return "red"
        }
    }
}

// MARK: - Ashtakavarga Grid Cell
struct AshtakavargaCell: Identifiable {
    let id = UUID()
    let planet: String
    let signIndex: Int
    let points: Int

    var isStrong: Bool {
        points >= 4  // 4 or more points is considered good
    }

    var strengthLevel: CellStrength {
        switch points {
        case 6...8: return .veryStrong
        case 4...5: return .strong
        case 2...3: return .average
        default: return .weak
        }
    }
}

enum CellStrength: String {
    case veryStrong = "Very Strong"
    case strong = "Strong"
    case average = "Average"
    case weak = "Weak"

    var colorName: String {
        switch self {
        case .veryStrong: return "green"
        case .strong: return "blue"
        case .average: return "yellow"
        case .weak: return "red"
        }
    }
}

// MARK: - Transit Analysis using Ashtakavarga
struct AshtakavargaTransitAnalysis {
    let planet: String
    let currentSignIndex: Int
    let currentPoints: Int
    let isTransitFavorable: Bool
    let recommendation: String

    init(planet: String, currentSignIndex: Int, points: Int) {
        self.planet = planet
        self.currentSignIndex = currentSignIndex
        self.currentPoints = points
        self.isTransitFavorable = points >= 4

        if points >= 5 {
            self.recommendation = "\(planet) transit is highly favorable in this sign"
        } else if points >= 4 {
            self.recommendation = "\(planet) transit is moderately favorable"
        } else if points >= 3 {
            self.recommendation = "\(planet) transit gives mixed results"
        } else {
            self.recommendation = "\(planet) transit may bring challenges"
        }
    }
}

// MARK: - Factory for Sample Data
extension AshtakavargaData {
    static func empty() -> AshtakavargaData {
        let emptyPoints = [Int](repeating: 0, count: 12)
        let planets = ["Sun", "Moon", "Mars", "Mercury", "Jupiter", "Venus", "Saturn", "Rahu"]

        var bhinnaData: [String: [Int]] = [:]
        for planet in planets {
            bhinnaData[planet] = emptyPoints
        }

        return AshtakavargaData(
            bhinnaAshtakavarga: bhinnaData,
            sarvaAshtakavarga: emptyPoints,
            planetTotals: [:],
            signAnalysis: []
        )
    }
}
