import SwiftUI

/// View modifier that applies load animation to chart content
struct ChartLoadAnimationModifier: ViewModifier {
    let isLoaded: Bool
    let delay: Double

    func body(content: Content) -> some View {
        content
            .opacity(isLoaded ? 1 : 0)
            .scaleEffect(isLoaded ? 1 : 0.9)
            .animation(
                .spring(response: 0.4, dampingFraction: 0.7)
                .delay(delay),
                value: isLoaded
            )
    }
}

/// View modifier for staggered house animation
struct HouseAnimationModifier: ViewModifier {
    let house: Int
    let state: ChartInteractionState

    func body(content: Content) -> some View {
        content
            .opacity(state.isHouseAnimated(house) ? 1 : 0)
            .scaleEffect(state.isHouseAnimated(house) ? 1 : 0.8)
    }
}

/// Extension for easy application of load animations
extension View {
    /// Applies a fade-in and scale animation to the view
    /// - Parameters:
    ///   - isLoaded: Whether the content should be shown
    ///   - delay: Delay before starting the animation
    func chartLoadAnimation(isLoaded: Bool, delay: Double = 0) -> some View {
        modifier(ChartLoadAnimationModifier(isLoaded: isLoaded, delay: delay))
    }

    /// Applies staggered house animation based on interaction state
    /// - Parameters:
    ///   - house: The house number (1-12)
    ///   - state: The chart interaction state
    func houseAnimation(house: Int, state: ChartInteractionState) -> some View {
        modifier(HouseAnimationModifier(house: house, state: state))
    }
}

// MARK: - Animated Chart Container

/// A container view that manages load animations for chart content
struct AnimatedChartContainer<Content: View>: View {
    @Bindable var state: ChartInteractionState
    let content: Content

    init(state: ChartInteractionState, @ViewBuilder content: () -> Content) {
        self.state = state
        self.content = content()
    }

    var body: some View {
        content
            .opacity(state.isChartLoaded ? 1 : 0)
            .scaleEffect(state.isChartLoaded ? 1 : 0.92)
            .onAppear {
                if !state.isChartLoaded {
                    state.startLoadAnimation()
                }
            }
    }
}

// MARK: - Pulsing Highlight Animation

struct PulsingHighlight: View {
    @State private var isPulsing = false

    var body: some View {
        Circle()
            .stroke(Color.kundliPrimary.opacity(isPulsing ? 0.3 : 0.7), lineWidth: 2)
            .scaleEffect(isPulsing ? 1.3 : 1.0)
            .opacity(isPulsing ? 0 : 1)
            .animation(
                .easeInOut(duration: 0.8)
                .repeatForever(autoreverses: false),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - House Selection Highlight

struct HouseSelectionHighlight: View {
    let isSelected: Bool

    var body: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.kundliPrimary, lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.kundliPrimary.opacity(0.1))
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }
}

// MARK: - Preview

#Preview {
    struct PreviewContainer: View {
        @State private var state = ChartInteractionState()
        @State private var isLoaded = false

        var body: some View {
            ZStack {
                Color.kundliBackground.ignoresSafeArea()

                VStack(spacing: 20) {
                    // Animated content
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.kundliPrimary.opacity(0.3))
                        .frame(width: 200, height: 200)
                        .chartLoadAnimation(isLoaded: isLoaded, delay: 0.2)

                    // Pulsing highlight
                    ZStack {
                        Circle()
                            .fill(Color.kundliPrimary.opacity(0.2))
                            .frame(width: 50, height: 50)

                        PulsingHighlight()
                            .frame(width: 50, height: 50)
                    }

                    // House highlight
                    HouseSelectionHighlight(isSelected: true)
                        .frame(width: 60, height: 60)

                    Button("Toggle Animation") {
                        isLoaded.toggle()
                    }
                    .foregroundColor(.kundliPrimary)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isLoaded = true
                }
            }
        }
    }

    return PreviewContainer()
}
