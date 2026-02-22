import Foundation
import os

/// Service for managing educational content - terms, articles, and search
@Observable
final class EducationService {
    static let shared = EducationService()

    private(set) var terms: [String: AstrologyTerm] = [:]
    private(set) var articles: [String: LearningArticle] = [:]
    private var termsByCategory: [TermCategory: [AstrologyTerm]] = [:]
    private var searchIndex: [String: Set<String>] = [:]  // tag → term IDs
    private var isLoaded = false

    private init() {}

    // MARK: - Loading

    /// Load all educational data from JSON files
    func loadData() {
        guard !isLoaded else { return }

        loadTerms()
        loadArticles()
        buildSearchIndex()
        isLoaded = true
    }

    private func loadTerms() {
        guard let url = Bundle.main.url(forResource: "astrology_terms", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            AppLogger.education.error("Could not load astrology_terms.json")
            return
        }

        do {
            let decoder = JSONDecoder()
            let loadedTerms = try decoder.decode([AstrologyTerm].self, from: data)

            for term in loadedTerms {
                terms[term.id] = term

                // Organize by category
                if termsByCategory[term.category] == nil {
                    termsByCategory[term.category] = []
                }
                termsByCategory[term.category]?.append(term)
            }

            AppLogger.education.info("Loaded \(loadedTerms.count) terms")
        } catch {
            AppLogger.education.error("Error decoding terms: \(error.localizedDescription)")
        }
    }

    private func loadArticles() {
        guard let url = Bundle.main.url(forResource: "learning_articles", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            AppLogger.education.error("Could not load learning_articles.json")
            return
        }

        do {
            let decoder = JSONDecoder()
            let loadedArticles = try decoder.decode([LearningArticle].self, from: data)

            for article in loadedArticles {
                articles[article.id] = article
            }

            AppLogger.education.info("Loaded \(loadedArticles.count) articles")
        } catch {
            AppLogger.education.error("Error decoding articles: \(error.localizedDescription)")
        }
    }

    private func buildSearchIndex() {
        for (termId, term) in terms {
            // Index by tags
            for tag in term.tags {
                let normalizedTag = tag.lowercased()
                if searchIndex[normalizedTag] == nil {
                    searchIndex[normalizedTag] = []
                }
                searchIndex[normalizedTag]?.insert(termId)
            }

            // Index by name words
            let nameWords = (term.englishName + " " + term.sanskritName)
                .lowercased()
                .split(separator: " ")
                .map(String.init)

            for word in nameWords {
                if searchIndex[word] == nil {
                    searchIndex[word] = []
                }
                searchIndex[word]?.insert(termId)
            }
        }
    }

    // MARK: - Term Lookup

    /// Get a term by its ID
    func term(forId id: String) -> AstrologyTerm? {
        return terms[id]
    }

    /// Get all terms in a category
    func terms(forCategory category: TermCategory) -> [AstrologyTerm] {
        return termsByCategory[category] ?? []
    }

    /// Get child terms of a parent term
    func childTerms(of parentId: String) -> [AstrologyTerm] {
        return terms.values.filter { $0.parentTermId == parentId }
    }

    /// Get related terms for a given term
    func relatedTerms(for termId: String) -> [AstrologyTerm] {
        guard let term = terms[termId] else { return [] }
        return term.relatedTermIds.compactMap { terms[$0] }
    }

    /// Get all terms sorted alphabetically
    var allTerms: [AstrologyTerm] {
        return terms.values.sorted { $0.englishName < $1.englishName }
    }

    // MARK: - Convenience Lookups

    /// Get tithi term by paksha and number
    func tithiTerm(paksha: Paksha, number: Int) -> AstrologyTerm? {
        let id = "tithi.\(paksha.rawValue.lowercased()).\(number)"
        return terms[id]
    }

    /// Get nakshatra term by name
    func nakshatraTerm(name: String) -> AstrologyTerm? {
        let id = "nakshatra.\(name.lowercased().replacingOccurrences(of: " ", with: "-"))"
        return terms[id]
    }

    /// Get planet term by name
    func planetTerm(name: String) -> AstrologyTerm? {
        let id = "planet.\(name.lowercased())"
        return terms[id]
    }

    /// Get zodiac sign term by name
    func signTerm(name: String) -> AstrologyTerm? {
        let id = "sign.\(name.lowercased())"
        return terms[id]
    }

