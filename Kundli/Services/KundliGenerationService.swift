import Foundation

/// Protocol for Kundli generation service
protocol KundliGenerationServiceProtocol {
    func generateKundli(
        birthDetails: BirthDetails,
        settings: CalculationSettings
    ) async throws -> KundliData
}

/// Error types for Kundli generation
enum KundliGenerationError: Error, LocalizedError {
    case invalidBirthDetails
    case ephemerisNotInitialized
    case calculationFailed(String)
    case planetPositionFailed(VedicPlanet)
    case houseCalculationFailed

    var errorDescription: String? {
        switch self {
        case .invalidBirthDetails:
            return "Invalid birth details provided"
        case .ephemerisNotInitialized:
            return "Ephemeris service not initialized"
        case .calculationFailed(let reason):
            return "Calculation failed: \(reason)"
        case .planetPositionFailed(let planet):
            return "Failed to calculate position for \(planet.rawValue)"
        case .houseCalculationFailed:
            return "Failed to calculate house positions"
        }
    }
}

/// Service for generating complete Kundli from birth details
final class KundliGenerationService: KundliGenerationServiceProtocol {
    static let shared = KundliGenerationService()

    private let ephemeris = EphemerisService.shared
    private let planetService = PlanetaryPositionService.shared
    private let houseService = HouseCalculationService.shared
    private let nakshatraService = NakshatraService.shared
    private let dashaService = DashaCalculationService.shared
    private let divisionalService = DivisionalChartService.shared
    private let yogaService = YogaDetectionService.shared
    private let doshaService = DoshaDetectionService.shared
    private let shadbalaService = ShadbalaService.shared
    private let ashtakavargaService = AshtakavargaService.shared
    private let transitService = TransitService.shared
    private let yoginiDashaService = YoginiDashaService.shared
    private let ashtottariDashaService = AshtottariDashaService.shared
    private let charaDashaService = CharaDashaService.shared

    private init() {
        // Initialize ephemeris
        ephemeris.initialize()
    }

    // MARK: - Main Generation

