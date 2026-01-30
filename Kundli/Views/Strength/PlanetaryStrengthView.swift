import SwiftUI

struct PlanetaryStrengthView: View {
    let strengths: [PlanetaryStrength]
    @State private var selectedPlanet: PlanetaryStrength?
    @State private var showDetails = false

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Shadbala")
                            .font(.kundliTitle2)
                            .foregroundColor(.kundliTextPrimary)

                        Text("Six-fold planetary strength analysis")
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextSecondary)
                    }
                    .padding(.top, 16)

                    // Summary card
                    strengthSummaryCard

                    // Strength bars for each planet
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Planetary Strengths")
                            .font(.kundliHeadline)
                            .foregroundColor(.kundliTextPrimary)

                        ForEach(strengths.sorted(by: { $0.strengthRatio > $1.strengthRatio })) { strength in
                            PlanetStrengthBar(
                                strength: strength,
                                onTap: {
                                    selectedPlanet = strength
                                    showDetails = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                        .frame(height: 20)
                }
                .padding(16)
            }
        }
        .navigationTitle("Shadbala")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $showDetails) {
            if let planet = selectedPlanet {
                ShadbalaDetailSheet(strength: planet)
            }
        }
    }

    private var strengthSummaryCard: some View {
        CardView {
            VStack(spacing: 16) {
                HStack(spacing: 20) {
                    // Strongest planet
                    if let strongest = strengths.max(by: { $0.strengthRatio < $1.strengthRatio }) {
                        VStack(spacing: 4) {
                            Text(strongest.planet)
                                .font(.kundliHeadline)
                                .foregroundColor(.kundliSuccess)

                            Text("Strongest")
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    Divider()
                        .frame(height: 40)
                        .background(Color.white.opacity(0.1))

                    // Weakest planet
                    if let weakest = strengths.min(by: { $0.strengthRatio < $1.strengthRatio }) {
                        VStack(spacing: 4) {
                            Text(weakest.planet)
                                .font(.kundliHeadline)
                                .foregroundColor(.kundliWarning)

                            Text("Needs Attention")
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }

                // Average strength
                let avgRatio = strengths.reduce(0) { $0 + $1.strengthRatio } / Double(max(strengths.count, 1))
                HStack {
                    Text("Average Strength Ratio")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)

                    Spacer()

                    Text(String(format: "%.2f", avgRatio))
                        .font(.kundliHeadline)
                        .foregroundColor(avgRatio >= 1.0 ? .kundliSuccess : .kundliWarning)
                }
            }
        }
    }
}

// MARK: - Planet Strength Bar
struct PlanetStrengthBar: View {
    let strength: PlanetaryStrength
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(strength.planet)
                                .font(.kundliHeadline)
                                .foregroundColor(.kundliTextPrimary)

                            Text(strength.vedName)
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)
                        }

                        Spacer()

                        // Strength badge
                        Text(strength.strengthLevel.rawValue)
                            .font(.kundliCaption2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(strengthColor)
                            )
                    }

                    // Strength bar
                    VStack(alignment: .leading, spacing: 4) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 8)

                                // Filled portion
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(strengthColor)
                                    .frame(width: min(geometry.size.width * (strength.percentageStrength / 100), geometry.size.width), height: 8)

                                // Required strength marker
                                let requiredPosition = (strength.requiredStrength / 360) * geometry.size.width
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: 2, height: 12)
                                    .offset(x: requiredPosition)
                            }
                        }
                        .frame(height: 12)

                        HStack {
                            Text("\(Int(strength.totalShadbala)) Virupas")
                                .font(.kundliCaption2)
                                .foregroundColor(.kundliTextSecondary)

                            Spacer()

                            Text("Ratio: \(String(format: "%.2f", strength.strengthRatio))")
                                .font(.kundliCaption2)
                                .foregroundColor(strength.strengthRatio >= 1 ? .kundliSuccess : .kundliWarning)
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var strengthColor: Color {
        switch strength.strengthLevel {
        case .veryStrong: return .kundliSuccess
        case .strong: return .kundliInfo
        case .moderate: return .kundliWarning
        case .weak, .veryWeak: return .kundliError
        }
    }
}

