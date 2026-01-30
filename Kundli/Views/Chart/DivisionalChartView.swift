import SwiftUI

struct DivisionalChartView: View {
    let chartData: DivisionalChartData
    let chartStyle: ChartStyle
    let size: CGFloat

    init(
        chartData: DivisionalChartData,
        chartStyle: ChartStyle = .northIndian,
        size: CGFloat = 280
    ) {
        self.chartData = chartData
        self.chartStyle = chartStyle
        self.size = size
    }

    var body: some View {
        VStack(spacing: 16) {
            // Chart title
            HStack {
                Text("\(chartData.chartType.rawValue) - \(chartData.chartType.fullName)")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                Spacer()

                ChartImportanceBadge(importance: chartData.chartType.importance)
            }

            // Chart display
            switch chartStyle {
            case .northIndian:
                DivisionalNorthIndianChart(chartData: chartData, size: size)
            case .southIndian:
                DivisionalSouthIndianChart(chartData: chartData, size: size)
            case .eastIndian:
                // Fall back to North Indian for now
                DivisionalNorthIndianChart(chartData: chartData, size: size)
            case .western:
                // Fall back to North Indian for divisional charts
                DivisionalNorthIndianChart(chartData: chartData, size: size)
            }

            // Significance info
            Text(chartData.chartType.significance)
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

// MARK: - North Indian Divisional Chart
struct DivisionalNorthIndianChart: View {
    let chartData: DivisionalChartData
    let size: CGFloat

    var body: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let outerSize = min(canvasSize.width, canvasSize.height) - 4

            // Draw outer diamond
            drawDiamond(context: context, center: center, size: outerSize)

            // Draw inner divisions
            drawInnerLines(context: context, center: center, size: outerSize)
        }
        .frame(width: size, height: size)
        .overlay {
            houseOverlay
        }
    }

    private func drawDiamond(context: GraphicsContext, center: CGPoint, size: CGFloat) {
        let halfSize = size / 2

        var path = Path()
        path.move(to: CGPoint(x: center.x, y: center.y - halfSize))
        path.addLine(to: CGPoint(x: center.x + halfSize, y: center.y))
        path.addLine(to: CGPoint(x: center.x, y: center.y + halfSize))
        path.addLine(to: CGPoint(x: center.x - halfSize, y: center.y))
        path.closeSubpath()

        context.stroke(path, with: .color(.kundliPrimary), lineWidth: 2)
    }

    private func drawInnerLines(context: GraphicsContext, center: CGPoint, size: CGFloat) {
        let halfSize = size / 2
        let quarterSize = size / 4

        // Inner square
        var innerSquare = Path()
        innerSquare.move(to: CGPoint(x: center.x, y: center.y - quarterSize))
        innerSquare.addLine(to: CGPoint(x: center.x + quarterSize, y: center.y))
        innerSquare.addLine(to: CGPoint(x: center.x, y: center.y + quarterSize))
        innerSquare.addLine(to: CGPoint(x: center.x - quarterSize, y: center.y))
        innerSquare.closeSubpath()

        context.stroke(innerSquare, with: .color(.kundliPrimary.opacity(0.7)), lineWidth: 1.5)

        // Corner connecting lines
        let lines: [(CGPoint, CGPoint)] = [
            (CGPoint(x: center.x - halfSize, y: center.y), CGPoint(x: center.x - quarterSize, y: center.y - quarterSize)),
            (CGPoint(x: center.x, y: center.y - halfSize), CGPoint(x: center.x - quarterSize, y: center.y - quarterSize)),
            (CGPoint(x: center.x, y: center.y - halfSize), CGPoint(x: center.x + quarterSize, y: center.y - quarterSize)),
            (CGPoint(x: center.x + halfSize, y: center.y), CGPoint(x: center.x + quarterSize, y: center.y - quarterSize)),
            (CGPoint(x: center.x + halfSize, y: center.y), CGPoint(x: center.x + quarterSize, y: center.y + quarterSize)),
            (CGPoint(x: center.x, y: center.y + halfSize), CGPoint(x: center.x + quarterSize, y: center.y + quarterSize)),
            (CGPoint(x: center.x, y: center.y + halfSize), CGPoint(x: center.x - quarterSize, y: center.y + quarterSize)),
            (CGPoint(x: center.x - halfSize, y: center.y), CGPoint(x: center.x - quarterSize, y: center.y + quarterSize))
        ]

        for (start, end) in lines {
            var line = Path()
            line.move(to: start)
            line.addLine(to: end)
            context.stroke(line, with: .color(.kundliPrimary.opacity(0.7)), lineWidth: 1)
        }
    }

    private var houseOverlay: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let chartSize = min(geometry.size.width, geometry.size.height) - 4
            let positions = housePositions(center: center, size: chartSize)

            ZStack {
                ForEach(1...12, id: \.self) { house in
                    if let position = positions[house] {
                        houseContent(house: house)
                            .position(position)
                    }
                }
            }
        }
    }

    private func houseContent(house: Int) -> some View {
        let planets = chartData.planets(inHouse: house)
        let isAscendant = house == 1
        let signIndex = (chartData.ascendantSign + house - 1) % 12
        let sign = ZodiacSign.allCases[signIndex]

        return VStack(spacing: 2) {
            if isAscendant {
                Text("Asc")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.kundliPrimary)
            }

            // Planet symbols
            Text(planets.map { $0.symbol }.joined(separator: " "))
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.kundliTextPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            // Sign abbreviation (optional, shown small)
            Text(sign.abbreviation)
                .font(.system(size: 8))
                .foregroundColor(.kundliTextSecondary.opacity(0.7))
        }
        .frame(width: size / 5)
    }

    private func housePositions(center: CGPoint, size: CGFloat) -> [Int: CGPoint] {
        let q = size / 4

        return [
            1:  CGPoint(x: center.x, y: center.y - q * 1.5),
            2:  CGPoint(x: center.x - q, y: center.y - q * 0.7),
            3:  CGPoint(x: center.x - q * 1.5, y: center.y),
            4:  CGPoint(x: center.x - q, y: center.y + q * 0.7),
            5:  CGPoint(x: center.x - q * 0.5, y: center.y + q * 1.3),
            6:  CGPoint(x: center.x, y: center.y + q * 1.5),
            7:  CGPoint(x: center.x + q * 0.5, y: center.y + q * 1.3),
            8:  CGPoint(x: center.x + q, y: center.y + q * 0.7),
            9:  CGPoint(x: center.x + q * 1.5, y: center.y),
            10: CGPoint(x: center.x + q, y: center.y - q * 0.7),
            11: CGPoint(x: center.x + q * 0.5, y: center.y - q * 1.3),
            12: CGPoint(x: center.x - q * 0.5, y: center.y - q * 1.3),
        ]
    }
}

