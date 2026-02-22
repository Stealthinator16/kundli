import SwiftUI

/// A floating popup that displays quick info about a selected planet
struct PlanetQuickInfoPopup: View {
    let planet: Planet
    let onDismiss: () -> Void
    let onViewDetails: () -> Void

    @State private var showPlanetSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with planet symbol and name
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(planetColor.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Text(planet.symbol)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(planetColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(planet.name)
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliTextPrimary)

                    Text(planet.vedName)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                }

                Spacer()

                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.kundliTextSecondary)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }
            }

            Divider()
                .background(Color.white.opacity(0.1))

            // Quick stats
            HStack(spacing: 16) {
                infoColumn(title: "Sign", value: planet.sign)
                infoColumn(title: "House", value: "\(planet.house)")
                infoColumn(title: "Degree", value: planet.degreeString)
            }

            // Status badge (if not neutral)
            if planet.status != .neutral {
                HStack {
                    Text("Status")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)

                    Spacer()

                    StatusBadge(status: planet.status)
                }
            }

            Divider()
                .background(Color.white.opacity(0.1))

            // Learn about planet button
            Button {
                showPlanetSheet = true
            } label: {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 12))
                    Text("Learn about \(planet.name)")
                        .font(.kundliCaption)
                }
                .foregroundColor(.kundliPrimary)
            }

            Divider()
                .background(Color.white.opacity(0.1))

            // View Details button
            Button {
                onViewDetails()
            } label: {
                HStack {
                    Text("View Details")
                        .font(.kundliSubheadline)

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(.system(size: 12))
                }
                .foregroundColor(.kundliPrimary)
                .padding(.vertical, 8)
            }
        }
        .padding(16)
        .frame(width: 260)
        .sheet(isPresented: $showPlanetSheet) {
            TermExplanationSheet(termId: "planet.\(planet.name.lowercased())")
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.kundliCardBg)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.kundliPrimary.opacity(0.3), lineWidth: 1)
        )
    }

    private func infoColumn(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.kundliCaption2)
                .foregroundColor(.kundliTextTertiary)

            Text(value)
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextPrimary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var planetColor: Color {
        .forPlanet(planet.name)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        PlanetQuickInfoPopup(
            planet: Planet(
                name: "Jupiter",
                vedName: "Guru",
                sign: "Sagittarius",
                vedSign: "Dhanu",
                nakshatra: "Moola",
                nakshatraPada: 2,
                degree: 12.5,
                minutes: 30,
                seconds: 15,
                house: 9,
                status: .ownSign,
                symbol: "Ju",
                lord: "Ketu"
            ),
            onDismiss: {},
            onViewDetails: {}
        )
    }
}
