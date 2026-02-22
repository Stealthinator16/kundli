import Foundation
import SwiftData

@Model
final class SavedKundli {
    var id: UUID
    var name: String
    var dateOfBirth: Date
    var timeOfBirth: Date
    var birthCity: String
    var latitude: Double
    var longitude: Double
    var timezone: String
    var gender: String
    var createdAt: Date
    var updatedAt: Date

    // Stored chart data (JSON encoded)
    var planetsData: Data?
    var ascendantData: Data?
    var ascendantSign: String
    var ascendantDegree: Double
    var ascendantNakshatra: String

    init(
        id: UUID = UUID(),
        name: String,
        dateOfBirth: Date,
        timeOfBirth: Date,
        birthCity: String,
        latitude: Double,
        longitude: Double,
        timezone: String = "IST",
        gender: String,
        ascendantSign: String = "",
        ascendantDegree: Double = 0,
        ascendantNakshatra: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.timeOfBirth = timeOfBirth
        self.birthCity = birthCity
        self.latitude = latitude
        self.longitude = longitude
        self.timezone = timezone
        self.gender = gender
        self.ascendantSign = ascendantSign
        self.ascendantDegree = ascendantDegree
        self.ascendantNakshatra = ascendantNakshatra
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    func decodePlanets() -> [Planet]? {
        guard let data = planetsData else { return nil }
        return try? JSONDecoder().decode([Planet].self, from: data)
    }

    func decodeAscendant() -> Ascendant? {
        guard let data = ascendantData else { return nil }
        return try? JSONDecoder().decode(Ascendant.self, from: data)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: dateOfBirth)
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: timeOfBirth)
    }

    var formattedDateTime: String {
        "\(formattedDate), \(formattedTime)"
    }

    var initials: String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    // Convert to BirthDetails for use with existing views
    func toBirthDetails() -> BirthDetails {
        BirthDetails(
            id: id,
            name: name,
            dateOfBirth: dateOfBirth,
            timeOfBirth: timeOfBirth,
            birthCity: birthCity,
            latitude: latitude,
            longitude: longitude,
            timezone: timezone,
            gender: BirthDetails.Gender(rawValue: gender) ?? .male
        )
    }

    // Create from BirthDetails
    static func from(_ details: BirthDetails, ascendant: Ascendant? = nil) -> SavedKundli {
        SavedKundli(
            id: details.id,
            name: details.name,
            dateOfBirth: details.dateOfBirth,
            timeOfBirth: details.timeOfBirth,
            birthCity: details.birthCity,
            latitude: details.latitude,
            longitude: details.longitude,
            timezone: details.timezone,
            gender: details.gender.rawValue,
            ascendantSign: ascendant?.sign.rawValue ?? "",
            ascendantDegree: ascendant?.degree ?? 0,
            ascendantNakshatra: ascendant?.nakshatra ?? ""
        )
    }
}
