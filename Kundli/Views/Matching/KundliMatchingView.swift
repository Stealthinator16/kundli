import SwiftUI
import CoreLocation

struct KundliMatchingView: View {
    @State private var viewModel = MatchingViewModel()
    @State private var showPerson1CitySearch = false
    @State private var showPerson2CitySearch = false
    @State private var person1CitySearchText = ""
    @State private var person2CitySearchText = ""
    @State private var person1CityResults: [City] = MockDataService.shared.cities
    @State private var person2CityResults: [City] = MockDataService.shared.cities

    var body: some View {
        NavigationStack {
            ZStack {
                Color.kundliBackground.ignoresSafeArea()

                if let result = viewModel.matchResult {
                    // Show results
                    matchResultView(result: result)
                } else {
                    // Show form
                    matchingFormView
                }

                // Loading overlay
                if viewModel.isMatching {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()

                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .kundliPrimary))
                            .scaleEffect(1.5)

                        Text("Calculating compatibility...")
                            .font(.kundliSubheadline)
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationTitle("Kundli Matching")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                if viewModel.matchResult != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("New Match") {
                            viewModel.reset()
                        }
                        .foregroundColor(.kundliPrimary)
                    }
                }
            }
        }
    }

    private var matchingFormView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.pink)

                    Text("Gun Milan")
                        .font(.kundliTitle2)
                        .foregroundColor(.kundliTextPrimary)

                    Text("Check Kundli compatibility for marriage")
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                // Person 1 Form
                personForm(
                    title: "Bride's Details",
                    name: $viewModel.person1Name,
                    dateOfBirth: $viewModel.person1DateOfBirth,
                    timeOfBirth: $viewModel.person1TimeOfBirth,
                    selectedCity: viewModel.person1City,
                    onCityTap: { showPerson1CitySearch = true }
                )

                // Person 2 Form
                personForm(
                    title: "Groom's Details",
                    name: $viewModel.person2Name,
                    dateOfBirth: $viewModel.person2DateOfBirth,
                    timeOfBirth: $viewModel.person2TimeOfBirth,
                    selectedCity: viewModel.person2City,
                    onCityTap: { showPerson2CitySearch = true }
                )

                // Match button
                GoldButton(
                    title: "Check Compatibility",
                    icon: "heart.fill"
                ) {
                    viewModel.performMatching()
                }
                .disabled(!viewModel.isFormValid)
                .opacity(viewModel.isFormValid ? 1 : 0.6)
                .padding(.top, 8)

                Spacer()
                    .frame(height: 20)
            }
            .padding(16)
        }
        .sheet(isPresented: $showPerson1CitySearch) {
            CitySearchView(
                searchText: $person1CitySearchText,
                selectedCity: $viewModel.person1City,
                cities: person1CityResults
            ) {
                searchCities(query: person1CitySearchText) { results in
                    person1CityResults = results
                }
            }
        }
        .sheet(isPresented: $showPerson2CitySearch) {
            CitySearchView(
                searchText: $person2CitySearchText,
                selectedCity: $viewModel.person2City,
                cities: person2CityResults
            ) {
                searchCities(query: person2CitySearchText) { results in
                    person2CityResults = results
                }
            }
        }
    }

    private func personForm(
        title: String,
        name: Binding<String>,
        dateOfBirth: Binding<Date>,
        timeOfBirth: Binding<Date>,
        selectedCity: City?,
        onCityTap: @escaping () -> Void
    ) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliPrimary)

                // Name
                VStack(alignment: .leading, spacing: 6) {
                    Text("Name")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)

                    TextField("Enter name", text: name)
                        .textFieldStyle(KundliTextFieldStyle())
                }

                // Date and Time
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Date of Birth")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)

                        DatePicker("", selection: dateOfBirth, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .tint(.kundliPrimary)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Time of Birth")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)

                        DatePicker("", selection: timeOfBirth, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .tint(.kundliPrimary)
                    }
                }

                // City
                VStack(alignment: .leading, spacing: 6) {
                    Text("Birth Place")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)

                    Button(action: onCityTap) {
                        HStack {
                            Text(selectedCity?.displayName ?? "Select city")
                                .font(.kundliBody)
                                .foregroundColor(selectedCity == nil ? .kundliTextSecondary : .kundliTextPrimary)

                            Spacer()

                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.kundliTextSecondary)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func matchResultView(result: KundliMatch) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Score circle
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 12)
                            .frame(width: 140, height: 140)

                        Circle()
                            .trim(from: 0, to: result.gunMilan.percentage / 100)
                            .stroke(
                                LinearGradient.kundliGold,
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .frame(width: 140, height: 140)
                            .rotationEffect(.degrees(-90))

                        VStack(spacing: 4) {
                            Text("\(Int(result.gunMilan.totalScore))")
                                .font(.kundliLargeTitle)
                                .foregroundColor(.kundliPrimary)

                            Text("out of 36")
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)
                        }
                    }

                    Text(result.overallCompatibility.rawValue)
                        .font(.kundliTitle2)
                        .foregroundColor(compatibilityColor(result.overallCompatibility))

                    Text(result.overallCompatibility.description)
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)

                // Gun Milan details
                CardView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            LearnableText(
                                text: "Ashtakoot Gun Milan",
                                termId: "ashtakoot",
                                style: .headline
                            )

                            Spacer()
                        }

                        Text("8-factor compatibility analysis based on Moon signs")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)

                        ForEach(result.gunMilan.allScores) { score in
                            gunScoreRow(score: score)
                        }
                    }
                }

                // Manglik status
                CardView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Manglik Status")
                            .font(.kundliHeadline)
                            .foregroundColor(.kundliTextPrimary)

                        Text(result.manglikStatus.statusDescription)
                            .font(.kundliSubheadline)
                            .foregroundColor(result.manglikStatus.isCompatible ? .kundliSuccess : .kundliWarning)
                    }
                }

                // Compare Charts button
                if let kundli1 = viewModel.person1Kundli, let kundli2 = viewModel.person2Kundli {
                    NavigationLink {
                        ChartComparisonView(kundli1: kundli1, kundli2: kundli2)
                    } label: {
                        HStack {
                            Image(systemName: "square.on.square")
                                .font(.system(size: 16))

                            Text("Compare Charts (Synastry)")
                                .font(.kundliSubheadline)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                        }
                        .foregroundColor(.kundliPrimary)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.kundliPrimary, lineWidth: 1.5)
                        )
                    }
                }

                // Marriage Muhurta Recommendations
                marriageMuhurtaSection

                Spacer()
                    .frame(height: 20)
            }
            .padding(16)
        }
    }

    // MARK: - Marriage Muhurta Section

    @ViewBuilder
    private var marriageMuhurtaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 14))
                    .foregroundColor(.pink)

                Text("Recommended Marriage Dates")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)
            }

            NavigationLink {
                MarriageMuhurtaListView()
            } label: {
                CardView {
                    VStack(alignment: .leading, spacing: 12) {
                        // Preview of upcoming dates
                        MarriageMuhurtaPreview()

                        Divider()
                            .background(Color.white.opacity(0.1))

                        HStack {
                            Text("View All Auspicious Dates")
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliPrimary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(.kundliPrimary)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    private func gunScoreRow(score: GunScore) -> some View {
        VStack(spacing: 8) {
            HStack {
                LearnableText(
                    text: score.name,
                    termId: "ashtakoot.\(score.name.lowercased().replacingOccurrences(of: " ", with: "-"))",
                    style: .default,
                    showIndicator: true
                )

                Spacer()

                Text("\(Int(score.score))/\(Int(score.maxScore))")
                    .font(.kundliSubheadline)
                    .foregroundColor(score.isFullMatch ? .kundliSuccess : .kundliTextSecondary)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(score.isFullMatch ? Color.kundliSuccess : Color.kundliPrimary)
                        .frame(width: geometry.size.width * score.percentage / 100, height: 6)
                }
            }
            .frame(height: 6)
        }
    }

    private func compatibilityColor(_ level: CompatibilityLevel) -> Color {
        switch level {
        case .excellent: return .kundliSuccess
        case .good: return .kundliPrimary
        case .average: return .kundliWarning
        case .poor: return .kundliError
        }
    }

    private func searchCities(query: String, completion: @escaping ([City]) -> Void) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            completion(MockDataService.shared.cities)
            return
        }
        Task {
            let geocoder = CLGeocoder()
            do {
                let placemarks = try await geocoder.geocodeAddressString(trimmed)
                let cities = placemarks.compactMap { placemark -> City? in
                    guard let name = placemark.locality,
                          let location = placemark.location else { return nil }
                    return City(
                        name: name,
                        state: placemark.administrativeArea ?? "",
                        country: placemark.country ?? "",
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude,
                        timezone: placemark.timeZone?.identifier ?? "UTC"
                    )
                }
                await MainActor.run {
                    completion(cities.isEmpty ? MockDataService.shared.cities : cities)
                }
            } catch {
                let filtered = MockDataService.shared.cities.filter {
                    $0.name.localizedCaseInsensitiveContains(trimmed)
                }
                await MainActor.run {
                    completion(filtered.isEmpty ? MockDataService.shared.cities : filtered)
                }
            }
        }
    }
}

#Preview {
    KundliMatchingView()
}
