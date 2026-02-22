import Foundation
import SwiftUI
import SwiftData
import CoreLocation
import os

@Observable
class KundliViewModel {
    var birthDetails: BirthDetails?
    var kundli: Kundli?
    var dashaPeriods: [DashaPeriod] = []
    var isGenerating: Bool = false
    var selectedChartType: ChartType = .birthChart
    var selectedChartStyle: ChartStyle = .northIndian
    var generationError: String?

    // Calculation results
    var yogas: [Yoga] = []
    var doshas: [Dosha] = []
    var divisionalCharts: [DivisionalChartData] = []

    // Advanced calculation results
    var planetaryStrengths: [PlanetaryStrength] = []
    var ashtakavargaData: AshtakavargaData?
    var transitData: TransitData?

    // Selected divisional chart for display
    var selectedDivisionalChart: DivisionalChart = .d1

    // Form fields for birth details
    var name: String = ""
    var dateOfBirth: Date = Date()
    var timeOfBirth: Date = Date()
    var selectedCity: City?
    var gender: BirthDetails.Gender = .male

    // City search
    var citySearchText: String = ""
    var searchResults: [City] = []

    // Services
    private let kundliService = KundliGenerationService.shared
    private let settingsService = SettingsService.shared
    private var geocodeTask: Task<Void, Never>?

    init() {
        // Load initial city list
        searchResults = MockDataService.shared.cities

        // Observe settings changes
        NotificationCenter.default.addObserver(
            forName: SettingsService.calculationSettingsChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.regenerateKundliIfNeeded()
        }
    }

    /// Regenerate kundli when calculation settings change
    private func regenerateKundliIfNeeded() {
        guard birthDetails != nil, selectedCity != nil else { return }
        generateKundli()
    }

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedCity != nil
    }

    func searchCities() {
        let query = citySearchText.trimmingCharacters(in: .whitespaces)
        guard query.count >= 2 else {
            searchResults = MockDataService.shared.cities
            return
        }

        geocodeTask?.cancel()
        geocodeTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }

            let geocoder = CLGeocoder()
            do {
                let placemarks = try await geocoder.geocodeAddressString(query)
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
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    searchResults = cities.isEmpty ? MockDataService.shared.cities : cities
                }
            } catch {
                guard !Task.isCancelled else { return }
                // Offline fallback: filter hardcoded cities
                let filtered = MockDataService.shared.cities.filter {
                    $0.name.localizedCaseInsensitiveContains(query)
                }
                await MainActor.run {
                    searchResults = filtered.isEmpty ? MockDataService.shared.cities : filtered
                }
            }
        }
    }

    func selectCity(_ city: City) {
        selectedCity = city
        citySearchText = city.displayName
    }

    func generateKundli() {
        guard isFormValid, let city = selectedCity else { return }

        isGenerating = true
        generationError = nil

        // Create birth details
        let details = BirthDetails(
            name: name,
            dateOfBirth: dateOfBirth,
            timeOfBirth: timeOfBirth,
            birthCity: city.displayName,
            latitude: city.latitude,
            longitude: city.longitude,
            timezone: city.timezone,
            gender: gender
        )

        self.birthDetails = details

        // Generate Kundli using real calculations
        Task {
            do {
                let data = try await kundliService.generateKundli(
                    birthDetails: details,
                    settings: settingsService.calculationSettings
                )

                await MainActor.run {
                    self.kundli = data.toKundli()
                    self.dashaPeriods = data.dashaPeriods
                    self.yogas = data.yogas
                    self.doshas = data.doshas
                    self.divisionalCharts = data.divisionalCharts
                    self.planetaryStrengths = data.planetaryStrengths
                    self.ashtakavargaData = data.ashtakavargaData
                    self.transitData = data.transitData
                    self.isGenerating = false
                }
            } catch {
                await MainActor.run {
                    AppLogger.kundli.error("Kundli generation error: \(error.localizedDescription)")
                    self.generationError = error.localizedDescription
                    self.kundli = nil
                    self.isGenerating = false
                }
            }
        }
    }

    func loadSampleKundli() {
        birthDetails = MockDataService.shared.sampleBirthDetails()
        kundli = MockDataService.shared.sampleKundli()
        dashaPeriods = MockDataService.shared.sampleDashaPeriods()
    }

    // Get planets for a specific house
    func planetsInHouse(_ house: Int) -> [Planet] {
        kundli?.planetsInHouse(house) ?? []
    }

    // Get planet abbreviations for chart display
    func planetSymbolsInHouse(_ house: Int) -> String {
        planetsInHouse(house)
            .map { $0.symbol }
            .joined(separator: " ")
    }

    // Active Dasha period
    var activeDasha: DashaPeriod? {
        dashaPeriods.first { $0.isActive }
    }

    // Active Antar Dasha
    var activeAntarDasha: AntarDasha? {
        activeDasha?.subPeriods.first { $0.isActive }
    }

    // Active Pratyantar Dasha
    var activePratyantarDasha: PratyantarDasha? {
        activeAntarDasha?.activePratyantarDasha
    }

    // Get selected divisional chart data
    var currentDivisionalChart: DivisionalChartData? {
        divisionalCharts.first { $0.chartType == selectedDivisionalChart }
    }

    // Check for specific doshas
    var hasManglikDosha: Bool {
        doshas.contains { $0.type == .manglik && !$0.isCancelled }
    }

    var hasKaalSarpDosha: Bool {
        doshas.contains { $0.type == .kaalSarp && !$0.isCancelled }
    }

    // Get benefic yogas
    var beneficYogas: [Yoga] {
        yogas.filter { $0.nature == .benefic }
    }

    // Get active (non-cancelled) doshas
    var activeDoshas: [Dosha] {
        doshas.filter { !$0.isCancelled }
    }

    // Create SavedKundli for persistence
    func createSavedKundli() -> SavedKundli? {
        guard let details = birthDetails, let kundli = kundli else { return nil }

        let saved = SavedKundli(
            id: details.id,
            name: details.name,
            dateOfBirth: details.dateOfBirth,
            timeOfBirth: details.timeOfBirth,
            birthCity: details.birthCity,
            latitude: details.latitude,
            longitude: details.longitude,
            timezone: details.timezone,
            gender: details.gender.rawValue,
            ascendantSign: kundli.ascendant.sign.rawValue,
            ascendantDegree: kundli.ascendant.degree,
            ascendantNakshatra: kundli.ascendant.nakshatra
        )

        saved.planetsData = try? JSONEncoder().encode(kundli.planets)
        saved.ascendantData = try? JSONEncoder().encode(kundli.ascendant)

        return saved
    }
}
