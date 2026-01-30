import SwiftUI

struct PlanetaryDetailsView: View {
    @Bindable var viewModel: KundliViewModel

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            if let kundli = viewModel.kundli {
                ScrollView {
                    VStack(spacing: 24) {
                        // Birth info summary
                        birthSummaryCard(kundli: kundli)

                        // Ascendant section
                        ascendantSection(kundli: kundli)

                        // All planets detailed list
                        planetsSection(kundli: kundli)

                        // Dasha period section (if available)
                        if let activeDasha = viewModel.activeDasha {
                            dashaSection(activeDasha: activeDasha)
                        }

                        // Yogas section
                        if !viewModel.yogas.isEmpty {
                            yogasSection
                        }

                        // Doshas section
                        if !viewModel.doshas.isEmpty {
                            doshasSection
                        }

                        // Navigation to detailed views
                        additionalAnalysisSection

                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("Full Report")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func birthSummaryCard(kundli: Kundli) -> some View {
        CardView {
            VStack(spacing: 16) {
                HStack {
                    Text("Birth Details")
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliTextPrimary)

                    Spacer()
                }

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    summaryItem("Name", kundli.birthDetails.name)
                    summaryItem("Gender", kundli.birthDetails.gender.rawValue)
                    summaryItem("Date", kundli.birthDetails.formattedDate)
                    summaryItem("Time", kundli.birthDetails.formattedTime)
                    summaryItem("Place", kundli.birthDetails.birthCity, fullWidth: true)
                }
            }
        }
    }

    private func summaryItem(_ title: String, _ value: String, fullWidth: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)

            Text(value)
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextPrimary)
                .lineLimit(fullWidth ? 2 : 1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func ascendantSection(kundli: Kundli) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ascendant (Lagna)")
                .font(.kundliHeadline)
                .foregroundColor(.kundliTextPrimary)

            CardView {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(kundli.ascendant.sign.rawValue)
                                .font(.kundliTitle2)
                                .foregroundColor(.kundliTextPrimary)

                            Text(kundli.ascendant.sign.vedName)
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliTextSecondary)
                        }

                        Spacer()