    /// Generate complete Kundli data from birth details
    func generateKundli(
        birthDetails: BirthDetails,
        settings: CalculationSettings = .default
    ) async throws -> KundliData {
        // Validate birth details
        guard !birthDetails.name.isEmpty else {
            throw KundliGenerationError.invalidBirthDetails
        }

        // Calculate planetary positions
        let planetPositions = planetService.calculatePlanets(
            from: birthDetails,
            settings: settings
        )

        guard planetPositions.count == 9 else {
            throw KundliGenerationError.calculationFailed("Could not calculate all planetary positions")
        }

        // Calculate houses
        let houseResult = houseService.calculateHouses(
            from: birthDetails,
            planets: planetPositions,
            settings: settings
        )

        // Convert VedicPlanetPosition to Planet model for existing UI
        let planets = planetPositions.map { position -> Planet in
            let house = houseResult.house(for: position.planet)
            return position.toPlanet(house: house)
        }

        // Get Moon position for Dasha calculation
        guard let moonPosition = planetPositions.first(where: { $0.planet == .moon }) else {
            throw KundliGenerationError.planetPositionFailed(.moon)
        }

        // Calculate Dasha periods (Vimshottari - primary system)
        let dashaPeriods = dashaService.calculateDashaPeriods(
            from: birthDetails,
            moonPosition: moonPosition
        )

        // Combine date and time for alternative dasha calculations
        let birthDateTime = combineBirthDateTime(birthDetails: birthDetails)

        // Calculate Yogini Dasha (36-year cycle)
        let yoginiDashaPeriods = yoginiDashaService.calculateYoginiDasha(
            moonLongitude: moonPosition.longitude,
            birthDate: birthDateTime
        )

        // Calculate Ashtottari Dasha (108-year cycle) - conditional
        var ashtottariDashaPeriods: [DashaPeriod]? = nil
        if ashtottariDashaService.isAshtottariApplicable(planets: planetPositions, houses: houseResult) {
            ashtottariDashaPeriods = ashtottariDashaService.calculateAshtottariDasha(
                moonLongitude: moonPosition.longitude,
                birthDate: birthDateTime
            )
        }

        // Calculate Chara Dasha (Jaimini sign-based system)
        let charaDashaPeriods = charaDashaService.calculateCharaDasha(
            houses: houseResult,
            planets: planetPositions,
            birthDate: birthDateTime
        )

        // Calculate Jaimini Karakas
        let jaiminiKarakas = charaDashaService.calculateKarakas(planets: planetPositions)

        // Calculate divisional charts (D9 and D10 priority)
        let divisionalCharts = divisionalService.calculatePriorityCharts(
            planets: planetPositions,
            ascendantLongitude: houseResult.ascendant.degree + Double(houseResult.ascendant.sign.number - 1) * 30
        )

        // Detect yogas
        let yogas = yogaService.detectYogas(
            planets: planetPositions,
            houses: houseResult
        )

        // Detect doshas
        let doshas = doshaService.detectDoshas(
            planets: planetPositions,
            houses: houseResult
        )

        // Calculate Shadbala (planetary strength)
        let planetaryStrengths = shadbalaService.calculateShadbala(
            planetPositions: planetPositions,
            houseResult: houseResult,
            birthDate: birthDetails.dateOfBirth,
            birthTime: birthDetails.timeOfBirth
        )

        // Calculate Ashtakavarga
        let ashtakavargaData = ashtakavargaService.calculateAshtakavarga(
            planetPositions: planetPositions,
            ascendantSignIndex: houseResult.ascendant.sign.number - 1
        )

        // Calculate current transits
        let moonSignNumber = moonPosition.sign.number - 1  // 0-indexed
        let transitData = transitService.calculateCurrentTransits(
            natalPositions: planetPositions,
            natalMoonSign: moonSignNumber
        )

        return KundliData(
            birthDetails: birthDetails,
            planets: planets,
            ascendant: houseResult.ascendant,
            houses: houseResult.houses,
            planetHouses: houseResult.planetHouses,
            dashaPeriods: dashaPeriods,
            yoginiDashaPeriods: yoginiDashaPeriods,
            charaDashaPeriods: charaDashaPeriods,
            ashtottariDashaPeriods: ashtottariDashaPeriods,
            jaiminiKarakas: jaiminiKarakas,
            divisionalCharts: divisionalCharts,
            yogas: yogas,
            doshas: doshas,
            planetaryStrengths: planetaryStrengths,
            ashtakavargaData: ashtakavargaData,
            transitData: transitData,
            settings: settings
        )
    }

    // MARK: - Quick Generation (for preview/testing)

    /// Generate Kundli with default settings
    func generateQuickKundli(birthDetails: BirthDetails) async throws -> KundliData {
        try await generateKundli(birthDetails: birthDetails, settings: .default)
    }

    // MARK: - Partial Calculations

    /// Calculate only planetary positions
    func calculatePlanets(birthDetails: BirthDetails) -> [VedicPlanetPosition] {
        planetService.calculatePlanets(from: birthDetails)
    }

    /// Calculate only Dasha periods
    func calculateDasha(birthDetails: BirthDetails, moonLongitude: Double) -> [DashaPeriod] {
        // Combine date and time
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: birthDetails.dateOfBirth)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: birthDetails.timeOfBirth)

        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        combined.second = timeComponents.second
        combined.timeZone = TimeZone(identifier: birthDetails.timezone)

        guard let birthDateTime = calendar.date(from: combined) else {
            return []
        }

        return dashaService.calculateDashaPeriods(
            moonLongitude: moonLongitude,
            birthDate: birthDateTime
        )
    }

    // MARK: - Helper Methods

    /// Combine birth date and time into a single Date
    private func combineBirthDateTime(birthDetails: BirthDetails) -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: birthDetails.dateOfBirth)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: birthDetails.timeOfBirth)

        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        combined.second = timeComponents.second
        combined.timeZone = TimeZone(identifier: birthDetails.timezone)

        return calendar.date(from: combined) ?? birthDetails.dateOfBirth
    }
}

