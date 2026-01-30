import Foundation
import SwiftUI

/// ViewModel for managing settings state
@Observable
class SettingsViewModel {
    // MARK: - Calculation Settings
    var ayanamsa: Ayanamsa
    var houseSystem: HouseSystem
    var nodeType: NodeType

    // MARK: - Display Settings
    var chartStyle: ChartStyle
    var appTheme: AppTheme

    // MARK: - Notification Settings
    var notificationSettings: NotificationSettings

    // MARK: - UI State
    var isRequestingPermission: Bool = false
    var notificationPermissionGranted: Bool = false

    private let settingsService = SettingsService.shared
    private let notificationService = NotificationService.shared

    init() {
        // Load current settings
        let calculationSettings = settingsService.calculationSettings
        self.ayanamsa = calculationSettings.ayanamsa
        self.houseSystem = calculationSettings.houseSystem
        self.nodeType = calculationSettings.nodeType

        self.chartStyle = settingsService.chartStyle
        self.appTheme = settingsService.appTheme
        self.notificationSettings = settingsService.notificationSettings

        // Check notification permission status
        Task {
            await checkNotificationPermission()
        }
    }

    // MARK: - Calculation Settings Updates

    func updateAyanamsa(_ newValue: Ayanamsa) {
        ayanamsa = newValue
        settingsService.setAyanamsa(newValue)
    }

    func updateHouseSystem(_ newValue: HouseSystem) {
        houseSystem = newValue
        settingsService.setHouseSystem(newValue)
    }

    func updateNodeType(_ newValue: NodeType) {
        nodeType = newValue
        settingsService.setNodeType(newValue)
    }

    // MARK: - Display Settings Updates

    func updateChartStyle(_ newValue: ChartStyle) {
        chartStyle = newValue
        settingsService.chartStyle = newValue
    }

    func updateAppTheme(_ newValue: AppTheme) {
        appTheme = newValue
        settingsService.appTheme = newValue
    }

    // MARK: - Notification Settings Updates

    func togglePanchangNotification(_ enabled: Bool) {
        notificationSettings.panchangEnabled = enabled
        saveNotificationSettings()
    }

    func updatePanchangTime(_ time: Date) {
        notificationSettings.panchangTime = time
        saveNotificationSettings()
    }

    func toggleRahuKaalNotification(_ enabled: Bool) {
        notificationSettings.rahuKaalEnabled = enabled
        saveNotificationSettings()
    }

    func updateRahuKaalMinutesBefore(_ minutes: Int) {
        notificationSettings.rahuKaalMinutesBefore = minutes
        saveNotificationSettings()
    }

    func toggleMuhurtaNotification(_ enabled: Bool) {
        notificationSettings.muhurtaEnabled = enabled
        saveNotificationSettings()
    }

    func toggleDashaTransitionNotification(_ enabled: Bool) {
        notificationSettings.dashaTransitionEnabled = enabled
        saveNotificationSettings()
    }

    func updateDashaTransitionDaysBefore(_ days: Int) {
        notificationSettings.dashaTransitionDaysBefore = days
        saveNotificationSettings()
    }

    private func saveNotificationSettings() {
        settingsService.notificationSettings = notificationSettings
    }

    // MARK: - Notification Permission

    func requestNotificationPermission() async {
        isRequestingPermission = true
        notificationPermissionGranted = await notificationService.requestAuthorization()
        isRequestingPermission = false
    }

    func checkNotificationPermission() async {
        let status = await notificationService.checkAuthorizationStatus()
        await MainActor.run {
            notificationPermissionGranted = (status == .authorized)
        }
    }

    // MARK: - Master Notifications Toggle

    var areAnyNotificationsEnabled: Bool {
        notificationSettings.panchangEnabled ||
        notificationSettings.rahuKaalEnabled ||
        notificationSettings.muhurtaEnabled ||
        notificationSettings.dashaTransitionEnabled
    }

    func disableAllNotifications() {
        notificationSettings = .disabled
        saveNotificationSettings()
    }

    func enableDefaultNotifications() {
        notificationSettings = .default
        saveNotificationSettings()
    }

    // MARK: - Reset

    func resetToDefaults() {
        settingsService.resetAllSettings()

        // Reload settings
        let calculationSettings = settingsService.calculationSettings
        ayanamsa = calculationSettings.ayanamsa
        houseSystem = calculationSettings.houseSystem
        nodeType = calculationSettings.nodeType
        chartStyle = settingsService.chartStyle
        appTheme = settingsService.appTheme
        notificationSettings = settingsService.notificationSettings
    }

    // MARK: - App Info

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}
