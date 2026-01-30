import SwiftUI
import SwiftData

struct SavedKundlisView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedKundli.updatedAt, order: .reverse) private var savedKundlis: [SavedKundli]

    @State private var showDeleteAlert = false
    @State private var kundliToDelete: SavedKundli?
    @State private var selectedKundli: SavedKundli?
    @State private var showKundliDetail = false

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            if savedKundlis.isEmpty {
                emptyState
            } else {
                kundliList
            }
        }
        .navigationTitle("Saved Kundlis")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert("Delete Kundli", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let kundli = kundliToDelete {
                    deleteKundli(kundli)
                }
            }
        } message: {
            Text("Are you sure you want to delete this kundli? This action cannot be undone.")
        }
        .navigationDestination(isPresented: $showKundliDetail) {
            if let kundli = selectedKundli {
                SavedKundliDetailView(savedKundli: kundli)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 60))
                .foregroundColor(.kundliTextSecondary)

            Text("No Saved Kundlis")
                .font(.kundliTitle3)
                .foregroundColor(.kundliTextPrimary)

            Text("Create a new kundli to see it here")
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextSecondary)
        }
    }

    private var kundliList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(savedKundlis) { kundli in
                    SavedKundliRow(kundli: kundli) {
                        selectedKundli = kundli
                        showKundliDetail = true
                    } onDelete: {
                        kundliToDelete = kundli
                        showDeleteAlert = true
                    }
                }
            }
            .padding(16)
        }
    }

    private func deleteKundli(_ kundli: SavedKundli) {
        withAnimation {
            modelContext.delete(kundli)
        }
    }
}

struct SavedKundliRow: View {
    let kundli: SavedKundli
    let onTap: () -> Void
    let onDelete: () -> Void

    @State private var hasBirthdayReminder = false
    @State private var showBirthdayReminderSheet = false

    private let notificationService = NotificationService.shared

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Avatar
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(Color.kundliPrimary.opacity(0.2))
                        .frame(width: 52, height: 52)
                        .overlay(
                            Text(kundli.initials)
                                .font(.kundliHeadline)
                                .foregroundColor(.kundliPrimary)
                        )

                    // Birthday reminder indicator
                    if hasBirthdayReminder {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Circle().fill(Color.pink))
                            .offset(x: 4, y: -4)
                    }
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(kundli.name)
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliTextPrimary)

                    Text(kundli.formattedDateTime)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)

                    Text(kundli.birthCity)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                        .lineLimit(1)
                }

                Spacer()

                // Ascendant badge
                if !kundli.ascendantSign.isEmpty {
                    VStack(spacing: 2) {
                        Text(kundli.ascendantSign)
                            .font(.kundliCaption)
                            .foregroundColor(.kundliPrimary)
                        Text("Lagna")
                            .font(.system(size: 9))
                            .foregroundColor(.kundliTextSecondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.kundliPrimary.opacity(0.1))
                    )
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.kundliTextSecondary)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.kundliCardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                onTap()
            } label: {
                Label("View Kundli", systemImage: "eye")
            }

            Button {
                showBirthdayReminderSheet = true
            } label: {
                Label(
                    hasBirthdayReminder ? "Edit Birthday Reminder" : "Set Birthday Reminder",
                    systemImage: hasBirthdayReminder ? "bell.fill" : "bell.badge.fill"
                )
            }

            if hasBirthdayReminder {
                Button(role: .destructive) {
                    cancelBirthdayReminder()
                } label: {
                    Label("Remove Reminder", systemImage: "bell.slash")
                }
            }

            Divider()

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showBirthdayReminderSheet) {
            BirthdayReminderSheet(
                kundli: kundli,
                hasExistingReminder: hasBirthdayReminder,
                onSave: { daysBefore in
                    setBirthdayReminder(daysBefore: daysBefore)
                },
                onCancel: {
                    cancelBirthdayReminder()
                }
            )
        }
        .task {
            await checkBirthdayReminder()
        }
    }

    private func checkBirthdayReminder() async {
        hasBirthdayReminder = await notificationService.hasBirthdayReminder(for: kundli.id)
    }

    private func setBirthdayReminder(daysBefore: Int) {
        Task {
            await notificationService.scheduleBirthdayReminder(for: kundli, notifyDaysBefore: daysBefore)
            await checkBirthdayReminder()
        }
    }

    private func cancelBirthdayReminder() {
        notificationService.cancelBirthdayReminder(for: kundli.id)
        hasBirthdayReminder = false
    }
}

// MARK: - Birthday Reminder Sheet

struct BirthdayReminderSheet: View {
    let kundli: SavedKundli
    let hasExistingReminder: Bool
    let onSave: (Int) -> Void
    let onCancel: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedDaysBefore: Int = 0

