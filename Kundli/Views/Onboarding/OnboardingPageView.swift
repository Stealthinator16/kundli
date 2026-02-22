import SwiftUI

/// A single page in the onboarding carousel
struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Visual content (icon or visual aid)
            if let visualAid = page.visualAid {
                OnboardingVisualAidView(type: visualAid)
                    .padding(.bottom, 8)
            } else {
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
            }

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

// MARK: - Visual Aid Views

struct OnboardingVisualAidView: View {
    let type: OnboardingVisualAid

    var body: some View {
        switch type {
        case .zodiacComparison:
            ZodiacComparisonVisual()
        case .miniChart:
            MiniChartVisual()
        case .tappableDemo:
            TappableDemoVisual()
        }
    }
}

struct ZodiacComparisonVisual: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Western")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)

                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 70, height: 70)

                        VStack(spacing: 2) {
                            Text("Mar 21")
                                .font(.kundliCaption2)
                                .foregroundColor(.kundliTextSecondary)
                        }
                    }
                }

                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 20))
                    .foregroundColor(.kundliPrimary)

                VStack(spacing: 8) {
                    Text("Vedic")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)

                    ZStack {
                        Circle()
                            .fill(Color.kundliPrimary.opacity(0.2))
                            .frame(width: 70, height: 70)

                        VStack(spacing: 2) {
                            Text("Apr 14")
                                .font(.kundliCaption2)
                                .foregroundColor(.kundliTextSecondary)
                        }
                    }
                }
            }

            Text("~24° Difference")
                .font(.kundliCaption)
                .foregroundColor(.kundliPrimary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.kundliCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct MiniChartVisual: View {
    var body: some View {
        VStack(spacing: 12) {
            // Simplified chart representation
            ZStack {
                // Outer square
                Rectangle()
                    .stroke(Color.kundliPrimary.opacity(0.5), lineWidth: 2)
                    .frame(width: 140, height: 140)

                // Inner diagonals (simplified)
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 140, y: 140))
                    path.move(to: CGPoint(x: 140, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: 140))
                }
                .stroke(Color.kundliPrimary.opacity(0.3), lineWidth: 1)

                // Center label
                VStack(spacing: 2) {
                    Text("You")
                        .font(.kundliCaption2)
                        .foregroundColor(.kundliTextSecondary)
                }

                // Planet indicators
                Circle()
                    .fill(Color.orange)
                    .frame(width: 12, height: 12)
                    .offset(x: -40, y: -40)

                Circle()
                    .fill(Color.white)
                    .frame(width: 12, height: 12)
                    .offset(x: 40, y: -20)

                Circle()
                    .fill(Color.yellow)
                    .frame(width: 12, height: 12)
                    .offset(x: 30, y: 40)
            }

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Circle().fill(Color.orange).frame(width: 8, height: 8)
                    Text("Sun").font(.kundliCaption2).foregroundColor(.kundliTextSecondary)
                }
                HStack(spacing: 4) {
                    Circle().fill(Color.white).frame(width: 8, height: 8)
                    Text("Moon").font(.kundliCaption2).foregroundColor(.kundliTextSecondary)
                }
                HStack(spacing: 4) {
                    Circle().fill(Color.yellow).frame(width: 8, height: 8)
                    Text("Jupiter").font(.kundliCaption2).foregroundColor(.kundliTextSecondary)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.kundliCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct TappableDemoVisual: View {
    @State private var demoTapped = false

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Text("Today's Tithi:")
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliTextSecondary)

                Button {
                    withAnimation(.spring(response: 0.3)) {
                        demoTapped = true
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("Shukla Dwadashi")
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextPrimary)

                        Image(systemName: "info.circle")
                            .font(.system(size: 10))
                            .foregroundColor(.kundliPrimary.opacity(0.5))
                    }
                }
                .buttonStyle(.plain)
            }

            if demoTapped {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Shukla Dwadashi")
                        .font(.kundliCaption)
                        .fontWeight(.semibold)
                        .foregroundColor(.kundliPrimary)

                    Text("The 12th lunar day of the bright fortnight")
                        .font(.kundliCaption2)
                        .foregroundColor(.kundliTextSecondary)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.kundliPrimary.opacity(0.1))
                )
                .transition(.scale.combined(with: .opacity))
            } else {
                Text("Tap the term above!")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliPrimary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.kundliCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

/// Model for onboarding page content
struct OnboardingPage: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let description: String
    let visualAid: OnboardingVisualAid?

    init(iconName: String, title: String, description: String, visualAid: OnboardingVisualAid? = nil) {
        self.iconName = iconName
        self.title = title
        self.description = description
        self.visualAid = visualAid
    }
}

/// Types of visual aids for educational onboarding slides
enum OnboardingVisualAid {
    case zodiacComparison    // Shows sidereal vs tropical difference
    case miniChart           // Simplified chart preview
    case tappableDemo        // Interactive demo of tappable terms
}

// MARK: - Default Pages

extension OnboardingPage {
    static let pages: [OnboardingPage] = [
        // 1. Welcome
        OnboardingPage(
            iconName: "sparkles",
            title: "Welcome to Kundli",
            description: "Your guide to understanding Vedic astrology - the ancient Indian science of light that has guided millions for over 5,000 years."
        ),

        // 2. What is Vedic Astrology (NEW EDUCATIONAL)
        OnboardingPage(
            iconName: "globe.asia.australia.fill",
            title: "5,000 Years of Wisdom",
            description: "Vedic astrology (Jyotish) uses the sidereal zodiac - aligned with actual star positions - making predictions remarkably precise. Your Vedic sign may differ from your Western sign!",
            visualAid: .zodiacComparison
        ),

        // 3. Your Birth Chart (NEW EDUCATIONAL)
        OnboardingPage(
            iconName: "chart.pie.fill",
            title: "Your Cosmic Blueprint",
            description: "Your Kundli captures the exact positions of 9 planets across 12 houses and 27 star constellations (nakshatras) at your birth moment. Each placement reveals different aspects of your life.",
            visualAid: .miniChart
        ),

        // 4. Learning Promise (NEW EDUCATIONAL)
        OnboardingPage(
            iconName: "lightbulb.fill",
            title: "We'll Guide You",
            description: "Don't worry about Sanskrit terms or complex calculations. Tap any highlighted concept in the app to learn what it means. Understanding your chart is easier than you think!",
            visualAid: .tappableDemo
        ),

        // 5. Get Started
        OnboardingPage(
            iconName: "arrow.right.circle.fill",
            title: "Create Your Kundli",
            description: "Enter your birth details and discover what the stars reveal about you. Your personalized cosmic journey begins now."
        )
    ]
}

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()
        OnboardingPageView(page: OnboardingPage.pages[0])
    }
}
