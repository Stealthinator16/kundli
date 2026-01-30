import Foundation
import SwissEphemeris

/// Service for interacting with Swiss Ephemeris for astronomical calculations
final class EphemerisService {
    static let shared = EphemerisService()

    private init() {}

    /// Initialize the ephemeris service (no-op with Swift wrapper, included for API compatibility)
    func initialize() {
        // The SwissEphemeris Swift wrapper handles initialization automatically
        // This method exists for API compatibility with KundliGenerationService
    }

    // MARK: - Julian Day Conversion

    /// Convert a Date to Julian Day number
    func julianDay(for date: Date, timezone: TimeZone = .current) -> Double {
        // The SwissEphemeris Date extension provides julianDate()
        return date.julianDate()
    }

    /// Convert Julian Day back to Date
    func date(from julianDay: Double) -> Date {
        // Create date from Julian day (this is approximate, mainly for display)
        let j2000 = 2451545.0 // Jan 1, 2000, 12:00 TT
        let secondsSinceJ2000 = (julianDay - j2000) * 86400.0
        let j2000Date = Date(timeIntervalSince1970: 946728000) // Jan 1, 2000 12:00 UTC
        return j2000Date.addingTimeInterval(secondsSinceJ2000)
    }

    // MARK: - Planetary Positions

    /// Get the tropical longitude of a planet in degrees (0-360)
    func tropicalLongitude(
        planet: VedicPlanet,
        date: Date
    ) -> PlanetaryPosition? {
        switch planet {
        case .sun:
            let coord = Coordinate(body: SwissEphemeris.Planet.sun, date: date)
            return makePlanetaryPosition(from: coord, isKetu: false)
        case .moon:
            let coord = Coordinate(body: SwissEphemeris.Planet.moon, date: date)
            return makePlanetaryPosition(from: coord, isKetu: false)
        case .mars:
            let coord = Coordinate(body: SwissEphemeris.Planet.mars, date: date)
            return makePlanetaryPosition(from: coord, isKetu: false)
        case .mercury:
            let coord = Coordinate(body: SwissEphemeris.Planet.mercury, date: date)
            return makePlanetaryPosition(from: coord, isKetu: false)
        case .jupiter:
            let coord = Coordinate(body: SwissEphemeris.Planet.jupiter, date: date)
            return makePlanetaryPosition(from: coord, isKetu: false)
        case .venus:
            let coord = Coordinate(body: SwissEphemeris.Planet.venus, date: date)
            return makePlanetaryPosition(from: coord, isKetu: false)
        case .saturn:
            let coord = Coordinate(body: SwissEphemeris.Planet.saturn, date: date)
            return makePlanetaryPosition(from: coord, isKetu: false)
        case .rahu:
            let coord = Coordinate(body: LunarNorthNode.meanNode, date: date)
            return makePlanetaryPosition(from: coord, isKetu: false)
        case .ketu:
            let coord = Coordinate(body: LunarNorthNode.meanNode, date: date)
            return makePlanetaryPosition(from: coord, isKetu: true)
        }
    }

    /// Get sidereal position (adjusting for ayanamsa)
    func siderealLongitude(
        planet: VedicPlanet,
        date: Date,
        ayanamsaType: AyanamsaType = .lahiri
    ) -> PlanetaryPosition? {
        guard let position = tropicalLongitude(planet: planet, date: date) else {
            return nil
        }

        let ayanamsaValue = ayanamsa(for: date, type: ayanamsaType)
        var siderealLong = position.longitude - ayanamsaValue

        // Normalize to 0-360
        while siderealLong < 0 { siderealLong += 360.0 }
        while siderealLong >= 360.0 { siderealLong -= 360.0 }

        return PlanetaryPosition(
            longitude: siderealLong,
            latitude: position.latitude,
            distance: position.distance,
            speedLongitude: position.speedLongitude,
            speedLatitude: position.speedLatitude,
            speedDistance: position.speedDistance
        )
    }

    /// Get sidereal position using Julian Day (for PlanetaryPositionService compatibility)
    func siderealLongitude(
        planet: VedicPlanet,
        julianDay: Double,
        ayanamsa: AyanamsaType = .lahiri
    ) -> PlanetaryPosition? {
        let date = self.date(from: julianDay)
        return siderealLongitude(planet: planet, date: date, ayanamsaType: ayanamsa)
    }

