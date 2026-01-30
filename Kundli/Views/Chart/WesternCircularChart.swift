import SwiftUI

/// Western-style circular zodiac chart
struct WesternCircularChart: View {
    let kundli: Kundli
    let size: CGFloat
    var interactionState: ChartInteractionState?
    var onPlanetTap: ((Planet, CGPoint) -> Void)?
    var onHouseTap: ((Int) -> Void)?

    private let zodiacSymbols = ["♈", "♉", "♊", "♋", "♌", "♍", "♎", "♏", "♐", "♑", "♒", "♓"]

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
            // Draw the chart using Canvas
            Canvas { context, canvasSize in
                let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
                let outerRadius = min(canvasSize.width, canvasSize.height) / 2 - 4
                let innerRadius = outerRadius * 0.7
                let houseRadius = outerRadius * 0.5

                // Draw outer circle
                drawCircle(context: context, center: center, radius: outerRadius, lineWidth: 2)

                // Draw inner circle (zodiac ring inner boundary)
                drawCircle(context: context, center: center, radius: innerRadius, lineWidth: 1.5)

                // Draw house circle
                drawCircle(context: context, center: center, radius: houseRadius, lineWidth: 1)

                // Draw zodiac sign divisions (12 segments)
                drawZodiacDivisions(context: context, center: center, outerRadius: outerRadius, innerRadius: innerRadius)

                // Draw house cusps based on ascendant
                drawHouseCusps(context: context, center: center, innerRadius: innerRadius, houseRadius: houseRadius)
            }
            .frame(width: size, height: size)

            // Overlay zodiac symbols and planets
            chartOverlay
        }
        .frame(width: size, height: size)
    }

    // MARK: - Drawing Methods

    private func drawCircle(context: GraphicsContext, center: CGPoint, radius: CGFloat, lineWidth: CGFloat) {
        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(0),
            endAngle: .degrees(360),
            clockwise: false
        )
        context.stroke(path, with: .color(.kundliPrimary), lineWidth: lineWidth)
    }

    private func drawZodiacDivisions(context: GraphicsContext, center: CGPoint, outerRadius: CGFloat, innerRadius: CGFloat) {
        for i in 0..<12 {
            let angle = Angle.degrees(Double(i) * 30 - 90)  // Start from top, each sign = 30°
            let startPoint = pointOnCircle(center: center, radius: innerRadius, angle: angle)
            let endPoint = pointOnCircle(center: center, radius: outerRadius, angle: angle)

            var path = Path()
            path.move(to: startPoint)
            path.addLine(to: endPoint)
            context.stroke(path, with: .color(.kundliPrimary.opacity(0.5)), lineWidth: 1)
        }
    }

    private func drawHouseCusps(context: GraphicsContext, center: CGPoint, innerRadius: CGFloat, houseRadius: CGFloat) {
        // Get ascendant degree to offset house cusps
        let ascDegree = kundli.ascendant.degree + Double(kundli.ascendant.sign.number - 1) * 30

        for i in 0..<12 {
            // House cusp angle (starting from ascendant position)
            let houseAngle = Angle.degrees(Double(i) * 30 - ascDegree - 90)
            let startPoint = pointOnCircle(center: center, radius: houseRadius, angle: houseAngle)
            let endPoint = pointOnCircle(center: center, radius: innerRadius, angle: houseAngle)

            var path = Path()
            path.move(to: startPoint)
            path.addLine(to: endPoint)

            // Highlight angles (1, 4, 7, 10)
            let isAngle = i == 0 || i == 3 || i == 6 || i == 9
            context.stroke(
                path,
                with: .color(.kundliPrimary.opacity(isAngle ? 0.8 : 0.3)),
                lineWidth: isAngle ? 1.5 : 1
            )
        }
    }

    private func pointOnCircle(center: CGPoint, radius: CGFloat, angle: Angle) -> CGPoint {
        CGPoint(
            x: center.x + radius * cos(CGFloat(angle.radians)),
            y: center.y + radius * sin(CGFloat(angle.radians))
        )
    }

    // MARK: - Overlay

    private var chartOverlay: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let outerRadius = min(geometry.size.width, geometry.size.height) / 2 - 4
            let innerRadius = outerRadius * 0.7
            let symbolRadius = (outerRadius + innerRadius) / 2
            let planetRadius = outerRadius * 0.35
            let houseNumberRadius = outerRadius * 0.58

            ZStack {
                // Zodiac symbols
                ForEach(0..<12, id: \.self) { index in
                    let angle = Angle.degrees(Double(index) * 30 + 15 - 90)  // Center of each sign
                    let position = pointOnCircle(center: center, radius: symbolRadius, angle: angle)

                    Text(zodiacSymbols[index])
                        .font(.system(size: 16))
                        .foregroundColor(zodiacColor(for: index))
                        .position(position)
                }

                // House numbers
                let ascDegree = kundli.ascendant.degree + Double(kundli.ascendant.sign.number - 1) * 30
                ForEach(1...12, id: \.self) { house in
                    let houseAngle = Angle.degrees(Double(house - 1) * 30 + 15 - ascDegree - 90)
                    let position = pointOnCircle(center: center, radius: houseNumberRadius, angle: houseAngle)
                    let isSelected = interactionState?.selectedHouse == house

                    Text("\(house)")
                        .font(.system(size: 10, weight: isSelected ? .bold : .regular))
                        .foregroundColor(isSelected ? .kundliPrimary : .kundliTextTertiary)
                        .position(position)
                        .onTapGesture {
                            onHouseTap?(house)
                        }
                }

                // Planet positions
                ForEach(kundli.planets, id: \.name) { planet in
                    let planetAngle = planetAngle(for: planet, ascDegree: ascDegree)
                    let position = pointOnCircle(center: center, radius: planetRadius, angle: planetAngle)
                    let isSelected = interactionState?.selectedPlanet?.name == planet.name

                    planetView(planet: planet, isSelected: isSelected)
                        .position(position)
                        .houseAnimation(house: planet.house, state: interactionState ?? ChartInteractionState())
                        .onTapGesture {
                            onPlanetTap?(planet, position)
                        }
                }
            }
        }
    }

    private func planetView(planet: Planet, isSelected: Bool) -> some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.kundliPrimary.opacity(0.3) : Color.kundliCardBg)
                .frame(width: 24, height: 24)

            Text(planet.symbol)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(isSelected ? .kundliPrimary : planetColor(for: planet))
        }
        .overlay(
            Circle()
                .stroke(
                    isSelected ? Color.kundliPrimary : Color.kundliPrimary.opacity(0.3),
                    lineWidth: isSelected ? 2 : 1
                )
        )
    }

    private func planetAngle(for planet: Planet, ascDegree: Double) -> Angle {
        // Calculate planet position relative to ascendant
        let planetDegree = totalLongitude(for: planet)
        let relativeAngle = planetDegree - ascDegree
        return Angle.degrees(-relativeAngle - 90)  // Negative because zodiac goes counter-clockwise
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

    private func zodiacColor(for index: Int) -> Color {
        // Fire signs (Aries, Leo, Sagittarius)
        if index == 0 || index == 4 || index == 8 {
            return .red.opacity(0.8)
        }
        // Earth signs (Taurus, Virgo, Capricorn)
        if index == 1 || index == 5 || index == 9 {
            return .green.opacity(0.8)
        }
        // Air signs (Gemini, Libra, Aquarius)
        if index == 2 || index == 6 || index == 10 {
            return .kundliInfo.opacity(0.8)
        }
        // Water signs (Cancer, Scorpio, Pisces)
        return .blue.opacity(0.8)
    }

    private func planetColor(for planet: Planet) -> Color {
        switch planet.name.lowercased() {
        case "sun": return .orange
        case "moon": return .white
        case "mars": return .red
        case "mercury": return .green
        case "jupiter": return .kundliPrimary
        case "venus": return .pink
        case "saturn": return .blue
        case "rahu": return .gray
        case "ketu": return .brown
        default: return .kundliTextPrimary
        }
    }
}

