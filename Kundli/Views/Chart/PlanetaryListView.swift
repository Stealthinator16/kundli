import SwiftUI

struct PlanetaryListView: View {
    let planets: [Planet]
    var onPlanetTap: ((Planet) -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            ForEach(planets) { planet in
                PlanetRow(planet: planet) {
                    onPlanetTap?(planet)
                }

                if planet.id != planets.last?.id {
                    Divider()
                        .background(Color.white.opacity(0.1))
                        .padding(.leading, 60)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.kundliCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct PlanetRow: View {
    let planet: Planet
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 12) {
                // Planet symbol circle
                ZStack {
                    Circle()
                        .fill(planetColor.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Text(planet.symbol)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(planetColor)
                }

                // Planet info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(planet.name)
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextPrimary)

                        Text("(\(planet.vedName))")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)
                    }

                    Text("\(planet.sign) \(planet.degreeString)")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                }

                Spacer()

                // Status badge
                if planet.status != .neutral {
                    StatusBadge(status: planet.status)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.kundliTextSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
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

// Compact planet list for chart view
struct CompactPlanetList: View {
    let planets: [Planet]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Planetary Positions")
                .font(.kundliHeadline)
                .foregroundColor(.kundliTextPrimary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(planets) { planet in
                    compactPlanetItem(planet)
                }
            }
        }
    }

    private func compactPlanetItem(_ planet: Planet) -> some View {
        HStack(spacing: 8) {
            Text(planet.symbol)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.kundliPrimary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(planet.sign)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextPrimary)

                Text(planet.degreeString)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.kundliTextSecondary)
            }

            Spacer()

            if planet.status == .retrograde {
                Text("R")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.kundliWarning)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.05))
        )
    }
}

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        ScrollView {
            VStack(spacing: 20) {
                PlanetaryListView(planets: MockDataService.shared.samplePlanets())

                CompactPlanetList(planets: MockDataService.shared.samplePlanets())
                    .padding()
            }
            .padding()
        }
    }
}
