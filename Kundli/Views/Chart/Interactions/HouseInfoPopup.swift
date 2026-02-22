import SwiftUI

/// House signification data for popup display
struct HousePopupData {
    let number: Int
    let name: String
    let vedName: String
    let category: HousePopupCategory
    let keywords: [String]

    static func forHouse(_ house: Int) -> HousePopupData {
        houseData[house] ?? HousePopupData(
            number: house,
            name: "House \(house)",
            vedName: "Bhava \(house)",
            category: .neutral,
            keywords: []
        )
    }

    private static let houseData: [Int: HousePopupData] = [
        1: HousePopupData(
            number: 1,
            name: "Self",
            vedName: "Tanu Bhava",
            category: .kendra,
            keywords: ["Personality", "Body", "Appearance", "Health", "Character"]
        ),
        2: HousePopupData(
            number: 2,
            name: "Wealth",
            vedName: "Dhana Bhava",
            category: .neutral,
            keywords: ["Money", "Family", "Speech", "Food", "Values"]
        ),
        3: HousePopupData(
            number: 3,
            name: "Siblings",
            vedName: "Sahaja Bhava",
            category: .neutral,
            keywords: ["Courage", "Communication", "Short Trips", "Skills", "Siblings"]
        ),
        4: HousePopupData(
            number: 4,
            name: "Home",
            vedName: "Bandhu Bhava",
            category: .kendra,
            keywords: ["Mother", "Property", "Comfort", "Education", "Happiness"]
        ),
        5: HousePopupData(
            number: 5,
            name: "Children",
            vedName: "Putra Bhava",
            category: .trikona,
            keywords: ["Creativity", "Romance", "Intelligence", "Past Life Merit", "Speculation"]
        ),
        6: HousePopupData(
            number: 6,
            name: "Enemies",
            vedName: "Ari Bhava",
            category: .dusthana,
            keywords: ["Health Issues", "Debts", "Enemies", "Service", "Obstacles"]
        ),
        7: HousePopupData(
            number: 7,
            name: "Marriage",
            vedName: "Kalatra Bhava",
            category: .kendra,
            keywords: ["Spouse", "Partnership", "Business", "Public Relations", "Desire"]
        ),
        8: HousePopupData(
            number: 8,
            name: "Transformation",
            vedName: "Randhra Bhava",
            category: .dusthana,
            keywords: ["Longevity", "Occult", "Inheritance", "Sudden Events", "Research"]
        ),
        9: HousePopupData(
            number: 9,
            name: "Fortune",
            vedName: "Dharma Bhava",
            category: .trikona,
            keywords: ["Father", "Luck", "Higher Learning", "Religion", "Long Journeys"]
        ),
        10: HousePopupData(
            number: 10,
            name: "Career",
            vedName: "Karma Bhava",
            category: .kendra,
            keywords: ["Profession", "Fame", "Authority", "Achievement", "Status"]
        ),
        11: HousePopupData(
            number: 11,
            name: "Gains",
            vedName: "Labha Bhava",
            category: .neutral,
            keywords: ["Income", "Friends", "Wishes", "Elder Siblings", "Social Networks"]
        ),
        12: HousePopupData(
            number: 12,
            name: "Loss",
            vedName: "Vyaya Bhava",
            category: .dusthana,
            keywords: ["Expenses", "Foreign Lands", "Moksha", "Isolation", "Sleep"]
        )
    ]
}

/// Categories of houses in Vedic astrology for popup display
enum HousePopupCategory: String {
    case kendra = "Kendra"
    case trikona = "Trikona"
    case dusthana = "Dusthana"
    case neutral = "Neutral"

    var color: Color {
        switch self {
        case .kendra: return .kundliInfo
        case .trikona: return .kundliSuccess
        case .dusthana: return .kundliWarning
        case .neutral: return .kundliTextSecondary
        }
    }

    var description: String {
        switch self {
        case .kendra: return "Angular House"
        case .trikona: return "Trine House"
        case .dusthana: return "Challenging House"
        case .neutral: return "Supportive House"
        }
    }
}

