import SwiftUI

/// View for displaying a composite chart calculated from two natal charts
struct CompositeChartView: View {
    let kundli1: Kundli
    let kundli2: Kundli

    @State private var compositeChart: CompositeChart?
    @State private var isLoading = true
    @State private var selectedChartStyle: ChartStyle = .northIndian
    @State private var showInterpretation = true

    private let compositeService = CompositeChartService.shared

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            if isLoading {
                loadingView
            } else if let chart = compositeChart {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection(chart: chart)

                        // Chart display
                        chartSection(chart: chart)

                        // Interpretation section
                        if showInterpretation {
                            interpretationSection(chart: chart)
                        }

                        // Planetary positions
                        planetaryPositionsSection(chart: chart)

                        // Aspects
                        aspectsSection(chart: chart)

                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("Composite Chart")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showInterpretation.toggle()
                } label: {
                    Image(systemName: showInterpretation ? "text.alignleft" : "text.alignleft")
                        .foregroundColor(.kundliPrimary)
                }
            }
        }
        .onAppear {
            calculateCompositeChart()
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .kundliPrimary))
                .scaleEffect(1.2)

            Text("Calculating composite chart...")
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextSecondary)
        }
    }

    // MARK: - Header Section

    private func headerSection(chart: CompositeChart) -> some View {
        CardView {
            VStack(spacing: 12) {
                // Title
                HStack {
                    Text(chart.kundli1Name)
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextPrimary)

                    Image(systemName: "plus")
                        .font(.system(size: 12))
                        .foregroundColor(.kundliPrimary)

                    Text(chart.kundli2Name)
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextPrimary)
                }

                Text("Relationship Chart")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)

                Divider()
                    .background(Color.white.opacity(0.1))

                // Composite Ascendant
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Composite Ascendant")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)

                        Text("\(chart.ascendant.sign.rawValue) \(chart.ascendant.degreeString)")
                            .font(.kundliHeadline)
                            .foregroundColor(.kundliPrimary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Nakshatra")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)

                        Text(chart.ascendant.nakshatra.rawValue)
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextPrimary)
                    }
                }
            }
        }
    }

    // MARK: - Chart Section

    private func chartSection(chart: CompositeChart) -> some View {
        VStack(spacing: 16) {
            // Chart style picker
            Picker("Chart Style", selection: $selectedChartStyle) {
                ForEach(ChartStyle.allCases, id: \.self) { style in
                    Text(style.rawValue).tag(style)
                }
            }
            .pickerStyle(.segmented)
            .tint(.kundliPrimary)

            // Chart view
            CompositeChartDiagram(
                chart: chart,
                style: selectedChartStyle,
                size: 280
            )
            .frame(height: 280)
        }
    }

    // MARK: - Interpretation Section

    private func interpretationSection(chart: CompositeChart) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Relationship Themes", icon: "sparkles")

            CardView {
                VStack(alignment: .leading, spacing: 16) {
                    // Themes
                    if !chart.interpretation.themes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(chart.interpretation.themes, id: \.self) { theme in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 6))
                                        .foregroundColor(.kundliPrimary)
                                        .padding(.top, 6)

                                    Text(theme)
                                        .font(.kundliBody)
                                        .foregroundColor(.kundliTextPrimary)
                                }
                            }
                        }
                    }

                    if !chart.interpretation.strengths.isEmpty {
                        Divider()
                            .background(Color.white.opacity(0.1))

                        VStack(alignment: .leading, spacing: 8) {
                            Label("Strengths", systemImage: "hand.thumbsup.fill")
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliSuccess)

                            ForEach(chart.interpretation.strengths, id: \.self) { strength in
                                Text("• \(strength)")
                                    .font(.kundliCaption)
                                    .foregroundColor(.kundliTextSecondary)
                            }
                        }
                    }

                    if !chart.interpretation.challenges.isEmpty {
                        Divider()
                            .background(Color.white.opacity(0.1))

                        VStack(alignment: .leading, spacing: 8) {
                            Label("Areas to Work On", systemImage: "exclamationmark.triangle.fill")
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliWarning)

                            ForEach(chart.interpretation.challenges, id: \.self) { challenge in
                                Text("• \(challenge)")
                                    .font(.kundliCaption)
                                    .foregroundColor(.kundliTextSecondary)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Planetary Positions Section

    private func planetaryPositionsSection(chart: CompositeChart) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Composite Planets", icon: "globe")

            CardView {
                VStack(spacing: 0) {
                    ForEach(Array(chart.planets.enumerated()), id: \.element.id) { index, planet in
                        if index > 0 {
                            Divider()
                                .background(Color.white.opacity(0.1))
                        }

                        HStack {
                            // Planet symbol
                            Text(planet.symbol)
                                .font(.system(size: 20))
                                .frame(width: 30)

                            // Planet name
                            Text(planet.name)
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliTextPrimary)
                                .frame(width: 60, alignment: .leading)

                            Spacer()

                            // Position
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(planet.fullPosition)
                                    .font(.kundliCaption)
                                    .foregroundColor(.kundliTextPrimary)

                                Text("House \(planet.house)")
                                    .font(.system(size: 10))
                                    .foregroundColor(.kundliTextTertiary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
    }

    // MARK: - Aspects Section

    private func aspectsSection(chart: CompositeChart) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Composite Aspects (\(chart.aspects.count))", icon: "arrow.triangle.swap")

            CardView {
                VStack(spacing: 0) {
                    ForEach(Array(chart.aspects.enumerated()), id: \.element.id) { index, aspect in
                        if index > 0 {
                            Divider()
                                .background(Color.white.opacity(0.1))
                        }

                        HStack {
                            // Aspect visualization
                            HStack(spacing: 4) {
                                Text(aspect.planet1Symbol)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.kundliPrimary)

                                Text(aspect.aspectType.symbol)
                                    .font(.system(size: 12))
                                    .foregroundColor(natureColor(aspect.nature))

                                Text(aspect.planet2Symbol)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.kundliPrimary)
                            }
                            .frame(width: 70)

                            // Aspect info
                            VStack(alignment: .leading, spacing: 2) {
                                Text(aspect.aspectType.rawValue)
                                    .font(.kundliCaption)
                                    .foregroundColor(.kundliTextPrimary)

                                Text("Orb: \(String(format: "%.1f", aspect.orb))°")
                                    .font(.system(size: 10))
                                    .foregroundColor(.kundliTextTertiary)
                            }

                            Spacer()

                            // Nature indicator
                            Text(aspect.nature.rawValue)
                                .font(.system(size: 10))
                                .foregroundColor(natureColor(aspect.nature))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(natureColor(aspect.nature).opacity(0.2))
                                )
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
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

    private func natureColor(_ nature: AspectNature) -> Color {
        switch nature {
        case .harmonious: return .kundliSuccess
        case .challenging: return .kundliError
        case .neutral: return .kundliInfo
        case .adjusting: return .kundliWarning
        }
    }

    private func calculateCompositeChart() {
        isLoading = true

        DispatchQueue.global(qos: .userInitiated).async {
            let chart = compositeService.calculateCompositeChart(
                kundli1: kundli1,
                kundli2: kundli2
            )

            DispatchQueue.main.async {
                compositeChart = chart
                isLoading = false
            }
        }
    }
}

// MARK: - Composite Chart Diagram

struct CompositeChartDiagram: View {
    let chart: CompositeChart
    let style: ChartStyle
    let size: CGFloat

    var body: some View {
        ZStack {
            switch style {
            case .northIndian, .eastIndian:
                NorthIndianCompositeChart(chart: chart, size: size)
            case .southIndian:
                SouthIndianCompositeChart(chart: chart, size: size)
            case .western:
                WesternCompositeChart(chart: chart, size: size)
            }
        }
    }
}

// MARK: - North Indian Composite Chart

struct NorthIndianCompositeChart: View {
    let chart: CompositeChart
    let size: CGFloat

    var body: some View {
        ZStack {
            // Diamond background
            DiamondShape()
                .stroke(Color.kundliPrimary.opacity(0.5), lineWidth: 1)
                .frame(width: size, height: size)

            // Inner diamond
            DiamondShape()
                .stroke(Color.kundliPrimary.opacity(0.3), lineWidth: 0.5)
                .frame(width: size * 0.5, height: size * 0.5)

            // Cross lines
            Path { path in
                path.move(to: CGPoint(x: size/2, y: 0))
                path.addLine(to: CGPoint(x: size/2, y: size))
                path.move(to: CGPoint(x: 0, y: size/2))
                path.addLine(to: CGPoint(x: size, y: size/2))
            }
            .stroke(Color.kundliPrimary.opacity(0.3), lineWidth: 0.5)

            // House numbers and planets
            ForEach(1...12, id: \.self) { house in
                let position = housePosition(house, size: size)
                VStack(spacing: 2) {
                    Text("\(house)")
                        .font(.system(size: 9))
                        .foregroundColor(.kundliTextTertiary)

                    let planets = chart.planetsInHouse(house)
                    if !planets.isEmpty {
                        Text(planets.map { $0.symbol }.joined())
                            .font(.system(size: 11))
                            .foregroundColor(.kundliPrimary)
                    }
                }
                .position(position)
            }

            // Ascendant marker
            Text("Asc")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.kundliPrimary)
                .position(x: size * 0.5, y: size * 0.15)
        }
        .frame(width: size, height: size)
    }

    private func housePosition(_ house: Int, size: CGFloat) -> CGPoint {
        let positions: [CGPoint] = [
            CGPoint(x: 0.5, y: 0.25),   // 1
            CGPoint(x: 0.25, y: 0.15),  // 2
            CGPoint(x: 0.12, y: 0.25),  // 3
            CGPoint(x: 0.25, y: 0.5),   // 4
            CGPoint(x: 0.12, y: 0.75),  // 5
            CGPoint(x: 0.25, y: 0.85),  // 6
            CGPoint(x: 0.5, y: 0.75),   // 7
            CGPoint(x: 0.75, y: 0.85),  // 8
            CGPoint(x: 0.88, y: 0.75),  // 9
            CGPoint(x: 0.75, y: 0.5),   // 10
            CGPoint(x: 0.88, y: 0.25),  // 11
            CGPoint(x: 0.75, y: 0.15)   // 12
        ]

        let pos = positions[house - 1]
        return CGPoint(x: pos.x * size, y: pos.y * size)
    }
}

// MARK: - South Indian Composite Chart

struct SouthIndianCompositeChart: View {
    let chart: CompositeChart
    let size: CGFloat

    var body: some View {
        let cellSize = size / 4

        ZStack {
            // Grid
            ForEach(0..<5) { i in
                Path { path in
                    path.move(to: CGPoint(x: CGFloat(i) * cellSize, y: 0))
                    path.addLine(to: CGPoint(x: CGFloat(i) * cellSize, y: size))
                }
                .stroke(Color.kundliPrimary.opacity(0.3), lineWidth: 0.5)

                Path { path in
                    path.move(to: CGPoint(x: 0, y: CGFloat(i) * cellSize))
                    path.addLine(to: CGPoint(x: size, y: CGFloat(i) * cellSize))
                }
                .stroke(Color.kundliPrimary.opacity(0.3), lineWidth: 0.5)
            }

            // House contents
            ForEach(1...12, id: \.self) { house in
                let position = southIndianHousePosition(house, cellSize: cellSize)
                VStack(spacing: 2) {
                    Text("\(house)")
                        .font(.system(size: 9))
                        .foregroundColor(.kundliTextTertiary)

                    let planets = chart.planetsInHouse(house)
                    if !planets.isEmpty {
                        Text(planets.map { $0.symbol }.joined())
                            .font(.system(size: 11))
                            .foregroundColor(.kundliPrimary)
                    }
                }
                .position(position)
            }
        }
        .frame(width: size, height: size)
    }

    private func southIndianHousePosition(_ house: Int, cellSize: CGFloat) -> CGPoint {
        let gridPositions: [(Int, Int)] = [
            (1, 0), (2, 0), (3, 0),     // Top row: 12, 1, 2
            (3, 1), (3, 2),              // Right column: 3, 4
            (3, 3), (2, 3), (1, 3),     // Bottom row: 5, 6, 7
            (0, 3), (0, 2),              // Left column: 8, 9
            (0, 1), (0, 0)               // Top-left: 10, 11
        ]

        // Reorder to match house numbers
        let houseToGrid: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 0]
        let gridIndex = houseToGrid[house - 1]
        let (col, row) = gridPositions[gridIndex]

        return CGPoint(
            x: CGFloat(col) * cellSize + cellSize / 2,
            y: CGFloat(row) * cellSize + cellSize / 2
        )
    }
}

// MARK: - Western Composite Chart

struct WesternCompositeChart: View {
    let chart: CompositeChart
    let size: CGFloat

    var body: some View {
        ZStack {
            // Outer circle
            Circle()
                .stroke(Color.kundliPrimary.opacity(0.3), lineWidth: 1)
                .frame(width: size, height: size)

            // Inner circle
            Circle()
                .stroke(Color.kundliPrimary.opacity(0.2), lineWidth: 0.5)
                .frame(width: size * 0.7, height: size * 0.7)

            // Zodiac divisions (12 segments)
            ForEach(0..<12) { i in
                let angle = Double(i) * 30 - 90
                let radian = angle * .pi / 180

                Path { path in
                    path.move(to: CGPoint(x: size/2, y: size/2))
                    path.addLine(to: CGPoint(
                        x: size/2 + cos(radian) * size/2,
                        y: size/2 + sin(radian) * size/2
                    ))
                }
                .stroke(Color.kundliPrimary.opacity(0.2), lineWidth: 0.5)

                // Sign symbol
                let signAngle = (Double(i) * 30 + 15 - 90) * .pi / 180
                let signRadius = size * 0.42
                Text(ZodiacSign.allCases[i].symbol)
                    .font(.system(size: 12))
                    .foregroundColor(.kundliPrimary.opacity(0.6))
                    .position(
                        x: size/2 + cos(signAngle) * signRadius,
                        y: size/2 + sin(signAngle) * signRadius
                    )
            }

            // Planets
            ForEach(chart.planets) { planet in
                let angle = (planet.longitude - 90) * .pi / 180
                let radius = size * 0.28

                Text(planet.symbol)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.kundliPrimary)
                    .position(
                        x: size/2 + CGFloat(cos(angle)) * radius,
                        y: size/2 + CGFloat(sin(angle)) * radius
                    )
            }

            // Ascendant marker
            let ascAngle = (chart.ascendant.longitude - 90) * .pi / 180
            Path { path in
                path.move(to: CGPoint(
                    x: size/2 + cos(ascAngle) * size * 0.35,
                    y: size/2 + sin(ascAngle) * size * 0.35
                ))
                path.addLine(to: CGPoint(
                    x: size/2 + cos(ascAngle) * size * 0.5,
                    y: size/2 + sin(ascAngle) * size * 0.5
                ))
            }
            .stroke(Color.kundliPrimary, lineWidth: 2)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Diamond Shape

struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CompositeChartView(
            kundli1: MockDataService.shared.sampleKundli(),
            kundli2: MockDataService.shared.sampleKundli()
        )
    }
}
