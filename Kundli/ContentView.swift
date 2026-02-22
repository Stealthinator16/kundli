import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(NavigationCoordinator.self) private var navigationCoordinator
    @Query(sort: \SavedKundli.createdAt) private var savedKundlis: [SavedKundli]
    @State private var showNotificationSettings = false
    @State private var settingsViewModel = SettingsViewModel()
    @State private var panchangViewModel = HomeViewModel()

    var body: some View {
        @Bindable var coordinator = navigationCoordinator

        TabBarContainer(selectedTab: $coordinator.selectedTab) {
            switch coordinator.selectedTab {
            case .chart:
                HomeView()
            case .panchang:
                panchangView
            case .matching:
                KundliMatchingView()
            case .profile:
                profileView
            }
        }
    }

    private var panchangView: some View {
        NavigationStack {
            ZStack {
                Color.kundliBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Full Panchang view
                        let panchang = panchangViewModel.panchang

                        // Date header
                        VStack(spacing: 4) {
                            Text(formattedDate)
                                .font(.kundliTitle2)
                                .foregroundColor(.kundliTextPrimary)

                            Text(panchang.moonPhase.rawValue)
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliTextSecondary)
                        }
                        .padding(.top, 16)

                        // Moon phase visual
                        Text(panchang.moonPhase.symbol)
                            .font(.system(size: 60))

                        // Panchang grid
                        PanchangGrid(panchang: panchang)

                        // Rahu Kaal
                        RahuKaalBanner(panchang: panchang)

                        // Sun times
                        CardView {
                            HStack {
                                sunTimeItem("Sunrise", time: panchang.sunriseTime, icon: "sunrise.fill")
                                Spacer()
                                sunTimeItem("Sunset", time: panchang.sunsetTime, icon: "sunset.fill")
                            }
                        }

                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Today's Panchang")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private func sunTimeItem(_ title: String, time: Date, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.kundliPrimary)

            Text(title)
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)

            Text(formatTime(time))
                .font(.kundliHeadline)
                .foregroundColor(.kundliTextPrimary)
        }
    }

    private var profileView: some View {
        NavigationStack {
            ZStack {
                Color.kundliBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Profile header
                        VStack(spacing: 16) {
                            Circle()
                                .fill(LinearGradient.kundliGold)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Text(primaryKundli?.initials ?? "?")
                                        .font(.kundliTitle2)
                                        .foregroundColor(.kundliBackground)
                                )

                            Text(primaryKundli?.name ?? "Guest")
                                .font(.kundliTitle2)
                                .foregroundColor(.kundliTextPrimary)

                            if let sign = primaryKundli?.ascendantSign, !sign.isEmpty {
                                Text(sign)
                                    .font(.kundliSubheadline)
                                    .foregroundColor(.kundliTextSecondary)
                            } else {
                                Text("Add a kundli to get started")
                                    .font(.kundliSubheadline)
                                    .foregroundColor(.kundliTextSecondary)
                            }
                        }
                        .padding(.top, 24)

                        // Menu items
                        VStack(spacing: 0) {
                            NavigationLink {
                                SavedKundlisView()
                            } label: {
                                profileMenuItemContent("My Kundlis", icon: "square.grid.2x2.fill")
                            }
                            .buttonStyle(.plain)

                            // Learning Center - NavigationLink
                            NavigationLink {
                                LearningCenterView()
                            } label: {
                                profileMenuItemContent("Learn Vedic Astrology", icon: "book.fill")
                            }
                            .buttonStyle(.plain)

                            // Notifications - NavigationLink to NotificationSettingsView
                            NavigationLink {
                                NotificationSettingsView(viewModel: settingsViewModel)
                            } label: {
                                profileMenuItemContent("Notifications", icon: "bell.fill")
                            }
                            .buttonStyle(.plain)

                            // Settings - NavigationLink
                            NavigationLink {
                                SettingsView()
                            } label: {
                                profileMenuItemContent("Settings", icon: "gearshape.fill")
                            }
                            .buttonStyle(.plain)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.kundliCardBg)
                        )

                        // App info
                        VStack(spacing: 4) {
                            Text("Kundli App")
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)

                            Text("Version 1.0.0")
                                .font(.kundliCaption2)
                                .foregroundColor(.kundliTextSecondary.opacity(0.7))
                        }
                        .padding(.top, 20)

                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onChange(of: navigationCoordinator.pendingDeepLink) { _, newValue in
                if case .notificationSettings = newValue {
                    showNotificationSettings = true
                    navigationCoordinator.clearPendingDeepLink()
                }
            }
            .navigationDestination(isPresented: $showNotificationSettings) {
                NotificationSettingsView(viewModel: settingsViewModel)
            }
        }
    }

    private var primaryKundli: SavedKundli? {
        savedKundlis.first
    }

    private func profileMenuItemContent(_ title: String, icon: String) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.kundliPrimary)
                    .frame(width: 28)

                Text(title)
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliTextPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.kundliTextSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            Divider()
                .background(Color.white.opacity(0.1))
                .padding(.leading, 56)
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: Date())
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
        .environment(NavigationCoordinator.shared)
}
