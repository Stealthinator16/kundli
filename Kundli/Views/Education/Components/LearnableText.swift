import SwiftUI

/// Style options for LearnableText
enum LearnableTextStyle {
    case `default`      // kundliSubheadline, primary color
    case headline       // kundliHeadline, primary color
    case caption        // kundliCaption, secondary color
    case value          // kundliBody, primary color, larger indicator
    case title          // kundliTitle3, primary color
    case custom(font: Font, textColor: Color, indicatorSize: CGFloat)

    var font: Font {
        switch self {
        case .default: return .kundliSubheadline
        case .headline: return .kundliHeadline
        case .caption: return .kundliCaption
        case .value: return .kundliBody
        case .title: return .kundliTitle3
        case .custom(let font, _, _): return font
        }
    }

    var textColor: Color {
        switch self {
        case .default, .value, .headline, .title: return .kundliTextPrimary
        case .caption: return .kundliTextSecondary
        case .custom(_, let color, _): return color
        }
    }

    var indicatorSize: CGFloat {
        switch self {
        case .default, .caption: return 10
        case .headline, .title: return 12
        case .value: return 11
        case .custom(_, _, let size): return size
        }
    }
}

/// A text view that can be tapped to reveal explanations about astrology terms
struct LearnableText: View {
    let text: String
    let termId: String
    var style: LearnableTextStyle = .default
    var showIndicator: Bool = true

    @State private var showSheet = false

    var body: some View {
        Button {
            showSheet = true
        } label: {
            HStack(spacing: 4) {
                Text(text)
                    .font(style.font)
                    .foregroundColor(style.textColor)

                if showIndicator {
                    Image(systemName: "info.circle")
                        .font(.system(size: style.indicatorSize))
                        .foregroundColor(.kundliPrimary.opacity(0.5))
                }
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showSheet) {
            TermExplanationSheet(termId: termId)
        }
    }
}

/// A component for displaying multi-part learnable terms like "Shukla Dwadashi"
struct CompoundLearnableText: View {
    let components: [TermComponent]
    var separator: String = " "
    var style: LearnableTextStyle = .default

    @State private var selectedComponent: TermComponent?

    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(components.enumerated()), id: \.offset) { index, component in
                if index > 0 {
                    Text(separator)
                        .font(style.font)
                        .foregroundColor(.kundliTextSecondary)
                }

                Button {
                    selectedComponent = component
                } label: {
                    Text(component.text)
                        .font(style.font)
                        .foregroundColor(style.textColor)
                        .underline(color: .kundliPrimary.opacity(0.3))
                }
                .buttonStyle(.plain)
            }

            // Single indicator for entire compound
            Image(systemName: "info.circle")
                .font(.system(size: style.indicatorSize))
                .foregroundColor(.kundliPrimary.opacity(0.5))
        }
        .sheet(item: $selectedComponent) { component in
            TermExplanationSheet(termId: component.termId)
        }
    }
}

/// A component of a compound learnable term
struct TermComponent: Identifiable {
    let id = UUID()
    let text: String
    let termId: String

    init(text: String, termId: String) {
        self.text = text
        self.termId = termId
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        VStack(spacing: 24) {
            // Single term examples
            VStack(alignment: .leading, spacing: 12) {
                Text("Single Terms:")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                LearnableText(
                    text: "Ashwini",
                    termId: "nakshatra.ashwini"
                )

                LearnableText(
                    text: "Shukla Paksha",
                    termId: "paksha.shukla",
                    style: .headline
                )

                LearnableText(
                    text: "Learn more about Yogas",
                    termId: "yoga",
                    style: .caption
                )
            }
            .padding()
            .background(Color.kundliCardBg)
            .cornerRadius(12)

            // Compound term example
            VStack(alignment: .leading, spacing: 12) {
                Text("Compound Term:")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                CompoundLearnableText(
                    components: [
                        TermComponent(text: "Shukla", termId: "paksha.shukla"),
                        TermComponent(text: "Dwadashi", termId: "tithi.shukla.12")
                    ]
                )
            }
            .padding()
            .background(Color.kundliCardBg)
            .cornerRadius(12)
        }
        .padding()
    }
}
