import SwiftUI

/// A detailed explanation sheet shown when tapping a learnable term
struct TermExplanationSheet: View {
    let termId: String
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRelatedTermId: String?

    private var term: AstrologyTerm? {
        EducationService.shared.term(forId: termId)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let term = term {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header: Sanskrit + English names
                        termHeader(term)

                        // Category badge + Group info
                        categorySection(term)

                        // Short explanation (highlighted card)
                        quickExplanationCard(term)

                        // Full explanation
                        fullExplanationSection(term)

                        // How it's calculated (if available)
                        if let calculation = term.howCalculated {
                            calculationSection(calculation)
                        }

                        // Significance
                        if let significance = term.significance {
                            significanceSection(significance)
                        }

                        // Related terms (tappable)
                        if !term.relatedTermIds.isEmpty {
                            relatedTermsSection(term.relatedTermIds)
                        }

                        // Link to Learning Center article
                        learnMoreButton(term)

                        Spacer(minLength: 40)
                    }
                    .padding()
                } else {
                    termNotFoundView
                }
            }
            .background(Color.kundliBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.kundliPrimary)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .sheet(item: $selectedRelatedTermId) { relatedId in
            TermExplanationSheet(termId: relatedId)
        }
    }

    // MARK: - Header

    private func termHeader(_ term: AstrologyTerm) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Icon and Sanskrit name
            HStack(spacing: 12) {
                if let iconName = term.iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 28))
                        .foregroundColor(.kundliPrimary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.kundliPrimary.opacity(0.15))
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(term.sanskritName)
                        .font(.kundliTitle2)
                        .foregroundColor(.kundliTextPrimary)

                    Text(term.englishName)
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextSecondary)
                }
            }
        }
    }

    // MARK: - Category Section

    private func categorySection(_ term: AstrologyTerm) -> some View {
        HStack(spacing: 12) {
            // Category badge
            HStack(spacing: 6) {
                Image(systemName: term.category.iconName)
                    .font(.system(size: 12))
                Text(term.category.rawValue)
                    .font(.kundliCaption)
            }
            .foregroundColor(.kundliPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.kundliPrimary.opacity(0.15))
            )

            // Group info if available
            if let groupInfo = term.groupInfo {
                Text(groupInfo.positionText)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .stroke(Color.kundliTextSecondary.opacity(0.3), lineWidth: 1)
                    )
            }

            Spacer()
        }
    }

    // MARK: - Quick Explanation Card

    private func quickExplanationCard(_ term: AstrologyTerm) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.kundliPrimary)
                Text("Quick Summary")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)
            }

            Text(term.shortExplanation)
                .font(.kundliBody)
                .foregroundColor(.kundliTextPrimary)
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.kundliPrimary.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.kundliPrimary.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Full Explanation

    private func fullExplanationSection(_ term: AstrologyTerm) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Full Explanation", icon: "doc.text")

            Text(term.fullExplanation)
                .font(.kundliBody)
                .foregroundColor(.kundliTextPrimary)
                .lineSpacing(6)
        }
    }

    // MARK: - Calculation Section

    private func calculationSection(_ calculation: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("How It's Calculated", icon: "function")

            Text(calculation)
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.kundliCardBg)
                )
        }
    }

    // MARK: - Significance Section

    private func significanceSection(_ significance: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Significance", icon: "sparkles")

            Text(significance)
                .font(.kundliBody)
                .foregroundColor(.kundliTextPrimary)
                .lineSpacing(4)
        }
    }

    // MARK: - Related Terms

    private func relatedTermsSection(_ termIds: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Related Concepts", icon: "link")

            FlowLayout(spacing: 8) {
                ForEach(termIds, id: \.self) { relatedId in
                    if let relatedTerm = EducationService.shared.term(forId: relatedId) {
                        Button {
                            selectedRelatedTermId = relatedId
                        } label: {
                            HStack(spacing: 4) {
                                Text(relatedTerm.sanskritName)
                                    .font(.kundliCaption)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 8))
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
                    }
                }
            }
        }
    }

    // MARK: - Learn More Button

    private func learnMoreButton(_ term: AstrologyTerm) -> some View {
        NavigationLink {
            LearningCenterView()
        } label: {
            HStack {
                Image(systemName: "book.fill")
                    .font(.system(size: 16))
                Text("Explore Learning Center")
                    .font(.kundliSubheadline)
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 14))
            }
            .foregroundColor(.kundliPrimary)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.kundliPrimary, lineWidth: 1.5)
            )
        }
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

    private var termNotFoundView: some View {
        VStack(spacing: 16) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 48))
                .foregroundColor(.kundliTextSecondary)

            Text("Term Not Found")
                .font(.kundliHeadline)
                .foregroundColor(.kundliTextPrimary)

            Text("The explanation for '\(termId)' is not yet available.")
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - String Extension for Identifiable

extension String: @retroactive Identifiable {
    public var id: String { self }
}

// MARK: - Preview

#Preview {
    TermExplanationSheet(termId: "nakshatra.ashwini")
}
