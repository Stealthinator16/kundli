import SwiftUI

struct ExtendedHoroscopeView: View {
    let sign: ZodiacSign
    @State private var selectedPeriod: HoroscopePeriod = .daily

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Sign header
                    signHeader

                    // Period selector
                    periodSelector

                    // Content based on selected period
                    switch selectedPeriod {
                    case .daily:
                        dailyContent
                    case .weekly:
                        weeklyContent
                    case .monthly:
                        monthlyContent
                    }

                    // Planetary influences
                    planetaryInfluencesSection

                    Spacer()
                        .frame(height: 20)
                }
                .padding(16)
            }
        }
        .navigationTitle("Horoscope")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    // MARK: - Sign Header

    private var signHeader: some View {
        HStack(spacing: 16) {
            // Sign circle
            ZStack {
                Circle()
                    .fill(LinearGradient.kundliGold)
                    .frame(width: 60, height: 60)

                Text(sign.symbol)
                    .font(.system(size: 30))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(sign.rawValue)
                    .font(.kundliTitle3)
                    .foregroundColor(.kundliTextPrimary)

                Text(sign.vedName)
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliTextSecondary)

                Text("Ruled by \(sign.lord)")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliPrimary)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.kundliCardBg)
        )
    }

    // MARK: - Period Selector

    private var periodSelector: some View {
        HStack(spacing: 0) {
            ForEach(HoroscopePeriod.allCases, id: \.self) { period in
                periodButton(period)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.kundliCardBg)
        )
    }

    private func periodButton(_ period: HoroscopePeriod) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPeriod = period
            }
        } label: {
            Text(period.rawValue)
                .font(.kundliSubheadline)
                .fontWeight(selectedPeriod == period ? .semibold : .regular)
                .foregroundColor(selectedPeriod == period ? .kundliBackground : .kundliTextSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedPeriod == period ? Color.kundliPrimary : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Daily Content

    private var dailyContent: some View {
        VStack(spacing: 16) {
            // Today's overview
            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Today's Overview")
                            .font(.kundliHeadline)
                            .foregroundColor(.kundliTextPrimary)

                        Spacer()

                        Text(formattedDate(Date()))
                            .font(.kundliCaption)
                            .foregroundColor(.kundliPrimary)
                    }

                    Text(generateDailyPrediction())
                        .font(.kundliBody)
                        .foregroundColor(.kundliTextSecondary)
                        .lineSpacing(6)
                }
            }

            // Daily ratings
            dailyRatingsCard
        }
    }

    private var dailyRatingsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Today's Aspects")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                HStack(spacing: 0) {
                    aspectRating(icon: "heart.fill", label: "Love", rating: randomRating(), color: .pink)
                    aspectRating(icon: "briefcase.fill", label: "Career", rating: randomRating(), color: .blue)
                    aspectRating(icon: "heart.text.square.fill", label: "Health", rating: randomRating(), color: .green)
                    aspectRating(icon: "indianrupeesign.circle.fill", label: "Wealth", rating: randomRating(), color: .yellow)
                }
            }
        }
    }

    // MARK: - Weekly Content

    private var weeklyContent: some View {
        VStack(spacing: 16) {
            // Week overview
            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("This Week")
                            .font(.kundliHeadline)
                            .foregroundColor(.kundliTextPrimary)

                        Spacer()

                        Text(weekDateRange)
                            .font(.kundliCaption)
                            .foregroundColor(.kundliPrimary)
                    }

                    Text(generateWeeklyOverview())
                        .font(.kundliBody)
                        .foregroundColor(.kundliTextSecondary)
                        .lineSpacing(6)
                }
            }

            // Day by day highlights
            CardView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Day-by-Day Highlights")
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliTextPrimary)

                    ForEach(weekDays, id: \.self) { day in
                        dayHighlightRow(day: day)

                        if day != weekDays.last {
                            Divider()
                                .background(Color.white.opacity(0.1))
                        }
                    }
                }
            }

            // Best and challenging days
            HStack(spacing: 12) {
                bestDayCard
                challengingDayCard
            }
        }
    }

    private var weekDays: [Date] {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) ?? today

        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: startOfWeek)
        }
    }

    private var weekDateRange: String {
        guard let first = weekDays.first, let last = weekDays.last else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: first)) - \(formatter.string(from: last))"
    }

    private func dayHighlightRow(day: Date) -> some View {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(day)
        let dayName = formattedDayName(day)
        let rating = dayRating(for: day)

        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(dayName)
                        .font(.kundliSubheadline)
                        .fontWeight(isToday ? .semibold : .regular)
                        .foregroundColor(isToday ? .kundliPrimary : .kundliTextPrimary)

                    if isToday {
                        Text("TODAY")
                            .font(.kundliCaption2)
                            .foregroundColor(.kundliBackground)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.kundliPrimary)
                            )
                    }
                }

                Text(getDayHighlight(for: day))
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)
            }

            Spacer()

            // Rating dots
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { index in
                    Circle()
                        .fill(index <= rating ? Color.kundliPrimary : Color.kundliPrimary.opacity(0.2))
                        .frame(width: 8, height: 8)
                }
            }
        }
    }

    private var bestDayCard: some View {
        CardView {
            VStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.kundliSuccess)

                Text("Best Day")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)

                Text(bestDayOfWeek)
                    .font(.kundliSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.kundliTextPrimary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var challengingDayCard: some View {
        CardView {
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.kundliWarning)

                Text("Be Cautious")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)

                Text(challengingDayOfWeek)
                    .font(.kundliSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.kundliTextPrimary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var bestDayOfWeek: String {
        switch sign {
        case .aries, .scorpio: return "Tuesday"
        case .taurus, .libra: return "Friday"
        case .gemini, .virgo: return "Wednesday"
        case .cancer: return "Monday"
        case .leo: return "Sunday"
        case .sagittarius, .pisces: return "Thursday"
        case .capricorn, .aquarius: return "Saturday"
        }
    }

    private var challengingDayOfWeek: String {
        // Typically 6th from the lucky day
        switch sign {
        case .aries, .scorpio: return "Saturday"
        case .taurus, .libra: return "Tuesday"
        case .gemini, .virgo: return "Thursday"
        case .cancer: return "Saturday"
        case .leo: return "Saturday"
        case .sagittarius, .pisces: return "Wednesday"
        case .capricorn, .aquarius: return "Monday"
        }
    }

    // MARK: - Monthly Content

    private var monthlyContent: some View {
        VStack(spacing: 16) {
            // Month overview
            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("This Month")
                            .font(.kundliHeadline)
                            .foregroundColor(.kundliTextPrimary)

                        Spacer()

                        Text(currentMonthName)
                            .font(.kundliCaption)
                            .foregroundColor(.kundliPrimary)
                    }

                    Text(generateMonthlyOverview())
                        .font(.kundliBody)
                        .foregroundColor(.kundliTextSecondary)
                        .lineSpacing(6)
                }
            }

            // Key dates
            CardView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Key Dates to Remember")
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliTextPrimary)

                    ForEach(keyDates, id: \.date) { keyDate in
                        keyDateRow(keyDate)

                        if keyDate.date != keyDates.last?.date {
                            Divider()
                                .background(Color.white.opacity(0.1))
                        }
                    }
                }
            }

            // Monthly themes
            monthlyThemesCard

            // Monthly ratings
            monthlyRatingsCard
        }
    }

    private var currentMonthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }

    private var keyDates: [(date: String, event: String, type: KeyDateType)] {
        [
            (date: "5th", event: "Favorable for new beginnings", type: .favorable),
            (date: "11th", event: "Career opportunities arise", type: .favorable),
            (date: "15th", event: "Full Moon - heightened emotions", type: .neutral),
            (date: "19th", event: "Avoid major decisions", type: .cautious),
            (date: "25th", event: "Financial gains possible", type: .favorable),
            (date: "29th", event: "New Moon - fresh start", type: .neutral)
        ]
    }

    private func keyDateRow(_ keyDate: (date: String, event: String, type: KeyDateType)) -> some View {
        HStack(spacing: 12) {
            Text(keyDate.date)
                .font(.kundliSubheadline)
                .fontWeight(.semibold)
                .foregroundColor(.kundliTextPrimary)
                .frame(width: 40)

            Circle()
                .fill(keyDate.type.color)
                .frame(width: 8, height: 8)

            Text(keyDate.event)
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)

            Spacer()
        }
    }

    private var monthlyThemesCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Monthly Themes")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    themeItem(icon: "briefcase.fill", title: "Career", description: "Focus on growth")
                    themeItem(icon: "heart.fill", title: "Love", description: "Open communication")
                    themeItem(icon: "dollarsign.circle.fill", title: "Finance", description: "Save wisely")
                    themeItem(icon: "figure.mind.and.body", title: "Health", description: "Self-care priority")
                }
            }
        }
    }

    private func themeItem(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.kundliPrimary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.kundliCaption)
                    .fontWeight(.medium)
                    .foregroundColor(.kundliTextPrimary)

                Text(description)
                    .font(.kundliCaption2)
                    .foregroundColor(.kundliTextSecondary)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.03))
        )
    }

    private var monthlyRatingsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Monthly Outlook")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                VStack(spacing: 12) {
                    monthlyRatingBar(label: "Career", rating: 0.8, color: .blue)
                    monthlyRatingBar(label: "Love", rating: 0.7, color: .pink)
                    monthlyRatingBar(label: "Health", rating: 0.85, color: .green)
                    monthlyRatingBar(label: "Finance", rating: 0.65, color: .yellow)
                    monthlyRatingBar(label: "Spirituality", rating: 0.75, color: .purple)
                }
            }
        }
    }

    private func monthlyRatingBar(label: String, rating: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)

                Spacer()

                Text("\(Int(rating * 100))%")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextPrimary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * rating, height: 8)
                }
            }
            .frame(height: 8)
        }
    }

    // MARK: - Planetary Influences

    private var planetaryInfluencesSection: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20))
                        .foregroundColor(.kundliPrimary)

                    Text("Planetary Influences")
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliTextPrimary)

                    Spacer()
                }

                Text(getPlanetaryInfluenceText())
                    .font(.kundliBody)
                    .foregroundColor(.kundliTextSecondary)
                    .lineSpacing(6)

                // Key planets
                VStack(alignment: .leading, spacing: 8) {
                    Text("Key Planetary Transits:")
                        .font(.kundliSubheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.kundliTextPrimary)

                    ForEach(keyTransits, id: \.planet) { transit in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(transit.isPositive ? Color.kundliSuccess : Color.kundliWarning)
                                .frame(width: 6, height: 6)

                            Text("\(transit.planet): \(transit.effect)")
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)
                        }
                    }
                }
            }
        }
    }

    private var keyTransits: [(planet: String, effect: String, isPositive: Bool)] {
        [
            (planet: "Jupiter", effect: "Supporting growth and expansion", isPositive: true),
            (planet: "Saturn", effect: "Encouraging discipline and patience", isPositive: true),
            (planet: "Mars", effect: "Boosting energy and initiative", isPositive: true),
            (planet: "Rahu", effect: "Creating unexpected opportunities", isPositive: false)
        ]
    }

    // MARK: - Helper Methods

    private func aspectRating(icon: String, label: String, rating: Int, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(label)
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)

            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { index in
                    Circle()
                        .fill(index <= rating ? color : color.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }

    private func formattedDayName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    private func randomRating() -> Int {
        Int.random(in: 3...5)
    }

    private func dayRating(for date: Date) -> Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        // Rating based on day of week and sign
        return max(2, min(5, 3 + (weekday + sign.number) % 3))
    }

    private func getDayHighlight(for date: Date) -> String {
        let highlights = [
            "Good for communication and networking",
            "Focus on financial matters",
            "Ideal for creative pursuits",
            "Rest and recuperation advised",
            "Career opportunities emerge",
            "Favorable for relationships",
            "Spiritual and reflective day"
        ]
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        return highlights[(weekday - 1) % highlights.count]
    }

    private func generateDailyPrediction() -> String {
        "Today brings positive energy for \(sign.rawValue) natives. The planetary alignments suggest a balanced day with opportunities for growth. Pay attention to your intuition as it will guide you well. Communication flows naturally, making it a good day for important conversations and negotiations."
    }

    private func generateWeeklyOverview() -> String {
        "This week holds promising developments for \(sign.rawValue). The early part of the week favors professional pursuits, while the weekend is better suited for personal relationships and relaxation. Watch for opportunities around midweek - they may lead to significant progress in your goals. Overall, maintain balance between work and personal life for optimal results."
    }

    private func generateMonthlyOverview() -> String {
        "The month ahead for \(sign.rawValue) emphasizes personal growth and transformation. With \(sign.lord) well-positioned, you can expect support in your endeavors. The first half of the month is particularly favorable for initiating new projects, while the second half is better for consolidation and completion. Financial matters require attention around the 15th. Relationships deepen through honest communication. Health remains stable with proper self-care routines."
    }

    private func getPlanetaryInfluenceText() -> String {
        "The current planetary configuration is generally supportive for \(sign.rawValue). Your ruling planet \(sign.lord) is well-aspected, bringing stability and clarity to your decisions. Jupiter's transit brings opportunities for expansion, while Saturn encourages disciplined progress. Pay attention to the Moon's phases for optimal timing of important activities."
    }
}

// MARK: - Supporting Types

enum HoroscopePeriod: String, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
}

enum KeyDateType {
    case favorable
    case cautious
    case neutral

    var color: Color {
        switch self {
        case .favorable: return .kundliSuccess
        case .cautious: return .kundliWarning
        case .neutral: return .kundliInfo
        }
    }
}

#Preview {
    NavigationStack {
        ExtendedHoroscopeView(sign: .scorpio)
    }
}
