import Foundation

/// Represents a geographic location for astronomical calculations
struct GeoLocation: Codable, Equatable {
    let latitude: Double    // Degrees, positive = North, negative = South
    let longitude: Double   // Degrees, positive = East, negative = West
    let altitude: Double    // Meters above sea level (default 0)
    let timezone: TimeZone  // Timezone for local time calculations

    init(
        latitude: Double,
        longitude: Double,
        altitude: Double = 0,
        timezone: TimeZone
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.timezone = timezone
    }

    /// Create from City model
    init(from city: City) {
        self.latitude = city.latitude
        self.longitude = city.longitude
        self.altitude = 0
        self.timezone = TimeZone(identifier: city.timezone) ?? TimeZone(abbreviation: "IST")!
    }

    /// Create from BirthDetails
    init(from details: BirthDetails) {
        self.latitude = details.latitude
        self.longitude = details.longitude
        self.altitude = 0
        self.timezone = TimeZone(identifier: details.timezone) ?? TimeZone(abbreviation: "IST")!
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case latitude, longitude, altitude, timezoneIdentifier
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        altitude = try container.decodeIfPresent(Double.self, forKey: .altitude) ?? 0
        let timezoneId = try container.decode(String.self, forKey: .timezoneIdentifier)
        timezone = TimeZone(identifier: timezoneId) ?? TimeZone(abbreviation: "UTC")!
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(timezone.identifier, forKey: .timezoneIdentifier)
    }
}

// MARK: - Common Indian Cities
extension GeoLocation {
    static let newDelhi = GeoLocation(
        latitude: 28.6139,
        longitude: 77.2090,
        timezone: TimeZone(identifier: "Asia/Kolkata")!
    )

    static let mumbai = GeoLocation(
        latitude: 19.0760,
        longitude: 72.8777,
        timezone: TimeZone(identifier: "Asia/Kolkata")!
    )

    static let chennai = GeoLocation(
        latitude: 13.0827,
        longitude: 80.2707,
        timezone: TimeZone(identifier: "Asia/Kolkata")!
    )

    static let kolkata = GeoLocation(
        latitude: 22.5726,
        longitude: 88.3639,
        timezone: TimeZone(identifier: "Asia/Kolkata")!
    )

    static let bangalore = GeoLocation(
        latitude: 12.9716,
        longitude: 77.5946,
        timezone: TimeZone(identifier: "Asia/Kolkata")!
    )
}
