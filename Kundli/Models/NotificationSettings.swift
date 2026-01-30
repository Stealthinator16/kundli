import Foundation

/// Settings for notification preferences
struct NotificationSettings: Codable, Equatable {
    /// Whether daily Panchang notifications are enabled
    var panchangEnabled: Bool

    /// Time to receive daily Panchang notification
    var panchangTime: Date

    /// Whether Rahu Kaal alert notifications are enabled
    var rahuKaalEnabled: Bool

    /// Minutes before Rahu Kaal to send alert
    var rahuKaalMinutesBefore: Int

    /// Whether Muhurta reminder notifications are enabled
    var muhurtaEnabled: Bool

    /// Whether Dasha transition notifications are enabled
    var dashaTransitionEnabled: Bool

    /// Days before Dasha transition to send notification
    var dashaTransitionDaysBefore: Int

    /// Whether transit notifications are enabled
    var transitEnabled: Bool

    /// Days before major transit to send notification
    var transitDaysBefore: Int

    init(
        panchangEnabled: Bool = true,
        panchangTime: Date = Calendar.current.date(from: DateComponents(hour: 6, minute: 0)) ?? Date(),
        rahuKaalEnabled: Bool = true,
        rahuKaalMinutesBefore: Int = 15,
        muhurtaEnabled: Bool = false,
        dashaTransitionEnabled: Bool = true,
        dashaTransitionDaysBefore: Int = 7,
        transitEnabled: Bool = true,
        transitDaysBefore: Int = 30
    ) {
        self.panchangEnabled = panchangEnabled
        self.panchangTime = panchangTime
        self.rahuKaalEnabled = rahuKaalEnabled
        self.rahuKaalMinutesBefore = rahuKaalMinutesBefore
        self.muhurtaEnabled = muhurtaEnabled
        self.dashaTransitionEnabled = dashaTransitionEnabled
        self.dashaTransitionDaysBefore = dashaTransitionDaysBefore
        self.transitEnabled = transitEnabled
        self.transitDaysBefore = transitDaysBefore
    }

    /// Default notification settings
    static let `default` = NotificationSettings()

    /// All notifications disabled
    static let disabled = NotificationSettings(
        panchangEnabled: false,
        rahuKaalEnabled: false,
        muhurtaEnabled: false,
        dashaTransitionEnabled: false,
        transitEnabled: false
    )
}

// MARK: - Notification Categories
enum NotificationCategory: String, CaseIterable {
    case panchang = "panchang"
    case rahuKaal = "rahu_kaal"
    case muhurta = "muhurta"
    case dashaTransition = "dasha_transition"
    case transit = "transit"
    case customReminder = "custom_reminder"

    var title: String {
        switch self {
        case .panchang: return "Daily Panchang"
        case .rahuKaal: return "Rahu Kaal Alert"
        case .muhurta: return "Muhurta Reminder"
        case .dashaTransition: return "Dasha Transition"
        case .transit: return "Transit Alert"
        case .customReminder: return "Custom Reminder"
        }
    }

    var description: String {
        switch self {
        case .panchang:
            return "Daily summary of Tithi, Nakshatra, Yoga, and Karana"
        case .rahuKaal:
            return "Alert before inauspicious Rahu Kaal begins"
        case .muhurta:
            return "Reminders for auspicious Muhurtas like Abhijit"
        case .dashaTransition:
            return "Notification when major Dasha periods change"
        case .transit:
            return "Alerts for major planetary transits like Sade-Sati"
        case .customReminder:
            return "Your personal reminders for dates and events"
        }
    }

    var icon: String {
        switch self {
        case .panchang: return "calendar.badge.clock"
        case .rahuKaal: return "exclamationmark.triangle.fill"
        case .muhurta: return "sparkles"
        case .dashaTransition: return "arrow.triangle.2.circlepath"
        case .transit: return "globe"
        case .customReminder: return "bell.fill"
        }
    }
}
