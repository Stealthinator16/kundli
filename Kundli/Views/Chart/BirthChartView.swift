import SwiftUI
import SwiftData

struct BirthChartView: View {
    @Bindable var viewModel: KundliViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var selectedChartStyle: ChartStyle = .northIndian
    @State private var showPlanetDetails = false
    @State private var selectedPlanet: Planet?
    @State private var showSaveAlert = false
    @State private var isSaved = false
    @State private var showDivisionalCharts = false

    // Interactive chart state
    @State private var chartInteractionState = ChartInteractionState()

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            if let kundli = viewModel.kundli {
                ScrollView {
                    VStack(spacing: 24) {
                        // Birth info header
                        birthInfoCard(kundli: kundli)

                        // Chart type toggle (Birth Chart vs Divisional)
                        chartTypeToggle

                        // Chart style picker
                        chartStylePicker

                        // Chart display
                        if showDivisionalCharts {
                            divisionalChartSection(kundli: kundli)
                        } else {
                            chartSection(kundli: kundli)
                        }

                        // Ascendant info
                        ascendantCard(kundli: kundli)

                        // Planet list
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Planetary Positions")
                                .font(.kundliHeadline)
                                .foregroundColor(.kundliTextPrimary)

                            PlanetaryListView(planets: kundli.planets) { planet in
                                selectedPlanet = planet
                                showPlanetDetails = true
                            }
                        }

                        // View Full Report button
                        NavigationLink {
                            PlanetaryDetailsView(viewModel: viewModel)
                        } label: {
                            HStack {
                                Text("View Full Report")
                                    .font(.kundliHeadline)
                                Image(systemName: "arrow.right")
                            }
                            .foregroundColor(.kundliPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.kundliPrimary, lineWidth: 1.5)
                            )
                        }

                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(16)
                }
            } else {
                // Loading or empty state
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .kundliPrimary))

                    Text("Loading chart...")
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextSecondary)
                }
            }
        }
        .navigationTitle("Birth Chart")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    saveKundli()
                } label: {
                    Image(systemName: isSaved ? "checkmark.circle.fill" : "square.and.arrow.down")
                        .foregroundColor(.kundliPrimary)
                }
                .disabled(isSaved)
            }
        }
        .sheet(isPresented: $showPlanetDetails) {
            if let planet = selectedPlanet {
                PlanetDetailSheet(planet: planet)
            }
        }
        .alert("Kundli Saved", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This kundli has been saved to your collection.")
        }
    }

    private func saveKundli() {
        guard let savedKundli = viewModel.createSavedKundli() else { return }
        modelContext.insert(savedKundli)
        isSaved = true
        showSaveAlert = true
    }

    private func birthInfoCard(kundli: Kundli) -> some View {
        CardView {
            HStack(spacing: 16) {
                // Avatar
                Circle()
                    .fill(Color.kundliPrimary.opacity(0.2))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Text(String(kundli.birthDetails.name.prefix(2)).uppercased())
                            .font(.kundliHeadline)
                            .foregroundColor(.kundliPrimary)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(kundli.birthDetails.name)
                        .font(.kundliTitle3)
                        .foregroundColor(.kundliTextPrimary)

                    Text(kundli.birthDetails.formattedDateTime)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)

                    Text(kundli.birthDetails.birthCity)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                        .lineLimit(1)
                }

                Spacer()
            }
        }
    }

    private var chartTypeToggle: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showDivisionalCharts = false
                }
            } label: {
                Text("Birth Chart")
                    .font(.kundliSubheadline)
                    .foregroundColor(showDivisionalCharts ? .kundliTextSecondary : .kundliBackground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(showDivisionalCharts ? Color.clear : Color.kundliPrimary)
                    )
            }

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showDivisionalCharts = true
                }
            } label: {
                Text("Divisional Charts")
                    .font(.kundliSubheadline)
                    .foregroundColor(showDivisionalCharts ? .kundliBackground : .kundliTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(showDivisionalCharts ? Color.kundliPrimary : Color.clear)
                    )
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.kundliCardBg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private var chartStylePicker: some View {
        Picker("Chart Style", selection: $selectedChartStyle) {
            ForEach(ChartStyle.allCases, id: \.self) { style in
                Text(style.rawValue).tag(style)
            }
        }
        .pickerStyle(.segmented)
        .tint(.kundliPrimary)
    }

    private func chartSection(kundli: Kundli) -> some View {
        CardView(padding: 20) {
            VStack(spacing: 16) {
                // Zoom indicator and aspect toggle
                HStack {
                    // Aspect lines toggle
                    Button {
                        chartInteractionState.toggleAspectLines()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: chartInteractionState.showAspectLines ? "line.diagonal" : "line.diagonal")
                                .font(.system(size: 12))
                            Text("Aspects")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(chartInteractionState.showAspectLines ? .kundliBackground : .kundliTextSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(chartInteractionState.showAspectLines ? Color.kundliPrimary : Color.white.opacity(0.1))
                        )
                    }
                    .buttonStyle(.plain)

                    Spacer()
                    ZoomIndicator(state: chartInteractionState)
                }
                .frame(height: 24)

                // Interactive chart with gestures
                ZStack {
                    interactiveChart(kundli: kundli)
                        .chartGestures(state: chartInteractionState, chartSize: 280)

                    // Aspect lines overlay
                    AspectLinesOverlay(
                        kundli: kundli,
                        chartSize: 280,
                        chartStyle: selectedChartStyle,
                        showAspects: chartInteractionState.showAspectLines
                    )

                    // Planet popup overlay
                    if chartInteractionState.showPlanetPopup,
                       let planet = chartInteractionState.selectedPlanet {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                chartInteractionState.clearSelection()
                            }

                        PlanetQuickInfoPopup(
                            planet: planet,
                            onDismiss: {
                                chartInteractionState.clearSelection()
                            },
                            onViewDetails: {
                                chartInteractionState.clearSelection()
                                selectedPlanet = planet
                                showPlanetDetails = true
                            }
                        )
                        .transition(.scale.combined(with: .opacity))
                    }

                    // House popup overlay
                    if chartInteractionState.showHousePopup,
                       let house = chartInteractionState.selectedHouse {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                chartInteractionState.clearSelection()
                            }

                        HouseInfoPopup(
                            house: house,
                            kundli: kundli,
                            onDismiss: {
                                chartInteractionState.clearSelection()
                            }
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(width: 280, height: 280)
                .clipped()

                // Instructions hint
                if !chartInteractionState.isZoomed {
                    Text("Tap planets or houses for details. Pinch to zoom.")
                        .font(.kundliCaption2)
                        .foregroundColor(.kundliTextTertiary)
                }

                ChartLegend()

                // Aspect legend (shown when aspects are enabled)
                if chartInteractionState.showAspectLines {
                    AspectLegendView()
                }
            }
        }
        .onAppear {
            chartInteractionState.startLoadAnimation()
        }
        .onChange(of: selectedChartStyle) { _, _ in
            chartInteractionState.resetAnimation()
            chartInteractionState.clearSelection()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                chartInteractionState.startLoadAnimation()
            }
        }
    }

    @ViewBuilder
    private func interactiveChart(kundli: Kundli) -> some View {
        switch selectedChartStyle {
        case .northIndian:
            NorthIndianChart(
                kundli: kundli,
                size: 280,
                interactionState: chartInteractionState,
                onPlanetTap: { planet, position in
                    chartInteractionState.selectPlanet(planet, at: position)
                },
                onHouseTap: { house in
                    chartInteractionState.selectHouse(house)
                }
            )
        case .southIndian:
            SouthIndianChart(
                kundli: kundli,
                size: 280,
                interactionState: chartInteractionState,
                onPlanetTap: { planet, position in
                    chartInteractionState.selectPlanet(planet, at: position)
                },
                onHouseTap: { house in
                    chartInteractionState.selectHouse(house)
                }
            )
        case .eastIndian:
            // Fall back to North Indian for now
            NorthIndianChart(
                kundli: kundli,
                size: 280,
                interactionState: chartInteractionState,
                onPlanetTap: { planet, position in
                    chartInteractionState.selectPlanet(planet, at: position)
                },
                onHouseTap: { house in
                    chartInteractionState.selectHouse(house)
                }
            )
        case .western:
            WesternCircularChart(
                kundli: kundli,
                size: 280,
                interactionState: chartInteractionState,
                onPlanetTap: { planet, position in
                    chartInteractionState.selectPlanet(planet, at: position)
                },
                onHouseTap: { house in
                    chartInteractionState.selectHouse(house)
                }
            )
        }
    }

    private func divisionalChartSection(kundli: Kundli) -> some View {
        VStack(spacing: 16) {
            // Divisional chart picker
            DivisionalChartSegmentedPicker(selectedChart: $viewModel.selectedDivisionalChart)

            // Divisional chart display
            CardView(padding: 20) {
                VStack(spacing: 16) {
                    // Chart title
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.selectedDivisionalChart.name)
                                .font(.kundliHeadline)
                                .foregroundColor(.kundliTextPrimary)

                            Text(viewModel.selectedDivisionalChart.description)
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)
                        }

                        Spacer()

                        Text(viewModel.selectedDivisionalChart.rawValue.uppercased())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.kundliPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.kundliPrimary.opacity(0.2))
                            )
                    }

                    Divider()
                        .background(Color.white.opacity(0.1))

                    // Chart display based on selected divisional chart
                    if let chartData = viewModel.currentDivisionalChart {
                        switch selectedChartStyle {
                        case .northIndian:
                            DivisionalNorthIndianChart(chartData: chartData, size: 280)
                        case .southIndian:
                            DivisionalSouthIndianChart(chartData: chartData, size: 280)
                        case .eastIndian:
                            DivisionalNorthIndianChart(chartData: chartData, size: 280)
                        case .western:
                            DivisionalWesternChart(chartData: chartData, size: 280)
                        }
                    } else {
                        // Fallback - use birth chart data for D1
                        if viewModel.selectedDivisionalChart == .d1 {
                            switch selectedChartStyle {
                            case .northIndian:
                                NorthIndianChart(kundli: kundli, size: 280)
                            case .southIndian:
                                SouthIndianChart(kundli: kundli, size: 280)
                            case .eastIndian:
                                NorthIndianChart(kundli: kundli, size: 280)
                            case .western:
                                WesternCircularChart(kundli: kundli, size: 280)
                            }
                        } else {
                            // Show placeholder for unavailable charts
                            VStack(spacing: 12) {
                                Image(systemName: "chart.bar.doc.horizontal")
                                    .font(.system(size: 40))
                                    .foregroundColor(.kundliTextSecondary)

                                Text("Chart data not available")
                                    .font(.kundliSubheadline)
                                    .foregroundColor(.kundliTextSecondary)

                                Text("Generate a full Kundli to view divisional charts")
                                    .font(.kundliCaption)
                                    .foregroundColor(.kundliTextTertiary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(width: 280, height: 280)
                        }
                    }

                    ChartLegend()
                }
            }

            // View all divisional charts link
            if !viewModel.divisionalCharts.isEmpty {
                NavigationLink {
                    DivisionalChartsDetailView(charts: viewModel.divisionalCharts)
                } label: {
                    HStack {
                        Text("View All Divisional Charts")
                            .font(.kundliSubheadline)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.kundliPrimary)
                }
            }
        }
    }

    private func ascendantCard(kundli: Kundli) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Ascendant (Lagna)")
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliTextPrimary)

                    Spacer()

                    Text(kundli.ascendant.sign.symbol)
                        .font(.system(size: 24))
                }

                HStack(spacing: 24) {
                    infoItem("Sign", "\(kundli.ascendant.sign.rawValue) (\(kundli.ascendant.sign.vedName))")
                    infoItem("Degree", kundli.ascendant.degreeString)
                }

                HStack(spacing: 24) {
                    infoItem("Nakshatra", kundli.ascendant.nakshatra)
                    infoItem("Lord", kundli.ascendant.lord)
                }
            }
        }
    }

    private func infoItem(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)

            Text(value)
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextPrimary)
        }
    }
}

