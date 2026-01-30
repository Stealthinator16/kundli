import SwiftUI
import SwiftData
import UserNotifications

@main
struct KundliApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var showOnboarding = !UserDefaultsService.shared.hasSeenOnboarding
    @State private var navigationCoordinator = NavigationCoordinator.shared
    @State private var appTheme: AppTheme = SettingsService.shared.appTheme

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SavedKundli.self,
            ChatConversation.self,
            CustomReminder.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        // Initialize ephemeris service at app startup
        EphemerisService.shared.initialize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
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
        }
        .modelContainer(sharedModelContainer)
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
