import Foundation

/// Dasha system types
enum DashaSystem: String, Codable, CaseIterable {
    case vimshottari = "Vimshottari"
    case yogini = "Yogini"
    case chara = "Chara"
    case ashtottari = "Ashtottari"

    var description: String {
        switch self {
        case .vimshottari:
            return "120-year cycle based on Moon's nakshatra"
        case .yogini:
            return "36-year cycle using 8 Yoginis"
        case .chara:
            return "Jaimini system based on signs"
        case .ashtottari:
            return "108-year cycle (conditional applicability)"
        }
    }

    var totalCycleYears: Int {
        switch self {
        case .vimshottari: return 120
        case .yogini: return 36
        case .chara: return 144  // Variable, approximately 12 signs x 12 years avg
        case .ashtottari: return 108
        }
    }
}

struct DashaPeriod: Identifiable {
    let id: UUID
    let planet: String          // Ruling planet name (or sign for Chara)
    let vedName: String         // Vedic name of planet
    let startDate: Date
    let endDate: Date
    let isActive: Bool
    let subPeriods: [AntarDasha]
    let dashaSystem: DashaSystem

    init(
        id: UUID = UUID(),
        planet: String,
        vedName: String,
        startDate: Date,
        endDate: Date,
        isActive: Bool = false,
        subPeriods: [AntarDasha] = [],
        dashaSystem: DashaSystem = .vimshottari
    ) {
        self.id = id
        self.planet = planet
        self.vedName = vedName
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
        self.subPeriods = subPeriods
        self.dashaSystem = dashaSystem
    }

    var duration: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }

    var yearsRemaining: String {
        guard isActive else { return "" }
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: now, to: endDate)
        if let years = components.year, let months = components.month {
            if years > 0 {
                return "\(years)y \(months)m remaining"
            } else {
                return "\(months) months remaining"
            }
        }
        return ""
    }
}

// MARK: - Antar Dasha (Sub-period)
struct AntarDasha: Identifiable {
    let id: UUID
    let planet: String
    let vedName: String
    let startDate: Date
    let endDate: Date
    let isActive: Bool
    let pratyantarDashas: [PratyantarDasha]

    init(
        id: UUID = UUID(),
        planet: String,
        vedName: String,
        startDate: Date,
        endDate: Date,
        isActive: Bool = false,
        pratyantarDashas: [PratyantarDasha] = []
    ) {
        self.id = id
        self.planet = planet
        self.vedName = vedName
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
        self.pratyantarDashas = pratyantarDashas
    }

    var duration: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }

    var activePratyantarDasha: PratyantarDasha? {
        pratyantarDashas.first { $0.isActive }
    }
}

// MARK: - Pratyantar Dasha (Sub-sub-period)
struct PratyantarDasha: Identifiable {
    let id: UUID
    let planet: String
    let vedName: String
    let startDate: Date
    let endDate: Date
    let isActive: Bool

    init(
        id: UUID = UUID(),
        planet: String,
        vedName: String,
        startDate: Date,
        endDate: Date,
        isActive: Bool = false
    ) {
        self.id = id
        self.planet = planet
        self.vedName = vedName
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
    }

    var duration: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }

    var shortDuration: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}

// MARK: - Vimshottari Dasha Order
enum VimshottariDashaOrder: CaseIterable {
    case ketu
    case venus
    case sun
    case moon
    case mars
    case rahu
    case jupiter
    case saturn
    case mercury

    var planetName: String {
        switch self {
        case .ketu: return "Ketu"
        case .venus: return "Venus"
        case .sun: return "Sun"
        case .moon: return "Moon"
        case .mars: return "Mars"
        case .rahu: return "Rahu"
        case .jupiter: return "Jupiter"
        case .saturn: return "Saturn"
        case .mercury: return "Mercury"
        }
    }

    var vedName: String {
        switch self {
        case .ketu: return "Ketu"
        case .venus: return "Shukra"
        case .sun: return "Surya"
        case .moon: return "Chandra"
        case .mars: return "Mangal"
        case .rahu: return "Rahu"
        case .jupiter: return "Guru"
        case .saturn: return "Shani"
        case .mercury: return "Budha"
        }
    }

    // Total years for each Mahadasha
    var totalYears: Int {
        switch self {
        case .ketu: return 7
        case .venus: return 20
        case .sun: return 6
        case .moon: return 10
        case .mars: return 7
        case .rahu: return 18
        case .jupiter: return 16
        case .saturn: return 19
        case .mercury: return 17
        }
    }
}
