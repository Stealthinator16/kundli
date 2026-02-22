import Foundation

// Note: TermCategory is defined in AstrologyTerm.swift

/// Represents a learning article about Vedic astrology concepts
struct LearningArticle: Identifiable, Codable {
    let id: String
    let title: String
    let subtitle: String?
    let category: TermCategory
    let readingTime: Int                // Minutes
    let difficulty: DifficultyLevel
    let introduction: String
    let sections: [ArticleSection]
    let keyTakeaways: [String]
    let relatedArticleIds: [String]
    let relatedTermIds: [String]

    init(
        id: String,
        title: String,
        subtitle: String? = nil,
        category: TermCategory,
        readingTime: Int,
        difficulty: DifficultyLevel,
        introduction: String,
        sections: [ArticleSection],
        keyTakeaways: [String] = [],
        relatedArticleIds: [String] = [],
        relatedTermIds: [String] = []
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.category = category
        self.readingTime = readingTime
        self.difficulty = difficulty
        self.introduction = introduction
        self.sections = sections
        self.keyTakeaways = keyTakeaways
        self.relatedArticleIds = relatedArticleIds
        self.relatedTermIds = relatedTermIds
    }
}

/// A section within a learning article
struct ArticleSection: Identifiable, Codable {
    let id: String
    let heading: String
    let content: String                 // Markdown with {term:termId} placeholders
    let illustration: String?           // Asset name or SF Symbol
    let example: ArticleExample?

    init(
        id: String,
        heading: String,
        content: String,
        illustration: String? = nil,
        example: ArticleExample? = nil
    ) {
        self.id = id
        self.heading = heading
        self.content = content
        self.illustration = illustration
        self.example = example
    }
}

/// An example within an article section
struct ArticleExample: Codable {
    let title: String
    let description: String
    let visual: String?                 // Reference to a visual component

    init(title: String, description: String, visual: String? = nil) {
        self.title = title
        self.description = description
        self.visual = visual
    }
}

/// Difficulty level for learning content
enum DifficultyLevel: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    var iconName: String {
        switch self {
        case .beginner: return "1.circle.fill"
        case .intermediate: return "2.circle.fill"
        case .advanced: return "3.circle.fill"
        }
    }

    var description: String {
        switch self {
        case .beginner: return "No prior knowledge required"
        case .intermediate: return "Some astrology basics helpful"
        case .advanced: return "For experienced practitioners"
        }
    }
}

/// Sections for organizing learning content
enum LearningSection: String, CaseIterable, Identifiable {
    case gettingStarted = "Getting Started"
    case birthChart = "Your Birth Chart"
    case panchang = "Daily Panchang"
    case timing = "Timing & Dasha"
    case yogasAndDoshas = "Yogas & Doshas"
    case matching = "Kundli Matching"
    case advanced = "Advanced Topics"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .gettingStarted: return "sparkles"
        case .birthChart: return "square.grid.2x2"
        case .panchang: return "calendar"
        case .timing: return "clock"
        case .yogasAndDoshas: return "star.circle"
        case .matching: return "heart.fill"
        case .advanced: return "graduationcap"
        }
    }

    var description: String {
        switch self {
        case .gettingStarted: return "Introduction to Vedic astrology"
        case .birthChart: return "Understanding your Kundli"
        case .panchang: return "Daily almanac and timings"
        case .timing: return "Planetary periods and predictions"
        case .yogasAndDoshas: return "Special combinations and afflictions"
        case .matching: return "Compatibility analysis"
        case .advanced: return "Advanced astrological concepts"
        }
    }

    var articleIds: [String] {
        switch self {
        case .gettingStarted:
            return ["what-is-vedic-astrology", "understanding-your-kundli"]
        case .birthChart:
            return ["the-9-planets", "the-12-houses", "the-12-signs", "the-27-nakshatras"]
        case .panchang:
            return ["reading-your-panchang", "tithis-explained", "auspicious-timings"]
        case .timing:
            return ["planetary-periods-dasha", "transit-predictions"]
        case .yogasAndDoshas:
            return ["yogas-cosmic-combinations", "doshas-chart-challenges"]
        case .matching:
            return ["kundli-matching-explained", "ashtakoot-gun-milan"]
        case .advanced:
            return ["planetary-strength-shadbala", "divisional-charts-vargas", "remedies-in-astrology"]
        }
    }
}