// MARK: - Planet Detail Sheet
struct PlanetDetailSheet: View {
    let planet: Planet
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.kundliBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Planet header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.kundliPrimary.opacity(0.2))
                                    .frame(width: 80, height: 80)

                                Text(planet.symbol)
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.kundliPrimary)
                            }

                            Text(planet.name)
                                .font(.kundliTitle2)
                                .foregroundColor(.kundliTextPrimary)

                            Text(planet.vedName)
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliTextSecondary)

                            if planet.status != .neutral {
                                StatusBadge(status: planet.status)
                            }
                        }
                        .padding(.top, 20)

                        // Details
                        CardView {
                            VStack(spacing: 16) {
                                detailRow("Sign", "\(planet.sign) (\(planet.vedSign))")
                                Divider().background(Color.white.opacity(0.1))
                                detailRow("Degree", planet.degreeString)
                                Divider().background(Color.white.opacity(0.1))
                                detailRow("House", "\(planet.house)")
                                Divider().background(Color.white.opacity(0.1))
                                detailRow("Nakshatra", planet.nakshatraWithPada)
                                Divider().background(Color.white.opacity(0.1))
                                detailRow("Nakshatra Lord", planet.lord)
                                Divider().background(Color.white.opacity(0.1))
                                detailRow("Status", planet.status.rawValue)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle(planet.name)
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

    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextSecondary)

            Spacer()

            Text(value)
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextPrimary)
        }
    }
}

#Preview {
    NavigationStack {
        BirthChartView(viewModel: {
            let vm = KundliViewModel()
            vm.loadSampleKundli()
            return vm
        }())
    }
    .modelContainer(for: SavedKundli.self, inMemory: true)
}