                        Text(kundli.ascendant.sign.symbol)
                            .font(.system(size: 40))
                    }

                    Divider()
                        .background(Color.white.opacity(0.1))

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        detailItem("Degree", kundli.ascendant.degreeString)
                        detailItem("Nakshatra", kundli.ascendant.nakshatra)
                        detailItem("Pada", "\(kundli.ascendant.nakshatraPada)")
                        detailItem("Lord", kundli.ascendant.lord)
                    }
                }
            }
        }
    }

    private func planetsSection(kundli: Kundli) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Planetary Positions")
                .font(.kundliHeadline)
                .foregroundColor(.kundliTextPrimary)

            ForEach(kundli.planets) { planet in
                planetDetailCard(planet: planet)
            }
        }
    }

    private func planetDetailCard(planet: Planet) -> some View {
        CardView {
            VStack(spacing: 12) {
                // Header
                HStack {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.kundliPrimary.opacity(0.2))
                                .frame(width: 44, height: 44)

                            Text(planet.symbol)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.kundliPrimary)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(planet.name)
                                .font(.kundliHeadline)
                                .foregroundColor(.kundliTextPrimary)

                            Text(planet.vedName)
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)
                        }
                    }

                    Spacer()

                    if planet.status != .neutral {
                        StatusBadge(status: planet.status)
                    }
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                // Details grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    detailItem("Sign", "\(planet.sign) (\(planet.vedSign))")
                    detailItem("House", "\(planet.house)")
                    detailItem("Degree", planet.degreeString)
                    detailItem("Nakshatra", planet.nakshatra)
                    detailItem("Pada", "\(planet.nakshatraPada)")
                    detailItem("Nakshatra Lord", planet.lord)
                }
            }
        }
    }

    private func dashaSection(activeDasha: DashaPeriod) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Dasha Period")
                .font(.kundliHeadline)
                .foregroundColor(.kundliTextPrimary)

            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Mahadasha")
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)

                            Text("\(activeDasha.planet) (\(activeDasha.vedName))")
                                .font(.kundliTitle3)
                                .foregroundColor(.kundliTextPrimary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Period")
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)

                            Text(activeDasha.duration)
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliTextPrimary)
                        }
                    }

                    if !activeDasha.yearsRemaining.isEmpty {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.kundliPrimary)
                            Text(activeDasha.yearsRemaining)
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliPrimary)
                        }
                    }

                    // Antar Dasha
                    if let antarDasha = viewModel.activeAntarDasha {
                        Divider()
                            .background(Color.white.opacity(0.1))

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Antardasha")
                                    .font(.kundliCaption)
                                    .foregroundColor(.kundliTextSecondary)

                                Text("\(antarDasha.planet) (\(antarDasha.vedName))")
                                    .font(.kundliSubheadline)
                                    .foregroundColor(.kundliTextPrimary)
                            }

                            Spacer()

                            Text(antarDasha.duration)
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)
                        }
                    }
                }
            }
        }
    }

    private func detailItem(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)

            Text(value)
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextPrimary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Yogas Section
    private var yogasSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Yogas")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                Spacer()

                NavigationLink {
                    YogaDetailView(yogas: viewModel.yogas)
                } label: {
                    Text("View All")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliPrimary)
                }
            }

            // Show top 3 yogas
            ForEach(viewModel.yogas.prefix(3)) { yoga in
                yogaMiniCard(yoga: yoga)
            }
        }
    }

    private func yogaMiniCard(yoga: Yoga) -> some View {
        CardView(padding: 12) {
            HStack {
                Circle()
                    .fill(yoga.nature == .benefic ? Color.kundliSuccess : (yoga.nature == .malefic ? Color.kundliError : Color.kundliWarning))
                    .frame(width: 10, height: 10)

                VStack(alignment: .leading, spacing: 2) {
                    Text(yoga.name)
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextPrimary)

                    Text(yoga.sanskritName)
                        .font(.kundliCaption2)
                        .foregroundColor(.kundliTextSecondary)
                }

                Spacer()

                Text(yoga.strength.rawValue)
                    .font(.kundliCaption2)
                    .foregroundColor(.kundliTextSecondary)
            }
        }
    }

    // MARK: - Doshas Section
    private var doshasSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Doshas")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                if viewModel.activeDoshas.count > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                        Text("\(viewModel.activeDoshas.count)")
                    }
                    .font(.kundliCaption)
                    .foregroundColor(.kundliWarning)
                }

                Spacer()

                NavigationLink {
                    DoshaDetailView(doshas: viewModel.doshas)
                } label: {
                    Text("View All")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliPrimary)
                }
            }

            // Show active doshas
            ForEach(viewModel.doshas.prefix(2)) { dosha in
                doshaMiniCard(dosha: dosha)
            }
        }
    }

    private func doshaMiniCard(dosha: Dosha) -> some View {
        CardView(padding: 12) {
            HStack {
                Image(systemName: dosha.isCancelled ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(dosha.isCancelled ? .kundliSuccess : severityColor(dosha.severity))

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(dosha.name)
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextPrimary)

                        if dosha.isCancelled {
                            Text("Cancelled")
                                .font(.system(size: 9))
                                .foregroundColor(.kundliSuccess)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.kundliSuccess.opacity(0.2)))
                        }
                    }

                    Text(dosha.sanskritName)
                        .font(.kundliCaption2)
                        .foregroundColor(.kundliTextSecondary)
                }

                Spacer()

                if !dosha.isCancelled {
                    Text(dosha.severity.rawValue)
                        .font(.kundliCaption2)
                        .foregroundColor(severityColor(dosha.severity))
                }
            }
        }
    }

    private func severityColor(_ severity: DoshaSeverity) -> Color {
        switch severity {
        case .high: return .kundliError
        case .medium: return .kundliWarning
        case .low: return .kundliInfo
        case .cancelled: return .kundliSuccess
        }
    }

    // MARK: - Additional Analysis Section
    private var additionalAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Detailed Analysis")
                .font(.kundliHeadline)
                .foregroundColor(.kundliTextPrimary)

            // Divisional Charts
            NavigationLink {
                DivisionalChartsDetailView(charts: viewModel.divisionalCharts)
            } label: {
                analysisNavigationCard(
                    icon: "square.grid.3x3",
                    title: "Divisional Charts",
                    subtitle: "D9 Navamsa, D10 Dasamsa & more"
                )
            }
            .buttonStyle(.plain)

            // Dasha Periods
            NavigationLink {
                DashaPeriodsView(dashaPeriods: viewModel.dashaPeriods)
            } label: {
                analysisNavigationCard(
                    icon: "clock.arrow.circlepath",
                    title: "Dasha Periods",
                    subtitle: "Vimshottari Dasha timeline"
                )
            }
            .buttonStyle(.plain)

            // Planetary Strength (if available)
            if !viewModel.planetaryStrengths.isEmpty {
                NavigationLink {
                    PlanetaryStrengthView(strengths: viewModel.planetaryStrengths)
                } label: {
                    analysisNavigationCard(
                        icon: "chart.bar.fill",
                        title: "Planetary Strength",
                        subtitle: "Shadbala analysis"
                    )
                }
                .buttonStyle(.plain)
            }

            // Ashtakavarga (if available)
            if let ashtakavarga = viewModel.ashtakavargaData {
                NavigationLink {
                    AshtakavargaView(ashtakavargaData: ashtakavarga)
                } label: {
                    analysisNavigationCard(
                        icon: "tablecells",
                        title: "Ashtakavarga",
                        subtitle: "Eight-fold strength analysis"
                    )
                }
                .buttonStyle(.plain)
            }

            // Transits (if available)
            if let transits = viewModel.transitData {
                NavigationLink {
                    TransitView(transitData: transits)
                } label: {
                    analysisNavigationCard(
                        icon: "arrow.triangle.2.circlepath",
                        title: "Current Transits",
                        subtitle: "Planetary movements today"
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func analysisNavigationCard(icon: String, title: String, subtitle: String) -> some View {
        CardView(padding: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.kundliPrimary)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextPrimary)

                    Text(subtitle)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.kundliTextSecondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PlanetaryDetailsView(viewModel: {
            let vm = KundliViewModel()
            vm.loadSampleKundli()
            return vm
        }())
    }
}
