import SwiftUI

/// View for displaying a full learning article
struct ArticleView: View {
    let articleId: String

    private var article: LearningArticle? {
        EducationService.shared.article(forId: articleId)
    }

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            ScrollView {
                if let article = article {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        articleHeader(article)

                        // Reading time & difficulty
                        metadataBadges(article)

                        // Introduction
                        Text(article.introduction)
                            .font(.kundliBody)
                            .foregroundColor(.kundliTextPrimary)
                            .lineSpacing(6)

                        // Content sections
                        ForEach(article.sections) { section in
                            articleSection(section)
                        }

                        // Key takeaways
                        if !article.keyTakeaways.isEmpty {
                            keyTakeawaysCard(article.keyTakeaways)
                        }

                        // Related articles
                        if !article.relatedArticleIds.isEmpty {
                            relatedArticlesSection(article.relatedArticleIds)
                        }

                        // Related terms
                        if !article.relatedTermIds.isEmpty {
                            relatedTermsSection(article.relatedTermIds)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding()
                } else {
                    articleNotFoundView
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    // MARK: - Header

    private func articleHeader(_ article: LearningArticle) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category badge
            HStack(spacing: 6) {
                Image(systemName: article.category.iconName)
                    .font(.system(size: 12))
                Text(article.category.rawValue)
                    .font(.kundliCaption)
            }
            .foregroundColor(.kundliPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.kundliPrimary.opacity(0.15))
            )

            // Title
            Text(article.title)
                .font(.kundliTitle)
                .foregroundColor(.kundliTextPrimary)

            // Subtitle
            if let subtitle = article.subtitle {
                Text(subtitle)
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliTextSecondary)
            }
        }
    }

    // MARK: - Metadata Badges

    private func metadataBadges(_ article: LearningArticle) -> some View {
        HStack(spacing: 16) {
            // Reading time
            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .font(.system(size: 12))
                Text("\(article.readingTime) min read")
                    .font(.kundliCaption)
            }
            .foregroundColor(.kundliTextSecondary)

            // Difficulty
            HStack(spacing: 6) {
                Image(systemName: article.difficulty.iconName)
                    .font(.system(size: 12))
                Text(article.difficulty.rawValue)
                    .font(.kundliCaption)
            }
            .foregroundColor(.kundliTextSecondary)

            Spacer()
        }
        .padding(.bottom, 8)
    }

    // MARK: - Article Section

    private func articleSection(_ section: ArticleSection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Illustration if present
            if let illustration = section.illustration {
                HStack {
                    Spacer()
                    Image(systemName: illustration)
                        .font(.system(size: 40))
                        .foregroundColor(.kundliPrimary.opacity(0.7))
                    Spacer()
                }
                .padding(.vertical, 8)
            }

            // Heading
            Text(section.heading)
                .font(.kundliTitle3)
                .foregroundColor(.kundliTextPrimary)

            // Content - parse and render with learnable terms
            RichArticleText(content: section.content)

            // Example if present
            if let example = section.example {
                exampleCard(example)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Example Card

    private func exampleCard(_ example: ArticleExample) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.kundliPrimary)
                Text(example.title)
                    .font(.kundliCaption)
                    .fontWeight(.semibold)
                    .foregroundColor(.kundliPrimary)
            }

            Text(example.description)
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)
                .lineSpacing(4)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.kundliPrimary.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.kundliPrimary.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Key Takeaways

    private func keyTakeawaysCard(_ takeaways: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.kundliSuccess)
                Text("Key Takeaways")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(takeaways, id: \.self) { takeaway in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.kundliSuccess)
                            .frame(width: 20)

                        Text(takeaway)
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextPrimary)
                            .lineSpacing(4)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.kundliSuccess.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.kundliSuccess.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Related Articles

    private func relatedArticlesSection(_ articleIds: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "doc.text")
                    .foregroundColor(.kundliPrimary)
                Text("Related Articles")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)
            }

            VStack(spacing: 10) {
                ForEach(articleIds, id: \.self) { relatedId in
                    if let related = EducationService.shared.article(forId: relatedId) {
                        NavigationLink(destination: ArticleView(articleId: relatedId)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(related.title)
                                        .font(.kundliSubheadline)
                                        .foregroundColor(.kundliTextPrimary)
                                        .lineLimit(1)

                                    Text("\(related.readingTime) min • \(related.difficulty.rawValue)")
                                        .font(.kundliCaption2)
                                        .foregroundColor(.kundliTextSecondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.kundliPrimary)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.kundliCardBg)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Related Terms

    private func relatedTermsSection(_ termIds: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "character.book.closed")
                    .foregroundColor(.kundliPrimary)
                Text("Terms in This Article")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)
            }

            FlowLayout(spacing: 8) {
                ForEach(termIds, id: \.self) { termId in
                    if let term = EducationService.shared.term(forId: termId) {
                        TermChipButton(term: term)
                    }
                }
            }
        }
    }

    // MARK: - Not Found View

    private var articleNotFoundView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.questionmark")
                .font(.system(size: 48))
                .foregroundColor(.kundliTextSecondary)

            Text("Article Not Found")
                .font(.kundliHeadline)
                .foregroundColor(.kundliTextPrimary)

            Text("The article '\(articleId)' is not yet available.")
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Rich Article Text

/// Renders article content with {term:termId} placeholders converted to learnable text
struct RichArticleText: View {
    let content: String

    var body: some View {
        // For now, just render as plain text
        // In a full implementation, this would parse {term:termId} markers
        Text(content)
            .font(.kundliBody)
            .foregroundColor(.kundliTextPrimary)
            .lineSpacing(6)
    }
}

// MARK: - Term Chip Button

struct TermChipButton: View {
    let term: AstrologyTerm
    @State private var showSheet = false

    var body: some View {
        Button {
            showSheet = true
        } label: {
            HStack(spacing: 4) {
                Text(term.sanskritName)
                    .font(.kundliCaption)
                Image(systemName: "info.circle")
                    .font(.system(size: 10))
            }
            .foregroundColor(.kundliPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.kundliCardBg)
                    .overlay(
                        Capsule()
                            .stroke(Color.kundliPrimary.opacity(0.3), lineWidth: 1)
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
    NavigationStack {
        ArticleView(articleId: "what-is-vedic-astrology")
    }
}
