import SwiftUI

struct NotificationSettingsView: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Panchang Notification
                    panchangSection

                    // Rahu Kaal Notification
                    rahuKaalSection

                    // Muhurta Notification
                    muhurtaSection

                    // Dasha Transition Notification
                    dashaSection

                    Spacer()
                        .frame(height: 40)
                }
                .padding(16)
            }
        }
        .navigationTitle("Notification Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    // MARK: - Panchang Section

    private var panchangSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            notificationHeader(
                category: .panchang,
                isEnabled: viewModel.notificationSettings.panchangEnabled
            )

            CardView {
                VStack(spacing: 0) {
                    // Enable toggle
                    toggleRow(
                        title: "Daily Panchang",
                        subtitle: "Receive daily summary at specified time",
                        isOn: Binding(
                            get: { viewModel.notificationSettings.panchangEnabled },
                            set: { viewModel.togglePanchangNotification($0) }
                        )
                    )

                    if viewModel.notificationSettings.panchangEnabled {
                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.leading, 16)

                        // Time picker
                        timePickerRow(
                            title: "Notification Time",
                            time: Binding(
                                get: { viewModel.notificationSettings.panchangTime },
                                set: { viewModel.updatePanchangTime($0) }
                            )
                        )
                    }
                }
            }
        }
    }

    // MARK: - Rahu Kaal Section

    private var rahuKaalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            notificationHeader(
                category: .rahuKaal,
                isEnabled: viewModel.notificationSettings.rahuKaalEnabled
            )

            CardView {
                VStack(spacing: 0) {
                    // Enable toggle
                    toggleRow(
                        title: "Rahu Kaal Alert",
                        subtitle: "Alert before inauspicious period begins",
                        isOn: Binding(
                            get: { viewModel.notificationSettings.rahuKaalEnabled },
                            set: { viewModel.toggleRahuKaalNotification($0) }
                        )
                    )

                    if viewModel.notificationSettings.rahuKaalEnabled {
                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.leading, 16)

                        // Minutes before picker
                        minutesPickerRow(
                            title: "Alert Before",
                            minutes: viewModel.notificationSettings.rahuKaalMinutesBefore,
                            options: [5, 10, 15, 30, 60],
                            onSelect: { viewModel.updateRahuKaalMinutesBefore($0) }
                        )
                    }
                }
            }
        }
    }

    // MARK: - Muhurta Section

    private var muhurtaSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            notificationHeader(
                category: .muhurta,
                isEnabled: viewModel.notificationSettings.muhurtaEnabled
            )

            CardView {
                toggleRow(
                    title: "Muhurta Reminders",
                    subtitle: "Reminders for Abhijit and Brahma Muhurta",
                    isOn: Binding(
                        get: { viewModel.notificationSettings.muhurtaEnabled },
                        set: { viewModel.toggleMuhurtaNotification($0) }
                    )
                )
            }
        }
    }

    // MARK: - Dasha Section

    private var dashaSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            notificationHeader(
                category: .dashaTransition,
                isEnabled: viewModel.notificationSettings.dashaTransitionEnabled
            )

            CardView {
                VStack(spacing: 0) {
                    // Enable toggle
                    toggleRow(
                        title: "Dasha Transition",
                        subtitle: "Notification when major periods change",
                        isOn: Binding(
                            get: { viewModel.notificationSettings.dashaTransitionEnabled },
                            set: { viewModel.toggleDashaTransitionNotification($0) }
                        )
                    )

                    if viewModel.notificationSettings.dashaTransitionEnabled {
                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.leading, 16)

                        // Days before picker
                        daysPickerRow(
                            title: "Notify Before",
                            days: viewModel.notificationSettings.dashaTransitionDaysBefore,
                            options: [1, 3, 7, 14, 30],
                            onSelect: { viewModel.updateDashaTransitionDaysBefore($0) }
                        )
                    }
                }
            }
        }
    }

    // MARK: - Helper Views

    private func notificationHeader(category: NotificationCategory, isEnabled: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: category.icon)
                .font(.system(size: 14))
                .foregroundColor(isEnabled ? .kundliPrimary : .kundliTextSecondary)

            Text(category.title)
                .font(.kundliHeadline)
                .foregroundColor(.kundliTextPrimary)

            Spacer()

            if isEnabled {
                Text("Enabled")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliSuccess)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.kundliSuccess.opacity(0.15))
                    )
            }
        }
    }

    private func toggleRow(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliTextPrimary)

                Text(subtitle)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .tint(.kundliPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func timePickerRow(title: String, time: Binding<Date>) -> some View {
        HStack {
            Text(title)
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextPrimary)

            Spacer()

            DatePicker(
                "",
                selection: time,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .tint(.kundliPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func minutesPickerRow(
        title: String,
        minutes: Int,
        options: [Int],
        onSelect: @escaping (Int) -> Void
    ) -> some View {
        HStack {
            Text(title)
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextPrimary)

            Spacer()

            Menu {
                ForEach(options, id: \.self) { option in
                    Button {
                        onSelect(option)
                    } label: {
                        HStack {
                            Text(formatMinutes(option))
                            if minutes == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(formatMinutes(minutes))
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

    private func daysPickerRow(
        title: String,
        days: Int,
        options: [Int],
        onSelect: @escaping (Int) -> Void
    ) -> some View {
        HStack {
            Text(title)
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextPrimary)

            Spacer()

            Menu {
                ForEach(options, id: \.self) { option in
                    Button {
                        onSelect(option)
                    } label: {
                        HStack {
                            Text(formatDays(option))
                            if days == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(formatDays(days))
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

    private func formatMinutes(_ minutes: Int) -> String {
        if minutes >= 60 {
            return "\(minutes / 60) hour\(minutes / 60 > 1 ? "s" : "")"
        }
        return "\(minutes) min"
    }

    private func formatDays(_ days: Int) -> String {
        return "\(days) day\(days > 1 ? "s" : "")"
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView(viewModel: SettingsViewModel())
    }
}
