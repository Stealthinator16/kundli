//
//  SuggestedQuestionsView.swift
//  Kundli
//
//  Quick question chips for starting conversations.
//

import SwiftUI

struct SuggestedQuestionsView: View {
    let questions: [String]
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.kundliPrimary)
                Text("Suggested Questions")
                    .font(.kundliSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.kundliTextPrimary)
            }

            FlowLayout(spacing: 8) {
                ForEach(questions, id: \.self) { question in
                    QuestionChip(text: question) {
                        onSelect(question)
                    }
                }
            }
        }
        .padding()
        .background(Color.kundliCardBg)
        .cornerRadius(16)
    }
}

// MARK: - Question Chip

struct QuestionChip: View {
    let text: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(text)
                .font(.kundliCaption)
                .foregroundColor(.kundliTextPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.kundliBackground)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.kundliPrimary.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )

        for (index, subview) in subviews.enumerated() {
            subview.place(
                at: CGPoint(
                    x: bounds.minX + result.positions[index].x,
                    y: bounds.minY + result.positions[index].y
                ),
                proposal: .unspecified
            )
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }

            self.size = CGSize(
                width: maxWidth,
                height: currentY + lineHeight
            )
        }
    }
}

// MARK: - Inline Suggestions (Horizontal Scroll)

struct InlineSuggestionsView: View {
    let questions: [String]
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(questions, id: \.self) { question in
                    QuestionChip(text: question) {
                        onSelect(question)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        VStack {
            SuggestedQuestionsView(
                questions: [
                    "What are my key strengths?",
                    "What career paths suit me?",
                    "When is a favorable time for decisions?",
                    "How does Mars influence me?",
                    "What remedies can help?"
                ],
                onSelect: { _ in }
            )
            .padding()

            InlineSuggestionsView(
                questions: [
                    "Career outlook",
                    "Relationship timing",
                    "Health advice"
                ],
                onSelect: { _ in }
            )
        }
    }
}
