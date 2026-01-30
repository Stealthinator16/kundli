import Foundation
import SwiftData

/// SwiftData model for custom user reminders
@Model
final class CustomReminder {
    /// Unique identifier
    var id: UUID

    /// Title of the reminder
    var title: String

    /// Optional description/notes
    var notes: String?

    /// Date and time for the reminder
    var reminderDate: Date

    /// Repeat interval (none, daily, weekly, monthly, yearly)
    var repeatInterval: ReminderRepeatInterval

    /// Whether the notification has been scheduled
    var isScheduled: Bool

    /// Whether the reminder is active
    var isActive: Bool

    /// Category for grouping
    var category: ReminderCategory

    /// Associated Kundli ID (optional)
    var kundliId: UUID?

    /// When the reminder was created
    var createdAt: Date

    /// When the reminder was last updated
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        notes: String? = nil,
        reminderDate: Date,
        repeatInterval: ReminderRepeatInterval = .none,
        category: ReminderCategory = .general,
        kundliId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.reminderDate = reminderDate
        self.repeatInterval = repeatInterval
        self.isScheduled = false
        self.isActive = true
        self.category = category
        self.kundliId = kundliId
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    /// Notification identifier for this reminder
    var notificationIdentifier: String {
        "custom-reminder-\(id.uuidString)"
    }

    /// Formatted date string
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: reminderDate)
    }

    /// Formatted time string
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: reminderDate)
    }

    /// Whether the reminder is in the past
    var isPast: Bool {
        reminderDate < Date() && repeatInterval == .none
    }

    /// Whether the reminder is today
    var isToday: Bool {
        Calendar.current.isDateInToday(reminderDate)
    }

    /// Time until reminder (or nil if past)
    var timeUntil: String? {
        guard reminderDate > Date() else { return nil }

        let components = Calendar.current.dateComponents(
            [.day, .hour, .minute],
            from: Date(),
            to: reminderDate
        )

        if let days = components.day, days > 0 {
            return "\(days) day\(days == 1 ? "" : "s")"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s")"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes) min"
        }
        return "Soon"
    }
}

// MARK: - Repeat Interval

enum ReminderRepeatInterval: String, Codable, CaseIterable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"

    var description: String {
        switch self {
        case .none: return "Does not repeat"
        case .daily: return "Every day"
        case .weekly: return "Every week"
        case .monthly: return "Every month"
        case .yearly: return "Every year"
        }
    }

    var icon: String {
        switch self {
        case .none: return "calendar"
        case .daily: return "sun.max"
        case .weekly: return "calendar.badge.clock"
        case .monthly: return "calendar.badge.plus"
        case .yearly: return "sparkles"
        }
    }

    /// Convert to calendar component for scheduling
    var calendarComponent: Calendar.Component? {
        switch self {
        case .none: return nil
        case .daily: return .day
        case .weekly: return .weekOfYear
        case .monthly: return .month
        case .yearly: return .year
        }
    }
}

// MARK: - Reminder Category

enum ReminderCategory: String, Codable, CaseIterable {
    case general = "General"
    case puja = "Puja"
    case vrat = "Vrat/Fast"
    case muhurta = "Muhurta"
    case transit = "Transit"
    case birthday = "Birthday"
    case anniversary = "Anniversary"

    var icon: String {
        switch self {
        case .general: return "bell.fill"
        case .puja: return "flame.fill"
        case .vrat: return "leaf.fill"
        case .muhurta: return "clock.fill"
        case .transit: return "globe"
        case .birthday: return "gift.fill"
        case .anniversary: return "heart.fill"
        }
    }

    var color: String {
        switch self {
        case .general: return "kundliPrimary"
        case .puja: return "orange"
        case .vrat: return "green"
        case .muhurta: return "blue"
        case .transit: return "purple"
        case .birthday: return "pink"
        case .anniversary: return "red"
        }
    }
}