// MARK: - Shadbala Detail Sheet
struct ShadbalaDetailSheet: View {
    let strength: PlanetaryStrength
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.kundliBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Planet header
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.kundliPrimary.opacity(0.2))
                                    .frame(width: 80, height: 80)

                                Text(strength.planet.prefix(2).uppercased())
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.kundliPrimary)
                            }

                            Text(strength.planet)
                                .font(.kundliTitle2)
                                .foregroundColor(.kundliTextPrimary)

                            Text(strength.vedName)
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliTextSecondary)

                            Text(strength.strengthLevel.rawValue)
                                .font(.kundliCaption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(strengthLevelColor)
                                )
                        }
                        .padding(.top, 20)

                        // Total strength
                        CardView {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Total Shadbala")
                                        .font(.kundliHeadline)
                                        .foregroundColor(.kundliTextPrimary)

                                    Spacer()

                                    Text("\(Int(strength.totalShadbala)) Virupas")
                                        .font(.kundliTitle3)
                                        .foregroundColor(.kundliPrimary)
                                }

                                HStack {
                                    Text("Required Strength")
                                        .font(.kundliCaption)
                                        .foregroundColor(.kundliTextSecondary)

                                    Spacer()

                                    Text("\(Int(strength.requiredStrength)) Virupas")
                                        .font(.kundliSubheadline)
                                        .foregroundColor(.kundliTextSecondary)
                                }

                                HStack {
                                    Text("Strength Ratio")
                                        .font(.kundliCaption)
                                        .foregroundColor(.kundliTextSecondary)

                                    Spacer()

                                    Text(String(format: "%.2f", strength.strengthRatio))
                                        .font(.kundliHeadline)
                                        .foregroundColor(strength.strengthRatio >= 1 ? .kundliSuccess : .kundliWarning)
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Components breakdown
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Shadbala Components")
                                .font(.kundliHeadline)
                                .foregroundColor(.kundliTextPrimary)
                                .padding(.horizontal)

                            ForEach(strength.components, id: \.name) { component in
                                ComponentBar(
                                    name: component.name,
                                    value: component.value,
                                    maxValue: component.maxValue
                                )
                            }
                        }

                        // Strength level description
                        CardView {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Interpretation")
                                    .font(.kundliHeadline)
                                    .foregroundColor(.kundliTextPrimary)

                                Text(strength.strengthLevel.description)
                                    .font(.kundliBody)
                                    .foregroundColor(.kundliTextSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(.horizontal)

                        Spacer()
                            .frame(height: 20)
                    }
                }
            }
            .navigationTitle("Shadbala Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.kundliPrimary)
                }
            }
            .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private var strengthLevelColor: Color {
        switch strength.strengthLevel {
        case .veryStrong: return .kundliSuccess
        case .strong: return .kundliInfo
        case .moderate: return .kundliWarning
        case .weak, .veryWeak: return .kundliError
        }
    }
}

// MARK: - Component Bar
struct ComponentBar: View {
    let name: String
    let value: Double
    let maxValue: Double

    var body: some View {
        CardView(padding: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(name)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextPrimary)

                    Spacer()

                    Text("\(Int(value))/\(Int(maxValue))")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(barColor)
                            .frame(width: geometry.size.width * (value / maxValue), height: 6)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(.horizontal)
    }

    private var barColor: Color {
        let ratio = value / maxValue
        if ratio >= 0.7 { return .kundliSuccess }
        if ratio >= 0.4 { return .kundliWarning }
        return .kundliError
    }
}

#Preview {
    NavigationStack {
        PlanetaryStrengthView(strengths: [
            PlanetaryStrength(
                planet: "Sun",
                vedName: "Surya",
                sthanaBala: 45,
                dikBala: 50,
                kalaBala: 35,
                chestaBala: 30,
                naisargikaBala: 60,
                drigBala: 40,
                requiredStrength: 390
            ),
            PlanetaryStrength(
                planet: "Moon",
                vedName: "Chandra",
                sthanaBala: 35,
                dikBala: 40,
                kalaBala: 45,
                chestaBala: 30,
                naisargikaBala: 51.43,
                drigBala: 35,
                requiredStrength: 360
            )
        ])
    }
}
