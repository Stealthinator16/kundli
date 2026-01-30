import SwiftUI

/// Animated gradient background for onboarding and special screens
struct AnimatedGradientBackground: View {
    @State private var animateGradient = false

    var body: some View {
        ZStack {
            // Base layer
            Color.kundliBackground

            // Animated gradient circles
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.kundliPrimary.opacity(0.15),
                            Color.kundliPrimary.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(
                    x: animateGradient ? 50 : -50,
                    y: animateGradient ? -100 : -150
                )
                .blur(radius: 60)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.kundliPrimaryDark.opacity(0.1),
                            Color.kundliPrimaryDark.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .frame(width: 500, height: 500)
                .offset(
                    x: animateGradient ? -80 : 80,
                    y: animateGradient ? 200 : 250
                )
                .blur(radius: 80)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(
                .easeInOut(duration: 4.0)
                .repeatForever(autoreverses: true)
            ) {
                animateGradient = true
            }
        }
    }
}

/// Subtle shimmer effect for cards
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.white.opacity(0.1),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 2.0)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

extension View {
    /// Adds a subtle shimmer animation to the view
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

/// Pulsing animation for emphasis
struct PulseAnimation: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .opacity(isPulsing ? 0.9 : 1.0)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            }
    }
}

extension View {
    /// Adds a subtle pulsing animation
    func pulse() -> some View {
        modifier(PulseAnimation())
    }
}

#Preview {
    AnimatedGradientBackground()
}
