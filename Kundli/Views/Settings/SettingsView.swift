import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // AI Settings Section
                    aiSettingsSection

                    // Education Section
                    educationSection

                    // iCloud Sync Section
                    iCloudSyncSection

                    // Calculation Settings Section
                    calculationSettingsSection

                    // Display Settings Section
                    displaySettingsSection

                    // Notifications Section
                    notificationsSection

                    // About Section
                    aboutSection

                    // Reset Section
                    resetSection

                    Spacer()
                        .frame(height: 40)
                }
                .padding(16)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    // MARK: - AI Settings

    private var aiSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("AI Features", icon: "sparkles")

            CardView {
                VStack(spacing: 0) {
                    NavigationLink {
                        AISettingsView()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("AI Settings")
                                    .font(.kundliSubheadline)
                                    .foregroundColor(.kundliTextPrimary)

                                Text(AIKeyManager.shared.hasAPIKey ? "API key configured" : "Configure your Claude API key")
                                    .font(.kundliCaption)
                                    .foregroundColor(.kundliTextSecondary)
                            }

                            Spacer()

                            HStack(spacing: 8) {
                                if AIKeyManager.shared.hasAPIKey {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.kundliSuccess)
                                } else {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.kundliWarning)
                                }

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.kundliTextSecondary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - iCloud Sync Section

    private var iCloudSyncSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("iCloud Sync", icon: "icloud.fill")

            CardView {
                VStack(spacing: 0) {
                    NavigationLink {
                        iCloudSyncView()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("iCloud Sync")
                                    .font(.kundliSubheadline)
                                    .foregroundColor(.kundliTextPrimary)

                                Text(SyncService.shared.statusDescription)
                                    .font(.kundliCaption)
                                    .foregroundColor(.kundliTextSecondary)
                            }

                            Spacer()

                            HStack(spacing: 8) {
                                Image(systemName: SyncService.shared.syncStatus.icon)
                                    .foregroundColor(syncStatusColor)

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.kundliTextSecondary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var syncStatusColor: Color {
        switch SyncService.shared.syncStatus {
        case .synced: return .kundliSuccess
        case .syncing: return .kundliInfo
        case .error: return .kundliError
        case .unavailable, .disabled: return .kundliWarning
        case .notStarted: return .kundliTextSecondary
        }
    }

    // MARK: - Calculation Settings

    private var calculationSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Calculation Settings", icon: "function")

            CardView {
                VStack(spacing: 0) {
                    // Ayanamsa Picker
                    settingsPickerRow(
                        title: "Ayanamsa",
                        subtitle: viewModel.ayanamsa.description,
                        selection: Binding(
                            get: { viewModel.ayanamsa },
                            set: { viewModel.updateAyanamsa($0) }
                        ),
                        options: Ayanamsa.allCases
                    )

                    Divider()
                        .background(Color.white.opacity(0.1))
                        .padding(.leading, 16)

                    // House System Picker
                    settingsPickerRow(
                        title: "House System",
                        subtitle: viewModel.houseSystem.description,
                        selection: Binding(
                            get: { viewModel.houseSystem },
                            set: { viewModel.updateHouseSystem($0) }
                        ),
                        options: HouseSystem.allCases
                    )

                    Divider()
                        .background(Color.white.opacity(0.1))
                        .padding(.leading, 16)

                    // Node Type Picker
                    settingsPickerRow(
                        title: "Node Type",
                        subtitle: viewModel.nodeType.description,
                        selection: Binding(
                            get: { viewModel.nodeType },
                            set: { viewModel.updateNodeType($0) }
                        ),
                        options: NodeType.allCases
                    )
                }
            }
        }
    }

    // MARK: - Display Settings

    private var displaySettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Display Preferences", icon: "square.grid.2x2")

            CardView {
                VStack(spacing: 0) {
                    // Theme Picker
                    settingsPickerRow(
                        title: "Appearance",
                        subtitle: viewModel.appTheme.description,
                        selection: Binding(
                            get: { viewModel.appTheme },
                            set: { viewModel.updateAppTheme($0) }
                        ),
                        options: AppTheme.allCases
                    )

                    Divider()
                        .background(Color.white.opacity(0.1))
                        .padding(.leading, 16)

                    // Chart Style Picker
                    settingsPickerRow(
                        title: "Chart Style",
                        subtitle: "Traditional chart display format",
                        selection: Binding(
                            get: { viewModel.chartStyle },
                            set: { viewModel.updateChartStyle($0) }
                        ),
                        options: ChartStyle.allCases
                    )
                }
            }
        }
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Notifications", icon: "bell.fill")

            CardView {
                VStack(spacing: 0) {
                    // Master toggle
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Enable Notifications")
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliTextPrimary)

                            Text(viewModel.notificationPermissionGranted ? "Notifications are enabled" : "Tap to enable")
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)
                        }

                        Spacer()

                        if viewModel.isRequestingPermission {
                            ProgressView()
                                .tint(.kundliPrimary)
                        } else {
                            Toggle("", isOn: Binding(
                                get: { viewModel.notificationPermissionGranted && viewModel.areAnyNotificationsEnabled },
                                set: { newValue in
                                    if newValue {
                                        if viewModel.notificationPermissionGranted {
                                            viewModel.enableDefaultNotifications()
                                        } else {
                                            Task {
                                                await viewModel.requestNotificationPermission()
                                            }
                                        }
                                    } else {
                                        viewModel.disableAllNotifications()
                                    }
                                }
                            ))
                            .tint(.kundliPrimary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)

                    if viewModel.notificationPermissionGranted {
                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.leading, 16)

                        NavigationLink {
                            NotificationSettingsView(viewModel: viewModel)
                        } label: {
                            HStack {
                                Text("Notification Settings")
                                    .font(.kundliSubheadline)
                                    .foregroundColor(.kundliTextPrimary)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.kundliTextSecondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)

                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.leading, 16)

                        NavigationLink {
                            RemindersListView()
                        } label: {
                            HStack {
                                Image(systemName: "bell.badge")
                                    .foregroundColor(.kundliPrimary)
                                    .frame(width: 24)

                                Text("Custom Reminders")
                                    .font(.kundliSubheadline)
                                    .foregroundColor(.kundliTextPrimary)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.kundliTextSecondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Education Section

    private var educationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Education", icon: "graduationcap")

            CardView {
                VStack(spacing: 0) {
                    NavigationLink {
                        LearningCenterView()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Learning Center")
                                    .font(.kundliSubheadline)
                                    .foregroundColor(.kundliTextPrimary)

                                Text("Articles and guides about Vedic astrology")
                                    .font(.kundliCaption)
                                    .foregroundColor(.kundliTextSecondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(.kundliTextSecondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)

                    Divider()
                        .background(Color.white.opacity(0.1))
                        .padding(.leading, 16)

                    NavigationLink {
                        GlossaryView()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Glossary")
                                    .font(.kundliSubheadline)
                                    .foregroundColor(.kundliTextPrimary)

                                Text("A-Z of astrology terms")
                                    .font(.kundliCaption)
                                    .foregroundColor(.kundliTextSecondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(.kundliTextSecondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("About", icon: "info.circle.fill")

            CardView {
                VStack(spacing: 0) {
                    infoRow(title: "Version", value: viewModel.appVersion)

                    Divider()
                        .background(Color.white.opacity(0.1))
                        .padding(.leading, 16)

                    infoRow(title: "Build", value: viewModel.buildNumber)
                }
            }
        }
    }

    // MARK: - Reset Section

    private var resetSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            CardView {
                Button {
                    viewModel.resetToDefaults()
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16))

                        Text("Reset to Defaults")
                            .font(.kundliSubheadline)

                        Spacer()
                    }
                    .foregroundColor(.kundliWarning)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Helper Views

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

    private func settingsPickerRow<T: Hashable & RawRepresentable>(
        title: String,
        subtitle: String,
        selection: Binding<T>,
        options: [T]
    ) -> some View where T.RawValue == String {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliTextPrimary)

                Text(subtitle)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)
                    .lineLimit(2)
            }

            Spacer()

            Menu {
                ForEach(options, id: \.self) { option in
                    Button {
                        selection.wrappedValue = option
                    } label: {
                        HStack {
                            Text(option.rawValue)
                            if selection.wrappedValue == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(selection.wrappedValue.rawValue)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliPrimary)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.kundliPrimary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.kundliPrimary.opacity(0.1))
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextPrimary)

            Spacer()

            Text(value)
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
