import SwiftUI
import SwiftData

struct CreateReminderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var reminderDate: Date = Date().addingTimeInterval(3600) // 1 hour from now
    @State private var repeatInterval: ReminderRepeatInterval = .none
    @State private var category: ReminderCategory = .general

    @State private var showDatePicker = false
    @State private var showTimePicker = false
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.kundliBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Title Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)

                            TextField("Reminder title", text: $title)
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliTextPrimary)
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.kundliCardBg)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                )
                        }

                        // Notes Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (Optional)")
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)

                            TextField("Add notes...", text: $notes, axis: .vertical)
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliTextPrimary)
                                .lineLimit(3...6)
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.kundliCardBg)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                )
                        }

                        // Date & Time Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Date & Time")
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)

                            CardView {
                                VStack(spacing: 0) {
                                    // Date picker row
                                    dateTimeRow(
                                        label: "Date",
                                        value: formatDate(reminderDate),
                                        icon: "calendar"
                                    )
                                    .onTapGesture {
                                        showDatePicker.toggle()
                                    }

                                    if showDatePicker {
                                        DatePicker(
                                            "",
                                            selection: $reminderDate,
                                            displayedComponents: .date
                                        )
                                        .datePickerStyle(.graphical)
                                        .tint(.kundliPrimary)
                                        .padding(.horizontal)
                                    }

                                    Divider()
                                        .background(Color.white.opacity(0.1))
                                        .padding(.leading, 16)

                                    // Time picker row
                                    dateTimeRow(
                                        label: "Time",
                                        value: formatTime(reminderDate),
                                        icon: "clock"
                                    )
                                    .onTapGesture {
                                        showTimePicker.toggle()
                                    }

                                    if showTimePicker {
                                        DatePicker(
                                            "",
                                            selection: $reminderDate,
                                            displayedComponents: .hourAndMinute
                                        )
                                        .datePickerStyle(.wheel)
                                        .tint(.kundliPrimary)
                                        .frame(height: 150)
                                    }
                                }
                            }
                        }

                        // Repeat Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Repeat")
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)

                            CardView {
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 10) {
                                    ForEach(ReminderRepeatInterval.allCases, id: \.self) { interval in
                                        repeatButton(interval)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }

                        // Category Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category")
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(ReminderCategory.allCases, id: \.self) { cat in
                                        categoryChip(cat)
                                    }
                                }
                            }
                        }

                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(16)
                }

                // Save button overlay
                VStack {
                    Spacer()

                    GoldButton(
                        title: isSaving ? "Saving..." : "Save Reminder",
                        icon: "checkmark.circle.fill"
                    ) {
                        saveReminder()
                    }
                    .disabled(title.isEmpty || isSaving)
                    .opacity(title.isEmpty ? 0.5 : 1.0)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .background(
                        LinearGradient(
                            colors: [
                                Color.kundliBackground.opacity(0),
                                Color.kundliBackground
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 100)
                        .allowsHitTesting(false),
                        alignment: .bottom
                    )
                }
            }
            .navigationTitle("New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.kundliTextSecondary)
                }
            }
        }
    }

    private func dateTimeRow(label: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.kundliPrimary)
                .frame(width: 24)

            Text(label)
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextPrimary)

            Spacer()

            Text(value)
                .font(.kundliSubheadline)
                .foregroundColor(.kundliPrimary)

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.kundliTextSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }

    private func repeatButton(_ interval: ReminderRepeatInterval) -> some View {
        let isSelected = repeatInterval == interval

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                repeatInterval = interval
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: interval.icon)
                    .font(.system(size: 16))

                Text(interval.rawValue)
                    .font(.system(size: 11))
            }
            .foregroundColor(isSelected ? .kundliBackground : .kundliTextSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.kundliPrimary : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? Color.clear : Color.white.opacity(0.1),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func categoryChip(_ cat: ReminderCategory) -> some View {
        let isSelected = category == cat

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                category = cat
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: cat.icon)
                    .font(.system(size: 12))

                Text(cat.rawValue)
                    .font(.kundliCaption)
            }
            .foregroundColor(isSelected ? .kundliBackground : .kundliTextSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.kundliPrimary : Color.kundliCardBg)
            )
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? Color.clear : Color.white.opacity(0.1),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d, yyyy"
        return formatter.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    private func saveReminder() {
        guard !title.isEmpty else { return }

        isSaving = true

        let reminder = CustomReminder(
            title: title,
            notes: notes.isEmpty ? nil : notes,
            reminderDate: reminderDate,
            repeatInterval: repeatInterval,
            category: category
        )

        modelContext.insert(reminder)

        // Schedule the notification
        Task {
            await NotificationService.shared.scheduleCustomReminder(reminder)

            await MainActor.run {
                isSaving = false
                dismiss()
            }
        }
    }
}

#Preview {
    CreateReminderView()
        .modelContainer(for: CustomReminder.self, inMemory: true)
}
