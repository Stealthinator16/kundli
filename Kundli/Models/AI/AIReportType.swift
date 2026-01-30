//
//  AIReportType.swift
//  Kundli
//
//  Enum defining the types of AI-generated reports available.
//

import Foundation

enum AIReportType: String, CaseIterable, Codable, Identifiable {
    case career = "Career & Profession"
    case health = "Health & Wellness"
    case relationships = "Relationships & Marriage"
    case finance = "Finance & Wealth"
    case family = "Family & Children"
    case spirituality = "Spirituality & Growth"
    case personality = "Personality & Self"
    case education = "Education & Learning"
    case travel = "Travel & Foreign"
    case legal = "Legal & Government"
    case longevity = "Longevity & Vitality"
    case lucky = "Lucky Factors"
    case yearAhead = "Year Ahead Forecast"
    case remedies = "Remedies & Solutions"
    case marriage = "Marriage Timing"
    case comprehensive = "Complete Life Overview"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .career:
            return "briefcase.fill"
        case .health:
            return "heart.fill"
        case .relationships:
            return "heart.circle.fill"
        case .finance:
            return "indianrupeesign.circle.fill"
        case .family:
            return "figure.2.and.child.holdinghands"
        case .spirituality:
            return "sparkles"
        case .personality:
            return "person.fill"
        case .education:
            return "book.fill"
        case .travel:
            return "airplane"
        case .legal:
            return "building.columns.fill"
        case .longevity:
            return "heart.text.square.fill"
        case .lucky:
            return "star.fill"
        case .yearAhead:
            return "calendar"
        case .remedies:
            return "leaf.fill"
        case .marriage:
            return "rings.fill"
        case .comprehensive:
            return "chart.pie.fill"
        }
    }

    var shortTitle: String {
        switch self {
        case .career:
            return "Career"
        case .health:
            return "Health"
        case .relationships:
            return "Relationships"
        case .finance:
            return "Finance"
        case .family:
            return "Family"
        case .spirituality:
            return "Spirituality"
        case .personality:
            return "Personality"
        case .education:
            return "Education"
        case .travel:
            return "Travel"
        case .legal:
            return "Legal"
        case .longevity:
            return "Longevity"
        case .lucky:
            return "Lucky Factors"
        case .yearAhead:
            return "Year Ahead"
        case .remedies:
            return "Remedies"
        case .marriage:
            return "Marriage"
        case .comprehensive:
            return "Comprehensive"
        }
    }

    var description: String {
        switch self {
        case .career:
            return "Professional growth, career paths, and work-related insights"
        case .health:
            return "Physical and mental wellness, vitality, and health considerations"
        case .relationships:
            return "Love, marriage, partnerships, and interpersonal dynamics"
        case .finance:
            return "Wealth accumulation, financial opportunities, and prosperity"
        case .family:
            return "Family relationships, children, and domestic harmony"
        case .spirituality:
            return "Spiritual evolution, inner growth, and life purpose"
        case .personality:
            return "Self-identity, temperament, physical appearance, and life approach"
        case .education:
            return "Academic success, learning style, higher education, and knowledge"
        case .travel:
            return "Short and long journeys, foreign settlement, and immigration"
        case .legal:
            return "Legal matters, government relations, authority, and politics"
        case .longevity:
            return "Life span indicators, vitality, recovery, and critical periods"
        case .lucky:
            return "Lucky numbers, colors, days, directions, and gemstones"
        case .yearAhead:
            return "Month-by-month predictions, transit effects, and key dates"
        case .remedies:
            return "Gemstones, mantras, charity, fasting, and pujas for afflictions"
        case .marriage:
            return "When to marry, spouse timing, and muhurta recommendations"
        case .comprehensive:
            return "Complete life summary covering all areas of your chart"
        }
    }

    /// Houses to emphasize for this report type
    var relatedHouses: [Int] {
        switch self {
        case .career:
            return [1, 2, 6, 10]
        case .health:
            return [1, 6, 8]
        case .relationships:
            return [5, 7, 8, 12]
        case .finance:
            return [2, 5, 8, 11]
        case .family:
            return [2, 4, 5]
        case .spirituality:
            return [5, 9, 12]
        case .personality:
            return [1, 5, 9]
        case .education:
            return [2, 4, 5, 9]
        case .travel:
            return [3, 9, 12]
        case .legal:
            return [6, 9, 10]
        case .longevity:
            return [1, 3, 8]
        case .lucky:
            return [5, 9, 11]
        case .yearAhead:
            return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
        case .remedies:
            return [6, 8, 12]
        case .marriage:
            return [2, 7, 8, 11]
        case .comprehensive:
            return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
        }
    }

    /// Key planets for this report type
    var keyPlanets: [String] {
        switch self {
        case .career:
            return ["Sun", "Saturn", "Mercury"]
        case .health:
            return ["Sun", "Moon", "Mars"]
        case .relationships:
            return ["Venus", "Moon", "Mars"]
        case .finance:
            return ["Jupiter", "Venus", "Mercury"]
        case .family:
            return ["Jupiter", "Moon", "Venus"]
        case .spirituality:
            return ["Jupiter", "Ketu", "Moon"]
        case .personality:
            return ["Sun", "Moon", "Ascendant Lord"]
        case .education:
            return ["Mercury", "Jupiter", "Moon"]
        case .travel:
            return ["Moon", "Rahu", "Jupiter"]
        case .legal:
            return ["Sun", "Jupiter", "Saturn"]
        case .longevity:
            return ["Saturn", "Mars", "Sun"]
        case .lucky:
            return ["Jupiter", "Venus", "Moon"]
        case .yearAhead:
            return ["Current Dasha Lords"]
        case .remedies:
            return ["Weak/Afflicted Planets"]
        case .marriage:
            return ["Venus", "Jupiter", "Moon"]
        case .comprehensive:
            return ["Sun", "Moon", "Mars", "Mercury", "Jupiter", "Venus", "Saturn", "Rahu", "Ketu"]
        }
    }

    /// Gradient colors for visual distinction
    var gradientColors: (start: String, end: String) {
        switch self {
        case .career:
            return ("3d5a80", "293241")
        case .health:
            return ("4a7c59", "2d4a3e")
        case .relationships:
            return ("8b4557", "5a2d3a")
        case .finance:
            return ("7d6608", "4a3d05")
        case .family:
            return ("6b5b95", "4a3d6b")
        case .spirituality:
            return ("5a5a8f", "3a3a5f")
        case .personality:
            return ("d4a574", "8b6914")
        case .education:
            return ("4a90a4", "2d5a6b")
        case .travel:
            return ("5dade2", "2e86ab")
        case .legal:
            return ("34495e", "1a252f")
        case .longevity:
            return ("27ae60", "1e7e4a")
        case .lucky:
            return ("f4d03f", "b8860b")
        case .yearAhead:
            return ("8e44ad", "5b2c6f")
        case .remedies:
            return ("1abc9c", "16a085")
        case .marriage:
            return ("e74c3c", "922b21")
        case .comprehensive:
            return ("3f51b5", "283593")
        }
    }
}
