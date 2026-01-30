import Foundation

/// Centralized service for managing all app settings
final class SettingsService {
    static let shared = SettingsService()

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Keys
    private enum Keys {
        static let calculationSettings = "calculationSettings"
        static let notificationSettings = "notificationSettings"
        static let chartStyle = "preferredChartStyle"
        static let appTheme = "appTheme"
    }

    // MARK: - Notification Names
    static let calculationSettingsChanged = Notification.Name("CalculationSettingsChanged")
    static let notificationSettingsChanged = Notification.Name("NotificationSettingsChanged")
    static let chartStyleChanged = Notification.Name("ChartStyleChanged")
    static let appThemeChanged = Notification.Name("AppThemeChanged")

    private init() {}

    // MARK: - Calculation Settings

    /// Current calculation settings (Ayanamsa, House System, Node Type)
    var calculationSettings: CalculationSettings {
        get {
            guard let data = defaults.data(forKey: Keys.calculationSettings),
                  let settings = try? decoder.decode(CalculationSettings.self, from: data) else {
                return .default
            }
            return settings
        }
        set {
            guard let data = try? encoder.encode(newValue) else { return }
            defaults.set(data, forKey: Keys.calculationSettings)
            NotificationCenter.default.post(name: Self.calculationSettingsChanged, object: newValue)
        }
    }

    /// Update Ayanamsa
    func setAyanamsa(_ ayanamsa: Ayanamsa) {
        let current = calculationSettings
        calculationSettings = CalculationSettings(
            ayanamsa: ayanamsa,
            houseSystem: current.houseSystem,
            nodeType: current.nodeType
        )
    }

    /// Update House System
    func setHouseSystem(_ houseSystem: HouseSystem) {
        let current = calculationSettings
        calculationSettings = CalculationSettings(
            ayanamsa: current.ayanamsa,
            houseSystem: houseSystem,
            nodeType: current.nodeType
        )
    }

    /// Update Node Type
    func setNodeType(_ nodeType: NodeType) {
        let current = calculationSettings
        calculationSettings = CalculationSettings(
            ayanamsa: current.ayanamsa,
            houseSystem: current.houseSystem,
            nodeType: nodeType
        )
    }

    // MARK: - Notification Settings

    /// Current notification settings
    var notificationSettings: NotificationSettings {
        get {
            guard let data = defaults.data(forKey: Keys.notificationSettings),
                  let settings = try? decoder.decode(NotificationSettings.self, from: data) else {
                return .default
            }
            return settings
        }
        set {
            guard let data = try? encoder.encode(newValue) else { return }
            defaults.set(data, forKey: Keys.notificationSettings)
            NotificationCenter.default.post(name: Self.notificationSettingsChanged, object: newValue)
        }
    }

    /// Update specific notification setting
    func updateNotificationSettings(_ update: (inout NotificationSettings) -> Void) {
        var settings = notificationSettings
        update(&settings)
        notificationSettings = settings
    }

    // MARK: - Chart Style

    /// Chart display style (North Indian, South Indian)
    var chartStyle: ChartStyle {
        get {
            let rawValue = defaults.string(forKey: Keys.chartStyle) ?? ChartStyle.northIndian.rawValue
            return ChartStyle(rawValue: rawValue) ?? .northIndian
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.chartStyle)
            NotificationCenter.default.post(name: Self.chartStyleChanged, object: newValue)
        }
    }

    // MARK: - App Theme

    /// App appearance theme (Dark, Light, System)
    var appTheme: AppTheme {
        get {
            let rawValue = defaults.string(forKey: Keys.appTheme) ?? AppTheme.dark.rawValue
            return AppTheme(rawValue: rawValue) ?? .dark
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.appTheme)
            NotificationCenter.default.post(name: Self.appThemeChanged, object: newValue)
        }
    }

    // MARK: - Reset

    /// Reset all settings to defaults
    func resetAllSettings() {
        defaults.removeObject(forKey: Keys.calculationSettings)
        defaults.removeObject(forKey: Keys.notificationSettings)
        defaults.removeObject(forKey: Keys.chartStyle)
        defaults.removeObject(forKey: Keys.appTheme)

        NotificationCenter.default.post(name: Self.calculationSettingsChanged, object: CalculationSettings.default)
        NotificationCenter.default.post(name: Self.notificationSettingsChanged, object: NotificationSettings.default)
        NotificationCenter.default.post(name: Self.chartStyleChanged, object: ChartStyle.northIndian)
        NotificationCenter.default.post(name: Self.appThemeChanged, object: AppTheme.dark)
    }
}