// MARK: - South Indian Divisional Chart
struct DivisionalSouthIndianChart: View {
    let chartData: DivisionalChartData
    let size: CGFloat

    var body: some View {
        Canvas { context, canvasSize in
            let chartSize = min(canvasSize.width, canvasSize.height) - 4
            let origin = CGPoint(x: (canvasSize.width - chartSize) / 2, y: (canvasSize.height - chartSize) / 2)

            // Draw grid
            drawGrid(context: context, origin: origin, size: chartSize)
        }
        .frame(width: size, height: size)
        .overlay {
            houseOverlay
        }
    }

    private func drawGrid(context: GraphicsContext, origin: CGPoint, size: CGFloat) {
        let cellSize = size / 4

        // Outer border
        var outerRect = Path()
        outerRect.addRect(CGRect(x: origin.x, y: origin.y, width: size, height: size))
        context.stroke(outerRect, with: .color(.kundliPrimary), lineWidth: 2)

        // Horizontal lines
        for i in 1...3 {
            var line = Path()
            let y = origin.y + cellSize * CGFloat(i)
            line.move(to: CGPoint(x: origin.x, y: y))
            line.addLine(to: CGPoint(x: origin.x + size, y: y))
            context.stroke(line, with: .color(.kundliPrimary.opacity(0.7)), lineWidth: 1)
        }

        // Vertical lines
        for i in 1...3 {
            var line = Path()
            let x = origin.x + cellSize * CGFloat(i)
            line.move(to: CGPoint(x: x, y: origin.y))
            line.addLine(to: CGPoint(x: x, y: origin.y + size))
            context.stroke(line, with: .color(.kundliPrimary.opacity(0.7)), lineWidth: 1)
        }
    }

