import SwiftUI

struct DashaPeriodsView: View {
    let dashaPeriods: [DashaPeriod]

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header info
                    VStack(spacing: 8) {
                        Text("Vimshottari Dasha")
                            .font(.kundliTitle2)
                            .foregroundColor(.kundliTextPrimary)

                        Text("120-year planetary period cycle")
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextSecondary)
                    }
                    .padding(.top, 16)

                    // Current period summary
                    if let activeDasha = dashaPeriods.first(where: { $0.isActive }) {
                        CurrentDashaSummaryCard(
                            mahadasha: activeDasha,
                            antardasha: activeDasha.subPeriods.first(where: { $0.isActive }),
                            pratyantardasha: activeDasha.subPeriods.first(where: { $0.isActive })?.activePratyantarDasha
                        )
                    }

                    // Timeline
                    VStack(spacing: 0) {
                        ForEach(dashaPeriods) { period in
                            DashaTimelineItem(period: period)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                        .frame(height: 20)
                }
            }
        }
        .navigationTitle("Dasha Periods")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// MARK: - Current Dasha Summary Card
struct CurrentDashaSummaryCard: View {
    let mahadasha: DashaPeriod
    let antardasha: AntarDasha?
    let pratyantardasha: PratyantarDasha?

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Current Running Period")
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliTextPrimary)

                    Spacer()

                    Image(systemName: "clock.fill")
                        .foregroundColor(.kundliPrimary)
                }

                // Mahadasha
                periodRow(
                    level: "Mahadasha",
                    planet: mahadasha.planet,
                    vedName: mahadasha.vedName,
                    duration: mahadasha.yearsRemaining.isEmpty ? mahadasha.duration : mahadasha.yearsRemaining,
                    isHighlighted: true
                )

                if let antardasha = antardasha {
                    Divider()
                        .background(Color.white.opacity(0.1))

                    // Antardasha
                    periodRow(
                        level: "Antardasha",
                        planet: antardasha.planet,
                        vedName: antardasha.vedName,
                        duration: antardasha.duration,
                        isHighlighted: false
                    )
                }

                if let pratyantardasha = pratyantardasha {
                    Divider()
                        .background(Color.white.opacity(0.1))

                    // Pratyantardasha
                    periodRow(
                        level: "Pratyantardasha",
                        planet: pratyantardasha.planet,
                        vedName: pratyantardasha.vedName,
                        duration: pratyantardasha.shortDuration,
                        isHighlighted: false
                    )
                }
            }
        }
        .padding(.horizontal)
    }

    private func periodRow(level: String, planet: String, vedName: String, duration: String, isHighlighted: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(level)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)

                HStack(spacing: 6) {
                    Text(planet)
                        .font(isHighlighted ? .kundliTitle3 : .kundliSubheadline)
                        .foregroundColor(isHighlighted ? .kundliPrimary : .kundliTextPrimary)

                    Text("(\(vedName))")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                }
            }

            Spacer()

            Text(duration)
                .font(.kundliCaption)
                .foregroundColor(isHighlighted ? .kundliPrimary : .kundliTextSecondary)
        }
    }
}

// MARK: - Dasha Timeline Item
struct DashaTimelineItem: View {
    let period: DashaPeriod
    @State private var isExpanded = false
    @State private var expandedAntarDashaId: UUID?

