import SwiftUI

struct TransitView: View {
    let transitData: TransitData

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Current Transits")
                            .font(.kundliTitle2)
                            .foregroundColor(.kundliTextPrimary)

                        Text("Planetary positions as of today")
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextSecondary)
                    }
                    .padding(.top, 16)

                    // Sade-Sati warning if active
                    if transitData.isSadeSatiActive, let phase = transitData.sadeSatiPhase {
                        SadeSatiWarningCard(phase: phase)
                    }

                    // Current positions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Current Positions")
                            .font(.kundliHeadline)
                            .foregroundColor(.kundliTextPrimary)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(transitData.transitPositions) { position in
                                TransitPositionCard(position: position)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Active transits
                    if !transitData.activeTransits.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Active Transits Over Natal Chart")
                                .font(.kundliHeadline)
                                .foregroundColor(.kundliTextPrimary)

                            ForEach(transitData.activeTransits) { transit in
                                ActiveTransitCard(transit: transit)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Major transit periods
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Major Transit Periods")
                            .font(.kundliHeadline)
                            .foregroundColor(.kundliTextPrimary)

                        ForEach(transitData.majorTransitPeriods) { period in
                            MajorTransitCard(period: period)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                        .frame(height: 20)
                }
                .padding(16)
            }
        }
        .navigationTitle("Transits")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// MARK: - Sade-Sati Warning Card
struct SadeSatiWarningCard: View {
    let phase: SadeSatiPhase

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.kundliWarning)

                    Text("Saturn Sade-Sati Active")
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliWarning)

                    Spacer()

                    Text(phase.rawValue)
                        .font(.kundliCaption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.kundliWarning)
                        )
                }

                Text(phase.description)
                    .font(.kundliBody)
                    .foregroundColor(.kundliTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    Text("Intensity:")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)

                    Text(phase.intensity)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliWarning)
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.kundliWarning.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

// MARK: - Transit Position Card
struct TransitPositionCard: View {
    let position: TransitPosition

    var body: some View {
        CardView(padding: 12) {
            VStack(spacing: 6) {
                // Planet symbol
                Text(position.planet.prefix(2).uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.kundliPrimary)

                // Sign
                Text(position.signName)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextPrimary)
                    .lineLimit(1)

                // Degree
                Text(position.formattedDegree)
                    .font(.system(size: 10))
                    .foregroundColor(.kundliTextSecondary)

                // Retrograde indicator
                if position.isRetrograde {
                    Text("R")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.kundliWarning)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.kundliWarning.opacity(0.2))
                        )
                }
            }
        }
    }
}

// MARK: - Active Transit Card
struct ActiveTransitCard: View {
    let transit: ActiveTransit

    var body: some View {
        CardView(padding: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // Transit description
                    VStack(alignment: .leading, spacing: 2) {
                        Text(transit.description)
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextPrimary)

                        HStack(spacing: 8) {
                            // Aspect nature badge
                            Text(transit.aspectType.nature.rawValue)
                                .font(.kundliCaption2)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(aspectColor)
                                )

                            // Strength
                            Text(transit.strength.rawValue)
                                .font(.kundliCaption2)
                                .foregroundColor(strengthColor)
                        }
                    }

                    Spacer()

                    // Applying/Separating indicator
                    VStack(alignment: .trailing, spacing: 2) {
                        Image(systemName: transit.isApplying ? "arrow.right" : "arrow.left")
                            .font(.system(size: 12))
                            .foregroundColor(.kundliTextSecondary)

                        Text(transit.isApplying ? "Applying" : "Separating")
                            .font(.kundliCaption2)
                            .foregroundColor(.kundliTextSecondary)
                    }
                }

                // Effects
                Text(transit.effects)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var aspectColor: Color {
        switch transit.aspectType.nature {
        case .harmonious: return .kundliSuccess
        case .challenging: return .kundliError
        case .neutral: return .kundliInfo
        case .adjusting: return .kundliWarning
        }
    }

    private var strengthColor: Color {
        switch transit.strength {
        case .strong: return .kundliError
        case .moderate: return .kundliWarning
        case .weak: return .kundliTextSecondary
        }
    }
}

// MARK: - Major Transit Card
struct MajorTransitCard: View {
    let period: MajorTransitPeriod

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(period.type.rawValue)
                            .font(.kundliHeadline)
                            .foregroundColor(.kundliTextPrimary)

                        Text("\(period.planet) in \(period.signName)")
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliPrimary)
                    }

                    Spacer()

                    if period.isCurrentlyActive {
                        Text("Active")
                            .font(.kundliCaption2)
                            .foregroundColor(.kundliBackground)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.kundliPrimary)
                            )
                    }
                }

                // Duration
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(.kundliTextSecondary)

                    Text(period.durationString)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                }

                // Remaining time
                if let remaining = period.remainingDuration {
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(.kundliPrimary)

                        Text(remaining)
                            .font(.kundliCaption)
                            .foregroundColor(.kundliPrimary)
                    }
                }

                // Effects
                Text(period.effects)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                // Sade-Sati phase if applicable
                if let phase = period.sadeSatiPhase {
                    HStack {
                        Text("Phase:")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)

                        Text(phase.rawValue)
                            .font(.kundliCaption)
                            .foregroundColor(.kundliWarning)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TransitView(transitData: TransitData(
            calculationDate: Date(),
            transitPositions: [
                TransitPosition(
                    planet: "Saturn",
                    vedName: "Shani",
                    longitude: 340.5,
                    signIndex: 11,
                    signName: "Pisces",
                    degreeInSign: 10.5,
                    nakshatra: "Uttara Bhadrapada",
                    nakshatraPada: 3,
                    isRetrograde: false
                ),
                TransitPosition(
                    planet: "Jupiter",
                    vedName: "Guru",
                    longitude: 45.2,
                    signIndex: 1,
                    signName: "Taurus",
                    degreeInSign: 15.2,
                    nakshatra: "Rohini",
                    nakshatraPada: 2,
                    isRetrograde: true
                )
            ],
            activeTransits: [],
            majorTransitPeriods: [
                MajorTransitPeriod(
                    type: .jupiterTransit,
                    planet: "Jupiter",
                    startDate: Date().addingTimeInterval(-86400 * 180),
                    endDate: Date().addingTimeInterval(86400 * 180),
                    signName: "Taurus",
                    effects: "Jupiter brings expansion and growth opportunities."
                )
            ]
        ))
    }
}