    private var houseOverlay: some View {
        GeometryReader { geometry in
            let chartSize = min(geometry.size.width, geometry.size.height) - 4
            let cellSize = chartSize / 4
            let origin = CGPoint(x: (geometry.size.width - chartSize) / 2, y: (geometry.size.height - chartSize) / 2)

            ZStack {
                ForEach(0..<12, id: \.self) { index in
                    let position = cellPosition(index: index, origin: origin, cellSize: cellSize)
                    let house = houseForSignIndex(index)
                    houseContent(house: house, signIndex: index)
                        .position(position)
                }
            }
        }
    }

    private func houseContent(house: Int, signIndex: Int) -> some View {
        let planets = chartData.planets(inHouse: house)
        let isAscendant = house == 1
        let sign = ZodiacSign.allCases[signIndex]

        return VStack(spacing: 2) {
            // Sign abbreviation
            Text(sign.abbreviation)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(isAscendant ? .kundliPrimary : .kundliTextSecondary)

            if isAscendant {
                Text("Asc")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.kundliPrimary)
            }

            // Planet symbols
            Text(planets.map { $0.symbol }.joined(separator: " "))
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.kundliTextPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: size / 5, height: size / 5)
    }

    private func houseForSignIndex(_ signIndex: Int) -> Int {
        let houseIndex = (signIndex - chartData.ascendantSign + 12) % 12
        return houseIndex + 1
    }

    private func cellPosition(index: Int, origin: CGPoint, cellSize: CGFloat) -> CGPoint {
        // South Indian chart layout (fixed signs, houses rotate)
        // Signs are placed in order starting from Aries at position 1 (row 0, col 1)
        let positions: [(row: Int, col: Int)] = [
            (0, 1), (0, 2), (0, 3),  // Aries, Taurus, Gemini (top row)
            (1, 3), (2, 3), (3, 3),  // Cancer, Leo, Virgo (right column)
            (3, 2), (3, 1), (3, 0),  // Libra, Scorpio, Sagittarius (bottom row)
            (2, 0), (1, 0), (0, 0)   // Capricorn, Aquarius, Pisces (left column)
        ]

        let pos = positions[index]
        return CGPoint(
            x: origin.x + cellSize * (CGFloat(pos.col) + 0.5),
            y: origin.y + cellSize * (CGFloat(pos.row) + 0.5)
        )
    }
}

// MARK: - Zodiac Sign Extension
extension ZodiacSign {
    var abbreviation: String {
        switch self {
        case .aries: return "Ar"
        case .taurus: return "Ta"
        case .gemini: return "Ge"
        case .cancer: return "Ca"
        case .leo: return "Le"
        case .virgo: return "Vi"
        case .libra: return "Li"
        case .scorpio: return "Sc"
        case .sagittarius: return "Sg"
        case .capricorn: return "Cp"
        case .aquarius: return "Aq"
        case .pisces: return "Pi"
        }
    }
}

// MARK: - Full Screen Divisional Charts View
struct DivisionalChartsDetailView: View {
    let charts: [DivisionalChartData]
    @State private var selectedChart: DivisionalChart = .d1
    @State private var chartStyle: ChartStyle = .northIndian

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Chart type selector
                    DivisionalChartSegmentedPicker(selectedChart: $selectedChart)