// MARK: - Divisional Western Chart

struct DivisionalWesternChart: View {
    let chartData: DivisionalChartData
    let size: CGFloat

    private let zodiacSymbols = ["♈", "♉", "♊", "♋", "♌", "♍", "♎", "♏", "♐", "♑", "♒", "♓"]

    var body: some View {
        ZStack {
            // Draw the chart using Canvas
            Canvas { context, canvasSize in
                let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
                let outerRadius = min(canvasSize.width, canvasSize.height) / 2 - 4
                let innerRadius = outerRadius * 0.7

                // Draw circles
                drawCircle(context: context, center: center, radius: outerRadius, lineWidth: 2)
                drawCircle(context: context, center: center, radius: innerRadius, lineWidth: 1.5)

                // Draw zodiac divisions
                for i in 0..<12 {
                    let angle = Angle.degrees(Double(i) * 30 - 90)
                    let startPoint = pointOnCircle(center: center, radius: innerRadius, angle: angle)
                    let endPoint = pointOnCircle(center: center, radius: outerRadius, angle: angle)

                    var path = Path()
                    path.move(to: startPoint)
                    path.addLine(to: endPoint)
                    context.stroke(path, with: .color(.kundliPrimary.opacity(0.5)), lineWidth: 1)
                }
            }
            .frame(width: size, height: size)

            // Overlay
            GeometryReader { geometry in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let outerRadius = min(geometry.size.width, geometry.size.height) / 2 - 4
                let innerRadius = outerRadius * 0.7
                let symbolRadius = (outerRadius + innerRadius) / 2
                let planetRadius = outerRadius * 0.35

                ZStack {
                    // Zodiac symbols
                    ForEach(0..<12, id: \.self) { index in
                        let angle = Angle.degrees(Double(index) * 30 + 15 - 90)
                        let position = pointOnCircle(center: center, radius: symbolRadius, angle: angle)

                        Text(zodiacSymbols[index])
                            .font(.system(size: 14))
                            .foregroundColor(.kundliTextSecondary)
                            .position(position)
                    }

                    // Planets
                    ForEach(chartData.planetPositions, id: \.planet) { position in
                        let longitude = Double(position.signIndex * 30) + position.degreeInSign
                        let planetAngle = Angle.degrees(-longitude - 90)
                        let pos = pointOnCircle(center: center, radius: planetRadius, angle: planetAngle)

                        Text(position.planet.symbol)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.kundliPrimary)
                            .padding(4)
                            .background(
                                Circle()
                                    .fill(Color.kundliCardBg)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.kundliPrimary.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .position(pos)
                    }
                }
            }
        }
        .frame(width: size, height: size)
    }

    private func drawCircle(context: GraphicsContext, center: CGPoint, radius: CGFloat, lineWidth: CGFloat) {
        var path = Path()
        path.addArc(center: center, radius: radius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
        context.stroke(path, with: .color(.kundliPrimary), lineWidth: lineWidth)
    }

    private func pointOnCircle(center: CGPoint, radius: CGFloat, angle: Angle) -> CGPoint {
        CGPoint(
            x: center.x + radius * cos(CGFloat(angle.radians)),
            y: center.y + radius * sin(CGFloat(angle.radians))
        )
    }
}

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        WesternCircularChart(
            kundli: MockDataService.shared.sampleKundli(),
            size: 300
        )
    }
}
