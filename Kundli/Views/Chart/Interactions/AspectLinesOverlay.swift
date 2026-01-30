import SwiftUI

/// Overlay view that draws aspect lines between planets on charts
struct AspectLinesOverlay: View {
    let kundli: Kundli
    let chartSize: CGFloat
    let chartStyle: ChartStyle
    let showAspects: Bool

    /// Aspect orbs for different types
    private let aspectOrbs: [TransitAspect: Double] = [
        .conjunction: 10,
        .opposition: 10,
        .trine: 8,
        .square: 8,
        .sextile: 6
    ]

    var body: some View {
        if showAspects {
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let aspects = calculateAspects()

                for aspect in aspects {
                    drawAspectLine(
                        context: context,
                        center: center,
                        aspect: aspect,
                        size: chartSize
                    )
                }
            }
            .frame(width: chartSize, height: chartSize)
            .allowsHitTesting(false)
        }
    }

    // MARK: - Aspect Calculation

    private func calculateAspects() -> [ChartAspect] {
        var aspects: [ChartAspect] = []
        let planets = kundli.planets

        for i in 0..<planets.count {
            for j in (i + 1)..<planets.count {
                let planet1 = planets[i]
                let planet2 = planets[j]

                if let aspect = calculateAspect(between: planet1, and: planet2) {
                    aspects.append(aspect)
                }
            }
        }

        return aspects
    }

    private func calculateAspect(between planet1: Planet, and planet2: Planet) -> ChartAspect? {
        let long1 = totalLongitude(for: planet1)
        let long2 = totalLongitude(for: planet2)

        var distance = abs(long1 - long2)
        if distance > 180 { distance = 360 - distance }

        // Check each aspect type
        for (aspectType, orb) in aspectOrbs {
            if abs(distance - aspectType.degrees) <= orb {
                let exactOrb = abs(distance - aspectType.degrees)
                return ChartAspect(
                    planet1: planet1,
                    planet2: planet2,
                    type: aspectType,
                    orb: exactOrb
                )
            }
        }

        return nil
    }

    // MARK: - Drawing

    private func drawAspectLine(
        context: GraphicsContext,
        center: CGPoint,
        aspect: ChartAspect,
        size: CGFloat
    ) {
        let position1 = planetPosition(for: aspect.planet1, center: center, size: size)
        let position2 = planetPosition(for: aspect.planet2, center: center, size: size)

        var path = Path()
        path.move(to: position1)
        path.addLine(to: position2)

        let color = aspectColor(aspect.type)
        let lineWidth = lineWidth(for: aspect)

        context.stroke(
            path,
            with: .color(color),
            style: StrokeStyle(
                lineWidth: lineWidth,
                dash: aspect.type == .opposition ? [4, 4] : []
            )
        )
    }

    private func planetPosition(for planet: Planet, center: CGPoint, size: CGFloat) -> CGPoint {
        switch chartStyle {
        case .northIndian, .eastIndian:
            return northIndianPosition(for: planet, center: center, size: size)
        case .southIndian:
            return southIndianPosition(for: planet, center: center, size: size)
        case .western:
            return westernPosition(for: planet, center: center, size: size)
        }
    }

    // MARK: - Western Chart Positions

    private func westernPosition(for planet: Planet, center: CGPoint, size: CGFloat) -> CGPoint {
        let ascDegree = Double(kundli.ascendant.sign.number - 1) * 30 + kundli.ascendant.degree
        let planetDegree = totalLongitude(for: planet)
        let relativeAngle = planetDegree - ascDegree
        let angle = Angle.degrees(-relativeAngle - 90)
        let radius = size * 0.35

        return CGPoint(
            x: center.x + radius * cos(CGFloat(angle.radians)),
            y: center.y + radius * sin(CGFloat(angle.radians))
        )
    }

    /// Get total ecliptic longitude (0-360) from planet's sign and degree
    private func totalLongitude(for planet: Planet) -> Double {
        let signIndex: Int
        switch planet.sign.lowercased() {
        case "aries", "mesha": signIndex = 0
        case "taurus", "vrishabha": signIndex = 1
        case "gemini", "mithuna": signIndex = 2
        case "cancer", "karka": signIndex = 3
        case "leo", "simha": signIndex = 4
        case "virgo", "kanya": signIndex = 5
        case "libra", "tula": signIndex = 6
        case "scorpio", "vrishchika": signIndex = 7
        case "sagittarius", "dhanu": signIndex = 8
        case "capricorn", "makara": signIndex = 9
        case "aquarius", "kumbha": signIndex = 10
        case "pisces", "meena": signIndex = 11
        default: signIndex = 0
        }
        return Double(signIndex * 30) + planet.degree + Double(planet.minutes) / 60.0 + Double(planet.seconds) / 3600.0
    }

    // MARK: - North Indian Chart Positions

    private func northIndianPosition(for planet: Planet, center: CGPoint, size: CGFloat) -> CGPoint {
        let house = planet.house
        let q = size / 4

        // House center positions for North Indian chart
        let housePositions: [Int: CGPoint] = [
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

        return housePositions[house] ?? center
    }

    // MARK: - South Indian Chart Positions

    private func southIndianPosition(for planet: Planet, center: CGPoint, size: CGFloat) -> CGPoint {
        let house = planet.house
        let cellSize = size / 4
        let startX = center.x - size / 2
        let startY = center.y - size / 2

        // Grid positions for South Indian chart (row, col)
        let gridPositions: [Int: (row: Int, col: Int)] = [
            1:  (0, 1),
            2:  (0, 0),
            3:  (1, 0),
            4:  (2, 0),
            5:  (3, 0),
            6:  (3, 1),
            7:  (3, 2),
            8:  (3, 3),
            9:  (2, 3),
            10: (1, 3),
            11: (0, 3),
            12: (0, 2),
        ]

        guard let position = gridPositions[house] else { return center }

        let cellX = startX + cellSize * CGFloat(position.col) + cellSize / 2
        let cellY = startY + cellSize * CGFloat(position.row) + cellSize / 2

        return CGPoint(x: cellX, y: cellY)
    }

    // MARK: - Styling

    private func aspectColor(_ type: TransitAspect) -> Color {
        switch type.nature {
        case .harmonious:
            return Color.kundliSuccess.opacity(0.7)
        case .challenging:
            return Color.kundliError.opacity(0.7)
        case .neutral:
            return Color.kundliInfo.opacity(0.7)
        case .adjusting:
            return Color.kundliWarning.opacity(0.7)
        }
    }

    private func lineWidth(for aspect: ChartAspect) -> CGFloat {
        // Tighter orbs = thicker lines (stronger aspect)
        let maxOrb = aspectOrbs[aspect.type] ?? 10
        let strength = 1 - (aspect.orb / maxOrb)
        return 1 + (strength * 2) // Range: 1-3 points
    }
}

// MARK: - Chart Aspect Model

struct ChartAspect {
    let planet1: Planet
    let planet2: Planet
    let type: TransitAspect
    let orb: Double

    var description: String {
        "\(planet1.symbol)-\(planet2.symbol) \(type.rawValue)"
    }
}

// MARK: - Aspect Legend View

struct AspectLegendView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Aspect Lines")
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)

            HStack(spacing: 16) {
                legendItem(color: .kundliSuccess, label: "Trine/Sextile")
                legendItem(color: .kundliError, label: "Square/Opposition")
                legendItem(color: .kundliInfo, label: "Conjunction")
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Rectangle()
                .fill(color.opacity(0.7))
                .frame(width: 16, height: 2)

            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.kundliTextSecondary)
        }
    }
}

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        VStack(spacing: 20) {
            ZStack {
                // This would overlay on top of the chart
                Rectangle()
                    .stroke(Color.kundliPrimary.opacity(0.3), lineWidth: 1)
                    .frame(width: 280, height: 280)

                AspectLinesOverlay(
                    kundli: MockDataService.shared.sampleKundli(),
                    chartSize: 280,
                    chartStyle: .northIndian,
                    showAspects: true
                )
            }

            AspectLegendView()
                .padding(.horizontal)
        }
    }
}
