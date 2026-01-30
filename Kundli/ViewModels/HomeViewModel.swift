import Foundation
import SwiftUI
import CoreLocation

@Observable
class HomeViewModel {
    var panchang: Panchang
    var dailyHoroscope: DailyHoroscope
    var userSign: ZodiacSign = .scorpio
    var greeting: String
    var isLoading: Bool = false

    // User location for Panchang calculation
    var userLatitude: Double = 28.6139  // Default: New Delhi
    var userLongitude: Double = 77.2090
    var userTimezone: TimeZone = TimeZone(identifier: "Asia/Kolkata") ?? .current

    // Services
    private let panchangService = PanchangCalculationService.shared
    private let muhurtaService = MuhurtaService.shared

    // Muhurta data
    var currentMuhurta: Muhurta?
    var abhijitMuhurta: (start: Date, end: Date)?
    var brahmaMuhurta: (start: Date, end: Date)?

    init() {
        // Initialize with real calculations
        self.panchang = PanchangCalculationService.shared.calculatePanchang(
            date: Date(),
            latitude: 28.6139,
            longitude: 77.2090,
            timezone: TimeZone(identifier: "Asia/Kolkata") ?? .current
        )
        self.dailyHoroscope = MockDataService.shared.dailyHoroscope(for: .scorpio)
        self.greeting = Self.generateGreeting()

        // Calculate muhurtas
        calculateMuhurtas()
    }

    private static func generateGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        case 17..<21:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }

    func refreshData() {
        isLoading = true

        Task {
            let newPanchang = panchangService.calculatePanchang(
                date: Date(),
                latitude: userLatitude,
                longitude: userLongitude,
                timezone: userTimezone
            )

            await MainActor.run {
                self.panchang = newPanchang
                self.dailyHoroscope = MockDataService.shared.dailyHoroscope(for: self.userSign)
                self.calculateMuhurtas()
                self.isLoading = false
            }
        }
    }

    /// Update location for Panchang calculations
    func updateLocation(latitude: Double, longitude: Double, timezone: TimeZone) {
        self.userLatitude = latitude
        self.userLongitude = longitude
        self.userTimezone = timezone
        refreshData()
    }

    /// Calculate Panchang for a specific date
    func calculatePanchang(for date: Date) -> Panchang {
        return panchangService.calculatePanchang(
            date: date,
            latitude: userLatitude,
            longitude: userLongitude,
            timezone: userTimezone
        )
    }

    /// Calculate muhurtas based on current panchang
    private func calculateMuhurtas() {
        let sunrise = panchang.sunriseTime
        let sunset = panchang.sunsetTime

        // Abhijit Muhurta
        abhijitMuhurta = muhurtaService.calculateAbhijitMuhurta(sunrise: sunrise, sunset: sunset)

        // Brahma Muhurta
        brahmaMuhurta = muhurtaService.calculateBrahmaMuhurta(sunrise: sunrise)

        // Current Muhurta
        let nextSunrise = Calendar.current.date(byAdding: .day, value: 1, to: sunrise) ?? sunrise
        currentMuhurta = muhurtaService.getCurrentMuhurta(
            at: Date(),
            sunrise: sunrise,
            sunset: sunset,
            nextSunrise: nextSunrise
        )
    }

    /// Check if Abhijit Muhurta is currently active
    var isAbhijitMuhurtaActive: Bool {
        guard let abhijit = abhijitMuhurta else { return false }
        let now = Date()
        return now >= abhijit.start && now <= abhijit.end
    }

    /// Get formatted Abhijit Muhurta time
    var formattedAbhijitMuhurta: String? {
        guard let abhijit = abhijitMuhurta else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return "\(formatter.string(from: abhijit.start)) - \(formatter.string(from: abhijit.end))"
    }

    /// Get formatted Brahma Muhurta time
    var formattedBrahmaMuhurta: String? {
        guard let brahma = brahmaMuhurta else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return "\(formatter.string(from: brahma.start)) - \(formatter.string(from: brahma.end))"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: Date())
    }

    var formattedSunrise: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: panchang.sunriseTime)
    }

    var formattedSunset: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: panchang.sunsetTime)
    }

    // MARK: - Notification Setup

    /// Setup notifications for a kundli (call when primary kundli loads)
    func setupNotificationsForKundli(_ kundli: SavedKundli) {
        Task {
            // Update location for location-based notifications
            NotificationService.shared.updateUserLocation(from: kundli)

            // Reschedule location-based notifications with new location
            await NotificationService.shared.scheduleNotifications()

            // Schedule dasha notifications if enabled
            let settings = SettingsService.shared.notificationSettings
            if settings.dashaTransitionEnabled {
                await scheduleDashaNotifications(for: kundli)
            }

            // Schedule transit notifications if enabled
            if settings.transitEnabled {
                await NotificationService.shared.scheduleTransitNotifications(for: kundli)
            }
        }
    }

    /// Schedule dasha transition notifications for the given kundli
    private func scheduleDashaNotifications(for kundli: SavedKundli) async {
        let birthDetails = kundli.toBirthDetails()

        do {
            let kundliData = try await KundliGenerationService.shared.generateKundli(
                birthDetails: birthDetails,
                settings: SettingsService.shared.calculationSettings
            )

            let dashaPeriods = kundliData.dashaPeriods

            // Find next upcoming dasha transition
            let now = Date()
            if let nextDasha = dashaPeriods.first(where: { $0.startDate > now }) {
                let settings = SettingsService.shared.notificationSettings
                await NotificationService.shared.scheduleDashaTransitionNotification(
                    dashaLord: nextDasha.planet,
                    transitionDate: nextDasha.startDate,
                    daysBefore: settings.dashaTransitionDaysBefore,
                    kundliId: kundli.id
                )
            }
        } catch {
            print("Failed to schedule dasha notifications: \(error.localizedDescription)")
        }
    }
}