    /// Get house term by number
    func houseTerm(number: Int) -> AstrologyTerm? {
        let id = "house.\(number)"
        return terms[id]
    }

    /// Get yoga term by name
    func yogaTerm(name: String) -> AstrologyTerm? {
        let id = "yoga.\(name.lowercased().replacingOccurrences(of: " ", with: "-"))"
        return terms[id]
    }

    /// Get dosha term by name
    func doshaTerm(name: String) -> AstrologyTerm? {
        let id = "dosha.\(name.lowercased().replacingOccurrences(of: " ", with: "-"))"
        return terms[id]
    }

    /// Get gun (ashtakoot) term by name
    func gunTerm(name: String) -> AstrologyTerm? {
        let id = "ashtakoot.\(name.lowercased().replacingOccurrences(of: " ", with: "-"))"
        return terms[id]
    }

    // MARK: - Articles

    /// Get an article by its ID
    func article(forId id: String) -> LearningArticle? {
        return articles[id]
    }

    /// Get all articles in a category
    func articles(forCategory category: TermCategory) -> [LearningArticle] {
        return articles.values.filter { $0.category == category }
    }

    /// Get featured articles for the learning center
    func featuredArticles() -> [LearningArticle] {
        let featuredIds = ["what-is-vedic-astrology", "understanding-your-kundli", "the-9-planets"]
        return featuredIds.compactMap { articles[$0] }
    }

    /// Get all articles sorted by title
    var allArticles: [LearningArticle] {
        return articles.values.sorted { $0.title < $1.title }
    }

    // MARK: - Search

    /// Search for terms and articles matching a query
    func search(query: String) -> [SearchResult] {
        guard !query.isEmpty else { return [] }

        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespaces)
        var results: [SearchResult] = []
        var seenIds = Set<String>()

        // Search terms
        for (termId, term) in terms {
            let matchScore = calculateMatchScore(for: term, query: normalizedQuery)
            if matchScore > 0 {
                results.append(SearchResult(
                    id: termId,
                    type: .term,
                    title: term.sanskritName,
                    subtitle: term.englishName,
                    relevanceScore: matchScore
                ))
                seenIds.insert(termId)
            }
        }

        // Search articles
        for (articleId, article) in articles {
            let matchScore = calculateArticleMatchScore(for: article, query: normalizedQuery)
            if matchScore > 0 {
                results.append(SearchResult(
                    id: articleId,
                    type: .article,
                    title: article.title,
                    subtitle: article.subtitle ?? article.category.rawValue,
                    relevanceScore: matchScore
                ))
            }
        }

        // Sort by relevance
        return results.sorted { $0.relevanceScore > $1.relevanceScore }
    }

    private func calculateMatchScore(for term: AstrologyTerm, query: String) -> Double {
        var score = 0.0

        // Exact match in Sanskrit name
        if term.sanskritName.lowercased() == query {
            score += 100
        } else if term.sanskritName.lowercased().contains(query) {
            score += 50
        }

        // Exact match in English name
        if term.englishName.lowercased() == query {
            score += 90
        } else if term.englishName.lowercased().contains(query) {
            score += 45
        }

        // Match in tags
        for tag in term.tags {
            if tag.lowercased() == query {
                score += 30
            } else if tag.lowercased().contains(query) {
                score += 15
            }
        }

        // Match in short explanation
        if term.shortExplanation.lowercased().contains(query) {
            score += 10
        }

        return score
    }

    private func calculateArticleMatchScore(for article: LearningArticle, query: String) -> Double {
        var score = 0.0

        if article.title.lowercased() == query {
            score += 100
        } else if article.title.lowercased().contains(query) {
            score += 50
        }

        if let subtitle = article.subtitle, subtitle.lowercased().contains(query) {
            score += 30
        }

        if article.introduction.lowercased().contains(query) {
            score += 10
        }

        return score
    }
}

/// Result from searching educational content
struct SearchResult: Identifiable {
    let id: String
    let type: SearchResultType
    let title: String
    let subtitle: String
    let relevanceScore: Double
}

/// Type of search result
enum SearchResultType {
    case term
    case article

    var iconName: String {
        switch self {
        case .term: return "character.book.closed"
        case .article: return "doc.text"
        }
    }
}
