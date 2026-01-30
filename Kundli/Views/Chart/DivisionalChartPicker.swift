import SwiftUI

struct DivisionalChartPicker: View {
    @Binding var selectedChart: DivisionalChart
    let availableCharts: [DivisionalChart]

    var body: some View {
        Menu {
            ForEach(groupedCharts, id: \.importance) { group in
                Section(group.importance.rawValue) {
                    ForEach(group.charts, id: \.self) { chart in
                        Button {
                            selectedChart = chart
                        } label: {
                            HStack {
                                Text(chart.rawValue)
                                    .fontWeight(.medium)
                                Text("- \(chart.fullName)")

                                if selectedChart == chart {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(selectedChart.rawValue)
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliTextPrimary)

                    Text(selectedChart.fullName)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 12))
                    .foregroundColor(.kundliTextSecondary)
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
    }

    private var groupedCharts: [(importance: ChartImportance, charts: [DivisionalChart])] {
        let grouped = Dictionary(grouping: availableCharts, by: { $0.importance })
        let order: [ChartImportance] = [.essential, .primary, .secondary, .tertiary]

        return order.compactMap { importance in
            guard let charts = grouped[importance], !charts.isEmpty else { return nil }
            return (importance: importance, charts: charts)
        }
    }
}

// MARK: - Segmented Divisional Chart Picker (for common charts)
struct DivisionalChartSegmentedPicker: View {
    @Binding var selectedChart: DivisionalChart

    // Common charts for segmented display
    private let commonCharts: [DivisionalChart] = [.d1, .d9, .d10]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(commonCharts, id: \.self) { chart in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedChart = chart
                    }
                } label: {
                    VStack(spacing: 2) {
                        Text(chart.rawValue)
                            .font(.kundliCaption)
                            .fontWeight(.semibold)

                        Text(chart.fullName)
                            .font(.system(size: 10))
                    }
                    .foregroundColor(selectedChart == chart ? .kundliBackground : .kundliTextSecondary)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedChart == chart ? Color.kundliPrimary : Color.clear)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.kundliCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Chart Info Card
struct DivisionalChartInfoCard: View {
    let chart: DivisionalChart

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(chart.rawValue) - \(chart.fullName)")
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliTextPrimary)

                    Spacer()

                    ChartImportanceBadge(importance: chart.importance)
                }

                Text(chart.significance)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Chart Importance Badge
struct ChartImportanceBadge: View {
    let importance: ChartImportance

    var body: some View {
        Text(importance.rawValue)
            .font(.kundliCaption2)
            .foregroundColor(badgeTextColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(badgeColor)
            )
    }

    private var badgeColor: Color {
        switch importance {
        case .essential: return .kundliPrimary
        case .primary: return .kundliInfo
        case .secondary: return .kundliTextSecondary.opacity(0.3)
        case .tertiary: return .kundliTextSecondary.opacity(0.2)
        }
    }

    private var badgeTextColor: Color {
        switch importance {
        case .essential: return .kundliBackground
        case .primary: return .white
        case .secondary, .tertiary: return .kundliTextPrimary
        }
    }
}

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        VStack(spacing: 20) {
            DivisionalChartSegmentedPicker(selectedChart: .constant(.d1))

            DivisionalChartPicker(
                selectedChart: .constant(.d9),
                availableCharts: [.d1, .d9, .d10, .d2, .d3, .d7, .d12]
            )

            DivisionalChartInfoCard(chart: .d9)
        }
        .padding()
    }
}
