import SwiftUI

/// A minimal inline explanation badge that expands on tap
/// Use this when a full sheet is too heavy - shows a small expandable card
struct InlineExplanationBadge: View {
    let termId: String
    @State private var isExpanded = false

    private var term: AstrologyTerm? {
        EducationService.shared.term(forId: termId)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isExpanded, let term = term {
                // Expanded state: show short explanation
                expandedView(term)
                    .transition(.scale.combined(with: .opacity))
            } else {
                // Collapsed state: just the info icon
                collapsedButton
            }
        }
        .animation(.spring(response: 0.3), value: isExpanded)
    }

    private var collapsedButton: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                isExpanded = true
            }
        } label: {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 12))
                .foregroundColor(.kundliPrimary.opacity(0.6))
        }
    }

    private func expandedView(_ term: AstrologyTerm) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(term.sanskritName)
                    .font(.kundliCaption)
                    .fontWeight(.semibold)
                    .foregroundColor(.kundliPrimary)

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.3)) {
                        isExpanded = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.kundliTextTertiary)
                }
            }

            Text(term.shortExplanation)
                .font(.kundliCaption2)
                .foregroundColor(.kundliTextSecondary)
                .lineLimit(3)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.kundliCardBg)
                .shadow(color: .black.opacity(0.15), radius: 4)
        )
        .frame(maxWidth: 240)
    }
}

/// A list row component for adding "What does this mean?" explanations
struct LearnMoreRow: View {
    let title: String
    let termId: String
    @State private var showSheet = false

    var body: some View {
        Button {
            showSheet = true
        } label: {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.kundliPrimary)
                    .font(.system(size: 14))

                Text(title)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.kundliTextTertiary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showSheet) {
            TermExplanationSheet(termId: termId)
        }
    }
}

/// A compact badge to display next to values that shows term category
struct TermCategoryBadge: View {
    let category: TermCategory

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: category.iconName)
                .font(.system(size: 10))
            Text(category.rawValue)
                .font(.kundliCaption2)
        }
        .foregroundColor(.kundliPrimary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.kundliPrimary.opacity(0.1))
        )
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        VStack(spacing: 32) {
            // Inline badge example
            VStack(alignment: .leading, spacing: 8) {
                Text("Inline Badge:")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                HStack {
                    Text("Nakshatra: Rohini")
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextPrimary)

                    InlineExplanationBadge(termId: "nakshatra.rohini")
                }
            }
            .padding()
            .background(Color.kundliCardBg)
            .cornerRadius(12)

            // Learn more row example
            VStack(alignment: .leading, spacing: 8) {
                Text("Learn More Row:")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                LearnMoreRow(
                    title: "What is Panchang?",
                    termId: "panchang"
                )
            }
            .padding()
            .background(Color.kundliCardBg)
            .cornerRadius(12)

            // Category badge example
            VStack(alignment: .leading, spacing: 8) {
                Text("Category Badge:")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                TermCategoryBadge(category: .nakshatra)
            }
            .padding()
            .background(Color.kundliCardBg)
            .cornerRadius(12)
        }
        .padding()
    }
}
