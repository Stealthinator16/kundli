import SwiftUI
import CloudKit

/// View for managing iCloud sync settings and status
struct iCloudSyncView: View {
    @State private var syncService = SyncService.shared
    @State private var isRefreshing = false
    @State private var showRestartAlert = false

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Sync Status Card
                    syncStatusCard

                    // Sync Settings
                    syncSettingsCard

                    // Info Card
                    infoCard

                    // Troubleshooting
                    troubleshootingCard

                    Spacer()
                        .frame(height: 40)
                }
                .padding(16)
            }
        }
        .navigationTitle("iCloud Sync")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    refreshSync()
                } label: {
                    if isRefreshing {
                        ProgressView()
                            .tint(.kundliPrimary)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.kundliPrimary)
                    }
                }
                .disabled(isRefreshing)
            }
        }
        .alert("Restart Required", isPresented: $showRestartAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Changes to iCloud sync settings will take effect after restarting the app.")
        }
        .onAppear {
            Task {
                await syncService.checkCloudStatus()
            }
        }
    }

    // MARK: - Sync Status Card

    private var syncStatusCard: some View {
        CardView {
            VStack(spacing: 16) {
                // Status icon
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.2))
                        .frame(width: 80, height: 80)

                    Image(systemName: syncService.syncStatus.icon)
                        .font(.system(size: 36))
                        .foregroundColor(statusColor)
                }

                // Status text
                VStack(spacing: 4) {
                    Text(syncService.syncStatus.rawValue)
                        .font(.kundliTitle3)
                        .foregroundColor(.kundliTextPrimary)

                    Text(syncService.statusDescription)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                        .multilineTextAlignment(.center)
                }

                // Last sync info
                if let lastSync = syncService.lastSyncDate {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                        Text("Last synced: \(formattedDate(lastSync))")
                            .font(.kundliCaption)
                    }
                    .foregroundColor(.kundliTextTertiary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Sync Settings Card

    private var syncSettingsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Settings", icon: "gearshape.fill")

            CardView {
                VStack(spacing: 0) {
                    // Enable Sync toggle
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Enable iCloud Sync")
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliTextPrimary)

                            Text("Sync kundlis, chats, and reminders across devices")
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)
                        }

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { syncService.isSyncEnabled },
                            set: { newValue in
                                syncService.isSyncEnabled = newValue
                                showRestartAlert = true
                            }
                        ))
                        .tint(.kundliPrimary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)

                    Divider()
                        .background(Color.white.opacity(0.1))
                        .padding(.leading, 16)

                    // Sync over cellular toggle
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sync Over Cellular")
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliTextPrimary)

                            Text("Allow sync when not on Wi-Fi")
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)
                        }

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { syncService.syncOverCellular },
                            set: { syncService.syncOverCellular = $0 }
                        ))
                        .tint(.kundliPrimary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
        }
    }

    // MARK: - Info Card

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("What gets synced", icon: "info.circle.fill")

            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    syncItem("Saved Kundlis", icon: "person.crop.circle", description: "Birth charts and details")
                    Divider().background(Color.white.opacity(0.1))
                    syncItem("AI Chat History", icon: "bubble.left.and.bubble.right", description: "Conversations with the AI")
                    Divider().background(Color.white.opacity(0.1))
                    syncItem("Custom Reminders", icon: "bell.badge", description: "Your created reminders")
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func syncItem(_ title: String, icon: String, description: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.kundliPrimary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliTextPrimary)

                Text(description)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.kundliSuccess)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Troubleshooting Card

    private var troubleshootingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Troubleshooting", icon: "wrench.and.screwdriver.fill")

            CardView {
                VStack(alignment: .leading, spacing: 16) {
                    if !syncService.isCloudAvailable {
                        troubleshootRow(
                            icon: "person.crop.circle.badge.xmark",
                            title: "iCloud Account",
                            description: syncService.accountStatusMessage(syncService.accountStatus),
                            color: .kundliWarning
                        )
                    }

                    if syncService.syncStatus == .error, let error = syncService.lastError {
                        troubleshootRow(
                            icon: "exclamationmark.triangle.fill",
                            title: "Sync Error",
                            description: error,
                            color: .kundliError
                        )
                    }

                    // Manual refresh button
                    Button {
                        refreshSync()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14))

                            Text("Force Refresh")
                                .font(.kundliSubheadline)

                            Spacer()

                            if isRefreshing {
                                ProgressView()
                                    .tint(.kundliPrimary)
                            }
                        }
                        .foregroundColor(.kundliPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .disabled(isRefreshing)
                }
            }
        }
    }

    private func troubleshootRow(icon: String, title: String, description: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliTextPrimary)

                Text(description)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.kundliPrimary)

            Text(title)
                .font(.kundliHeadline)
                .foregroundColor(.kundliTextPrimary)
        }
    }

    private var statusColor: Color {
        switch syncService.syncStatus {
        case .synced: return .kundliSuccess
        case .syncing: return .kundliInfo
        case .error: return .kundliError
        case .unavailable, .disabled: return .kundliWarning
        case .notStarted: return .kundliTextSecondary
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func refreshSync() {
        isRefreshing = true
        Task {
            await syncService.refreshSync()
            await MainActor.run {
                isRefreshing = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        iCloudSyncView()
    }
}
