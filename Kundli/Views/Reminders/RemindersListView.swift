import SwiftUI
import SwiftData

struct RemindersListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CustomReminder.reminderDate, order: .forward) private var reminders: [CustomReminder]

    @State private var showCreateReminder = false
    @State private var selectedReminder: CustomReminder?
    @State private var showDeleteConfirmation = false
    @State private var reminderToDelete: CustomReminder?

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            if reminders.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        // Upcoming reminders
                        if !upcomingReminders.isEmpty {
                            reminderSection(
                                title: "Upcoming",
                                icon: "clock.fill",
                                reminders: upcomingReminders
                            )
                        }

                        // Today's reminders
                        if !todayReminders.isEmpty {
                            reminderSection(
                                title: "Today",
                                icon: "sun.max.fill",
                                reminders: todayReminders
                            )
                        }

                        // Past reminders
                        if !pastReminders.isEmpty {
                            reminderSection(
                                title: "Past",
                                icon: "clock.arrow.circlepath",
                                reminders: pastReminders,
                                isPast: true
                            )
                        }

                        Spacer()
                            .frame(height: 80)
                    }
                    .padding(16)
                }
            }

            // Floating add button
            VStack {
                Spacer()

                Button {
                    showCreateReminder = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))

                        Text("New Reminder")
                            .font(.kundliSubheadline)
                    }
                    .foregroundColor(.kundliBackground)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color.kundliPrimary)
                    )
                    .shadow(color: Color.kundliPrimary.opacity(0.3), radius: 8, y: 4)
                }
                .padding(.bottom, 16)
            }
        }
        .navigationTitle("Reminders")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $showCreateReminder) {
            CreateReminderView()
        }
        .sheet(item: $selectedReminder) { reminder in
            ReminderDetailSheet(reminder: reminder)
        }
        .alert("Delete Reminder?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let reminder = reminderToDelete {
                    deleteReminder(reminder)
                }
            }
        } message: {
            Text("This reminder will be permanently deleted.")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundColor(.kundliTextSecondary)

            Text("No Reminders")
                .font(.kundliTitle3)
                .foregroundColor(.kundliTextPrimary)

            Text("Create a reminder for important dates,\npujas, or auspicious timings")
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextSecondary)
                .multilineTextAlignment(.center)

            Button {
                showCreateReminder = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Reminder")
                }
                .font(.kundliSubheadline)
                .foregroundColor(.kundliPrimary)
            }
            .padding(.top, 8)
        }
        .padding(32)
    }

    private func reminderSection(
        title: String,
        icon: String,
        reminders: [CustomReminder],
        isPast: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.kundliPrimary)

                Text(title)
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                Text("(\(reminders.count))")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)
            }

            VStack(spacing: 10) {
                ForEach(reminders) { reminder in
                    reminderRow(reminder, isPast: isPast)
                }
            }
        }
    }

    private func reminderRow(_ reminder: CustomReminder, isPast: Bool) -> some View {
        HStack(spacing: 12) {
            // Category icon
            ZStack {
                Circle()
                    .fill(categoryColor(reminder.category).opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: reminder.category.icon)
                    .font(.system(size: 18))
                    .foregroundColor(categoryColor(reminder.category))
            }
            .opacity(isPast ? 0.5 : 1.0)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.kundliSubheadline)
                    .foregroundColor(isPast ? .kundliTextSecondary : .kundliTextPrimary)
                    .strikethrough(isPast)

                HStack(spacing: 8) {
                    Text(reminder.formattedDate)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)

                    if reminder.repeatInterval != .none {
                        HStack(spacing: 2) {
                            Image(systemName: "repeat")
                                .font(.system(size: 10))
                            Text(reminder.repeatInterval.rawValue)
                                .font(.system(size: 10))
                        }
                        .foregroundColor(.kundliPrimary.opacity(0.7))
                    }
                }
            }

            Spacer()

            // Time until or menu
            if let timeUntil = reminder.timeUntil {
                Text(timeUntil)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliPrimary)
            }

            // Actions menu
            Menu {
                Button {
                    selectedReminder = reminder
                } label: {
                    Label("View Details", systemImage: "eye")
                }

                Button(role: .destructive) {
                    reminderToDelete = reminder
                    showDeleteConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16))
                    .foregroundColor(.kundliTextSecondary)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.kundliCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .opacity(isPast ? 0.7 : 1.0)
    }

    private func categoryColor(_ category: ReminderCategory) -> Color {
        switch category {
        case .general: return .kundliPrimary
        case .puja: return .orange
        case .vrat: return .green
        case .muhurta: return .kundliInfo
        case .transit: return .purple
        case .birthday: return .pink
        case .anniversary: return .red
        }
    }

    private func deleteReminder(_ reminder: CustomReminder) {
        // Cancel notification
        Task {
            await NotificationService.shared.cancelCustomReminder(reminder)
        }

        // Delete from context
        modelContext.delete(reminder)
    }

    // MARK: - Computed Properties

    private var upcomingReminders: [CustomReminder] {
        let calendar = Calendar.current
        return reminders.filter { reminder in
            !calendar.isDateInToday(reminder.reminderDate) && reminder.reminderDate > Date()
        }
    }

    private var todayReminders: [CustomReminder] {
        reminders.filter { Calendar.current.isDateInToday($0.reminderDate) }
    }

    private var pastReminders: [CustomReminder] {
        reminders.filter { $0.isPast }
    }
}

// MARK: - Reminder Detail Sheet

struct ReminderDetailSheet: View {
    let reminder: CustomReminder
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.kundliBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.kundliPrimary.opacity(0.2))
                                    .frame(width: 80, height: 80)

                                Image(systemName: reminder.category.icon)
                                    .font(.system(size: 32))
                                    .foregroundColor(.kundliPrimary)
                            }

                            Text(reminder.title)
                                .font(.kundliTitle2)
                                .foregroundColor(.kundliTextPrimary)
                                .multilineTextAlignment(.center)

                            Text(reminder.category.rawValue)
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)
                        }
                        .padding(.top, 20)

                        // Details card
                        CardView {
                            VStack(spacing: 12) {
                                detailRow("Date", reminder.formattedDate)
                                Divider().background(Color.white.opacity(0.1))
                                detailRow("Repeat", reminder.repeatInterval.description)
                                if let notes = reminder.notes, !notes.isEmpty {
                                    Divider().background(Color.white.opacity(0.1))
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Notes")
                                            .font(.kundliCaption)
                                            .foregroundColor(.kundliTextSecondary)
                                        Text(notes)
                                            .font(.kundliSubheadline)
                                            .foregroundColor(.kundliTextPrimary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .padding(.horizontal, 16)

                        if let timeUntil = reminder.timeUntil {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.kundliPrimary)
                                Text("\(timeUntil) from now")
                                    .font(.kundliSubheadline)
                                    .foregroundColor(.kundliTextSecondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Reminder Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.kundliPrimary)
                }
            }
            .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextSecondary)

            Spacer()

            Text(value)
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextPrimary)
        }
    }
}

#Preview {
    NavigationStack {
        RemindersListView()
    }
    .modelContainer(for: CustomReminder.self, inMemory: true)
}
