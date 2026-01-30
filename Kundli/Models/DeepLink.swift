import Foundation

/// Deep link destinations for navigation from notifications
enum DeepLink: Equatable {
    case tab(TabItem)
    case panchang
    case rahuKaal
    case dasha(kundliId: UUID?)
    case transit(kundliId: UUID?)
    case settings
    case notificationSettings

    /// Parse deep link from notification category and user info
    static func from(category: String, userInfo: [AnyHashable: Any]?) -> DeepLink? {
        switch category {
        case NotificationCategory.panchang.rawValue:
            return .panchang
        case NotificationCategory.rahuKaal.rawValue:
            return .rahuKaal
        case NotificationCategory.muhurta.rawValue:
            return .panchang
        case NotificationCategory.dashaTransition.rawValue:
            if let idString = userInfo?["kundliId"] as? String,
               let id = UUID(uuidString: idString) {
                return .dasha(kundliId: id)
            }
            return .dasha(kundliId: nil)
        case NotificationCategory.transit.rawValue:
            if let idString = userInfo?["kundliId"] as? String,
               let id = UUID(uuidString: idString) {
                return .transit(kundliId: id)
            }
            return .transit(kundliId: nil)
        default:
            return nil
        }
    }
}
