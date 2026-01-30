import Foundation

// Preview helpers for SwiftUI previews
struct PreviewData {
    static let birthDetails = MockDataService.shared.sampleBirthDetails()
    static let kundli = MockDataService.shared.sampleKundli()
    static let panchang = MockDataService.shared.todayPanchang()
    static let planets = MockDataService.shared.samplePlanets()
    static let dashaPeriods = MockDataService.shared.sampleDashaPeriods()

    static var sampleViewModel: KundliViewModel {
        let vm = KundliViewModel()
        vm.loadSampleKundli()
        return vm
    }
}
