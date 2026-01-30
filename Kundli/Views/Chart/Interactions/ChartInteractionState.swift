import SwiftUI
import UIKit

/// Observable state for all chart interactions including selection, zoom, pan, and animations
@Observable
final class ChartInteractionState {
    // MARK: - Selection State
    var selectedPlanet: Planet?
    var selectedHouse: Int?

    // MARK: - Zoom/Pan State
    var scale: CGFloat = 1.0
    var offset: CGSize = .zero
    var lastScale: CGFloat = 1.0
    var lastOffset: CGSize = .zero

    let minScale: CGFloat = 1.0
    let maxScale: CGFloat = 3.0

    // MARK: - Popup State
    var showPlanetPopup: Bool = false
    var showHousePopup: Bool = false
    var popupPosition: CGPoint = .zero

    // MARK: - Aspect Lines State
    var showAspectLines: Bool = false

    // MARK: - Animation State
    var isChartLoaded: Bool = false
    var houseAnimationProgress: [Int: Bool] = [:]

    // MARK: - Initialization
    init() {
        // Initialize house animation state
        for house in 1...12 {
            houseAnimationProgress[house] = false
        }
    }

    // MARK: - Zoom Methods

    func resetZoom() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            scale = 1.0
            offset = .zero
            lastScale = 1.0
            lastOffset = .zero
        }
    }

    func updateScale(_ newScale: CGFloat) {
        let proposedScale = lastScale * newScale
        scale = min(max(proposedScale, minScale), maxScale)
    }

    func finalizeScale() {
        lastScale = scale
    }

    func updateOffset(_ translation: CGSize, chartSize: CGFloat) {
        guard scale > 1 else {
            offset = .zero
            return
        }

        let maxOffset = (chartSize * (scale - 1)) / 2
        let newX = lastOffset.width + translation.width
        let newY = lastOffset.height + translation.height

        offset = CGSize(
            width: min(max(newX, -maxOffset), maxOffset),
            height: min(max(newY, -maxOffset), maxOffset)
        )
    }

    func finalizeOffset() {
        lastOffset = offset
    }

    var isZoomed: Bool {
        scale > 1.01
    }

    var zoomPercentage: Int {
        Int(scale * 100)
    }

    // MARK: - Selection Methods

    func selectPlanet(_ planet: Planet, at position: CGPoint) {
        clearSelection()
        selectedPlanet = planet
        popupPosition = position

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showPlanetPopup = true
        }

        triggerHaptic(.light)
    }

    func selectHouse(_ house: Int) {
        clearSelection()
        selectedHouse = house

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showHousePopup = true
        }

        triggerHaptic(.light)
    }

    func clearSelection() {
        withAnimation(.easeOut(duration: 0.2)) {
            showPlanetPopup = false
            showHousePopup = false
        }

        // Delay clearing the data so the dismissal animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.selectedPlanet = nil
            self?.selectedHouse = nil
        }
    }

    // MARK: - Animation Methods

    func startLoadAnimation() {
        // First fade in the chart
        withAnimation(.easeOut(duration: 0.3)) {
            isChartLoaded = true
        }

        // Then stagger animate each house
        for house in 1...12 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(house) * 0.03) { [weak self] in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    self?.houseAnimationProgress[house] = true
                }
            }
        }
    }

    func resetAnimation() {
        isChartLoaded = false
        for house in 1...12 {
            houseAnimationProgress[house] = false
        }
    }

    func isHouseAnimated(_ house: Int) -> Bool {
        houseAnimationProgress[house] ?? false
    }

    // MARK: - Haptic Feedback

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func triggerSelectionHaptic() {
        triggerHaptic(.light)
    }

    func triggerZoomHaptic() {
        triggerHaptic(.medium)
    }

    // MARK: - Aspect Lines

    func toggleAspectLines() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showAspectLines.toggle()
        }
        triggerHaptic(.light)
    }
}
