import Foundation

struct KundliMatch: Identifiable {
    let id: UUID
    let person1: BirthDetails
    let person2: BirthDetails
    let gunMilan: GunMilan
    let manglikStatus: ManglikComparison
    let createdAt: Date

    init(
        id: UUID = UUID(),
        person1: BirthDetails,
        person2: BirthDetails,
        gunMilan: GunMilan,
        manglikStatus: ManglikComparison,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.person1 = person1
        self.person2 = person2
        self.gunMilan = gunMilan
        self.manglikStatus = manglikStatus
        self.createdAt = createdAt
    }

    var overallCompatibility: CompatibilityLevel {
        let score = gunMilan.totalScore
        if score >= 28 {
            return .excellent
        } else if score >= 21 {
            return .good
        } else if score >= 14 {
            return .average
        } else {
            return .poor
        }
    }
}

// MARK: - Gun Milan (Ashtakoot)
struct GunMilan {
    let varna: GunScore        // 1 point max
    let vashya: GunScore       // 2 points max
    let tara: GunScore         // 3 points max
    let yoni: GunScore         // 4 points max
    let grihaMaitri: GunScore  // 5 points max
    let gana: GunScore         // 6 points max
    let bhakoot: GunScore      // 7 points max
    let nadi: GunScore         // 8 points max

    var totalScore: Double {
        varna.score + vashya.score + tara.score + yoni.score +
        grihaMaitri.score + gana.score + bhakoot.score + nadi.score
    }

    var maxScore: Double {
        36.0
    }

    var percentage: Double {
        (totalScore / maxScore) * 100
    }

    var allScores: [GunScore] {
        [varna, vashya, tara, yoni, grihaMaitri, gana, bhakoot, nadi]
    }
}

struct GunScore: Identifiable {
    let id: UUID
    let name: String
    let score: Double
    let maxScore: Double
    let description: String

    init(
        id: UUID = UUID(),
        name: String,
        score: Double,
        maxScore: Double,
        description: String
    ) {
        self.id = id
        self.name = name
        self.score = score
        self.maxScore = maxScore
        self.description = description
    }

    var percentage: Double {
        (score / maxScore) * 100
    }

    var isFullMatch: Bool {
        score == maxScore
    }
}

// MARK: - Manglik Status
struct ManglikComparison {
    let person1Manglik: Bool
    let person2Manglik: Bool
    let isCompatible: Bool
    let remedySuggested: String?

    var statusDescription: String {
        switch (person1Manglik, person2Manglik) {
        case (false, false):
            return "Neither partner is Manglik - Compatible"
        case (true, true):
            return "Both partners are Manglik - Compatible"
        case (true, false):
            return "First partner is Manglik - Remedies may be needed"
        case (false, true):
            return "Second partner is Manglik - Remedies may be needed"
        }
    }
}

// MARK: - Compatibility Level
enum CompatibilityLevel: String {
    case excellent = "Excellent"
    case good = "Good"
    case average = "Average"
    case poor = "Poor"

    var emoji: String {
        switch self {
        case .excellent: return "💚"
        case .good: return "💛"
        case .average: return "🧡"
        case .poor: return "❤️"
        }
    }

    var description: String {
        switch self {
        case .excellent:
            return "Highly compatible match with excellent prospects"
        case .good:
            return "Good compatibility with positive outlook"
        case .average:
            return "Average compatibility, consider other factors"
        case .poor:
            return "Lower compatibility, remedies recommended"
        }
    }
}
