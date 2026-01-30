import SwiftUI

/// A tappable planet symbol that provides visual feedback and triggers selection
struct TappablePlanetSymbol: View {
    let planet: Planet
    let onTap: (Planet, CGPoint) -> Void
    let isSelected: Bool

    @State private var isPressed = false

    init(planet: Planet, isSelected: Bool = false, onTap: @escaping (Planet, CGPoint) -> Void) {
        self.planet = planet
        self.isSelected = isSelected
        self.onTap = onTap
    }

    var body: some View {
        GeometryReader { geometry in
            Text(planet.symbol)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(symbolColor)
                .scaleEffect(isPressed ? 1.3 : (isSelected ? 1.2 : 1.0))
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
                .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isSelected)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    let center = CGPoint(
                        x: geometry.frame(in: .global).midX,
                        y: geometry.frame(in: .global).midY
                    )
                    onTap(planet, center)
                }
                .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                    isPressed = pressing
                }, perform: {})
        }
        .frame(width: 24, height: 20)
    }

    private var symbolColor: Color {
        if isSelected {
            return planetColor.opacity(1.0)
        }
        return planetColor
    }

    private var planetColor: Color {
        switch planet.name.lowercased() {
        case "sun": return .orange
        case "moon": return .white
        case "mars": return .red
        case "mercury": return .green
        case "jupiter": return .yellow
        case "venus": return .pink
        case "saturn": return .blue
        case "rahu": return .purple
        case "ketu": return .brown
        default: return .kundliPrimary
        }
    }
}

/// A container for multiple tappable planet symbols in a house
struct TappablePlanetRow: View {
    let planets: [Planet]
    let selectedPlanet: Planet?
    let onPlanetTap: (Planet, CGPoint) -> Void

    var body: some View {
        HStack(spacing: 2) {
            ForEach(planets) { planet in
                TappablePlanetSymbol(
                    planet: planet,
                    isSelected: selectedPlanet?.id == planet.id,
                    onTap: onPlanetTap
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        VStack(spacing: 20) {
            // Single planet
            TappablePlanetSymbol(
                planet: Planet(
                    name: "Sun",
                    vedName: "Surya",
                    sign: "Aries",
                    vedSign: "Mesha",
                    nakshatra: "Ashwini",
                    nakshatraPada: 1,
                    degree: 15.5,
                    minutes: 30,
                    seconds: 45,
                    house: 1,
                    status: .exalted,
                    symbol: "Su",
                    lord: "Ketu"
                ),
                isSelected: false,
                onTap: { planet, position in
                    print("Tapped \(planet.name) at \(position)")
                }
            )
            .background(Color.white.opacity(0.1))

            // Row of planets
            TappablePlanetRow(
                planets: [
                    Planet(name: "Sun", vedName: "Surya", sign: "Aries", vedSign: "Mesha", nakshatra: "Ashwini", nakshatraPada: 1, degree: 15, minutes: 30, seconds: 0, house: 1, status: .exalted, symbol: "Su", lord: "Ketu"),
                    Planet(name: "Moon", vedName: "Chandra", sign: "Aries", vedSign: "Mesha", nakshatra: "Bharani", nakshatraPada: 2, degree: 20, minutes: 15, seconds: 0, house: 1, status: .direct, symbol: "Mo", lord: "Venus"),
                    Planet(name: "Mars", vedName: "Mangal", sign: "Aries", vedSign: "Mesha", nakshatra: "Krittika", nakshatraPada: 1, degree: 27, minutes: 45, seconds: 0, house: 1, status: .ownSign, symbol: "Ma", lord: "Sun")
                ],
                selectedPlanet: nil,
                onPlanetTap: { planet, position in
                    print("Tapped \(planet.name)")
                }
            )
            .background(Color.white.opacity(0.1))
        }
    }
}
