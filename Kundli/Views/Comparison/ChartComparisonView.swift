import SwiftUI

struct ChartComparisonView: View {
    let kundli1: Kundli
    let kundli2: Kundli

    @State private var comparison: ChartComparison?
    @State private var isLoading = true
    @State private var selectedChartStyle: ChartStyle = .northIndian

    private let synastryService = SynastryService.shared

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            if isLoading {
                loadingView
            } else if let comparison = comparison {
                ScrollView {
                    VStack(spacing: 24) {
                        // Compatibility score header
                        compatibilityHeader(comparison: comparison)

                        // Side-by-side charts
                        chartsSection

                        // Key aspects
                        keyAspectsSection(comparison: comparison)

                        // Detailed aspects
                        detailedAspectsSection(comparison: comparison)

                        // Composite chart link
                        compositeChartSection

                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(16)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 60))
                        .foregroundColor(.kundliTextSecondary)

                    Text("Unable to calculate comparison")
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextSecondary)

                    Button { calculateComparison() } label: {
                        Label("Retry", systemImage: "arrow.clockwise")
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliPrimary)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .navigationTitle("Chart Comparison")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            calculateComparison()
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .kundliPrimary))
                .scaleEffect(1.2)

            Text("Analyzing charts...")
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextSecondary)
        }
    }

    // MARK: - Compatibility Header

    private func compatibilityHeader(comparison: ChartComparison) -> some View {
        CardView {
            VStack(spacing: 16) {
                // Names
                HStack {
                    Text(kundli1.birthDetails.name)
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextPrimary)

                    Image(systemName: "heart.fill")
                        .foregroundColor(.kundliPrimary)

                    Text(kundli2.birthDetails.name)
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextPrimary)
                }

                // Score
                VStack(spacing: 8) {
                    Text("\(Int(comparison.compositeScore))%")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(ratingColor(comparison.compatibilityRating))

                    Text(comparison.compatibilityRating.rawValue)
                        .font(.kundliHeadline)
                        .foregroundColor(ratingColor(comparison.compatibilityRating))

                    Text(comparison.compatibilityRating.description)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                        .multilineTextAlignment(.center)
                }

                // Aspect summary
                HStack(spacing: 24) {
                    aspectStat(
                        count: comparison.harmoniousAspects,
                        label: "Harmonious",
                        color: .kundliSuccess
                    )

                    aspectStat(
                        count: comparison.challengingAspects,
                        label: "Challenging",
                        color: .kundliError
                    )

                    aspectStat(
                        count: comparison.synastryAspects.count - comparison.harmoniousAspects - comparison.challengingAspects,
                        label: "Neutral",
                        color: .kundliInfo
                    )
                }
            }
        }
    }

    private func aspectStat(count: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.kundliTitle3)
                .foregroundColor(color)

            Text(label)
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)
        }
    }

    // MARK: - Charts Section

    private var chartsSection: some View {
        VStack(spacing: 16) {
            // Chart style picker
            Picker("Chart Style", selection: $selectedChartStyle) {
                ForEach(ChartStyle.allCases, id: \.self) { style in
                    Text(style.rawValue).tag(style)
                }
            }
            .pickerStyle(.segmented)
            .tint(.kundliPrimary)

            // Side-by-side charts
            HStack(spacing: 12) {
                // Chart 1
                VStack(spacing: 8) {
                    Text(kundli1.birthDetails.name.components(separatedBy: " ").first ?? "")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)

                    chartView(for: kundli1)
                        .frame(width: 150, height: 150)
                }

                // Chart 2
                VStack(spacing: 8) {
                    Text(kundli2.birthDetails.name.components(separatedBy: " ").first ?? "")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)

                    chartView(for: kundli2)
                        .frame(width: 150, height: 150)
                }
            }
            .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private func chartView(for kundli: Kundli) -> some View {
        switch selectedChartStyle {
        case .northIndian, .eastIndian:
            NorthIndianChart(kundli: kundli, size: 150)
        case .southIndian:
            SouthIndianChart(kundli: kundli, size: 150)
        case .western:
            WesternCircularChart(kundli: kundli, size: 150)
        }
    }

    // MARK: - Key Aspects Section

    private func keyAspectsSection(comparison: ChartComparison) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Key Connections", icon: "star.fill")

            CardView {
                VStack(spacing: 12) {
                    let keyAspects = synastryService.getKeyAspects(from: comparison, limit: 5)
                    ForEach(Array(keyAspects.enumerated()), id: \.element.id) { index, aspect in
                        if index > 0 {
                            Divider()
                                .background(Color.white.opacity(0.1))
                        }
                        keyAspectRow(aspect)
                    }
                }
            }
        }
    }

    private func keyAspectRow(_ aspect: SynastryAspect) -> some View {
        HStack(spacing: 12) {
            // Aspect visualization
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
            .frame(width: 70)

            // Aspect info
            VStack(alignment: .leading, spacing: 2) {
                Text("\(aspect.planet1Name) \(aspect.aspectType.rawValue) \(aspect.planet2Name)")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextPrimary)

                Text("Orb: \(String(format: "%.1f", aspect.orb))°")
                    .font(.system(size: 10))
                    .foregroundColor(.kundliTextTertiary)
            }

            Spacer()

            // Nature indicator
            Circle()
                .fill(natureColor(aspect.nature))
                .frame(width: 10, height: 10)
        }
    }

    // MARK: - Detailed Aspects Section

    private func detailedAspectsSection(comparison: ChartComparison) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("All Aspects (\(comparison.synastryAspects.count))", icon: "list.bullet")

            SynastryAspectList(aspects: comparison.synastryAspects)
        }
    }

    // MARK: - Composite Chart Section

    private var compositeChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Relationship Chart", icon: "person.2.fill")

            NavigationLink {
                CompositeChartView(kundli1: kundli1, kundli2: kundli2)
            } label: {
                CardView {
                    HStack(spacing: 16) {
                        Image(systemName: "chart.pie.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.kundliPrimary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("View Composite Chart")
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliTextPrimary)

                            Text("A merged chart representing the relationship itself")
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)
                                .multilineTextAlignment(.leading)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.kundliTextSecondary)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Helpers

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

    private func ratingColor(_ rating: CompatibilityRating) -> Color {
        switch rating {
        case .excellent: return .kundliSuccess
        case .good: return .kundliInfo
        case .moderate: return .kundliWarning
        case .challenging: return .orange
        case .difficult: return .kundliError
        }
    }

    private func natureColor(_ nature: AspectNature) -> Color {
        switch nature {
        case .harmonious: return .kundliSuccess
        case .challenging: return .kundliError
        case .neutral: return .kundliInfo
        case .adjusting: return .kundliWarning
        }
    }

    private func calculateComparison() {
        isLoading = true

        Task {
            let result = synastryService.calculateSynastry(kundli1: kundli1, kundli2: kundli2)

            await MainActor.run {
                comparison = result
                isLoading = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ChartComparisonView(
            kundli1: MockDataService.shared.sampleKundli(),
            kundli2: MockDataService.shared.sampleKundli()
        )
    }
}
