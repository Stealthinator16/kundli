import Foundation
import SwiftUI

@Observable
class MatchingViewModel {
    var person1Details: BirthDetails?
    var person2Details: BirthDetails?
    var matchResult: KundliMatch?
    var isMatching: Bool = false

    // Kundlis for chart comparison
    var person1Kundli: Kundli?
    var person2Kundli: Kundli?

    // Form fields for person 1
    var person1Name: String = ""
    var person1DateOfBirth: Date = Date()
    var person1TimeOfBirth: Date = Date()
    var person1City: City?
    var person1Gender: BirthDetails.Gender = .female

    // Form fields for person 2
    var person2Name: String = ""
    var person2DateOfBirth: Date = Date()
    var person2TimeOfBirth: Date = Date()
    var person2City: City?
    var person2Gender: BirthDetails.Gender = .male

    var isFormValid: Bool {
        !person1Name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !person2Name.trimmingCharacters(in: .whitespaces).isEmpty &&
        person1City != nil &&
        person2City != nil
    }

    func performMatching() {
        guard isFormValid,
              let city1 = person1City,
              let city2 = person2City else { return }

        isMatching = true

        // Create birth details for both
        let details1 = BirthDetails(
            name: person1Name,
            dateOfBirth: person1DateOfBirth,
            timeOfBirth: person1TimeOfBirth,
            birthCity: city1.displayName,
            latitude: city1.latitude,
            longitude: city1.longitude,
            timezone: city1.timezone,
            gender: person1Gender
        )

        let details2 = BirthDetails(
            name: person2Name,
            dateOfBirth: person2DateOfBirth,
            timeOfBirth: person2TimeOfBirth,
            birthCity: city2.displayName,
            latitude: city2.latitude,
            longitude: city2.longitude,
            timezone: city2.timezone,
            gender: person2Gender
        )

        person1Details = details1
        person2Details = details2

        // Generate kundlis for both persons for chart comparison
        Task {
            do {
                let kundli1 = try await KundliGenerationService.shared.generateKundli(
                    birthDetails: details1,
                    settings: SettingsService.shared.calculationSettings
                )
                let kundli2 = try await KundliGenerationService.shared.generateKundli(
                    birthDetails: details2,
                    settings: SettingsService.shared.calculationSettings
                )

                await MainActor.run {
                    self.person1Kundli = kundli1.toKundli()
                    self.person2Kundli = kundli2.toKundli()
                    self.matchResult = Self.generateMockMatch(person1: details1, person2: details2)
                    self.isMatching = false
                }
            } catch {
                await MainActor.run {
                    // Even if kundli generation fails, still show match results
                    self.matchResult = Self.generateMockMatch(person1: details1, person2: details2)
                    self.isMatching = false
                }
            }
        }
    }

    private static func generateMockMatch(person1: BirthDetails, person2: BirthDetails) -> KundliMatch {
        // Generate mock Gun Milan scores
        let gunMilan = GunMilan(
            varna: GunScore(name: "Varna", score: 1, maxScore: 1, description: "Spiritual compatibility"),
            vashya: GunScore(name: "Vashya", score: 2, maxScore: 2, description: "Dominance in relationship"),
            tara: GunScore(name: "Tara", score: 2.5, maxScore: 3, description: "Destiny and luck"),
            yoni: GunScore(name: "Yoni", score: 3, maxScore: 4, description: "Physical compatibility"),
            grihaMaitri: GunScore(name: "Griha Maitri", score: 4, maxScore: 5, description: "Mental compatibility"),
            gana: GunScore(name: "Gana", score: 5, maxScore: 6, description: "Temperament"),
            bhakoot: GunScore(name: "Bhakoot", score: 7, maxScore: 7, description: "Love and family"),
            nadi: GunScore(name: "Nadi", score: 6, maxScore: 8, description: "Health and genes")
        )

        let manglik = ManglikComparison(
            person1Manglik: false,
            person2Manglik: false,
            isCompatible: true,
            remedySuggested: nil
        )

        return KundliMatch(
            person1: person1,
            person2: person2,
            gunMilan: gunMilan,
            manglikStatus: manglik
        )
    }

    func reset() {
        person1Name = ""
        person1DateOfBirth = Date()
        person1TimeOfBirth = Date()
        person1City = nil
        person2Name = ""
        person2DateOfBirth = Date()
        person2TimeOfBirth = Date()
        person2City = nil
        matchResult = nil
        person1Kundli = nil
        person2Kundli = nil
    }
}
