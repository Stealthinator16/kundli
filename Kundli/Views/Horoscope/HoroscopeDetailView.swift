import SwiftUI

struct HoroscopeDetailView: View {
    let horoscope: DailyHoroscope
    @State private var selectedCategory: HoroscopeCategory = .overview

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header with sign info
                    headerSection

                    // Category tabs
                    categoryTabs

                    // Content based on selected category
                    categoryContent

                    // Lucky elements section
                    luckyElementsSection

                    // Favorable times
                    favorableTimesSection

                    // Advice section
                    adviceSection

                    Spacer()
                        .frame(height: 20)
                }
                .padding(16)
            }
        }
        .navigationTitle("Daily Horoscope")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        CardView {
            VStack(spacing: 16) {
                // Sign symbol and name
                HStack(spacing: 16) {
                    // Sign circle
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient.kundliGold
                            )
                            .frame(width: 80, height: 80)

                        Text(horoscope.sign.symbol)
                            .font(.system(size: 40))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(horoscope.sign.rawValue)
                            .font(.kundliTitle2)
                            .foregroundColor(.kundliTextPrimary)

                        Text(horoscope.sign.vedName)
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextSecondary)

                        Text(formattedDate)
                            .font(.kundliCaption)
                            .foregroundColor(.kundliPrimary)
                    }

                    Spacer()

                    // Overall rating
                    VStack(spacing: 4) {
                        Text("Overall")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)

                        ratingStars(rating: horoscope.overallRating)

                        Text(ratingDescription(horoscope.overallRating))
                            .font(.kundliCaption)
                            .foregroundColor(ratingColor(horoscope.overallRating))
                    }
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                // Ratings row
                HStack(spacing: 0) {
                    ratingItem(icon: "heart.fill", label: "Love", rating: horoscope.loveRating, color: .pink)
                    ratingItem(icon: "briefcase.fill", label: "Career", rating: horoscope.careerRating, color: .blue)
                    ratingItem(icon: "heart.text.square.fill", label: "Health", rating: horoscope.healthRating, color: .green)
                }
            }
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: horoscope.date)
    }

    private func ratingStars(rating: Int) -> some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .font(.system(size: 14))
                    .foregroundColor(.kundliPrimary)
            }
        }
    }

    private func ratingItem(icon: String, label: String, rating: Int, color: Color) -> some View {
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
                        .frame(width: 8, height: 8)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func ratingDescription(_ rating: Int) -> String {
        switch rating {
        case 1: return "Challenging"
        case 2: return "Moderate"
        case 3: return "Good"
        case 4: return "Very Good"
        case 5: return "Excellent"
        default: return "Neutral"
        }
    }

    private func ratingColor(_ rating: Int) -> Color {
        switch rating {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        case 5: return .kundliSuccess
        default: return .kundliTextSecondary
        }
    }

    // MARK: - Category Tabs

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(HoroscopeCategory.allCases, id: \.self) { category in
                    categoryTab(category)
                }
            }
        }
    }

    private func categoryTab(_ category: HoroscopeCategory) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 14))

                Text(category.rawValue)
                    .font(.kundliSubheadline)
            }
            .foregroundColor(selectedCategory == category ? .kundliBackground : .kundliTextPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(selectedCategory == category ? Color.kundliPrimary : Color.kundliCardBg)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Category Content

    @ViewBuilder
    private var categoryContent: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: selectedCategory.icon)
                        .font(.system(size: 20))
                        .foregroundColor(.kundliPrimary)

                    Text(selectedCategory.rawValue)
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliTextPrimary)

                    Spacer()
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                Text(getCategoryPrediction(selectedCategory))
                    .font(.kundliBody)
                    .foregroundColor(.kundliTextSecondary)
                    .lineSpacing(6)

                // Category-specific tips
                if let tips = getCategoryTips(selectedCategory) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tips for today:")
                            .font(.kundliSubheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.kundliTextPrimary)

                        ForEach(tips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.kundliPrimary)
                                    .padding(.top, 2)

                                Text(tip)
                                    .font(.kundliCaption)
                                    .foregroundColor(.kundliTextSecondary)
                            }
                        }
                    }
                }
            }
        }
    }

    private func getCategoryPrediction(_ category: HoroscopeCategory) -> String {
        switch category {
        case .overview:
            return horoscope.prediction + "\n\nPlanetary alignments suggest a balanced day ahead. Pay attention to the cosmic energies and use them to your advantage. The universe is guiding you toward growth and self-improvement."
        case .love:
            return generateLovePrediction()
        case .career:
            return generateCareerPrediction()
        case .health:
            return generateHealthPrediction()
        case .wealth:
            return generateWealthPrediction()
        }
    }

    private func getCategoryTips(_ category: HoroscopeCategory) -> [String]? {
        switch category {
        case .overview:
            return [
                "Start your day with positive affirmations",
                "Trust your intuition in important decisions",
                "Stay open to unexpected opportunities"
            ]
        case .love:
            return [
                "Express your feelings openly",
                "Plan a special activity with your loved one",
                "Practice active listening in conversations"
            ]
        case .career:
            return [
                "Focus on completing pending tasks",
                "Network with colleagues and peers",
                "Document your achievements"
            ]
        case .health:
            return [
                "Stay hydrated throughout the day",
                "Take short breaks to stretch",
                "Practice deep breathing exercises"
            ]
        case .wealth:
            return [
                "Review your budget and expenses",
                "Avoid impulsive purchases",
                "Consider long-term investment options"
            ]
        }
    }

    private func generateLovePrediction() -> String {
        let rating = horoscope.loveRating
        var prediction = ""

        if rating >= 4 {
            prediction = "Romance is in the air! This is an excellent day for matters of the heart. If you're in a relationship, expect deeper emotional connections and meaningful conversations with your partner. Single? The stars favor new romantic encounters."
        } else if rating >= 3 {
            prediction = "A balanced day for love and relationships. Communication flows naturally with your partner. Take time to appreciate the small moments together. For singles, social activities may lead to interesting connections."
        } else {
            prediction = "Today may bring minor challenges in relationships. Practice patience and avoid unnecessary conflicts. Focus on self-love and personal growth. This is a good day for introspection about what you truly want in a partner."
        }

        prediction += "\n\nVenus influences suggest focusing on emotional honesty and vulnerability. Let your true feelings guide your romantic decisions today."

        return prediction
    }

    private func generateCareerPrediction() -> String {
        let rating = horoscope.careerRating
        var prediction = ""

        if rating >= 4 {
            prediction = "An outstanding day for professional growth! Your hard work will be recognized, and new opportunities may present themselves. Take initiative on projects and don't hesitate to share your ideas with superiors. Leadership qualities will shine."
        } else if rating >= 3 {
            prediction = "A steady day at work with good progress on ongoing tasks. Collaboration with colleagues will be productive. Focus on completing pending projects and organizing your workspace. New opportunities may develop through networking."
        } else {
            prediction = "Work may feel more challenging today. Stay focused and avoid getting caught up in office politics. Double-check important documents and communications. Use this time to plan and strategize for future projects."
        }

        prediction += "\n\nMercury's position favors clear communication. Express your professional goals and aspirations clearly to those who matter."

        return prediction
    }

    private func generateHealthPrediction() -> String {
        let rating = horoscope.healthRating
        var prediction = ""

        if rating >= 4 {
            prediction = "Your vitality is at its peak! Energy levels are high, making this an excellent day for physical activities and exercise. Mental clarity is also strong - use this to tackle complex tasks. Your immune system is robust."
        } else if rating >= 3 {
            prediction = "A balanced day for health and well-being. Maintain your regular health routines and they will serve you well. Pay attention to nutrition and ensure adequate rest. Moderate exercise will help maintain energy levels."
        } else {
            prediction = "Take extra care of your health today. Avoid overexertion and listen to your body's signals. Focus on rest and recovery if needed. Stress management techniques like meditation may be particularly beneficial."
        }

        prediction += "\n\nThe Moon's influence suggests paying attention to your emotional well-being. A calm mind supports a healthy body."

        return prediction
    }

    private func generateWealthPrediction() -> String {
        var prediction = ""
        let overallRating = horoscope.overallRating

        if overallRating >= 4 {
            prediction = "Financial prospects look favorable today! This is a good time to review investments and consider new financial opportunities. Unexpected gains are possible through careful planning and timely action."
        } else if overallRating >= 3 {
            prediction = "A stable day for financial matters. Stick to your budget and avoid impulsive spending. Long-term investments continue to grow steadily. Consider seeking advice on financial planning if needed."
        } else {
            prediction = "Exercise caution in financial dealings today. Avoid major purchases or risky investments. Focus on saving and reducing unnecessary expenses. This is a good day to create or review your financial goals."
        }

        prediction += "\n\nJupiter's influence encourages wise financial decisions. Trust your instincts but also seek counsel from those with experience."

        return prediction
    }

    // MARK: - Lucky Elements Section

    private var luckyElementsSection: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20))
                        .foregroundColor(.kundliPrimary)

                    Text("Lucky Elements")
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliTextPrimary)

                    Spacer()
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                // Grid of lucky elements
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    luckyElementItem(icon: "number.circle.fill", title: "Number", value: "\(horoscope.luckyNumber)")
                    luckyElementItem(icon: "paintpalette.fill", title: "Color", value: horoscope.luckyColor)
                    luckyElementItem(icon: "arrow.up.right.circle.fill", title: "Direction", value: luckyDirection)
                    luckyElementItem(icon: "calendar.circle.fill", title: "Day", value: luckyDay)
                    luckyElementItem(icon: "clock.fill", title: "Time", value: luckyTime)
                    luckyElementItem(icon: "character.textbox", title: "Letter", value: luckyLetter)
                }
            }
        }
    }

    private func luckyElementItem(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.kundliPrimary)

            Text(title)
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)

            Text(value)
                .font(.kundliSubheadline)
                .fontWeight(.medium)
                .foregroundColor(.kundliTextPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    // Lucky element computed properties based on sign
    private var luckyDirection: String {
        switch horoscope.sign {
        case .aries, .leo, .sagittarius: return "East"
        case .taurus, .virgo, .capricorn: return "South"
        case .gemini, .libra, .aquarius: return "West"
        case .cancer, .scorpio, .pisces: return "North"
        }
    }

    private var luckyDay: String {
        switch horoscope.sign {
        case .aries, .scorpio: return "Tuesday"
        case .taurus, .libra: return "Friday"
        case .gemini, .virgo: return "Wednesday"
        case .cancer: return "Monday"
        case .leo: return "Sunday"
        case .sagittarius, .pisces: return "Thursday"
        case .capricorn, .aquarius: return "Saturday"
        }
    }

    private var luckyTime: String {
        switch horoscope.sign {
        case .aries, .leo, .sagittarius: return "Morning"
        case .taurus, .virgo, .capricorn: return "Afternoon"
        case .gemini, .libra, .aquarius: return "Evening"
        case .cancer, .scorpio, .pisces: return "Night"
        }
    }

    private var luckyLetter: String {
        switch horoscope.sign {
        case .aries: return "A, L"
        case .taurus: return "B, V"
        case .gemini: return "C, G"
        case .cancer: return "D, H"
        case .leo: return "M, T"
        case .virgo: return "P, N"
        case .libra: return "R, T"
        case .scorpio: return "N, Y"
        case .sagittarius: return "B, D"
        case .capricorn: return "K, J"
        case .aquarius: return "G, S"
        case .pisces: return "D, C"
        }
    }

    // MARK: - Favorable Times Section

    private var favorableTimesSection: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "clock.badge.checkmark")
                        .font(.system(size: 20))
                        .foregroundColor(.kundliPrimary)

                    Text("Favorable & Unfavorable Times")
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliTextPrimary)

                    Spacer()
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                // Favorable times
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.kundliSuccess)
                        Text("Favorable Times")
                            .font(.kundliSubheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.kundliTextPrimary)
                    }

                    ForEach(favorableTimes, id: \.self) { time in
                        HStack(spacing: 8) {
                            Text("•")
                                .foregroundColor(.kundliSuccess)
                            Text(time)
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)
                        }
                    }
                }

                // Unfavorable times
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.kundliError)
                        Text("Avoid Important Activities")
                            .font(.kundliSubheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.kundliTextPrimary)
                    }

                    ForEach(unfavorableTimes, id: \.self) { time in
                        HStack(spacing: 8) {
                            Text("•")
                                .foregroundColor(.kundliError)
                            Text(time)
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)
                        }
                    }
                }
            }
        }
    }

    private var favorableTimes: [String] {
        ["6:00 AM - 8:00 AM (Brahma Muhurta period)", "10:30 AM - 12:00 PM (Productive work)", "4:00 PM - 5:30 PM (Creative activities)"]
    }

    private var unfavorableTimes: [String] {
        ["9:00 AM - 10:30 AM (Rahu Kaal)", "3:00 PM - 4:30 PM (Yamagandam)"]
    }

    // MARK: - Advice Section

    private var adviceSection: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "quote.bubble.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.kundliPrimary)

                    Text("Today's Guidance")
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliTextPrimary)

                    Spacer()
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                Text(getDailyAdvice())
                    .font(.kundliBody)
                    .italic()
                    .foregroundColor(.kundliTextSecondary)
                    .lineSpacing(6)

                // Mantra of the day
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mantra of the Day")
                        .font(.kundliSubheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.kundliTextPrimary)

                    Text(getDailyMantra())
                        .font(.kundliSubheadline)
                        .italic()
                        .foregroundColor(.kundliPrimary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.kundliPrimary.opacity(0.1))
                        )
                }
            }
        }
    }

    private func getDailyAdvice() -> String {
        switch horoscope.sign {
        case .aries:
            return "Channel your natural energy into productive pursuits. Leadership opportunities await those who take initiative with wisdom and patience."
        case .taurus:
            return "Stability is your strength. Focus on building lasting foundations in relationships and finances. Small, consistent efforts lead to great results."
        case .gemini:
            return "Your quick wit serves you well today. Use your communication skills to bridge gaps and create understanding. Knowledge shared is wisdom multiplied."
        case .cancer:
            return "Trust your intuition - it's your greatest guide. Nurture yourself as you nurture others. Home and family bring the deepest satisfaction."
        case .leo:
            return "Let your inner light shine without dimming others. True leadership inspires rather than overshadows. Generosity returns manifold."
        case .virgo:
            return "Attention to detail brings rewards, but don't lose sight of the bigger picture. Perfect is the enemy of good. Progress matters more than perfection."
        case .libra:
            return "Balance requires constant adjustment. In seeking harmony, don't forget your own needs. Beautiful relationships begin with self-respect."
        case .scorpio:
            return "Your intensity is a gift when directed wisely. Transform challenges into opportunities. The phoenix rises stronger from each trial."
        case .sagittarius:
            return "Adventure awaits in both distant lands and nearby hearts. True freedom comes from wisdom, not just wandering. Aim your arrow with purpose."
        case .capricorn:
            return "Steady climbing leads to mountain peaks. Your discipline is admirable - ensure it serves your joy as well as your ambition."
        case .aquarius:
            return "Innovation flows through you. Use your unique perspective to benefit not just yourself but humanity. Connection in community brings strength."
        case .pisces:
            return "Dreams and reality dance together in your world. Trust your visions while staying grounded. Compassion is your superpower."
        }
    }

    private func getDailyMantra() -> String {
        switch horoscope.sign {
        case .aries: return "Om Kraam Kreem Kraum Sah Bhaumaya Namah"
        case .taurus: return "Om Draam Dreem Draum Sah Shukraya Namah"
        case .gemini: return "Om Braam Breem Braum Sah Budhaya Namah"
        case .cancer: return "Om Shraam Shreem Shraum Sah Chandramase Namah"
        case .leo: return "Om Hraam Hreem Hraum Sah Suryaya Namah"
        case .virgo: return "Om Braam Breem Braum Sah Budhaya Namah"
        case .libra: return "Om Draam Dreem Draum Sah Shukraya Namah"
        case .scorpio: return "Om Kraam Kreem Kraum Sah Bhaumaya Namah"
        case .sagittarius: return "Om Graam Greem Graum Sah Gurave Namah"
        case .capricorn: return "Om Praam Preem Praum Sah Shanaischaraya Namah"
        case .aquarius: return "Om Praam Preem Praum Sah Shanaischaraya Namah"
        case .pisces: return "Om Graam Greem Graum Sah Gurave Namah"
        }
    }
}

// MARK: - Horoscope Category

enum HoroscopeCategory: String, CaseIterable {
    case overview = "Overview"
    case love = "Love"
    case career = "Career"
    case health = "Health"
    case wealth = "Wealth"

    var icon: String {
        switch self {
        case .overview: return "sun.max.fill"
        case .love: return "heart.fill"
        case .career: return "briefcase.fill"
        case .health: return "heart.text.square.fill"
        case .wealth: return "indianrupeesign.circle.fill"
        }
    }
}

#Preview {
    NavigationStack {
        HoroscopeDetailView(
            horoscope: MockDataService.shared.dailyHoroscope(for: .scorpio)
        )
    }
}
