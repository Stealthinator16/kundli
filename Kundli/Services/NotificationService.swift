import Foundation
import UserNotifications
import os

/// Service for managing local notifications
final class NotificationService {
    static let shared = NotificationService()

    private let notificationCenter = UNUserNotificationCenter.current()
    private let settingsService = SettingsService.shared

    /// User's location for location-based notifications
    private var userLocation: (latitude: Double, longitude: Double, timezone: TimeZone)?

    /// Default location (Delhi) when user location is not set
    private let defaultLocation = (
        latitude: 28.6139,
        longitude: 77.2090,
        timezone: TimeZone(identifier: "Asia/Kolkata") ?? .current
    )

    private init() {
        // Observe notification settings changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNotificationSettingsChanged),
            name: SettingsService.notificationSettingsChanged,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Permission

    /// Request notification permissions
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                await scheduleNotifications()
            }
            return granted
        } catch {
            AppLogger.notifications.error("Notification authorization error: \(error.localizedDescription)")
            return false
        }
    }

    /// Check current authorization status
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Location

    /// Update user location from a saved kundli
    func updateUserLocation(from kundli: SavedKundli) {
        let timezone = TimeZone(identifier: kundli.timezone) ?? defaultLocation.timezone
        userLocation = (
            latitude: kundli.latitude,
            longitude: kundli.longitude,
            timezone: timezone
        )
    }

    /// Update user location with explicit values
    func updateUserLocation(latitude: Double, longitude: Double, timezone: TimeZone) {
        userLocation = (latitude: latitude, longitude: longitude, timezone: timezone)
    }

    /// Get current location (user's or default)
    private var currentLocation: (latitude: Double, longitude: Double, timezone: TimeZone) {
        userLocation ?? defaultLocation
    }

    // MARK: - Scheduling

    /// Schedule all enabled notifications based on current settings
    func scheduleNotifications() async {
        let settings = settingsService.notificationSettings

        // Remove all existing scheduled notifications
        notificationCenter.removeAllPendingNotificationRequests()

        // Schedule Panchang notification
        if settings.panchangEnabled {
            await scheduleDailyPanchangNotification(at: settings.panchangTime)
        }

        // Schedule Rahu Kaal notifications
        if settings.rahuKaalEnabled {
            await scheduleRahuKaalNotifications(minutesBefore: settings.rahuKaalMinutesBefore)
        }

        // Schedule Muhurta notifications
        if settings.muhurtaEnabled {
            await scheduleMuhurtaNotifications()
        }

        // Note: Dasha transition notifications require user's kundli data
        // and will be scheduled when a kundli is loaded
    }

    /// Schedule daily Panchang notification
    private func scheduleDailyPanchangNotification(at time: Date) async {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)

        var dateComponents = DateComponents()
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let content = UNMutableNotificationContent()
        content.title = "Daily Panchang"
        content.body = "View today's Tithi, Nakshatra, Yoga, and Karana for auspicious timings."
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.panchang.rawValue

        let request = UNNotificationRequest(
            identifier: "daily-panchang",
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
        } catch {
            AppLogger.notifications.error("Failed to schedule Panchang notification: \(error.localizedDescription)")
        }
    }

    /// Schedule Rahu Kaal alert notifications for the week
    private func scheduleRahuKaalNotifications(minutesBefore: Int) async {
        let calendar = Calendar.current
        let panchangService = PanchangCalculationService.shared

        // Schedule for next 7 days
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()) else { continue }

            // Get Rahu Kaal times for this day using user location
            let location = currentLocation
            let panchang = panchangService.calculatePanchang(
                date: date,
                latitude: location.latitude,
                longitude: location.longitude,
                timezone: location.timezone
            )

            // Calculate notification time
            guard let notificationTime = calendar.date(
                byAdding: .minute,
                value: -minutesBefore,
                to: panchang.rahuKaalStart
            ) else { continue }

            // Skip if notification time is in the past
            if notificationTime < Date() { continue }

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationTime),
                repeats: false
            )

            let content = UNMutableNotificationContent()
            content.title = "Rahu Kaal Alert"
            content.body = "Rahu Kaal begins in \(minutesBefore) minutes. Avoid starting new activities."
            content.sound = .default
            content.categoryIdentifier = NotificationCategory.rahuKaal.rawValue

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let identifier = "rahu-kaal-\(dateFormatter.string(from: date))"

            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )

            do {
                try await notificationCenter.add(request)
            } catch {
                AppLogger.notifications.error("Failed to schedule Rahu Kaal notification: \(error.localizedDescription)")
            }
        }
    }

    /// Schedule Muhurta notifications (Abhijit and Brahma Muhurta)
    private func scheduleMuhurtaNotifications() async {
        let calendar = Calendar.current
        let muhurtaService = MuhurtaService.shared

        // Schedule for next 7 days
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()) else { continue }

            // Get Muhurta times using user location
            let location = currentLocation
            let panchang = PanchangCalculationService.shared.calculatePanchang(
                date: date,
                latitude: location.latitude,
                longitude: location.longitude,
                timezone: location.timezone
            )

            // Schedule Abhijit Muhurta notification
            if let abhijitTime = muhurtaService.calculateAbhijitMuhurta(
                sunrise: panchang.sunriseTime,
                sunset: panchang.sunsetTime
            ) {
                let notificationTime = calendar.date(byAdding: .minute, value: -5, to: abhijitTime.start) ?? abhijitTime.start

                if notificationTime > Date() {
                    await scheduleAbhijitNotification(for: notificationTime, dayOffset: dayOffset)
                }
            }

            // Schedule Brahma Muhurta notification (early morning)
            let brahmaMuhurta = muhurtaService.calculateBrahmaMuhurta(sunrise: panchang.sunriseTime)
            let notificationTime = calendar.date(byAdding: .minute, value: -5, to: brahmaMuhurta.start) ?? brahmaMuhurta.start

            if notificationTime > Date() {
                await scheduleBrahmaMuhurtaNotification(for: notificationTime, dayOffset: dayOffset)
            }
        }
    }

    private func scheduleAbhijitNotification(for time: Date, dayOffset: Int) async {
        let calendar = Calendar.current
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: time),
            repeats: false
        )

        let content = UNMutableNotificationContent()
        content.title = "Abhijit Muhurta"
        content.body = "The most auspicious time of the day begins in 5 minutes. Ideal for important activities."
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.muhurta.rawValue

        let request = UNNotificationRequest(
            identifier: "abhijit-muhurta-\(dayOffset)",
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
        } catch {
            AppLogger.notifications.error("Failed to schedule Abhijit notification: \(error.localizedDescription)")
        }
    }

    private func scheduleBrahmaMuhurtaNotification(for time: Date, dayOffset: Int) async {
        let calendar = Calendar.current
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: time),
            repeats: false
        )

        let content = UNMutableNotificationContent()
        content.title = "Brahma Muhurta"
        content.body = "The sacred pre-dawn period begins soon. Ideal for meditation and spiritual practice."
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.muhurta.rawValue

        let request = UNNotificationRequest(
            identifier: "brahma-muhurta-\(dayOffset)",
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
        } catch {
            AppLogger.notifications.error("Failed to schedule Brahma Muhurta notification: \(error.localizedDescription)")
        }
    }

    // MARK: - Dasha Transition Notifications

    /// Schedule Dasha transition notification for a specific kundli
    func scheduleDashaTransitionNotification(
        dashaLord: String,
        transitionDate: Date,
        daysBefore: Int,
        kundliId: UUID? = nil
    ) async {
        let calendar = Calendar.current

        guard let notificationDate = calendar.date(
            byAdding: .day,
            value: -daysBefore,
            to: transitionDate
        ) else { return }

        // Skip if notification date is in the past
        if notificationDate < Date() { return }

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate),
            repeats: false
        )

        let content = UNMutableNotificationContent()
        content.title = "Dasha Transition"
        content.body = "\(dashaLord) Mahadasha begins in \(daysBefore) days. Check your kundli for detailed predictions."
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.dashaTransition.rawValue

        if let kundliId = kundliId {
            content.userInfo = ["kundliId": kundliId.uuidString]
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let identifier = "dasha-transition-\(dateFormatter.string(from: transitionDate))"

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
        } catch {
            AppLogger.notifications.error("Failed to schedule Dasha notification: \(error.localizedDescription)")
        }
    }

    // MARK: - Transit Notifications

    /// Schedule transit notifications for a saved kundli
    /// Checks for upcoming Sade-Sati and major Jupiter transit changes
    func scheduleTransitNotifications(for savedKundli: SavedKundli) async {
        let settings = settingsService.notificationSettings
        guard settings.transitEnabled else { return }

        let birthDetails = savedKundli.toBirthDetails()

        do {
            let kundliData = try await KundliGenerationService.shared.generateKundli(
                birthDetails: birthDetails,
                settings: SettingsService.shared.calculationSettings
            )

            // Get natal Moon sign for Sade-Sati calculation
            guard let moonPlanet = kundliData.planets.first(where: { $0.name == "Moon" }),
                  let moonSign = ZodiacSign(rawValue: moonPlanet.sign) else {
                return
            }

            // Check for upcoming Sade-Sati phases
            await scheduleSadeSatiNotifications(
                moonSign: moonSign,
                kundliId: savedKundli.id,
                daysBefore: settings.transitDaysBefore
            )

            // Check for upcoming Jupiter transit
            await scheduleJupiterTransitNotifications(
                kundliId: savedKundli.id,
                daysBefore: settings.transitDaysBefore
            )

        } catch {
            AppLogger.notifications.error("Failed to generate kundli for transit notifications: \(error.localizedDescription)")
        }
    }

    /// Schedule Sade-Sati related notifications
    private func scheduleSadeSatiNotifications(
        moonSign: ZodiacSign,
        kundliId: UUID,
        daysBefore: Int
    ) async {
        // Sade-Sati occurs when Saturn transits:
        // - 12th house from Moon (beginning)
        // - 1st house (Moon sign - peak)
        // - 2nd house from Moon (ending)

        // Get current Saturn position
        let transitService = TransitService.shared
        let currentTransits = transitService.calculateCurrentTransits(
            natalPositions: [],
            natalMoonSign: moonSign.number - 1
        )

        // Find Saturn in current transits
        guard let saturnTransit = currentTransits.transitPositions.first(where: {
            $0.planet == "Saturn"
        }) else { return }

        // Calculate Sade-Sati status
        let saturnSignIndex = saturnTransit.signIndex
        let moonSignIndex = moonSign.number - 1

        // Calculate relative position
        let relativePosition = (saturnSignIndex - moonSignIndex + 12) % 12

        // Check if Sade-Sati is about to begin (Saturn entering 12th from Moon)
        if relativePosition == 10 { // One sign before 12th house
            // Saturn is about to enter Sade-Sati zone
            await scheduleTransitNotification(
                title: "Sade-Sati Approaching",
                body: "Saturn is approaching the 12th house from your Moon sign. The 7.5 year Sade-Sati period may begin soon.",
                identifier: "sade-sati-approach-\(kundliId.uuidString)",
                kundliId: kundliId,
                daysBefore: daysBefore
            )
        } else if relativePosition == 11 {
            // Saturn is in 12th house - Sade-Sati has begun
            await scheduleTransitNotification(
                title: "Sade-Sati Phase 1",
                body: "Saturn has entered the 12th house from your Moon. The first phase of Sade-Sati has begun - a period of inner transformation.",
                identifier: "sade-sati-phase1-\(kundliId.uuidString)",
                kundliId: kundliId,
                daysBefore: 0
            )
        } else if relativePosition == 0 {
            // Saturn is over Moon sign - peak phase
            await scheduleTransitNotification(
                title: "Sade-Sati Peak Phase",
                body: "Saturn is transiting your Moon sign. This is the peak phase of Sade-Sati - focus on patience and perseverance.",
                identifier: "sade-sati-peak-\(kundliId.uuidString)",
                kundliId: kundliId,
                daysBefore: 0
            )
        }
    }

    /// Schedule Jupiter transit notifications
    private func scheduleJupiterTransitNotifications(
        kundliId: UUID,
        daysBefore: Int
    ) async {
        // Jupiter transits are generally benefic
        // Schedule notification when Jupiter changes signs

        let transitService = TransitService.shared
        let currentTransits = transitService.calculateCurrentTransits(
            natalPositions: [],
            natalMoonSign: 0
        )

        guard let jupiterTransit = currentTransits.transitPositions.first(where: {
            $0.planet == "Jupiter"
        }) else { return }

        // Get the sign Jupiter is in
        let jupiterSign = ZodiacSign.allCases[jupiterTransit.signIndex]

        await scheduleTransitNotification(
            title: "Jupiter Transit Update",
            body: "Jupiter is currently transiting \(jupiterSign.rawValue). Review how this transit affects your chart.",
            identifier: "jupiter-transit-\(kundliId.uuidString)",
            kundliId: kundliId,
            daysBefore: daysBefore
        )
    }

    /// Helper to schedule a transit notification
    private func scheduleTransitNotification(
        title: String,
        body: String,
        identifier: String,
        kundliId: UUID,
        daysBefore: Int
    ) async {
        let calendar = Calendar.current

        // Schedule for daysBefore from now, at 9 AM
        var notificationDate = Date()
        if daysBefore > 0 {
            notificationDate = calendar.date(byAdding: .day, value: daysBefore, to: Date()) ?? Date()
        }

        var components = calendar.dateComponents([.year, .month, .day], from: notificationDate)
        components.hour = 9
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.transit.rawValue
        content.userInfo = ["kundliId": kundliId.uuidString]

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
        } catch {
            AppLogger.notifications.error("Failed to schedule transit notification: \(error.localizedDescription)")
        }
    }

    // MARK: - Custom Reminders

    /// Schedule a custom reminder notification
    func scheduleCustomReminder(_ reminder: CustomReminder) async {
        let calendar = Calendar.current

        // Don't schedule if date is in the past and not repeating
        if reminder.reminderDate < Date() && reminder.repeatInterval == .none {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.notes ?? "Reminder"
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.customReminder.rawValue
        content.userInfo = ["reminderId": reminder.id.uuidString]

        let trigger: UNNotificationTrigger

        if reminder.repeatInterval == .none {
            // One-time notification
            let components = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: reminder.reminderDate
            )
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        } else {
            // Repeating notification
            var components: DateComponents

            switch reminder.repeatInterval {
            case .daily:
                components = calendar.dateComponents([.hour, .minute], from: reminder.reminderDate)
            case .weekly:
                components = calendar.dateComponents([.weekday, .hour, .minute], from: reminder.reminderDate)
            case .monthly:
                components = calendar.dateComponents([.day, .hour, .minute], from: reminder.reminderDate)
            case .yearly:
                components = calendar.dateComponents([.month, .day, .hour, .minute], from: reminder.reminderDate)
            case .none:
                components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.reminderDate)
            }

            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: reminder.repeatInterval != .none)
        }

        let request = UNNotificationRequest(
            identifier: reminder.notificationIdentifier,
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
        } catch {
            AppLogger.notifications.error("Failed to schedule custom reminder: \(error.localizedDescription)")
        }
    }

    /// Cancel a custom reminder notification
    func cancelCustomReminder(_ reminder: CustomReminder) async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminder.notificationIdentifier])
    }

    /// Reschedule all custom reminders (e.g., after app restart)
    func rescheduleAllCustomReminders(_ reminders: [CustomReminder]) async {
        for reminder in reminders where reminder.isActive && !reminder.isPast {
            await scheduleCustomReminder(reminder)
        }
    }

    // MARK: - Birthday Reminders

    /// Schedule a birthday reminder for a saved kundli
    /// The reminder will trigger on the person's birthday every year
    func scheduleBirthdayReminder(for savedKundli: SavedKundli, notifyDaysBefore: Int = 0) async {
        let calendar = Calendar.current

        // Get birth date components
        let birthMonth = calendar.component(.month, from: savedKundli.dateOfBirth)
        let birthDay = calendar.component(.day, from: savedKundli.dateOfBirth)

        // Calculate the next birthday
        var nextBirthdayComponents = DateComponents()
        nextBirthdayComponents.month = birthMonth
        nextBirthdayComponents.day = birthDay - notifyDaysBefore
        nextBirthdayComponents.hour = 9  // Notify at 9 AM
        nextBirthdayComponents.minute = 0

        // Adjust for days before (handle month boundary)
        if notifyDaysBefore > 0 && birthDay - notifyDaysBefore <= 0 {
            // Need to go to previous month
            let adjustedMonth = birthMonth == 1 ? 12 : birthMonth - 1
            let daysInPreviousMonth = calendar.range(of: .day, in: .month, for: calendar.date(from: DateComponents(month: adjustedMonth))!)?.count ?? 30
            nextBirthdayComponents.month = adjustedMonth
            nextBirthdayComponents.day = daysInPreviousMonth + (birthDay - notifyDaysBefore)
        }

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: nextBirthdayComponents,
            repeats: true  // Repeat yearly
        )

        let content = UNMutableNotificationContent()

        if notifyDaysBefore == 0 {
            content.title = "Birthday Today!"
            content.body = "Today is \(savedKundli.name)'s birthday! View their kundli for birthday predictions."
        } else if notifyDaysBefore == 1 {
            content.title = "Birthday Tomorrow"
            content.body = "\(savedKundli.name)'s birthday is tomorrow! Check their yearly predictions."
        } else {
            content.title = "Upcoming Birthday"
            content.body = "\(savedKundli.name)'s birthday is in \(notifyDaysBefore) days."
        }

        content.sound = .default
        content.categoryIdentifier = NotificationCategory.customReminder.rawValue
        content.userInfo = [
            "kundliId": savedKundli.id.uuidString,
            "type": "birthday"
        ]

        let identifier = "birthday-\(savedKundli.id.uuidString)"

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
        } catch {
            AppLogger.notifications.error("Failed to schedule birthday reminder: \(error.localizedDescription)")
        }
    }

    /// Cancel birthday reminder for a kundli
    func cancelBirthdayReminder(for kundliId: UUID) {
        let identifier = "birthday-\(kundliId.uuidString)"
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    /// Check if birthday reminder exists for a kundli
    func hasBirthdayReminder(for kundliId: UUID) async -> Bool {
        let identifier = "birthday-\(kundliId.uuidString)"
        let requests = await notificationCenter.pendingNotificationRequests()
        return requests.contains { $0.identifier == identifier }
    }

    /// Schedule birthday reminders for all saved kundlis
    func scheduleAllBirthdayReminders(_ savedKundlis: [SavedKundli]) async {
        for kundli in savedKundlis {
            await scheduleBirthdayReminder(for: kundli)
        }
    }

    // MARK: - Management

    /// Remove all pending notifications
    func removeAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    /// Remove notifications by category
    func removeNotifications(for category: NotificationCategory) {
        notificationCenter.getPendingNotificationRequests { requests in
            let identifiersToRemove = requests
                .filter { $0.content.categoryIdentifier == category.rawValue }
                .map { $0.identifier }

            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
    }

    /// Get pending notification count
    func getPendingNotificationCount() async -> Int {
        let requests = await notificationCenter.pendingNotificationRequests()
        return requests.count
    }

    // MARK: - Settings Observer

    @objc private func handleNotificationSettingsChanged(_ notification: Notification) {
        Task {
            await scheduleNotifications()
        }
    }
}
