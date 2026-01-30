import Foundation
import SwiftUI

enum PlanetStatus: String, Codable, CaseIterable {
    case direct = "Direct"
    case retrograde = "Retrograde"
    case exalted = "Exalted"
    case debilitated = "Debilitated"
    case ownSign = "Own Sign"
    case neutral = "Neutral"

    var color: Color {
        switch self {
        case .direct: return .kundliSuccess
        case .retrograde: return .kundliWarning
        case .exalted: return .kundliSuccess
        case .debilitated: return .kundliError
        case .ownSign: return .kundliInfo
        case .neutral: return .kundliTextSecondary
        }
    }

    var shortLabel: String {
        switch self {
        case .direct: return "D"
        case .retrograde: return "R"
        case .exalted: return "Ex"
        case .debilitated: return "Db"
        case .ownSign: return "Own"
        case .neutral: return ""
        }
    }
}

struct Planet: Identifiable {
    let id: UUID
    let name: String           // "Sun", "Moon", etc.
    let vedName: String        // "Surya", "Chandra", etc.
    let sign: String           // "Aries", "Taurus", etc.
    let vedSign: String        // "Mesha", "Vrishabha", etc.
    let nakshatra: String
    let nakshatraPada: Int     // 1-4
    let degree: Double
    let minutes: Int
    let seconds: Int
    let house: Int
    let status: PlanetStatus
    let symbol: String         // "Su", "Mo", etc.
    let lord: String           // Nakshatra lord

    init(
        id: UUID = UUID(),
        name: String,
        vedName: String,
        sign: String,
        vedSign: String,
        nakshatra: String,
        nakshatraPada: Int,
        degree: Double,
        minutes: Int,
        seconds: Int,
        house: Int,
        status: PlanetStatus,
        symbol: String,
        lord: String
    ) {
        self.id = id
        self.name = name
        self.vedName = vedName
        self.sign = sign
        self.vedSign = vedSign
        self.nakshatra = nakshatra
        self.nakshatraPada = nakshatraPada
        self.degree = degree
        self.minutes = minutes
        self.seconds = seconds
        self.house = house
        self.status = status
        self.symbol = symbol
        self.lord = lord
    }

    var degreeString: String {
        String(format: "%02d°%02d'%02d\"", Int(degree), minutes, seconds)
    }

    var fullPosition: String {
        "\(sign) \(degreeString)"
    }

    var nakshatraWithPada: String {
        "\(nakshatra) (Pada \(nakshatraPada))"
    }
}

// MARK: - Zodiac Signs
enum ZodiacSign: String, CaseIterable {
    case aries = "Aries"
    case taurus = "Taurus"
    case gemini = "Gemini"
    case cancer = "Cancer"
    case leo = "Leo"
    case virgo = "Virgo"
    case libra = "Libra"
    case scorpio = "Scorpio"
    case sagittarius = "Sagittarius"
    case capricorn = "Capricorn"
    case aquarius = "Aquarius"
    case pisces = "Pisces"

    var vedName: String {
        switch self {
        case .aries: return "Mesha"
        case .taurus: return "Vrishabha"
        case .gemini: return "Mithuna"
        case .cancer: return "Karka"
        case .leo: return "Simha"
        case .virgo: return "Kanya"
        case .libra: return "Tula"
        case .scorpio: return "Vrishchika"
        case .sagittarius: return "Dhanu"
        case .capricorn: return "Makara"
        case .aquarius: return "Kumbha"
        case .pisces: return "Meena"
        }
    }

    var symbol: String {
        switch self {
        case .aries: return "♈"
        case .taurus: return "♉"
        case .gemini: return "♊"
        case .cancer: return "♋"
        case .leo: return "♌"
        case .virgo: return "♍"
        case .libra: return "♎"
        case .scorpio: return "♏"
        case .sagittarius: return "♐"
        case .capricorn: return "♑"
        case .aquarius: return "♒"
        case .pisces: return "♓"
        }
    }

    var number: Int {
        switch self {
        case .aries: return 1
        case .taurus: return 2
        case .gemini: return 3
        case .cancer: return 4
        case .leo: return 5
        case .virgo: return 6
        case .libra: return 7
        case .scorpio: return 8
        case .sagittarius: return 9
        case .capricorn: return 10
        case .aquarius: return 11
        case .pisces: return 12
        }
    }

    var lord: String {
        switch self {
        case .aries, .scorpio: return "Mars"
        case .taurus, .libra: return "Venus"
        case .gemini, .virgo: return "Mercury"
        case .cancer: return "Moon"
        case .leo: return "Sun"
        case .sagittarius, .pisces: return "Jupiter"
        case .capricorn, .aquarius: return "Saturn"
        }
    }
}
