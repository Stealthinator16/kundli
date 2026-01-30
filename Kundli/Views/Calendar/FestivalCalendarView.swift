import SwiftUI

struct FestivalCalendarView: View {
    @State private var selectedMonth: Date = Date()
    @State private var selectedFestival: FestivalInstance?
    @State private var viewMode: FestivalViewMode = .list

    private let festivalService = FestivalService.shared

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // View mode toggle
                viewModeToggle
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                if viewMode == .calendar {
                    calendarView
                } else {
                    upcomingListView
                }
            }
        }
        .navigationTitle("Festival Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    GrahaPraveshView()
                } label: {
                    Image(systemName: "house.fill")
                        .foregroundColor(.kundliPrimary)
                }
            }
        }
        .sheet(item: $selectedFestival) { festival in
            FestivalDetailView(festival: festival)
        }
    }

    // MARK: - View Mode Toggle

    private var viewModeToggle: some View {
        HStack(spacing: 0) {
            ForEach(FestivalViewMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewMode = mode
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 12))
                        Text(mode.rawValue)
                            .font(.kundliCaption)
                    }
                    .foregroundColor(viewMode == mode ? .kundliBackground : .kundliTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(viewMode == mode ? Color.kundliPrimary : Color.clear)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.kundliCardBg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Calendar View

    private var calendarView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Month selector
                monthSelector

                // Month's festivals
                let festivals = festivalsForSelectedMonth
                if festivals.isEmpty {
                    emptyMonthState
                } else {
                    VStack(spacing: 12) {
                        ForEach(festivals) { festival in
                            festivalRow(festival)
                                .onTapGesture {
                                    selectedFestival = festival
                                }
                        }
                    }
                }

                Spacer()
                    .frame(height: 20)
            }
            .padding(16)
        }
    }

    private var monthSelector: some View {
        HStack {
            Button {
                changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.kundliPrimary)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            Text(monthYearString)
                .font(.kundliTitle3)
                .foregroundColor(.kundliTextPrimary)

            Spacer()

            Button {
                changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.kundliPrimary)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.vertical, 8)
    }

    private var emptyMonthState: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 40))
                .foregroundColor(.kundliTextSecondary)

            Text("No festivals this month")
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Upcoming List View

    private var upcomingListView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Today's festivals section
                if !todaysFestivals.isEmpty {
                    festivalSection(
                        title: "Today",
                        icon: "sun.max.fill",
                        festivals: todaysFestivals,
                        showBadge: true
                    )
                }

                // This week
                if !thisWeekFestivals.isEmpty {
                    festivalSection(
                        title: "This Week",
                        icon: "calendar",
                        festivals: thisWeekFestivals
                    )
                }

                // Upcoming
                festivalSection(
                    title: "Upcoming",
                    icon: "calendar.badge.clock",
                    festivals: upcomingFestivals
                )

                Spacer()
                    .frame(height: 20)
            }
            .padding(16)
        }
    }

    private func festivalSection(
        title: String,
        icon: String,
        festivals: [FestivalInstance],
        showBadge: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.kundliPrimary)

                Text(title)
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                if showBadge {
                    Text("\(festivals.count)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.kundliBackground)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.kundliPrimary))
                }
            }

            VStack(spacing: 10) {
                ForEach(festivals) { festival in
                    festivalRow(festival)
                        .onTapGesture {
                            selectedFestival = festival
                        }
                }
            }
        }
    }

    // MARK: - Festival Row

    private func festivalRow(_ instance: FestivalInstance) -> some View {
        HStack(spacing: 12) {
            // Category icon
            ZStack {
                Circle()
                    .fill(categoryColor(instance.festival.category).opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: instance.festival.icon)
                    .font(.system(size: 18))
                    .foregroundColor(categoryColor(instance.festival.category))
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(instance.festival.name)
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliTextPrimary)

                HStack(spacing: 8) {
                    Text(instance.shortDate)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)

                    if let deity = instance.festival.deity {
                        Text("• \(deity)")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextTertiary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            // Days until
            if let daysUntil = instance.daysUntil {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(daysUntil)")
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliPrimary)

                    Text(daysUntil == 1 ? "day" : "days")
                        .font(.system(size: 9))
                        .foregroundColor(.kundliTextSecondary)
                }
            } else if instance.isToday {
                Text("Today")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliBackground)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.kundliPrimary))
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.kundliTextTertiary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(instance.isToday ? Color.kundliPrimary.opacity(0.1) : Color.kundliCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            instance.isToday ? Color.kundliPrimary.opacity(0.3) : Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
        )
    }

    // MARK: - Helpers

    private func categoryColor(_ category: FestivalCategory) -> Color {
        switch category {
        case .major: return .kundliPrimary
        case .religious: return .orange
        case .fasting: return .green
        case .auspicious: return .kundliInfo
        case .regional: return .purple
        case .newYear: return .red
        case .grahaPravesh: return .teal
        }
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }

    private func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: selectedMonth) {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedMonth = newDate
            }
        }
    }

    private var festivalsForSelectedMonth: [FestivalInstance] {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: selectedMonth)
        let year = calendar.component(.year, from: selectedMonth)
        return festivalService.getFestivalsForMonth(month: month, year: year)
    }

    private var todaysFestivals: [FestivalInstance] {
        festivalService.getTodaysFestivals()
    }

    private var thisWeekFestivals: [FestivalInstance] {
        let calendar = Calendar.current
        let weekFromNow = calendar.date(byAdding: .day, value: 7, to: Date()) ?? Date()

        return festivalService.getUpcomingFestivals(limit: 20)
            .filter { instance in
                instance.date > Date() && instance.date <= weekFromNow
            }
    }

    private var upcomingFestivals: [FestivalInstance] {
        festivalService.getUpcomingFestivals(limit: 15)
    }
}

// MARK: - View Mode

enum FestivalViewMode: String, CaseIterable {
    case list = "List"
    case calendar = "Calendar"

    var icon: String {
        switch self {
        case .list: return "list.bullet"
        case .calendar: return "calendar"
        }
    }
}

#Preview {
    NavigationStack {
        FestivalCalendarView()
    }
}