    // MARK: - Ayanamsa

    /// Get ayanamsa value for a date
    func ayanamsa(for date: Date, type: AyanamsaType = .lahiri) -> Double {
        // Use Coordinate to get tropical position, then calculate offset from sidereal
        // The SwissEphemeris package computes Lahiri ayanamsa internally
        let coord = Coordinate(body: SwissEphemeris.Planet.sun, date: date)
        // Ayanamsa = tropical - sidereal
        return coord.longitude - coord.sidereal.value
    }

    // MARK: - House Calculation

    /// Calculate houses for a given date and location
    func calculateHouses(
        date: Date,
        latitude: Double,
        longitude: Double,
        system: HouseSystemType = .equal
    ) -> HouseCalculationData? {
        let swissHouseSystem: SwissEphemeris.HouseSystem
        switch system {
        case .equal:
            swissHouseSystem = .equal
        case .wholeSign:
            swissHouseSystem = .wholeSign
        case .placidus:
            swissHouseSystem = .placidus
        case .koch:
            swissHouseSystem = .koch
        }

        let houseCusps = HouseCusps(
            date: date,
            latitude: latitude,
            longitude: longitude,
            houseSystem: swissHouseSystem
        )

        return HouseCalculationData(
            cusps: [
                houseCusps.first.tropical.value,
                houseCusps.second.tropical.value,
                houseCusps.third.tropical.value,
                houseCusps.fourth.tropical.value,
                houseCusps.fifth.tropical.value,
                houseCusps.sixth.tropical.value,
                houseCusps.seventh.tropical.value,
                houseCusps.eighth.tropical.value,
                houseCusps.ninth.tropical.value,
                houseCusps.tenth.tropical.value,
                houseCusps.eleventh.tropical.value,
                houseCusps.twelfth.tropical.value
            ],
            ascendant: houseCusps.ascendent.tropical.value,
            mc: houseCusps.midHeaven.tropical.value
        )
    }

    /// Calculate sidereal houses
    func calculateSiderealHouses(
        date: Date,
        latitude: Double,
        longitude: Double,
        system: HouseSystemType = .equal,
        ayanamsaType: AyanamsaType = .lahiri
    ) -> HouseCalculationData? {
        guard let tropical = calculateHouses(date: date, latitude: latitude, longitude: longitude, system: system) else {
            return nil
        }

        let ayanamsaValue = ayanamsa(for: date, type: ayanamsaType)

        // Convert all cusps to sidereal
        let siderealCusps = tropical.cusps.map { cusp -> Double in
            var sidereal = cusp - ayanamsaValue
            while sidereal < 0 { sidereal += 360.0 }
            while sidereal >= 360.0 { sidereal -= 360.0 }
            return sidereal
        }

        var siderealAsc = tropical.ascendant - ayanamsaValue
        while siderealAsc < 0 { siderealAsc += 360.0 }
        while siderealAsc >= 360.0 { siderealAsc -= 360.0 }

        var siderealMC = tropical.mc - ayanamsaValue
        while siderealMC < 0 { siderealMC += 360.0 }
        while siderealMC >= 360.0 { siderealMC -= 360.0 }

        return HouseCalculationData(
            cusps: siderealCusps,
            ascendant: siderealAsc,
            mc: siderealMC
        )
    }

    // MARK: - Overloads for CalculationSettings Types

    /// Get sidereal position using Ayanamsa from CalculationSettings
    func siderealLongitude(
        planet: VedicPlanet,
        julianDay: Double,
        ayanamsa: Ayanamsa
    ) -> PlanetaryPosition? {
        let date = self.date(from: julianDay)
        let ayanamsaType = convertAyanamsa(ayanamsa)
        return siderealLongitude(planet: planet, date: date, ayanamsaType: ayanamsaType)
    }

