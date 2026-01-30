import Foundation
import SwiftData
import CloudKit
import Combine

/// Service for managing iCloud sync functionality
/// Handles sync status monitoring, error handling, and user preferences
@Observable
final class SyncService {
    static let shared = SyncService()

    // MARK: - Published Properties

    /// Current sync status
    private(set) var syncStatus: SyncStatus = .notStarted

    /// Last sync date
    private(set) var lastSyncDate: Date?

    /// Whether iCloud is available
    private(set) var isCloudAvailable: Bool = false

    /// Current iCloud account status
    private(set) var accountStatus: CKAccountStatus = .couldNotDetermine

    /// Error message if sync failed
    private(set) var lastError: String?

    /// Number of pending changes to sync
    private(set) var pendingChangesCount: Int = 0

    // MARK: - Settings

    /// Whether sync is enabled (user preference)
    var isSyncEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.syncEnabled) }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.syncEnabled)
            if newValue {
                startMonitoring()
            } else {
                stopMonitoring()
            }
            NotificationCenter.default.post(name: Self.syncSettingsChanged, object: nil)
        }
    }

    /// Whether to sync over cellular data
    var syncOverCellular: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.syncOverCellular) }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.syncOverCellular)
            NotificationCenter.default.post(name: Self.syncSettingsChanged, object: nil)
        }
    }

    // MARK: - Private Properties

    private var accountStatusObserver: NSObjectProtocol?
    private var networkMonitor: Any?
    private var cancellables = Set<AnyCancellable>()
    private let container = CKContainer.default()

    // MARK: - Keys

    private enum Keys {
        static let syncEnabled = "com.kundli.sync.enabled"
        static let syncOverCellular = "com.kundli.sync.overCellular"
        static let lastSyncDate = "com.kundli.sync.lastSyncDate"
    }

    // MARK: - Notifications

    static let syncStatusChanged = Notification.Name("SyncService.syncStatusChanged")
    static let syncSettingsChanged = Notification.Name("SyncService.syncSettingsChanged")
    static let syncCompleted = Notification.Name("SyncService.syncCompleted")
    static let syncFailed = Notification.Name("SyncService.syncFailed")

    // MARK: - Initialization

    private init() {
        loadLastSyncDate()

        // Set default value for sync enabled if not set
        if !UserDefaults.standard.bool(forKey: Keys.syncEnabled) &&
           UserDefaults.standard.object(forKey: Keys.syncEnabled) == nil {
            UserDefaults.standard.set(true, forKey: Keys.syncEnabled)
        }

        // Check initial cloud status
        Task {
            await checkCloudStatus()
        }

        startMonitoring()
    }

    // MARK: - Public Methods

    /// Check current iCloud account status
    func checkCloudStatus() async {
        do {
            let status = try await container.accountStatus()
            await MainActor.run {
                self.accountStatus = status
                self.isCloudAvailable = status == .available

                if status == .available {
                    self.syncStatus = .syncing
                    // SwiftData with CloudKit handles sync automatically
                    // We just need to monitor the status
                    self.updateSyncStatus(.synced)
                } else {
                    self.updateSyncStatus(.unavailable)
                    self.lastError = self.accountStatusMessage(status)
                }
            }
        } catch {
            await MainActor.run {
                self.isCloudAvailable = false
                self.syncStatus = .error
                self.lastError = error.localizedDescription
            }
        }
    }

    /// Force a sync refresh
    func refreshSync() async {
        guard isSyncEnabled && isCloudAvailable else {
            updateSyncStatus(.unavailable)
            return
        }

        updateSyncStatus(.syncing)

        // With SwiftData + CloudKit, sync is automatic
        // This triggers a check and updates status
        await checkCloudStatus()

        if isCloudAvailable {
            // Record sync time
            lastSyncDate = Date()
            saveLastSyncDate()
            updateSyncStatus(.synced)
            NotificationCenter.default.post(name: Self.syncCompleted, object: nil)
        }
    }

    /// Get user-friendly description of current status
    var statusDescription: String {
        switch syncStatus {
        case .notStarted:
            return "Sync not started"
        case .syncing:
            return "Syncing..."
        case .synced:
            if let date = lastSyncDate {
                return "Last synced \(relativeTimeString(from: date))"
            }
            return "Synced"
        case .error:
            return lastError ?? "Sync error"
        case .unavailable:
            return accountStatusMessage(accountStatus)
        case .disabled:
            return "Sync disabled"
        }
    }

    /// Get user-friendly iCloud account status message
    func accountStatusMessage(_ status: CKAccountStatus) -> String {
        switch status {
        case .available:
            return "iCloud available"
        case .noAccount:
            return "No iCloud account. Sign in to iCloud in Settings."
        case .restricted:
            return "iCloud access restricted"
        case .couldNotDetermine:
            return "Unable to determine iCloud status"
        case .temporarilyUnavailable:
            return "iCloud temporarily unavailable"
        @unknown default:
            return "Unknown iCloud status"
        }
    }

    // MARK: - Private Methods

    private func startMonitoring() {
        // Monitor iCloud account changes
        accountStatusObserver = NotificationCenter.default.addObserver(
            forName: .CKAccountChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task {
                await self?.checkCloudStatus()
            }
        }
    }

    private func stopMonitoring() {
        if let observer = accountStatusObserver {
            NotificationCenter.default.removeObserver(observer)
            accountStatusObserver = nil
        }
    }

    private func updateSyncStatus(_ status: SyncStatus) {
        syncStatus = status
        NotificationCenter.default.post(name: Self.syncStatusChanged, object: status)
    }

    private func loadLastSyncDate() {
        if let timestamp = UserDefaults.standard.object(forKey: Keys.lastSyncDate) as? TimeInterval {
            lastSyncDate = Date(timeIntervalSince1970: timestamp)
        }
    }

    private func saveLastSyncDate() {
        if let date = lastSyncDate {
            UserDefaults.standard.set(date.timeIntervalSince1970, forKey: Keys.lastSyncDate)
        }
    }

    private func relativeTimeString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    deinit {
        stopMonitoring()
    }
}

