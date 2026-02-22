import SwiftUI

/// Main Learning Center view - the hub for educational content
struct LearningCenterView: View {
    @State private var searchText = ""
    @State private var selectedSection: LearningSection?
    @State private var selectedTermId: String?

    private var searchResults: [SearchResult] {
        EducationService.shared.search(query: searchText)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.kundliBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Search bar
                        searchBar

                        if searchText.isEmpty {
                            // Featured article
                            featuredArticleCard

                            // Quick start guide
                            quickStartSection

                            // Browse by category
                            categoriesGrid

                            // All articles
                            allArticlesSection
                        } else {
                            // Search results
                            searchResultsView
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Learn Astrology")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: GlossaryView()) {
                        Image(systemName: "character.book.closed")
                            .foregroundColor(.kundliPrimary)
                    }
                }
            }
            .sheet(isPresented: Binding(
                get: { selectedTermId != nil },
                set: { if !$0 { selectedTermId = nil } }
            )) {
                if let termId = selectedTermId {
                    TermExplanationSheet(termId: termId)
                }
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.kundliTextSecondary)

            TextField("Search terms and articles...", text: $searchText)
                .foregroundColor(.kundliTextPrimary)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.kundliTextSecondary)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.kundliCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    // MARK: - Featured Article

    private var featuredArticleCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let featured = EducationService.shared.article(forId: "what-is-vedic-astrology") {
                NavigationLink(destination: ArticleView(articleId: featured.id)) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("FEATURED")
                                .font(.kundliCaption2)
                                .fontWeight(.bold)
                                .foregroundColor(.kundliPrimary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.kundliPrimary.opacity(0.2))
                                )

                            Spacer()

                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                Text("\(featured.readingTime) min")
                            }
                            .font(.kundliCaption2)
                            .foregroundColor(.kundliTextSecondary)
                        }

                        Text(featured.title)
                            .font(.kundliTitle3)
                            .foregroundColor(.kundliTextPrimary)
                            .multilineTextAlignment(.leading)

                        if let subtitle = featured.subtitle {
                            Text(subtitle)
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliTextSecondary)
                                .multilineTextAlignment(.leading)
                        }

                        HStack {
                            Text("Start Reading")
                                .font(.kundliSubheadline)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.kundliPrimary)
                        .padding(.top, 8)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.kundliPrimary.opacity(0.15),
                                        Color.kundliCardBg
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.kundliPrimary.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Quick Start Section

    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Quick Start", icon: "sparkles")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(LearningSection.allCases.prefix(4)) { section in
                        quickStartCard(section)
                    }
                }
            }
        }
    }

    private func quickStartCard(_ section: LearningSection) -> some View {
        NavigationLink {
            LearningSectionView(section: section)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: section.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(.kundliPrimary)

                Text(section.rawValue)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(width: 100, height: 90)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.kundliCardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Categories Grid

    private var categoriesGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Browse by Topic", icon: "square.grid.2x2")

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(TermCategory.allCases.prefix(8), id: \.self) { category in
                    categoryCard(category)
                }
            }
        }
    }

    private func categoryCard(_ category: TermCategory) -> some View {
        NavigationLink {
            CategoryDetailView(category: category)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: category.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(.kundliPrimary)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.rawValue)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextPrimary)

                    Text("\(EducationService.shared.terms(forCategory: category).count) terms")
                        .font(.kundliCaption2)
                        .foregroundColor(.kundliTextSecondary)
                }

                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.kundliCardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - All Articles Section

    private var allArticlesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("All Articles", icon: "doc.text")

            VStack(spacing: 12) {
                ForEach(EducationService.shared.allArticles) { article in
                    articleRow(article)
                }
            }
        }
    }

    private func articleRow(_ article: LearningArticle) -> some View {
        NavigationLink(destination: ArticleView(articleId: article.id)) {
            HStack(spacing: 14) {
                Image(systemName: article.category.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(.kundliPrimary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color.kundliPrimary.opacity(0.15))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(article.title)
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextPrimary)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text(article.difficulty.rawValue)
                            .font(.kundliCaption2)
                            .foregroundColor(.kundliTextSecondary)

                        Text("•")
                            .foregroundColor(.kundliTextTertiary)

                        Text("\(article.readingTime) min read")
                            .font(.kundliCaption2)
                            .foregroundColor(.kundliTextSecondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.kundliTextSecondary)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.kundliCardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Search Results

    private var searchResultsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            if searchResults.isEmpty {
                emptySearchView
            } else {
                Text("\(searchResults.count) results")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)

                VStack(spacing: 12) {
                    ForEach(searchResults) { result in
                        searchResultRow(result)
                    }
                }
            }
        }
    }

    private var emptySearchView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.kundliTextSecondary)

            Text("No results found")
                .font(.kundliHeadline)
                .foregroundColor(.kundliTextPrimary)

            Text("Try a different search term")
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private func searchResultRow(_ result: SearchResult) -> some View {
        Group {
            if result.type == .term {
                Button {
                    selectedTermId = result.id
                } label: {
                    searchResultContent(result)
                }
            } else {
                NavigationLink(destination: ArticleView(articleId: result.id)) {
                    searchResultContent(result)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func searchResultContent(_ result: SearchResult) -> some View {
        HStack(spacing: 12) {
            Image(systemName: result.type.iconName)
                .font(.system(size: 16))
                .foregroundColor(.kundliPrimary)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.kundliPrimary.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(result.title)
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliTextPrimary)

                Text(result.subtitle)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)
            }

            Spacer()

            Image(systemName: result.type == .term ? "info.circle" : "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.kundliTextSecondary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.kundliCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    // MARK: - Helper Views

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.kundliPrimary)
            Text(title)
                .font(.kundliHeadline)
                .foregroundColor(.kundliTextPrimary)
        }
    }
}