                    // All charts dropdown
                    if charts.count > 3 {
                        DivisionalChartPicker(
                            selectedChart: $selectedChart,
                            availableCharts: charts.map { $0.chartType }
                        )
                    }

                    // Chart style picker
                    Picker("Style", selection: $chartStyle) {
                        ForEach([ChartStyle.northIndian, .southIndian], id: \.self) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)

                    // Selected chart display
                    if let chartData = charts.first(where: { $0.chartType == selectedChart }) {
                        CardView(padding: 20) {
                            DivisionalChartView(
                                chartData: chartData,
                                chartStyle: chartStyle,
                                size: 280
                            )
                        }

                        // Planet positions for this chart
                        DivisionalChartPlanetList(chartData: chartData)
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("Divisional Charts")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// MARK: - Planet List for Divisional Chart
struct DivisionalChartPlanetList: View {
    let chartData: DivisionalChartData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Planet Positions in \(chartData.chartType.rawValue)")
                .font(.kundliHeadline)
                .foregroundColor(.kundliTextPrimary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(chartData.planetPositions, id: \.planet) { position in
                    planetPositionCard(position: position)
                }
            }
        }
    }

    private func planetPositionCard(position: DivisionalPlanetPosition) -> some View {
        CardView(padding: 12) {
            VStack(spacing: 4) {
                Text(position.planet.symbol)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.kundliPrimary)

                Text(position.sign.vedName)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextPrimary)

                if let house = chartData.house(for: position.planet) {
                    Text("H\(house)")
                        .font(.kundliCaption2)
                        .foregroundColor(.kundliTextSecondary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DivisionalChartsDetailView(charts: [
            DivisionalChartData(
                chartType: .d1,
                ascendantSign: 0,
                ascendantDegree: 15.5,
                planetPositions: [
                    DivisionalPlanetPosition(planet: .sun, signIndex: 0, degreeInSign: 10.5),
                    DivisionalPlanetPosition(planet: .moon, signIndex: 3, degreeInSign: 20.0),
                    DivisionalPlanetPosition(planet: .mars, signIndex: 6, degreeInSign: 5.0),
                    DivisionalPlanetPosition(planet: .mercury, signIndex: 0, degreeInSign: 15.0),
                    DivisionalPlanetPosition(planet: .jupiter, signIndex: 9, degreeInSign: 12.0),
                    DivisionalPlanetPosition(planet: .venus, signIndex: 1, degreeInSign: 25.0),
                    DivisionalPlanetPosition(planet: .saturn, signIndex: 10, degreeInSign: 8.0),
                    DivisionalPlanetPosition(planet: .rahu, signIndex: 4, degreeInSign: 18.0),
                    DivisionalPlanetPosition(planet: .ketu, signIndex: 10, degreeInSign: 18.0)
                ]
            ),
            DivisionalChartData(
                chartType: .d9,
                ascendantSign: 5,
                ascendantDegree: 22.0,
                planetPositions: [
                    DivisionalPlanetPosition(planet: .sun, signIndex: 3, degreeInSign: 15.0),
                    DivisionalPlanetPosition(planet: .moon, signIndex: 0, degreeInSign: 10.0),
                    DivisionalPlanetPosition(planet: .mars, signIndex: 9, degreeInSign: 5.0),
                    DivisionalPlanetPosition(planet: .mercury, signIndex: 6, degreeInSign: 20.0),
                    DivisionalPlanetPosition(planet: .jupiter, signIndex: 3, degreeInSign: 12.0),
                    DivisionalPlanetPosition(planet: .venus, signIndex: 11, degreeInSign: 25.0),
                    DivisionalPlanetPosition(planet: .saturn, signIndex: 2, degreeInSign: 8.0),
                    DivisionalPlanetPosition(planet: .rahu, signIndex: 6, degreeInSign: 18.0),
                    DivisionalPlanetPosition(planet: .ketu, signIndex: 0, degreeInSign: 18.0)
                ]
            )
        ])
    }
}
