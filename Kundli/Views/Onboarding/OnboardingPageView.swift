import SwiftUI

/// A single page in the onboarding carousel
struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.kundliPrimary.opacity(0.3),
                                Color.kundliPrimary.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 160, height: 160)

                Image(systemName: page.iconName)
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(
                        LinearGradient.kundliGold
                    )
            }
            .padding(.bottom, 16)

            // Title
            Text(page.title)
                .font(.kundliTitle)
                .foregroundColor(.kundliTextPrimary)
                .multilineTextAlignment(.center)

            // Description
            Text(page.description)
                .font(.kundliBody)
                .foregroundColor(.kundliTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 24)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

/// Model for onboarding page content
struct OnboardingPage: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let description: String
}

// MARK: - Default Pages

extension OnboardingPage {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            iconName: "sparkles",
            title: "Welcome to Kundli",
            description: "Discover the ancient wisdom of Vedic astrology. Get personalized insights based on your birth chart."
        ),
        OnboardingPage(
            iconName: "chart.pie.fill",
            title: "Create Your Kundli",
            description: "Generate accurate birth charts with detailed planetary positions, nakshatras, and house placements."
        ),
        OnboardingPage(
            iconName: "calendar.badge.clock",
            title: "Daily Panchang",
            description: "Stay aligned with cosmic rhythms. Check tithi, nakshatra, yoga, and auspicious timings every day."
        ),
        OnboardingPage(
            iconName: "heart.circle.fill",
            title: "Kundli Matching",
            description: "Find compatibility through traditional Gun Milan. Compare charts for marriage and relationships."
        )
    ]
}

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()
        OnboardingPageView(page: OnboardingPage.pages[0])
    }
}