// MARK: - KundliData Result Type

/// Complete Kundli calculation result
struct KundliData {
    let birthDetails: BirthDetails
    let planets: [Planet]
    let ascendant: Ascendant
    let houses: [HouseInfo]
    let planetHouses: [VedicPlanet: Int]
    let dashaPeriods: [DashaPeriod]
    let yoginiDashaPeriods: [DashaPeriod]
    let charaDashaPeriods: [DashaPeriod]
    let ashtottariDashaPeriods: [DashaPeriod]?  // nil if not applicable
    let jaiminiKarakas: [String: VedicPlanet]
    let divisionalCharts: [DivisionalChartData]
    let yogas: [Yoga]
    let doshas: [Dosha]
    let planetaryStrengths: [PlanetaryStrength]
    let ashtakavargaData: AshtakavargaData
    let transitData: TransitData
    let settings: CalculationSettings

    /// Create a Kundli model for the existing UI
    func toKundli() -> Kundli {
        Kundli(
            birthDetails: birthDetails,
            planets: planets,
            ascendant: ascendant
        )
    }

    /// Get the current active Dasha period (Vimshottari)
    var activeDasha: DashaPeriod? {
        dashaPeriods.first { $0.isActive }
    }

    /// Get the current active Yogini Dasha period
    var activeYoginiDasha: DashaPeriod? {
        yoginiDashaPeriods.first { $0.isActive }
    }

    /// Get the current active Chara Dasha period
    var activeCharaDasha: DashaPeriod? {
        charaDashaPeriods.first { $0.isActive }
    }

    /// Get the current active Ashtottari Dasha period (if applicable)
    var activeAshtottariDasha: DashaPeriod? {
        ashtottariDashaPeriods?.first { $0.isActive }
    }

    /// Check if Ashtottari Dasha is applicable for this chart
    var isAshtottariApplicable: Bool {
        ashtottariDashaPeriods != nil
    }

    /// Get the Moon's nakshatra
    var moonNakshatra: String? {
        planets.first { $0.name == "Moon" }?.nakshatra
    }

    /// Get the Ascendant sign
    var lagnaSign: ZodiacSign {
        ascendant.sign
    }

    /// Get D9 (Navamsa) chart if available
    var navamsaChart: DivisionalChartData? {
        divisionalCharts.first { $0.chartType == .d9 }
    }

    /// Get D10 (Dasamsa) chart if available
    var dasamsaChart: DivisionalChartData? {
        divisionalCharts.first { $0.chartType == .d10 }
    }

    /// Check if chart has Manglik dosha
    var hasManglikDosha: Bool {
        doshas.contains { $0.type == .manglik && !$0.isCancelled }
    }

    /// Check if chart has Kaal Sarp dosha
    var hasKaalSarpDosha: Bool {
        doshas.contains { $0.type == .kaalSarp }
    }

    /// Get all benefic yogas
    var beneficYogas: [Yoga] {
        yogas.filter { $0.nature == .benefic }
    }
}

// MARK: - Extensions for Existing Models

extension VedicPlanetPosition {
    /// Convert to the existing Planet model for UI compatibility
    func toPlanetModel(house: Int) -> Planet {
        Planet(
            name: planet.rawValue,
            vedName: planet.vedName,
            sign: sign.rawValue,
            vedSign: sign.vedName,
            nakshatra: nakshatra.rawValue,
            nakshatraPada: nakshatraPada,
            degree: degreeInSign,
            minutes: minutes,
            seconds: seconds,
            house: house,
            status: status,
            symbol: planet.symbol,
            lord: nakshatraLord
        )
    }
}
