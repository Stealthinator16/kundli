import SwiftUI

/// View modifier that adds zoom, pan, and double-tap gestures to chart views
struct ChartGestureHandler: ViewModifier {
    @Bindable var state: ChartInteractionState
    let chartSize: CGFloat

    func body(content: Content) -> some View {
        content
            .scaleEffect(state.scale)
            .offset(state.offset)
            .gesture(magnificationGesture)
            .simultaneousGesture(panGesture)
            .gesture(doubleTapGesture)
    }

    // MARK: - Gestures

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                state.updateScale(value)
            }
            .onEnded { _ in
                state.finalizeScale()

                // Trigger haptic when hitting min/max bounds
                if state.scale == state.minScale || state.scale == state.maxScale {
                    state.triggerZoomHaptic()
                }
            }
    }

    private var panGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                // Only allow panning when zoomed
                guard state.isZoomed else { return }
                state.updateOffset(value.translation, chartSize: chartSize)
            }
            .onEnded { _ in
                state.finalizeOffset()
            }
    }

    private var doubleTapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                if state.isZoomed {
                    state.resetZoom()
                    state.triggerZoomHaptic()
                }
            }
    }
}

// MARK: - View Extension

extension View {
    /// Adds chart gestures (pinch-to-zoom, pan, double-tap to reset) to any view
    /// - Parameters:
    ///   - state: The chart interaction state to bind to
    ///   - chartSize: The size of the chart for calculating pan bounds
    func chartGestures(state: ChartInteractionState, chartSize: CGFloat) -> some View {
        modifier(ChartGestureHandler(state: state, chartSize: chartSize))
    }
}

// MARK: - Zoom Indicator View

struct ZoomIndicator: View {
    @Bindable var state: ChartInteractionState

    var body: some View {
        if state.isZoomed {
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 10, weight: .medium))

                Text("\(state.zoomPercentage)%")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
            }
            .foregroundColor(.kundliTextPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.kundliCardBg.opacity(0.9))
                    .overlay(
                        Capsule()
                            .stroke(Color.kundliPrimary.opacity(0.5), lineWidth: 1)
                    )
            )
            .transition(.scale.combined(with: .opacity))
        }
    }
}

// MARK: - Preview

#Preview {
    struct PreviewContainer: View {
        @State private var state = ChartInteractionState()

        var body: some View {
            ZStack {
                Color.kundliBackground.ignoresSafeArea()

                VStack {
                    ZoomIndicator(state: state)
                        .padding()

                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.kundliPrimary.opacity(0.3))
                        .frame(width: 200, height: 200)
                        .chartGestures(state: state, chartSize: 200)

                    Text("Pinch to zoom, double-tap to reset")
                        .font(.caption)
                        .foregroundColor(.kundliTextSecondary)
                        .padding()
                }
            }
        }
    }

    return PreviewContainer()
}
