import SwiftUI

struct YogaListView: View {
    let yogas: [Yoga]
    @State private var expandedYogaId: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Yogas")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                Spacer()

                Text("\(yogas.count) found")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)
            }

            if yogas.isEmpty {
                emptyStateView
            } else {
                // Group yogas by category
                ForEach(groupedYogas, id: \.category) { group in
                    yogaCategorySection(category: group.category, yogas: group.yogas)
                }
            }
        }
    }

    private var emptyStateView: some View {
        CardView {
            HStack(spacing: 12) {
                Image(systemName: "star.slash")
                    .font(.system(size: 24))
                    .foregroundColor(.kundliTextSecondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("No Yogas Detected")
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextPrimary)

                    Text("This chart has no major yogas")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                }

                Spacer()
            }
        }
    }

    private func yogaCategorySection(category: YogaCategory, yogas: [Yoga]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Category header
            Text(category.rawValue)
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)
                .padding(.top, 8)

            ForEach(yogas) { yoga in
                YogaCard(
                    yoga: yoga,
                    isExpanded: expandedYogaId == yoga.id,
                    onTap: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if expandedYogaId == yoga.id {
                                expandedYogaId = nil
                            } else {
                                expandedYogaId = yoga.id
                            }
                        }
                    }
                )
            }
        }
    }

    private var groupedYogas: [(category: YogaCategory, yogas: [Yoga])] {
        let grouped = Dictionary(grouping: yogas, by: { $0.category })
        return YogaCategory.allCases.compactMap { category in
            guard let yogas = grouped[category], !yogas.isEmpty else { return nil }
            return (category: category, yogas: yogas)
        }
    }
}

// MARK: - Yoga Card
struct YogaCard: View {
    let yoga: Yoga
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                // Header row
                Button(action: onTap) {
                    HStack {
                        // Yoga nature indicator
                        Circle()
                            .fill(yoga.nature.color)
                            .frame(width: 12, height: 12)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(yoga.name)
                                .font(.kundliHeadline)
                                .foregroundColor(.kundliTextPrimary)

                            Text(yoga.sanskritName)
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)
                        }

                        Spacer()

                        // Strength badge
                        YogaStrengthBadge(strength: yoga.strength)

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.kundliTextSecondary)
                    }
                }
                .buttonStyle(.plain)

                // Expanded content
                if isExpanded {
                    Divider()
                        .background(Color.white.opacity(0.1))

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Formation")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)

                        Text(yoga.description)
                            .font(.kundliBody)
                            .foregroundColor(.kundliTextPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Forming planets
                    if !yoga.formingPlanets.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Forming Planets")
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)

                            HStack(spacing: 8) {
                                ForEach(yoga.formingPlanets, id: \.self) { planet in
                                    Text(planet)
                                        .font(.kundliCaption)
                                        .foregroundColor(.kundliTextPrimary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(Color.kundliPrimary.opacity(0.2))
                                        )
                                }
                            }
                        }
                    }

                    // Effects
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Effects")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)

                        Text(yoga.effects)
                            .font(.kundliBody)
                            .foregroundColor(yoga.nature.color.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}

// MARK: - Yoga Strength Badge
struct YogaStrengthBadge: View {
    let strength: YogaStrength

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(index < strengthLevel ? Color.kundliPrimary : Color.kundliTextSecondary.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.kundliPrimary.opacity(0.1))
        )
    }

    private var strengthLevel: Int {
        switch strength {
        case .strong: return 3
        case .moderate: return 2
        case .weak: return 1
        }
    }
}

// MARK: - Extensions
extension YogaNature {
    var color: Color {
        switch self {
        case .benefic: return .kundliSuccess
        case .malefic: return .kundliError
        case .mixed: return .kundliWarning
        }
    }
}

// MARK: - Full Screen View
struct YogaDetailView: View {
    let yogas: [Yoga]

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Summary card
                    CardView {
                        HStack(spacing: 20) {
                            yogaSummaryItem(
                                count: yogas.filter { $0.nature == .benefic }.count,
                                label: "Benefic",
                                color: .kundliSuccess
                            )

                            Divider()
                                .frame(height: 40)
                                .background(Color.white.opacity(0.1))

                            yogaSummaryItem(
                                count: yogas.filter { $0.nature == .malefic }.count,
                                label: "Malefic",
                                color: .kundliError
                            )

                            Divider()
                                .frame(height: 40)
                                .background(Color.white.opacity(0.1))

                            yogaSummaryItem(
                                count: yogas.filter { $0.nature == .mixed }.count,
                                label: "Mixed",
                                color: .kundliWarning
                            )
                        }
                        .frame(maxWidth: .infinity)
                    }

                    YogaListView(yogas: yogas)
                }
                .padding(16)
            }
        }
        .navigationTitle("Yogas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func yogaSummaryItem(count: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.kundliTitle2)
                .foregroundColor(color)

            Text(label)
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        ScrollView {
            YogaListView(yogas: [
                .gajaKesari(strength: .strong, formingPlanets: ["Jupiter", "Moon"]),
                .budhaditya(strength: .moderate, formingPlanets: ["Sun", "Mercury"]),
                .ruchaka(strength: .strong, formingPlanets: ["Mars"]),
                .hamsa(strength: .weak, formingPlanets: ["Jupiter"])
            ])
            .padding()
        }
    }
}
