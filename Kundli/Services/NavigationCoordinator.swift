import SwiftUI
import Combine

/// Centralized navigation coordinator for handling deep links and tab selection
@Observable
final class NavigationCoordinator {
    static let shared = NavigationCoordinator()

    /// Currently selected tab
    var selectedTab: TabItem = .chart

    /// Pending deep link to be handled by the destination view
    var pendingDeepLink: DeepLink?

    /// Navigation path for home tab
    var homeNavigationPath = NavigationPath()

    /// Navigation path for panchang tab
    var panchangNavigationPath = NavigationPath()

    /// Navigation path for profile tab
    var profileNavigationPath = NavigationPath()

    private init() {}

    /// Handle a deep link by navigating to the appropriate destination
    func handle(_ deepLink: DeepLink) {
        switch deepLink {
        case .tab(let tab):
            selectedTab = tab

        case .panchang, .rahuKaal:
            selectedTab = .panchang

        case .dasha:
            selectedTab = .chart
            pendingDeepLink = deepLink

        case .transit:
            selectedTab = .chart
            pendingDeepLink = deepLink

        case .settings, .notificationSettings:
            selectedTab = .profile
            pendingDeepLink = deepLink
        }
    }

    /// Clear the pending deep link after it has been handled
    func clearPendingDeepLink() {
        pendingDeepLink = nil
    }

    /// Reset all navigation paths
    func resetNavigation() {
        homeNavigationPath = NavigationPath()
        panchangNavigationPath = NavigationPath()
        profileNavigationPath = NavigationPath()
        pendingDeepLink = nil
    }
}

// MARK: - Notification Name Extension

extension Notification.Name {
    /// Posted when a deep link needs to be handled
    static let handleDeepLink = Notification.Name("handleDeepLink")
}
