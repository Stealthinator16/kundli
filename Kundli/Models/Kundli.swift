import Foundation

struct Kundli: Identifiable, Equatable {
    static func == (lhs: Kundli, rhs: Kundli) -> Bool {
        lhs.id == rhs.id
    }

    let id: UUID
    let birthDetails: BirthDetails
    let planets: [Planet]
    let ascendant: Ascendant
    let housePlanets: [Int: [Planet]] // House number to planets mapping
    let createdAt: Date

    init(
        id: UUID = UUID(),
        birthDetails: BirthDetails,
        planets: [Planet],
        ascendant: Ascendant,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.birthDetails = birthDetails
        self.planets = planets
        self.ascendant = ascendant
        self.createdAt = createdAt

        // Build house to planets mapping
        var mapping: [Int: [Planet]] = [:]
        for i in 1...12 {
            mapping[i] = planets.filter { $0.house == i }
        }
        self.housePlanets = mapping
    }

    func planetsInHouse(_ house: Int) -> [Planet] {
        housePlanets[house] ?? []
    }

    func planet(named name: String) -> Planet? {
        planets.first { $0.name.lowercased() == name.lowercased() }
    }
}

// MARK: - Ascendant (Lagna)
struct Ascendant: Codable {
    let sign: ZodiacSign
    let degree: Double
    let minutes: Int
    let seconds: Int
    let nakshatra: String
    let nakshatraPada: Int
    let lord: String

    var degreeString: String {
        String(format: "%02d°%02d'%02d\"", Int(degree), minutes, seconds)
    }

    var fullDescription: String {
        "\(sign.rawValue) (\(sign.vedName)) \(degreeString)"
    }
}

// MARK: - Chart Type
enum ChartType: String, CaseIterable {
    case birthChart = "Birth Chart"
    case navamsa = "Navamsa (D9)"
    case dasamsa = "Dasamsa (D10)"
    case dwadasamsa = "Dwadasamsa (D12)"

    var shortName: String {
        switch self {
        case .birthChart: return "D1"
        case .navamsa: return "D9"
        case .dasamsa: return "D10"
        case .dwadasamsa: return "D12"
        }
    }
}

// MARK: - Chart Style
enum ChartStyle: String, CaseIterable {
    case northIndian = "North Indian"
    case southIndian = "South Indian"
    case eastIndian = "East Indian"
    case western = "Western"
}
