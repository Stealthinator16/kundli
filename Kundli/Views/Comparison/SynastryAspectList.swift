import SwiftUI

/// List view for displaying synastry aspects
struct SynastryAspectList: View {
    let aspects: [SynastryAspect]

    @State private var expandedAspect: UUID?
    @State private var filterNature: AspectNature?

    var body: some View {
        VStack(spacing: 12) {
            // Filter buttons
            filterBar

            // Aspects list
            LazyVStack(spacing: 10) {
                ForEach(filteredAspects) { aspect in
                    aspectCard(aspect)
                }
            }
        }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(nature: nil, label: "All")
                filterChip(nature: .harmonious, label: "Harmonious")
                filterChip(nature: .challenging, label: "Challenging")
                filterChip(nature: .neutral, label: "Neutral")
            }
        }
    }

    private func filterChip(nature: AspectNature?, label: String) -> some View {
        let isSelected = filterNature == nature

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                filterNature = nature
            }
        } label: {
            Text(label)
                .font(.kundliCaption)
                .foregroundColor(isSelected ? .kundliBackground : .kundliTextSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.kundliPrimary : Color.kundliCardBg)
                )
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? Color.clear : Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Aspect Card

    private func aspectCard(_ aspect: SynastryAspect) -> some View {
        let isExpanded = expandedAspect == aspect.id

        return VStack(spacing: 0) {
            // Header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedAspect = isExpanded ? nil : aspect.id
                }
            } label: {
                HStack(spacing: 12) {
                    // Nature indicator
                    Circle()
                        .fill(natureColor(aspect.nature))
                        .frame(width: 12, height: 12)

                    // Aspect symbols
                    HStack(spacing: 4) {
                        Text(aspect.planet1Symbol)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.kundliPrimary)

                        Text(aspect.aspectSymbol)
                            .font(.system(size: 12))
                            .foregroundColor(natureColor(aspect.nature))

                        Text(aspect.planet2Symbol)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.kundliPrimary)
                    }

                    // Aspect type
                    VStack(alignment: .leading, spacing: 2) {
                        Text(aspect.aspectType.rawValue)
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextPrimary)

                        Text("\(aspect.planet1Name) - \(aspect.planet2Name)")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)
                    }

                    Spacer()

                    // Orb
                    Text("\(String(format: "%.1f", aspect.orb))°")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextTertiary)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.kundliTextSecondary)
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .background(Color.white.opacity(0.1))

                    Text(aspect.interpretation)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                        .lineSpacing(4)

                    // Nature badge
                    HStack {
                        Text(aspect.nature.rawValue)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(natureColor(aspect.nature))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(natureColor(aspect.nature).opacity(0.2))
                            )

                        Spacer()
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.kundliCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    // MARK: - Helpers

    private var filteredAspects: [SynastryAspect] {
        guard let filter = filterNature else { return aspects }
        return aspects.filter { $0.nature == filter }
    }

    private func natureColor(_ nature: AspectNature) -> Color {
        switch nature {
        case .harmonious: return .kundliSuccess
        case .challenging: return .kundliError
        case .neutral: return .kundliInfo
        case .adjusting: return .kundliWarning
        }
    }
}

// MARK: - Synastry Summary Card

struct SynastrySummaryCard: View {
    let comparison: ChartComparison

    var body: some View {
        CardView {
            VStack(spacing: 16) {
                // Title
                HStack {
                    Text("Relationship Overview")
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliTextPrimary)

                    Spacer()
                }

                // Categories
                VStack(spacing: 12) {
                    categoryRow(
                        title: "Romantic Connection",
                        icon: "heart.fill",
                        aspects: SynastryService.shared.getRomanticIndicators(from: comparison),
                        color: .pink
                    )

                    categoryRow(
                        title: "Communication",
                        icon: "message.fill",
                        aspects: SynastryService.shared.getCommunicationIndicators(from: comparison),
                        color: .kundliInfo
                    )

                    categoryRow(
                        title: "Long-term Stability",
                        icon: "building.2.fill",
                        aspects: SynastryService.shared.getStabilityIndicators(from: comparison),
                        color: .kundliPrimary
                    )
                }
            }
        }
    }

    private func categoryRow(title: String, icon: String, aspects: [SynastryAspect], color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)

            Text(title)
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextPrimary)

            Spacer()

            // Aspect count and nature
            let harmonious = aspects.filter { $0.nature == .harmonious }.count
            let challenging = aspects.filter { $0.nature == .challenging }.count

            HStack(spacing: 8) {
                if harmonious > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10))
                        Text("\(harmonious)")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.kundliSuccess)
                }

                if challenging > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "xmark")
                            .font(.system(size: 10))
                        Text("\(challenging)")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.kundliError)
                }

                if aspects.isEmpty {
                    Text("—")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextTertiary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        SynastryAspectList(aspects: [
            SynastryAspect(
                planet1Name: "Sun",
                planet1Symbol: "Su",
                planet2Name: "Moon",
                planet2Symbol: "Mo",
                aspectType: .conjunction,
                orb: 2.5
            ),
            SynastryAspect(
                planet1Name: "Venus",
                planet1Symbol: "Ve",
                planet2Name: "Mars",
                planet2Symbol: "Ma",
                aspectType: .trine,
                orb: 3.2
            ),
            SynastryAspect(
                planet1Name: "Moon",
                planet1Symbol: "Mo",
                planet2Name: "Saturn",
                planet2Symbol: "Sa",
                aspectType: .square,
                orb: 4.1
            )
        ])
        .padding()
    }
}