    var body: some View {
        VStack(spacing: 0) {
            // Timeline connector
            HStack(spacing: 12) {
                // Timeline dot and line
                VStack(spacing: 0) {
                    Circle()
                        .fill(period.isActive ? Color.kundliPrimary : Color.kundliTextSecondary)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .fill(period.isActive ? Color.kundliPrimary : Color.clear)
                                .frame(width: 8, height: 8)
                        )

                    Rectangle()
                        .fill(Color.kundliTextSecondary.opacity(0.3))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
                .frame(width: 16)

                // Content
                VStack(spacing: 0) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.toggle()
                            if !isExpanded {
                                expandedAntarDashaId = nil
                            }
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Text(period.planet)
                                        .font(.kundliHeadline)
                                        .foregroundColor(period.isActive ? .kundliPrimary : .kundliTextPrimary)

                                    Text("(\(period.vedName))")
                                        .font(.kundliCaption)
                                        .foregroundColor(.kundliTextSecondary)

                                    if period.isActive {
                                        Text("Active")
                                            .font(.kundliCaption2)
                                            .foregroundColor(.kundliBackground)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(
                                                Capsule()
                                                    .fill(Color.kundliPrimary)
                                            )
                                    }
                                }

                                Text(period.duration)
                                    .font(.kundliCaption)
                                    .foregroundColor(.kundliTextSecondary)
                            }

                            Spacer()

                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12))
                                .foregroundColor(.kundliTextSecondary)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(period.isActive ? Color.kundliPrimary.opacity(0.1) : Color.kundliCardBg)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(period.isActive ? Color.kundliPrimary.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)

                    // Expanded sub-periods (Antar Dasha)
                    if isExpanded && !period.subPeriods.isEmpty {
                        VStack(spacing: 4) {
                            ForEach(period.subPeriods) { antarDasha in
                                AntarDashaRow(
                                    antarDasha: antarDasha,
                                    isExpanded: expandedAntarDashaId == antarDasha.id,
                                    onTap: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            if expandedAntarDashaId == antarDasha.id {
                                                expandedAntarDashaId = nil
                                            } else {
                                                expandedAntarDashaId = antarDasha.id
                                            }
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.top, 8)
                        .padding(.leading, 16)
                    }

                    Spacer()
                        .frame(height: 12)
                }
            }
        }
    }
}

// MARK: - Antar Dasha Row with Pratyantar expansion
struct AntarDashaRow: View {
    let antarDasha: AntarDasha
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Antar Dasha button
            Button(action: onTap) {
                HStack {
                    Circle()
                        .fill(antarDasha.isActive ? Color.kundliPrimary : Color.kundliTextSecondary.opacity(0.5))
                        .frame(width: 8, height: 8)

                    Text("\(antarDasha.planet) (\(antarDasha.vedName))")
                        .font(.kundliCaption)
                        .foregroundColor(antarDasha.isActive ? .kundliPrimary : .kundliTextPrimary)

                    Spacer()

                    Text(antarDasha.duration)
                        .font(.kundliCaption2)
                        .foregroundColor(.kundliTextSecondary)

                    if antarDasha.isActive {
                        Text("Now")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.kundliPrimary)
                    }

                    if !antarDasha.pratyantarDashas.isEmpty {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 10))
                            .foregroundColor(.kundliTextSecondary)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(antarDasha.isActive ? Color.kundliPrimary.opacity(0.08) : Color.clear)
                )
            }
            .buttonStyle(.plain)

            // Pratyantar Dasha expansion
            if isExpanded && !antarDasha.pratyantarDashas.isEmpty {
                VStack(spacing: 2) {
                    ForEach(antarDasha.pratyantarDashas) { pratyantarDasha in
                        PratyantarDashaRow(pratyantarDasha: pratyantarDasha)
                    }
                }
                .padding(.leading, 24)
                .padding(.top, 4)
            }
        }
    }
}

// MARK: - Pratyantar Dasha Row
struct PratyantarDashaRow: View {
    let pratyantarDasha: PratyantarDasha

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(pratyantarDasha.isActive ? Color.kundliPrimary : Color.kundliTextSecondary.opacity(0.3))
                .frame(width: 4, height: 4)

            Text("\(pratyantarDasha.planet)")
                .font(.system(size: 11))
                .foregroundColor(pratyantarDasha.isActive ? .kundliPrimary : .kundliTextSecondary)

            Spacer()

            Text(pratyantarDasha.shortDuration)
                .font(.system(size: 10))
                .foregroundColor(.kundliTextSecondary.opacity(0.8))

            if pratyantarDasha.isActive {
                Circle()
                    .fill(Color.kundliPrimary)
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(pratyantarDasha.isActive ? Color.kundliPrimary.opacity(0.05) : Color.clear)
        )
    }
}

#Preview {
    NavigationStack {
        DashaPeriodsView(dashaPeriods: MockDataService.shared.sampleDashaPeriods())
    }
}
