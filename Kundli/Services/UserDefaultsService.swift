import Foundation

/// Service for managing user preferences and flags using UserDefaults
final class UserDefaultsService {
    static let shared = UserDefaultsService()

    private let defaults = UserDefaults.standard

    // MARK: - Keys
    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let preferredChartStyle = "preferredChartStyle"
        static let notificationsEnabled = "notificationsEnabled"
        static let calculationSettings = "calculationSettings"
        static let notificationSettings = "notificationSettings"
    }

    private init() {}

    // MARK: - Onboarding

    /// Whether the user has completed the onboarding flow
    var hasSeenOnboarding: Bool {
        get { defaults.bool(forKey: Keys.hasSeenOnboarding) }
        set { defaults.set(newValue, forKey: Keys.hasSeenOnboarding) }
    }

    /// Mark onboarding as complete
    func setOnboardingComplete() {
        hasSeenOnboarding = true
    }

    /// Reset onboarding (for testing purposes)
    func resetOnboarding() {
        hasSeenOnboarding = false
    }

    // MARK: - Preferences

    /// User's preferred chart style (north, south, east)
    var preferredChartStyle: String {
        get { defaults.string(forKey: Keys.preferredChartStyle) ?? "north" }
        set { defaults.set(newValue, forKey: Keys.preferredChartStyle) }
    }

    /// Whether notifications are enabled
    var notificationsEnabled: Bool {
        get { defaults.bool(forKey: Keys.notificationsEnabled) }
        set { defaults.set(newValue, forKey: Keys.notificationsEnabled) }
    }

    // MARK: - Reset

    /// Reset all user preferences to defaults
    func resetAllPreferences() {
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
    }
}
