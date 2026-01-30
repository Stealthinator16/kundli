import SwiftUI

struct SouthIndianChart: View {
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
        ZStack {
            // Draw grid
            Canvas { context, canvasSize in
                let gridSize = min(canvasSize.width, canvasSize.height)
                let cellSize = gridSize / 4
                let startX = (canvasSize.width - gridSize) / 2
                let startY = (canvasSize.height - gridSize) / 2

                // Draw outer rectangle
                var outerRect = Path()
                outerRect.addRect(CGRect(x: startX, y: startY, width: gridSize, height: gridSize))
                context.stroke(outerRect, with: .color(.kundliPrimary), lineWidth: 2)

                // Draw grid lines
                for i in 1...3 {
                    // Vertical lines
                    var vLine = Path()
                    vLine.move(to: CGPoint(x: startX + cellSize * CGFloat(i), y: startY))
                    vLine.addLine(to: CGPoint(x: startX + cellSize * CGFloat(i), y: startY + gridSize))
                    context.stroke(vLine, with: .color(.kundliPrimary.opacity(0.7)), lineWidth: 1)

                    // Horizontal lines
                    var hLine = Path()
                    hLine.move(to: CGPoint(x: startX, y: startY + cellSize * CGFloat(i)))
                    hLine.addLine(to: CGPoint(x: startX + gridSize, y: startY + cellSize * CGFloat(i)))
                    context.stroke(hLine, with: .color(.kundliPrimary.opacity(0.7)), lineWidth: 1)
                }

                // Draw diagonal in center (to mark it as empty)
                var diagonal1 = Path()
                diagonal1.move(to: CGPoint(x: startX + cellSize, y: startY + cellSize))
                diagonal1.addLine(to: CGPoint(x: startX + cellSize * 3, y: startY + cellSize * 3))
                context.stroke(diagonal1, with: .color(.kundliPrimary.opacity(0.3)), lineWidth: 0.5)

                var diagonal2 = Path()
                diagonal2.move(to: CGPoint(x: startX + cellSize * 3, y: startY + cellSize))
                diagonal2.addLine(to: CGPoint(x: startX + cellSize, y: startY + cellSize * 3))
                context.stroke(diagonal2, with: .color(.kundliPrimary.opacity(0.3)), lineWidth: 0.5)
            }
            .frame(width: size, height: size)

            // House contents
            GeometryReader { geometry in
                let gridSize = min(geometry.size.width, geometry.size.height)
                let cellSize = gridSize / 4
                let startX = (geometry.size.width - gridSize) / 2
                let startY = (geometry.size.height - gridSize) / 2

                ForEach(Array(houseGridPositions.enumerated()), id: \.offset) { index, position in
                    let house = index + 1
                    let cellX = startX + cellSize * CGFloat(position.col) + cellSize / 2
                    let cellY = startY + cellSize * CGFloat(position.row) + cellSize / 2

                    ZStack {
                        // Tap zone with selection highlight
                        houseTapZone(house: house, cellSize: cellSize)

                        // House content
                        houseCell(house: house, cellSize: cellSize)
                            .houseAnimation(house: house, state: interactionState ?? ChartInteractionState())
                    }
                    .frame(width: cellSize, height: cellSize)
                    .position(x: cellX, y: cellY)
                }
            }
        }
        .frame(width: size, height: size)
    }

    private func houseTapZone(house: Int, cellSize: CGFloat) -> some View {
        let isSelected = interactionState?.selectedHouse == house

        return Rectangle()
            .fill(Color.clear)
            .frame(width: cellSize - 4, height: cellSize - 4)
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
            .contentShape(Rectangle())
            .onTapGesture {
                onHouseTap?(house)
            }
    }

    private func houseCell(house: Int, cellSize: CGFloat) -> some View {
        let planets = kundli.planetsInHouse(house)
        let ascendantHouse = 1

        return VStack(spacing: 2) {
            // House number
            Text("\(house)")
                .font(.system(size: 8))
                .foregroundColor(.kundliTextSecondary)

            // Planets - tappable if interaction callbacks provided
            if let onPlanetTap = onPlanetTap, !planets.isEmpty {
                TappablePlanetRow(
                    planets: planets,
                    selectedPlanet: interactionState?.selectedPlanet,
                    onPlanetTap: onPlanetTap
                )
            } else {
                Text(planets.map { $0.symbol }.joined(separator: " "))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.kundliTextPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }

            if house == ascendantHouse {
                Text("Asc")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundColor(.kundliPrimary)
            }
        }
        .frame(width: cellSize - 8, height: cellSize - 8)
    }

    // South Indian chart layout (fixed sign positions)
    // Houses are placed in a 4x4 grid with center 2x2 empty
    private var houseGridPositions: [(row: Int, col: Int)] {
        [
            (0, 1), // House 1 - Pisces position
            (0, 0), // House 2 - Aries
            (1, 0), // House 3 - Taurus
            (2, 0), // House 4 - Gemini
            (3, 0), // House 5 - Cancer
            (3, 1), // House 6 - Leo
            (3, 2), // House 7 - Virgo
            (3, 3), // House 8 - Libra
            (2, 3), // House 9 - Scorpio
            (1, 3), // House 10 - Sagittarius
            (0, 3), // House 11 - Capricorn
            (0, 2), // House 12 - Aquarius
        ]
    }
}

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        SouthIndianChart(kundli: MockDataService.shared.sampleKundli(), size: 300)
    }
}
