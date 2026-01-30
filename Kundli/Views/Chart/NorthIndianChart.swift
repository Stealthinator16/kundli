import SwiftUI

struct NorthIndianChart: View {
    let kundli: Kundli
    let size: CGFloat
    var interactionState: ChartInteractionState?
    var onPlanetTap: ((Planet, CGPoint) -> Void)?
    var onHouseTap: ((Int) -> Void)?

    init(
        kundli: Kundli,
        size: CGFloat = 300,
        interactionState: ChartInteractionState? = nil,
        onPlanetTap: ((Planet, CGPoint) -> Void)? = nil,
        onHouseTap: ((Int) -> Void)? = nil
    ) {
        self.kundli = kundli
        self.size = size
        self.interactionState = interactionState
        self.onPlanetTap = onPlanetTap
        self.onHouseTap = onHouseTap
    }

    var body: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let outerSize = min(canvasSize.width, canvasSize.height) - 4

            // Draw outer diamond
            drawDiamond(context: context, center: center, size: outerSize)

            // Draw inner divisions
            drawInnerLines(context: context, center: center, size: outerSize)

            // Draw house numbers and planets
        } symbols: {
            // Empty symbols dictionary
        }
        .frame(width: size, height: size)
        .overlay {
            // Draw house contents using SwiftUI
            houseOverlay
        }
    }

    private func drawDiamond(context: GraphicsContext, center: CGPoint, size: CGFloat) {
        let halfSize = size / 2

        var path = Path()
        path.move(to: CGPoint(x: center.x, y: center.y - halfSize))    // Top
        path.addLine(to: CGPoint(x: center.x + halfSize, y: center.y)) // Right
        path.addLine(to: CGPoint(x: center.x, y: center.y + halfSize)) // Bottom
        path.addLine(to: CGPoint(x: center.x - halfSize, y: center.y)) // Left
        path.closeSubpath()

        context.stroke(
            path,
            with: .color(.kundliPrimary),
            lineWidth: 2
        )
    }

    private func drawInnerLines(context: GraphicsContext, center: CGPoint, size: CGFloat) {
        let halfSize = size / 2
        let quarterSize = size / 4

        // Draw the inner square (rotated 45 degrees, connecting midpoints)
        var innerSquare = Path()
        innerSquare.move(to: CGPoint(x: center.x, y: center.y - quarterSize))
        innerSquare.addLine(to: CGPoint(x: center.x + quarterSize, y: center.y))
        innerSquare.addLine(to: CGPoint(x: center.x, y: center.y + quarterSize))
        innerSquare.addLine(to: CGPoint(x: center.x - quarterSize, y: center.y))
        innerSquare.closeSubpath()

        context.stroke(
            innerSquare,
            with: .color(.kundliPrimary.opacity(0.7)),
            lineWidth: 1.5
        )

        // Draw lines from corners to inner square
        // Top-left corner lines
        var line1 = Path()
        line1.move(to: CGPoint(x: center.x - halfSize, y: center.y))
        line1.addLine(to: CGPoint(x: center.x - quarterSize, y: center.y - quarterSize))
        context.stroke(line1, with: .color(.kundliPrimary.opacity(0.7)), lineWidth: 1)

        var line2 = Path()
        line2.move(to: CGPoint(x: center.x, y: center.y - halfSize))
        line2.addLine(to: CGPoint(x: center.x - quarterSize, y: center.y - quarterSize))
        context.stroke(line2, with: .color(.kundliPrimary.opacity(0.7)), lineWidth: 1)

        // Top-right corner lines
        var line3 = Path()
        line3.move(to: CGPoint(x: center.x, y: center.y - halfSize))
        line3.addLine(to: CGPoint(x: center.x + quarterSize, y: center.y - quarterSize))
        context.stroke(line3, with: .color(.kundliPrimary.opacity(0.7)), lineWidth: 1)

        var line4 = Path()
        line4.move(to: CGPoint(x: center.x + halfSize, y: center.y))
        line4.addLine(to: CGPoint(x: center.x + quarterSize, y: center.y - quarterSize))
        context.stroke(line4, with: .color(.kundliPrimary.opacity(0.7)), lineWidth: 1)

        // Bottom-right corner lines
        var line5 = Path()
        line5.move(to: CGPoint(x: center.x + halfSize, y: center.y))
        line5.addLine(to: CGPoint(x: center.x + quarterSize, y: center.y + quarterSize))
        context.stroke(line5, with: .color(.kundliPrimary.opacity(0.7)), lineWidth: 1)

        var line6 = Path()
        line6.move(to: CGPoint(x: center.x, y: center.y + halfSize))
        line6.addLine(to: CGPoint(x: center.x + quarterSize, y: center.y + quarterSize))
        context.stroke(line6, with: .color(.kundliPrimary.opacity(0.7)), lineWidth: 1)

        // Bottom-left corner lines
        var line7 = Path()
        line7.move(to: CGPoint(x: center.x, y: center.y + halfSize))
        line7.addLine(to: CGPoint(x: center.x - quarterSize, y: center.y + quarterSize))
        context.stroke(line7, with: .color(.kundliPrimary.opacity(0.7)), lineWidth: 1)

        var line8 = Path()
        line8.move(to: CGPoint(x: center.x - halfSize, y: center.y))
        line8.addLine(to: CGPoint(x: center.x - quarterSize, y: center.y + quarterSize))
        context.stroke(line8, with: .color(.kundliPrimary.opacity(0.7)), lineWidth: 1)
    }

    private var houseOverlay: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let chartSize = min(geometry.size.width, geometry.size.height) - 4
            let positions = housePositions(center: center, size: chartSize)
            let tapZones = houseTapZones(center: center, size: chartSize)

            ZStack {
                // House tap zones (invisible, for tap detection)
                ForEach(1...12, id: \.self) { house in
                    if let zone = tapZones[house] {
                        houseTapZone(house: house, zone: zone)
                    }
                }

                // House contents (visible)
                ForEach(1...12, id: \.self) { house in
                    if let position = positions[house] {
                        houseContent(house: house)
                            .position(position)
                            .houseAnimation(house: house, state: interactionState ?? ChartInteractionState())
                    }
                }
            }
        }
    }

    private func houseTapZone(house: Int, zone: CGRect) -> some View {
        let isSelected = interactionState?.selectedHouse == house

        return Rectangle()
            .fill(Color.clear)
            .frame(width: zone.width, height: zone.height)
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.kundliPrimary.opacity(0.6), lineWidth: 1.5)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.kundliPrimary.opacity(0.1))
                        )
                }
            }
            .position(x: zone.midX, y: zone.midY)
            .contentShape(Rectangle())
            .onTapGesture {
                onHouseTap?(house)
            }
    }

    private func houseContent(house: Int) -> some View {
        let planets = kundli.planetsInHouse(house)
        let isAscendant = house == 1

        return VStack(spacing: 2) {
            if isAscendant {
                Text("Asc")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.kundliPrimary)
            }

            // If we have interaction callbacks, make planets tappable
            if let onPlanetTap = onPlanetTap, !planets.isEmpty {
                TappablePlanetRow(
                    planets: planets,
                    selectedPlanet: interactionState?.selectedPlanet,
                    onPlanetTap: onPlanetTap
                )
            } else {
                Text(planets.map { $0.symbol }.joined(separator: " "))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.kundliTextPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: size / 5)
    }

    // Calculate tap zones for each house based on the diamond layout
    private func houseTapZones(center: CGPoint, size: CGFloat) -> [Int: CGRect] {
        let q = size / 4
        let smallSize = CGSize(width: q * 0.9, height: q * 0.7)
        let positions = housePositions(center: center, size: size)

        var zones: [Int: CGRect] = [:]
        for house in 1...12 {
            if let pos = positions[house] {
                zones[house] = CGRect(
                    x: pos.x - smallSize.width / 2,
                    y: pos.y - smallSize.height / 2,
                    width: smallSize.width,
                    height: smallSize.height
                )
            }
        }
        return zones
    }

    private func housePositions(center: CGPoint, size: CGFloat) -> [Int: CGPoint] {
        let q = size / 4

        // North Indian chart house positions
        // House 1 is at top center (Ascendant)
        return [
            1:  CGPoint(x: center.x, y: center.y - q * 1.5),           // Top center
            2:  CGPoint(x: center.x - q, y: center.y - q * 0.7),       // Upper left
            3:  CGPoint(x: center.x - q * 1.5, y: center.y),           // Left upper
            4:  CGPoint(x: center.x - q, y: center.y + q * 0.7),       // Left lower
            5:  CGPoint(x: center.x - q * 0.5, y: center.y + q * 1.3), // Lower left
            6:  CGPoint(x: center.x, y: center.y + q * 1.5),           // Bottom center
            7:  CGPoint(x: center.x + q * 0.5, y: center.y + q * 1.3), // Lower right
            8:  CGPoint(x: center.x + q, y: center.y + q * 0.7),       // Right lower
            9:  CGPoint(x: center.x + q * 1.5, y: center.y),           // Right upper
            10: CGPoint(x: center.x + q, y: center.y - q * 0.7),       // Upper right
            11: CGPoint(x: center.x + q * 0.5, y: center.y - q * 1.3), // Top right
            12: CGPoint(x: center.x - q * 0.5, y: center.y - q * 1.3), // Top left
        ]
    }
}

// MARK: - Chart Legend
struct ChartLegend: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Planet Symbols")
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                legendItem("Su", "Sun")
                legendItem("Mo", "Moon")
                legendItem("Ma", "Mars")
                legendItem("Me", "Mercury")
                legendItem("Ju", "Jupiter")
                legendItem("Ve", "Venus")
                legendItem("Sa", "Saturn")
                legendItem("Ra", "Rahu")
                legendItem("Ke", "Ketu")
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func legendItem(_ symbol: String, _ name: String) -> some View {
        HStack(spacing: 4) {
            Text(symbol)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.kundliPrimary)
                .frame(width: 24)

            Text(name)
                .font(.system(size: 11))
                .foregroundColor(.kundliTextSecondary)
        }
    }
}

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        VStack(spacing: 20) {
            NorthIndianChart(kundli: MockDataService.shared.sampleKundli(), size: 300)

            ChartLegend()
                .padding(.horizontal)
        }
    }
}