    /// Calculate sidereal houses using Julian Day and GeoLocation
    func calculateSiderealHouses(
        julianDay: Double,
        location: GeoLocation,
        houseSystem: HouseSystem,
        ayanamsa: Ayanamsa
    ) -> HouseCalculationData? {
        let date = self.date(from: julianDay)
        let systemType = convertHouseSystem(houseSystem)
        let ayanamsaType = convertAyanamsa(ayanamsa)
        return calculateSiderealHouses(
            date: date,
            latitude: location.latitude,
            longitude: location.longitude,
            system: systemType,
            ayanamsaType: ayanamsaType
        )
    }

    /// Convert Ayanamsa from CalculationSettings to internal AyanamsaType
    private func convertAyanamsa(_ ayanamsa: Ayanamsa) -> AyanamsaType {
        switch ayanamsa {
        case .lahiri, .trueChitra, .fagan:
            return .lahiri
        case .raman:
            return .raman
        case .krishnamurti:
            return .krishnamurti
        }
    }

    /// Convert HouseSystem from CalculationSettings to internal HouseSystemType
    private func convertHouseSystem(_ system: HouseSystem) -> HouseSystemType {
        switch system {
        case .equal, .sriPati, .bhava:
            return .equal
        case .wholeSign:
            return .wholeSign
        case .placidus:
            return .placidus
        case .koch:
            return .koch
        }
    }

    // MARK: - Sunrise/Sunset Calculations

    /// Calculate sunrise time for a given date and location
    /// Uses iterative refinement for accuracy
    func calculateSunrise(date: Date, latitude: Double, longitude: Double, timezone: TimeZone = .current) -> Date? {
        // Get the start of the day in local timezone
        var calendar = Calendar.current
        calendar.timeZone = timezone
        guard let startOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date) else {
            return nil
        }

        // Standard sunrise calculation using solar depression angle
        let sunriseAngle = -0.833 // Standard refraction adjustment in degrees