// MARK: - Sync Status

enum SyncStatus: String, Equatable {
    case notStarted = "Not Started"
    case syncing = "Syncing"
    case synced = "Synced"
    case error = "Error"
    case unavailable = "Unavailable"
    case disabled = "Disabled"

    var icon: String {
        switch self {
        case .notStarted: return "icloud"
        case .syncing: return "arrow.triangle.2.circlepath.icloud"
        case .synced: return "checkmark.icloud"
        case .error: return "exclamationmark.icloud"
        case .unavailable: return "icloud.slash"
        case .disabled: return "xmark.icloud"
        }
    }

    var color: String {
        switch self {
        case .notStarted: return "gray"
        case .syncing: return "blue"
        case .synced: return "green"
        case .error: return "red"
        case .unavailable: return "orange"
        case .disabled: return "gray"
        }
    }
}

// MARK: - CloudKit Configuration Helper

struct CloudKitConfiguration {
    /// The CloudKit container identifier for the app
    /// This should match the container ID in your entitlements
    static let containerIdentifier = "iCloud.com.kundli.app"

    /// Configure ModelContainer for CloudKit sync
    static func createCloudModelContainer() throws -> ModelContainer {
        let schema = Schema([
            SavedKundli.self,
            ChatConversation.self,
            CustomReminder.self,
        ])

        // Check if sync is enabled
        let syncEnabled = SyncService.shared.isSyncEnabled

        let modelConfiguration: ModelConfiguration

        if syncEnabled {
            // CloudKit-enabled configuration
            modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )
        } else {
            // Local-only configuration
            modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
        }

        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    }

    /// Create a local-only ModelContainer (for when sync is disabled)
    static func createLocalModelContainer() throws -> ModelContainer {
        let schema = Schema([
            SavedKundli.self,
            ChatConversation.self,
            CustomReminder.self,
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    }
}
