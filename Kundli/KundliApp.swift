import SwiftUI
import SwiftData
import UserNotifications
import CloudKit

@main
struct KundliApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var showOnboarding = !UserDefaultsService.shared.hasSeenOnboarding
    @State private var navigationCoordinator = NavigationCoordinator.shared
    @State private var appTheme: AppTheme = SettingsService.shared.appTheme

    let sharedModelContainer: ModelContainer?
    private let containerError: String?

    init() {
        let schema = Schema([
            SavedKundli.self,
            ChatConversation.self,
            CustomReminder.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            sharedModelContainer = try ModelContainer(
                for: schema,
                migrationPlan: KundliMigrationPlan.self,
                configurations: [config]
            )
            containerError = nil
        } catch {
            sharedModelContainer = nil
            containerError = error.localizedDescription
        }

        // Initialize ephemeris service at app startup
        EphemerisService.shared.initialize()

        // Temporarily disabled - may cause crash on simulator
        // _ = SyncService.shared

        // Initialize education service and load data
        EducationService.shared.loadData()
    }

    var body: some Scene {
        WindowGroup {
            if let container = sharedModelContainer {
                ContentView()
                    .modelContainer(container)
                    .environment(navigationCoordinator)
                    .preferredColorScheme(appTheme.colorScheme)
                    .fullScreenCover(isPresented: $showOnboarding) {
                        OnboardingView(isPresented: $showOnboarding)
                            .preferredColorScheme(appTheme.colorScheme)
                    }
                    .onReceive(NotificationCenter.default.publisher(for: .handleDeepLink)) { notification in
                        if let deepLink = notification.object as? DeepLink {
                            navigationCoordinator.handle(deepLink)
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: SettingsService.appThemeChanged)) { notification in
                        if let newTheme = notification.object as? AppTheme {
                            appTheme = newTheme
                        }
                    }
            } else {
                DataErrorView(errorMessage: containerError ?? "Unknown error")
            }
        }
    }
}

// MARK: - Data Error View

private struct DataErrorView: View {
    let errorMessage: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.red)

            Text("Unable to Load Data")
                .font(.title2.bold())

            Text(errorMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Text("Try restarting the app. If the problem persists, reinstall the app.")
                .font(.footnote)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding()
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        Task {
            _ = await NotificationService.shared.requestAuthorization()
        }
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    /// Show notification even when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    /// Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let category = response.notification.request.content.categoryIdentifier
        let userInfo = response.notification.request.content.userInfo

        if let deepLink = DeepLink.from(category: category, userInfo: userInfo) {
            NotificationCenter.default.post(name: .handleDeepLink, object: deepLink)
        }

        completionHandler()
    }
}