        // Binary search for sunrise
        return findSunEventTime(
            startOfDay: startOfDay,
            latitude: latitude,
            longitude: longitude,
            targetAltitude: sunriseAngle,
            isRising: true
        )
    }

    /// Calculate sunset time for a given date and location
    func calculateSunset(date: Date, latitude: Double, longitude: Double, timezone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timezone
        guard let startOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date) else {
            return nil
        }

        let sunsetAngle = -0.833

        return findSunEventTime(
            startOfDay: startOfDay,
            latitude: latitude,
            longitude: longitude,
            targetAltitude: sunsetAngle,
            isRising: false
        )
    }

    /// Calculate moonrise time for a given date and location
    func calculateMoonrise(date: Date, latitude: Double, longitude: Double, timezone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timezone
        guard let startOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date) else {
            return nil
        }

        // Moon parallax correction
        let moonriseAngle = 0.125 // Approximate parallax + refraction

        return findMoonEventTime(
            startOfDay: startOfDay,
            latitude: latitude,
            longitude: longitude,
            targetAltitude: moonriseAngle,
            isRising: true
        )
    }

    /// Calculate moonset time for a given date and location
    func calculateMoonset(date: Date, latitude: Double, longitude: Double, timezone: TimeZone = .current) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timezone
        guard let startOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date) else {
            return nil
        }

        let moonsetAngle = 0.125

        return findMoonEventTime(
            startOfDay: startOfDay,
            latitude: latitude,
            longitude: longitude,
            targetAltitude: moonsetAngle,
            isRising: false
        )
    }

    /// Find the time when Sun reaches a target altitude (for sunrise/sunset)
    private func findSunEventTime(
        startOfDay: Date,
        latitude: Double,
        longitude: Double,
        targetAltitude: Double,
        isRising: Bool
    ) -> Date? {
        // Initial estimate based on approximate solar noon
        let solarNoonOffset = -longitude / 15.0 * 3600 // seconds from UTC noon
        let approxNoon = startOfDay.addingTimeInterval(12 * 3600 + solarNoonOffset)

        // Search window: 6 hours before/after noon for rising/setting
        let searchStart = isRising ? startOfDay : approxNoon
        let searchEnd = isRising ? approxNoon : startOfDay.addingTimeInterval(24 * 3600)

        // Binary search for the time when altitude crosses target
        var low = searchStart.timeIntervalSince1970
        var high = searchEnd.timeIntervalSince1970

        for _ in 0..<20 { // 20 iterations for ~1 second accuracy
            let mid = (low + high) / 2
            let midDate = Date(timeIntervalSince1970: mid)
            let altitude = calculateSunAltitude(date: midDate, latitude: latitude, longitude: longitude)

            if isRising {
                if altitude < targetAltitude {
                    low = mid
                } else {
                    high = mid
                }
            } else {
                if altitude > targetAltitude {
                    low = mid
                } else {
                    high = mid
                }
            }
        }

        return Date(timeIntervalSince1970: (low + high) / 2)
    }

    /// Find the time when Moon reaches a target altitude
    private func findMoonEventTime(
        startOfDay: Date,
        latitude: Double,
        longitude: Double,
        targetAltitude: Double,
        isRising: Bool
    ) -> Date? {
        // Moon rises ~50 minutes later each day, search in 30-minute intervals
        var searchTime = startOfDay
        let endTime = startOfDay.addingTimeInterval(25 * 3600) // Search 25 hours

        var previousAltitude: Double?

        while searchTime < endTime {
            let currentAltitude = calculateMoonAltitude(date: searchTime, latitude: latitude, longitude: longitude)

            if let prevAlt = previousAltitude {
                let crossedTarget: Bool
                if isRising {
                    crossedTarget = prevAlt < targetAltitude && currentAltitude >= targetAltitude
                } else {
                    crossedTarget = prevAlt > targetAltitude && currentAltitude <= targetAltitude
                }

                if crossedTarget {
                    // Refine with binary search
                    let refinedTime = refineEventTime(
                        start: searchTime.addingTimeInterval(-1800),
                        end: searchTime,
                        targetAltitude: targetAltitude,
                        isRising: isRising,
                        altitudeFunc: { self.calculateMoonAltitude(date: $0, latitude: latitude, longitude: longitude) }
                    )
                    return refinedTime
                }
            }

            previousAltitude = currentAltitude
            searchTime = searchTime.addingTimeInterval(1800) // 30 minute steps
        }

        return nil
    }

    private func refineEventTime(
        start: Date,
        end: Date,
        targetAltitude: Double,
        isRising: Bool,
        altitudeFunc: (Date) -> Double
    ) -> Date {
        var low = start.timeIntervalSince1970
        var high = end.timeIntervalSince1970

        for _ in 0..<15 {
            let mid = (low + high) / 2
            let altitude = altitudeFunc(Date(timeIntervalSince1970: mid))

            if isRising {
                if altitude < targetAltitude {
                    low = mid
                } else {
                    high = mid
                }
            } else {
                if altitude > targetAltitude {
                    low = mid
                } else {
                    high = mid
                }
            }
        }

        return Date(timeIntervalSince1970: (low + high) / 2)
    }

    /// Calculate Sun's altitude above horizon
    func calculateSunAltitude(date: Date, latitude: Double, longitude: Double) -> Double {
        guard let sunPos = tropicalLongitude(planet: .sun, date: date) else {
            return 0
        }

        // Calculate Local Sidereal Time
        let jd = julianDay(for: date)
        let lst = localSiderealTime(julianDay: jd, longitude: longitude)

        // Sun's right ascension and declination (simplified)
        let sunLong = sunPos.longitude * .pi / 180
        let obliquity = 23.44 * .pi / 180 // Earth's axial tilt

        let rightAscension = atan2(sin(sunLong) * cos(obliquity), cos(sunLong))
        let declination = asin(sin(obliquity) * sin(sunLong))

        // Hour angle
        let hourAngle = lst * .pi / 180 - rightAscension

        // Altitude calculation
        let latRad = latitude * .pi / 180
        let altitude = asin(sin(latRad) * sin(declination) + cos(latRad) * cos(declination) * cos(hourAngle))

        return altitude * 180 / .pi
    }

    /// Calculate Moon's altitude above horizon
    func calculateMoonAltitude(date: Date, latitude: Double, longitude: Double) -> Double {
        guard let moonPos = tropicalLongitude(planet: .moon, date: date) else {
            return 0
        }

        let jd = julianDay(for: date)
        let lst = localSiderealTime(julianDay: jd, longitude: longitude)

        let moonLong = moonPos.longitude * .pi / 180
        let moonLat = moonPos.latitude * .pi / 180
        let obliquity = 23.44 * .pi / 180

        // Moon's RA and Dec with latitude consideration
        let rightAscension = atan2(sin(moonLong) * cos(obliquity) - tan(moonLat) * sin(obliquity), cos(moonLong))
        let declination = asin(sin(moonLat) * cos(obliquity) + cos(moonLat) * sin(obliquity) * sin(moonLong))

        let hourAngle = lst * .pi / 180 - rightAscension
        let latRad = latitude * .pi / 180

        let altitude = asin(sin(latRad) * sin(declination) + cos(latRad) * cos(declination) * cos(hourAngle))

        return altitude * 180 / .pi
    }

    /// Calculate Local Sidereal Time in degrees
    private func localSiderealTime(julianDay: Double, longitude: Double) -> Double {
        let T = (julianDay - 2451545.0) / 36525.0
        var gst = 280.46061837 + 360.98564736629 * (julianDay - 2451545.0) + 0.000387933 * T * T

        // Normalize to 0-360
        gst = gst.truncatingRemainder(dividingBy: 360)
        if gst < 0 { gst += 360 }

        var lst = gst + longitude
        lst = lst.truncatingRemainder(dividingBy: 360)
        if lst < 0 { lst += 360 }

        return lst
    }

    // MARK: - Helper Methods

    private func makePlanetaryPosition<T: CelestialBody>(
        from coord: Coordinate<T>,
        isKetu: Bool
    ) -> PlanetaryPosition {
        var longitude = coord.longitude
        var speed = coord.speedLongitude

        // For Ketu, add 180° to Rahu's position
        if isKetu {
            longitude = (longitude + 180.0).truncatingRemainder(dividingBy: 360.0)
            speed = -speed  // Ketu moves opposite
        }

        return PlanetaryPosition(
            longitude: longitude,
            latitude: coord.latitude,
            distance: coord.distance,
            speedLongitude: speed,
            speedLatitude: coord.speedLatitude,
            speedDistance: coord.speedDistance
        )
    }
}

