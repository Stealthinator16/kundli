import SwiftUI

/// Main onboarding view with carousel and navigation
struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    private let pages = OnboardingPage.pages

    var body: some View {
        ZStack {
            // Background
            Color.kundliBackground.ignoresSafeArea()

            // Animated gradient background
            AnimatedGradientBackground()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()

                    if currentPage < pages.count - 1 {
                        Button {
                            completeOnboarding()
                        } label: {
                            Text("Skip")
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliTextSecondary)
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 24)
                        .padding(.top, 16)
                    }
                }
                .frame(height: 44)

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Page indicator and buttons
                VStack(spacing: 32) {
                    // Custom page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(
                                    index == currentPage
                                        ? Color.kundliPrimary
                                        : Color.kundliTextSecondary.opacity(0.3)
                                )
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }

                    // Action button
                    if currentPage == pages.count - 1 {
                        GoldButton(title: "Get Started", icon: "arrow.right") {
                            completeOnboarding()
                        }
                        .padding(.horizontal, 32)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    } else {
                        GoldButton(title: "Next", icon: "chevron.right") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                        .padding(.horizontal, 32)
                    }
                }
                .padding(.bottom, 48)
            }
        }
    }

    private func completeOnboarding() {
        UserDefaultsService.shared.setOnboardingComplete()
        withAnimation(.easeOut(duration: 0.3)) {
            isPresented = false
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