/// A floating popup that displays info about a selected house
struct HouseInfoPopup: View {
    let house: Int
    let kundli: Kundli
    let onDismiss: () -> Void

    @State private var showCategorySheet = false
    @State private var showHouseSheet = false

    private var significance: HousePopupData {
        HousePopupData.forHouse(house)
    }

    private var planetsInHouse: [Planet] {
        kundli.planetsInHouse(house)
    }

    private var houseSign: ZodiacSign {
        // Calculate sign based on ascendant
        let ascendantIndex = kundli.ascendant.sign.number - 1
        let signIndex = (ascendantIndex + house - 1) % 12
        return ZodiacSign.allCases[signIndex]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text("House \(house)")
                            .font(.kundliHeadline)
                            .foregroundColor(.kundliTextPrimary)

                        categoryBadge
                    }

                    Text("\(significance.name) - \(significance.vedName)")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                }

                Spacer()

                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.kundliTextSecondary)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }
            }

            Divider()
                .background(Color.white.opacity(0.1))

            // Sign info
            HStack(spacing: 8) {
                Text(houseSign.symbol)
                    .font(.system(size: 20))

                VStack(alignment: .leading, spacing: 1) {
                    Text(houseSign.rawValue)
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextPrimary)

                    Text("Lord: \(houseSign.lord)")
                        .font(.kundliCaption2)
                        .foregroundColor(.kundliTextSecondary)
                }

                Spacer()
            }
            .padding(.vertical, 4)

            // Planets in house
            if !planetsInHouse.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Planets")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)

                    HStack(spacing: 6) {
                        ForEach(planetsInHouse) { planet in
                            planetChip(planet)
                        }
                    }
                }
            } else {
                Text("No planets in this house")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextTertiary)
                    .italic()
            }

            Divider()
                .background(Color.white.opacity(0.1))

            // Keywords
            VStack(alignment: .leading, spacing: 6) {
                Text("Significations")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)

                KeywordFlowLayout(spacing: 6) {
                    ForEach(significance.keywords, id: \.self) { keyword in
                        Text(keyword)
                            .font(.kundliCaption2)
                            .foregroundColor(.kundliTextPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.1))
                            )
                    }
                }
            }

            Divider()
                .background(Color.white.opacity(0.1))

            // Learn more button
            Button {
                showHouseSheet = true
            } label: {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 12))
                    Text("Learn about House \(house)")
                        .font(.kundliCaption)
                }
                .foregroundColor(.kundliPrimary)
            }
        }
        .padding(16)
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.kundliCardBg)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.kundliPrimary.opacity(0.3), lineWidth: 1)
        )
        .sheet(isPresented: $showCategorySheet) {
            TermExplanationSheet(termId: "house-category.\(significance.category.rawValue.lowercased())")
        }
        .sheet(isPresented: $showHouseSheet) {
            TermExplanationSheet(termId: "house.\(house)")
        }
    }

    private var categoryBadge: some View {
        Button {
            showCategorySheet = true
        } label: {
            Text(significance.category.rawValue)
                .font(.kundliCaption2)
                .foregroundColor(significance.category == .dusthana ? .kundliBackground : .white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(significance.category.color)
                )
        }
        .buttonStyle(.plain)
    }

    private func planetChip(_ planet: Planet) -> some View {
        HStack(spacing: 4) {
            Text(planet.symbol)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(planetColor(for: planet))

            if planet.status != .neutral {
                Text(planet.status.shortLabel)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(planet.status.color)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(planetColor(for: planet).opacity(0.15))
        )
    }

    private func planetColor(for planet: Planet) -> Color {
        .forPlanet(planet.name)
    }
}

// MARK: - Keyword Flow Layout

struct KeywordFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)

        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var frames: [CGRect] = []
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

            frames.append(CGRect(origin: CGPoint(x: currentX, y: currentY), size: size))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }

        let totalHeight = currentY + lineHeight
        return (CGSize(width: maxWidth, height: totalHeight), frames)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        HouseInfoPopup(
            house: 7,
            kundli: MockDataService.shared.sampleKundli(),
            onDismiss: {}
        )
    }
}