// MARK: - Learning Section View

struct LearningSectionView: View {
    let section: LearningSection

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: section.iconName)
                            .font(.system(size: 32))
                            .foregroundColor(.kundliPrimary)

                        Text(section.description)
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextSecondary)
                    }
                    .padding(.bottom, 8)

                    // Articles in this section
                    ForEach(section.articleIds, id: \.self) { articleId in
                        if let article = EducationService.shared.article(forId: articleId) {
                            NavigationLink(destination: ArticleView(articleId: articleId)) {
                                articleCard(article)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(section.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func articleCard(_ article: LearningArticle) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(article.title)
                .font(.kundliHeadline)
                .foregroundColor(.kundliTextPrimary)

            if let subtitle = article.subtitle {
                Text(subtitle)
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliTextSecondary)
            }

            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text("\(article.readingTime) min")
                }
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)

                HStack(spacing: 4) {
                    Image(systemName: article.difficulty.iconName)
                    Text(article.difficulty.rawValue)
                }
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.kundliPrimary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.kundliCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Category Detail View

struct CategoryDetailView: View {
    let category: TermCategory

    private var terms: [AstrologyTerm] {
        EducationService.shared.terms(forCategory: category)
    }

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: category.iconName)
                            .font(.system(size: 32))
                            .foregroundColor(.kundliPrimary)

                        Text(category.description)
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextSecondary)

                        Text("\(terms.count) terms")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextTertiary)
                    }
                    .padding(.bottom, 8)

                    // Terms list
                    ForEach(terms) { term in
                        TermRowView(term: term)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TermRowView: View {
    let term: AstrologyTerm
    @State private var showSheet = false

    var body: some View {
        Button {
            showSheet = true
        } label: {
            HStack(spacing: 14) {
                if let iconName = term.iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 18))
                        .foregroundColor(.kundliPrimary)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color.kundliPrimary.opacity(0.15))
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(term.sanskritName)
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextPrimary)

                    Text(term.englishName)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "info.circle")
                    .font(.system(size: 14))
                    .foregroundColor(.kundliPrimary.opacity(0.6))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.kundliCardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showSheet) {
            TermExplanationSheet(termId: term.id)
        }
    }
}

// MARK: - Preview

#Preview {
    LearningCenterView()
}
