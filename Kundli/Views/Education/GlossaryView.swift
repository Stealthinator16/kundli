import SwiftUI

/// A-Z glossary view for browsing all astrology terms
struct GlossaryView: View {
    @State private var searchText = ""
    @State private var selectedCategory: TermCategory?

    private var filteredTerms: [AstrologyTerm] {
        var terms = EducationService.shared.allTerms

        if let category = selectedCategory {
            terms = terms.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            terms = terms.filter {
                $0.englishName.localizedCaseInsensitiveContains(searchText) ||
                $0.sanskritName.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }

        return terms.sorted { $0.sanskritName < $1.sanskritName }
    }

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Search bar
                searchBar
                    .padding(.horizontal)
                    .padding(.top, 8)

                // Category filter chips
                categoryFilterChips
                    .padding(.vertical, 12)

                // Terms list
                if filteredTerms.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(filteredTerms) { term in
                                GlossaryTermRow(term: term)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationTitle("Glossary")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.kundliTextSecondary)

            TextField("Search Sanskrit or English...", text: $searchText)
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
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.kundliCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    // MARK: - Category Filter

    private var categoryFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All categories chip
                categoryChip(nil, title: "All")

                // Individual category chips
                ForEach(TermCategory.allCases, id: \.self) { category in
                    categoryChip(category, title: category.rawValue)
                }
            }
            .padding(.horizontal)
        }
    }

    private func categoryChip(_ category: TermCategory?, title: String) -> some View {
        let isSelected = selectedCategory == category

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategory = category
            }
        } label: {
            Text(title)
                .font(.kundliCaption)
                .foregroundColor(isSelected ? .kundliBackground : .kundliTextPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.kundliPrimary : Color.kundliCardBg)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.white.opacity(0.1), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.kundliTextSecondary)

            Text("No terms found")
                .font(.kundliHeadline)
                .foregroundColor(.kundliTextPrimary)

            if selectedCategory != nil {
                Text("Try selecting 'All' or a different category")
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Glossary Term Row

struct GlossaryTermRow: View {
    let term: AstrologyTerm
    @State private var showSheet = false

    var body: some View {
        Button {
            showSheet = true
        } label: {
            HStack(spacing: 14) {
                // Icon
                if let iconName = term.iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 18))
                        .foregroundColor(.kundliPrimary)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color.kundliPrimary.opacity(0.15))
                        )
                } else {
                    Image(systemName: term.category.iconName)
                        .font(.system(size: 18))
                        .foregroundColor(.kundliPrimary)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color.kundliPrimary.opacity(0.15))
                        )
                }

                // Names
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

                // Category badge
                Text(term.category.rawValue)
                    .font(.kundliCaption2)
                    .foregroundColor(.kundliPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.kundliPrimary.opacity(0.1))
                    )
            }
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
        .sheet(isPresented: $showSheet) {
            TermExplanationSheet(termId: term.id)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        GlossaryView()
    }
}
