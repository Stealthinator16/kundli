import Foundation

struct BirthDetails: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var dateOfBirth: Date
    var timeOfBirth: Date
    var birthCity: String
    var latitude: Double
    var longitude: Double
    var timezone: String
    var gender: Gender

    enum Gender: String, Codable, CaseIterable {
        case male = "Male"
        case female = "Female"
        case other = "Other"
    }

    init(
        id: UUID = UUID(),
        name: String,
        dateOfBirth: Date,
        timeOfBirth: Date,
        birthCity: String,
        latitude: Double,
        longitude: Double,
        timezone: String = "IST",
        gender: Gender
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
}

// MARK: - City Model for Search
struct City: Identifiable, Hashable {
    let id: UUID
    let name: String
    let state: String
    let country: String
    let latitude: Double
    let longitude: Double
    let timezone: String

    init(
        id: UUID = UUID(),
        name: String,
        state: String,
        country: String,
        latitude: Double,
        longitude: Double,
        timezone: String
    ) {
        self.id = id
        self.name = name
        self.state = state
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.timezone = timezone
    }

    var displayName: String {
        "\(name), \(state), \(country)"
    }
}