    private let daysBeforeOptions = [
        (0, "On birthday"),
        (1, "1 day before"),
        (3, "3 days before"),
        (7, "1 week before")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.kundliBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "gift.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.pink)

                            Text("Birthday Reminder")
                                .font(.kundliTitle2)
                                .foregroundColor(.kundliTextPrimary)

                            Text("Set a reminder for \(kundli.name)'s birthday")
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)

                        // Birthday info
                        CardView {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Birthday")
                                        .font(.kundliSubheadline)
                                        .foregroundColor(.kundliTextSecondary)

                                    Spacer()

                                    Text(birthdayString)
                                        .font(.kundliSubheadline)
                                        .foregroundColor(.kundliTextPrimary)
                                }

                                if let daysUntil = daysUntilBirthday {
                                    HStack {
                                        Text("Days until birthday")
                                            .font(.kundliSubheadline)
                                            .foregroundColor(.kundliTextSecondary)

                                        Spacer()

                                        Text("\(daysUntil) days")
                                            .font(.kundliSubheadline)
                                            .foregroundColor(.kundliPrimary)
                                    }
                                }
                            }
                        }

                        // Reminder options
                        CardView {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("When to remind")
                                    .font(.kundliHeadline)
                                    .foregroundColor(.kundliTextPrimary)

                                ForEach(daysBeforeOptions, id: \.0) { option in
                                    Button {
                                        selectedDaysBefore = option.0
                                    } label: {
                                        HStack {
                                            Image(systemName: selectedDaysBefore == option.0 ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(selectedDaysBefore == option.0 ? .kundliPrimary : .kundliTextSecondary)

                                            Text(option.1)
                                                .font(.kundliBody)
                                                .foregroundColor(.kundliTextPrimary)

                                            Spacer()
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // Save button
                        GoldButton(title: hasExistingReminder ? "Update Reminder" : "Set Reminder", icon: "bell.fill") {
                            onSave(selectedDaysBefore)
                            dismiss()
                        }

                        // Cancel reminder button (if exists)
                        if hasExistingReminder {
                            Button {
                                onCancel()
                                dismiss()
                            } label: {
                                Text("Remove Reminder")
                                    .font(.kundliSubheadline)
                                    .foregroundColor(.kundliError)
                            }
                        }

                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Birthday Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.kundliTextSecondary)
                }
            }
        }
    }

    private var birthdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: kundli.dateOfBirth)
    }

    private var daysUntilBirthday: Int? {
        let calendar = Calendar.current
        let today = Date()

        let birthMonth = calendar.component(.month, from: kundli.dateOfBirth)
        let birthDay = calendar.component(.day, from: kundli.dateOfBirth)

        var nextBirthdayComponents = DateComponents()
        nextBirthdayComponents.month = birthMonth
        nextBirthdayComponents.day = birthDay
        nextBirthdayComponents.year = calendar.component(.year, from: today)

        guard var nextBirthday = calendar.date(from: nextBirthdayComponents) else {
            return nil
        }

        // If birthday has passed this year, use next year
        if nextBirthday < today {
            nextBirthdayComponents.year = calendar.component(.year, from: today) + 1
            nextBirthday = calendar.date(from: nextBirthdayComponents) ?? nextBirthday
        }

        return calendar.dateComponents([.day], from: today, to: nextBirthday).day
    }
}

struct SavedKundliDetailView: View {
    let savedKundli: SavedKundli
    @State private var viewModel = KundliViewModel()

    var body: some View {
        BirthChartView(viewModel: viewModel)
            .onAppear {
                loadKundli()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AIFeatureEntryView(savedKundli: savedKundli)) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.kundliPrimary)
                    }
                }
            }
    }

    private func loadKundli() {
        // Load the saved kundli data into the view model
        viewModel.birthDetails = savedKundli.toBirthDetails()

        // Generate mock chart data (in real app, this would be stored/calculated)
        let planets = MockDataService.shared.samplePlanets()
        let ascendant = Ascendant(
            sign: ZodiacSign(rawValue: savedKundli.ascendantSign) ?? .scorpio,
            degree: savedKundli.ascendantDegree,
            minutes: 0,
            seconds: 0,
            nakshatra: savedKundli.ascendantNakshatra,
            nakshatraPada: 1,
            lord: "Mars"
        )

        viewModel.kundli = Kundli(
            id: savedKundli.id,
            birthDetails: savedKundli.toBirthDetails(),
            planets: planets,
            ascendant: ascendant
        )

        viewModel.dashaPeriods = MockDataService.shared.sampleDashaPeriods()
    }
}

#Preview {
    NavigationStack {
        SavedKundlisView()
    }
    .modelContainer(for: SavedKundli.self, inMemory: true)
}