// MARK: - Supporting Types

/// Raw planetary position data
struct PlanetaryPosition {
    let longitude: Double       // 0-360 degrees
    let latitude: Double        // Celestial latitude
    let distance: Double        // Distance in AU
    let speedLongitude: Double  // Daily motion in longitude (degrees/day)
    let speedLatitude: Double   // Daily motion in latitude
    let speedDistance: Double   // Daily change in distance

    /// Check if planet is retrograde (negative speed)
    var isRetrograde: Bool {
        speedLongitude < 0
    }

    /// Get the sign index (0-11, where 0 = Aries)
    var signIndex: Int {
        Int(longitude / 30.0) % 12
    }

    /// Get the degree within the sign (0-30)
    var degreeInSign: Double {
        longitude.truncatingRemainder(dividingBy: 30.0)
    }

    /// Get the zodiac sign
    var sign: ZodiacSign {
        ZodiacSign.allCases[signIndex]
    }

    /// Get degree, minutes, seconds within sign
    var dms: (degree: Int, minutes: Int, seconds: Int) {
        let totalDegrees = degreeInSign
        let degree = Int(totalDegrees)
        let minutesFraction = (totalDegrees - Double(degree)) * 60
        let minutes = Int(minutesFraction)
        let seconds = Int((minutesFraction - Double(minutes)) * 60)
        return (degree, minutes, seconds)
    }
}

/// House calculation data
struct HouseCalculationData {
    let cusps: [Double]      // 12 house cusps
    let ascendant: Double    // Ascendant degree
    let mc: Double           // Medium Coeli

    var ascendantSignIndex: Int {
        Int(ascendant / 30.0) % 12
    }

    var ascendantDegreeInSign: Double {
        ascendant.truncatingRemainder(dividingBy: 30.0)
    }
}

/// Ayanamsa types
enum AyanamsaType {
    case lahiri
    case raman
    case krishnamurti
}

/// House system types
enum HouseSystemType {
    case equal
    case wholeSign
    case placidus
    case koch
}
