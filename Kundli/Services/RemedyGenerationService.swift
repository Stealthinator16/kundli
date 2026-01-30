import Foundation

/// Service for generating personalized remedies based on chart analysis
final class RemedyGenerationService {
    static let shared = RemedyGenerationService()

    private init() {}

    // MARK: - Main Generation Method

    /// Generate personalized remedies based on chart analysis
    /// - Parameters:
    ///   - planets: Array of planets from the birth chart
    ///   - doshas: Detected doshas in the chart
    ///   - planetaryStrengths: Shadbala calculations for planets
    ///   - activeDasha: Current active Mahadasha period
    ///   - activeAntarDasha: Current active Antardasha period
    /// - Returns: PersonalizedRemedies containing all recommended remedies
    func generateRemedies(
        planets: [Planet],
        doshas: [Dosha],
        planetaryStrengths: [PlanetaryStrength],
        activeDasha: DashaPeriod?,
        activeAntarDasha: AntarDasha?
    ) -> PersonalizedRemedies {
        var gemstones: [Gemstone] = []
        var mantras: [Mantra] = []
        var charities: [Charity] = []
        var fastingDays: [FastingDay] = []
        var pujas: [Puja] = []

        // 1. Generate remedies for weak planets (low Shadbala)
        let weakPlanetRemedies = generateWeakPlanetRemedies(
            planets: planets,
            strengths: planetaryStrengths
        )
        gemstones.append(contentsOf: weakPlanetRemedies.gemstones)
        mantras.append(contentsOf: weakPlanetRemedies.mantras)
        charities.append(contentsOf: weakPlanetRemedies.charities)
        fastingDays.append(contentsOf: weakPlanetRemedies.fastingDays)

        // 2. Generate remedies for debilitated planets
        let debilitatedRemedies = generateDebilitatedPlanetRemedies(planets: planets)
        gemstones.append(contentsOf: debilitatedRemedies.gemstones)
        mantras.append(contentsOf: debilitatedRemedies.mantras)
        pujas.append(contentsOf: debilitatedRemedies.pujas)

        // 3. Generate remedies for active doshas
        let doshaRemedies = generateDoshaRemedies(doshas: doshas)
        mantras.append(contentsOf: doshaRemedies.mantras)
        charities.append(contentsOf: doshaRemedies.charities)
        fastingDays.append(contentsOf: doshaRemedies.fastingDays)
        pujas.append(contentsOf: doshaRemedies.pujas)

        // 4. Generate remedies for current Dasha lord
        if let dasha = activeDasha {
            let dashaRemedies = generateDashaLordRemedies(
                dasha: dasha,
                antarDasha: activeAntarDasha
            )
            mantras.append(contentsOf: dashaRemedies.mantras)
            charities.append(contentsOf: dashaRemedies.charities)
        }

        // Remove duplicates and sort by severity
        gemstones = removeDuplicateGemstones(gemstones)
        mantras = removeDuplicateMantras(mantras)
        charities = removeDuplicateCharities(charities)
        fastingDays = removeDuplicateFastingDays(fastingDays)
        pujas = removeDuplicatePujas(pujas)

        return PersonalizedRemedies(
            generatedAt: Date(),
            gemstones: gemstones.sorted { $0.reason.severity.sortOrder < $1.reason.severity.sortOrder },
            mantras: mantras.sorted { $0.reason.severity.sortOrder < $1.reason.severity.sortOrder },
            charities: charities.sorted { $0.reason.severity.sortOrder < $1.reason.severity.sortOrder },
            fastingDays: fastingDays.sorted { $0.reason.severity.sortOrder < $1.reason.severity.sortOrder },
            pujas: pujas.sorted { $0.reason.severity.sortOrder < $1.reason.severity.sortOrder }
        )
    }

    // MARK: - Weak Planet Remedies

    private func generateWeakPlanetRemedies(
        planets: [Planet],
        strengths: [PlanetaryStrength]
    ) -> (gemstones: [Gemstone], mantras: [Mantra], charities: [Charity], fastingDays: [FastingDay]) {
        var gemstones: [Gemstone] = []
        var mantras: [Mantra] = []
        var charities: [Charity] = []
        var fastingDays: [FastingDay] = []

        // Find weak planets based on Shadbala
        let weakStrengths = strengths.filter {
            $0.strengthLevel == .weak || $0.strengthLevel == .veryWeak
        }

        for strength in weakStrengths {
            guard let remedyData = PlanetRemedyData.data(forPlanetName: strength.planet) else { continue }

            let severity: RemedySeverity = strength.strengthLevel == .veryWeak ? .high : .moderate
            let reason = RemedyReason(
                type: .weakPlanet,
                description: "\(strength.planet) is \(strength.strengthLevel.rawValue.lowercased()) in your chart (Shadbala ratio: \(String(format: "%.2f", strength.strengthRatio)))",
                severity: severity
            )

            // Add gemstone
            gemstones.append(createGemstone(for: remedyData, reason: reason))

            // Add mantra
            mantras.append(createMantra(for: remedyData, reason: reason))

            // Add charity
            charities.append(createCharity(for: remedyData, reason: reason))

            // Add fasting for very weak planets
            if strength.strengthLevel == .veryWeak {
                fastingDays.append(createFastingDay(for: remedyData, reason: reason))
            }
        }

        return (gemstones, mantras, charities, fastingDays)
    }

    // MARK: - Debilitated Planet Remedies

    private func generateDebilitatedPlanetRemedies(
        planets: [Planet]
    ) -> (gemstones: [Gemstone], mantras: [Mantra], pujas: [Puja]) {
        var gemstones: [Gemstone] = []
        var mantras: [Mantra] = []
        var pujas: [Puja] = []

        let debilitatedPlanets = planets.filter { $0.status == .debilitated }

        for planet in debilitatedPlanets {
            guard let remedyData = PlanetRemedyData.data(forPlanetName: planet.name) else { continue }

            let reason = RemedyReason(
                type: .debilitatedPlanet,
                description: "\(planet.name) is debilitated in \(planet.sign), reducing its positive effects",
                severity: .high
            )

            // Add gemstone
            gemstones.append(createGemstone(for: remedyData, reason: reason))

            // Add mantra
            mantras.append(createMantra(for: remedyData, reason: reason))

            // Add specific puja
            pujas.append(createPlanetPuja(for: remedyData, reason: reason))
        }

        return (gemstones, mantras, pujas)
    }

    // MARK: - Dosha Remedies

    private func generateDoshaRemedies(
        doshas: [Dosha]
    ) -> (mantras: [Mantra], charities: [Charity], fastingDays: [FastingDay], pujas: [Puja]) {
        var mantras: [Mantra] = []
        var charities: [Charity] = []
        var fastingDays: [FastingDay] = []
        var pujas: [Puja] = []

        // Only generate remedies for active (non-cancelled) doshas
        let activeDoshas = doshas.filter { !$0.isCancelled }

        for dosha in activeDoshas {
            let severity: RemedySeverity
            switch dosha.severity {
            case .high: severity = .high
            case .medium: severity = .moderate
            case .low, .cancelled: severity = .low
            }

            let reason = RemedyReason(
                type: .dosha,
                description: "\(dosha.name): \(dosha.description)",
                severity: severity
            )

            switch dosha.type {
            case .manglik:
                // Manglik Dosha remedies
                if let marsData = PlanetRemedyData.data(forPlanetName: "Mars") {
                    mantras.append(createMantra(for: marsData, reason: reason))
                    charities.append(createCharity(for: marsData, reason: reason))
                    fastingDays.append(createFastingDay(for: marsData, reason: reason))
                }

                pujas.append(Puja(
                    name: "Mangal Shanti Puja",
                    sanskritName: "Mangal Graha Shanti",
                    deity: "Lord Hanuman",
                    planet: "Mars",
                    planetVedName: "Mangal",
                    purpose: "To pacify Mars and reduce Manglik dosha effects",
                    timing: "Tuesday during Mars hora",
                    frequency: "Once, or annually on Tuesdays",
                    estimatedDuration: "2-3 hours",
                    reason: reason,
                    benefits: [
                        "Reduces delay in marriage",
                        "Improves marital harmony",
                        "Pacifies aggressive tendencies"
                    ],
                    templeRecommendations: ["Mangalnath Temple, Ujjain", "Varanasi Hanuman Temples"]
                ))

            case .kaalSarp:
                // Kaal Sarp Dosha remedies
                pujas.append(Puja(
                    name: "Kaal Sarp Dosh Nivaran Puja",
                    sanskritName: "Kaal Sarpa Dosha Shanti",
                    deity: "Lord Shiva",
                    purpose: "To neutralize the effects of Kaal Sarp dosha",
                    timing: "Nag Panchami or favorable muhurta",
                    frequency: "Once in lifetime",
                    estimatedDuration: "4-5 hours",
                    reason: reason,
                    benefits: [
                        "Removes obstacles in life",
                        "Brings peace and stability",
                        "Reduces fear and anxiety"
                    ],
                    templeRecommendations: ["Trimbakeshwar, Nashik", "Kalahasti Temple, Andhra Pradesh"]
                ))

                // Rahu mantra for Kaal Sarp
                if let rahuData = PlanetRemedyData.data(forPlanetName: "Rahu") {
                    mantras.append(createMantra(for: rahuData, reason: reason))
                    charities.append(createCharity(for: rahuData, reason: reason))
                }

                // Maha Mrityunjaya mantra
                mantras.append(Mantra(
                    text: "Om Tryambakam Yajamahe Sugandhim Pushtivardhanam Urvarukamiva Bandhanan Mrityor Mukshiya Maamritat",
                    meaning: "We worship the three-eyed one (Lord Shiva) who is fragrant and nourishes all beings. May he liberate us from death.",
                    planet: "Rahu/Ketu",
                    planetVedName: "Rahu/Ketu",
                    deity: "Lord Shiva",
                    repetitions: 108,
                    totalCount: 125000,
                    bestTime: "Brahma Muhurta (4-6 AM)",
                    bestDay: "Monday or Saturday",
                    duration: "40 days minimum",
                    reason: reason,
                    benefits: ["Protection from negativity", "Spiritual growth", "Health improvement"]
                ))

            case .kemdrum:
                // Kemdrum Dosha remedies
                if let moonData = PlanetRemedyData.data(forPlanetName: "Moon") {
                    mantras.append(createMantra(for: moonData, reason: reason))
                    charities.append(createCharity(for: moonData, reason: reason))
                    fastingDays.append(createFastingDay(for: moonData, reason: reason))
                }

                pujas.append(Puja(
                    name: "Chandra Graha Shanti",
                    sanskritName: "Chandra Shanti Puja",
                    deity: "Lord Chandra/Goddess Parvati",
                    planet: "Moon",
                    planetVedName: "Chandra",
                    purpose: "To strengthen Moon and reduce Kemdrum effects",
                    timing: "Monday during Moon hora",
                    frequency: "Monthly on Purnima",
                    estimatedDuration: "2-3 hours",
                    reason: reason,
                    benefits: [
                        "Mental peace and stability",
                        "Improved emotional well-being",
                        "Better relationships"
                    ],
                    templeRecommendations: ["Somnath Temple, Gujarat", "Chandranath Temple"]
                ))

            case .pitra:
                // Pitra Dosha remedies
                pujas.append(Puja(
                    name: "Pitra Dosh Nivaran Puja",
                    sanskritName: "Pitra Shanti",
                    deity: "Ancestors/Lord Vishnu",
                    purpose: "To pacify ancestors and resolve ancestral karma",
                    timing: "Pitru Paksha (Shraddha period)",
                    frequency: "Annually during Pitru Paksha",
                    estimatedDuration: "3-4 hours",
                    reason: reason,
                    benefits: [
                        "Blessings from ancestors",
                        "Removal of family obstacles",
                        "Peace for departed souls"
                    ],
                    templeRecommendations: ["Gaya, Bihar", "Prayagraj", "Varanasi"]
                ))

                charities.append(Charity(
                    item: "Food and clothes",
                    itemDescription: "Feed Brahmins and donate clothes during Pitru Paksha",
                    planet: "Sun/Saturn",
                    planetVedName: "Surya/Shani",
                    day: "Amavasya (New Moon)",
                    beneficiary: "Brahmins, poor, and needy",
                    frequency: "Annually during Pitru Paksha",
                    reason: reason,
                    alternatives: ["Feed crows", "Donate to orphanages"]
                ))

            case .shani:
                // Shani Dosha remedies
                if let saturnData = PlanetRemedyData.data(forPlanetName: "Saturn") {
                    mantras.append(createMantra(for: saturnData, reason: reason))
                    charities.append(createCharity(for: saturnData, reason: reason))
                    fastingDays.append(createFastingDay(for: saturnData, reason: reason))
                }

                pujas.append(Puja(
                    name: "Shani Graha Shanti",
                    sanskritName: "Shani Dev Puja",
                    deity: "Lord Shani/Hanuman",
                    planet: "Saturn",
                    planetVedName: "Shani",
                    purpose: "To pacify Saturn and reduce malefic effects",
                    timing: "Saturday during Saturn hora",
                    frequency: "Weekly on Saturdays",
                    estimatedDuration: "1-2 hours",
                    reason: reason,
                    benefits: [
                        "Reduces Sade Sati effects",
                        "Career stability",
                        "Justice in legal matters"
                    ],
                    templeRecommendations: ["Shani Shingnapur, Maharashtra", "Thirunallar, Tamil Nadu"]
                ))

            case .other, .grahan, .guruChandal, .shrapit, .gandmool, .nadi, .bhakoot, .gana:
                // General remedies for other/misc doshas
                pujas.append(Puja(
                    name: "Navagraha Shanti Puja",
                    sanskritName: "Navagraha Shanti",
                    deity: "Nine Planets",
                    purpose: "To balance all planetary energies",
                    timing: "Favorable muhurta",
                    frequency: "Once or annually",
                    estimatedDuration: "3-4 hours",
                    reason: reason,
                    benefits: [
                        "Overall planetary balance",
                        "General well-being",
                        "Removal of obstacles"
                    ],
                    templeRecommendations: ["Navagraha temples in Tamil Nadu", "Any Shiva temple"]
                ))
            }
        }

        return (mantras, charities, fastingDays, pujas)
    }

    // MARK: - Dasha Lord Remedies

    private func generateDashaLordRemedies(
        dasha: DashaPeriod,
        antarDasha: AntarDasha?
    ) -> (mantras: [Mantra], charities: [Charity]) {
        var mantras: [Mantra] = []
        var charities: [Charity] = []

        // Remedies for Mahadasha lord
        if let remedyData = PlanetRemedyData.data(forPlanetName: dasha.planet) {
            let reason = RemedyReason(
                type: .dashaLord,
                description: "Currently running \(dasha.planet) Mahadasha - strengthening this planet can improve results",
                severity: .moderate
            )

            mantras.append(createMantra(for: remedyData, reason: reason))
            charities.append(createCharity(for: remedyData, reason: reason))
        }

        // Remedies for Antardasha lord (if different from Mahadasha)
        if let antarDasha = antarDasha,
           antarDasha.planet != dasha.planet,
           let remedyData = PlanetRemedyData.data(forPlanetName: antarDasha.planet) {
            let reason = RemedyReason(
                type: .dashaLord,
                description: "Currently in \(antarDasha.planet) Antardasha within \(dasha.planet) Mahadasha",
                severity: .low
            )

            mantras.append(createMantra(for: remedyData, reason: reason))
        }

        return (mantras, charities)
    }

    // MARK: - Helper Methods to Create Remedies

    private func createGemstone(for data: PlanetRemedyData, reason: RemedyReason) -> Gemstone {
        Gemstone(
            name: data.gemstone,
            sanskritName: data.gemstoneSanskrit,
            planet: data.planet.rawValue,
            planetVedName: data.planet.vedName,
            weight: gemstoneWeight(for: data.planet),
            metal: data.metal,
            finger: data.finger,
            hand: "Right",
            dayToWear: data.day,
            mantraToChant: data.mantra,
            reason: reason,
            alternativeStones: data.alternativeStones,
            precautions: gemstonePrecautions(for: data.planet)
        )
    }

    private func createMantra(for data: PlanetRemedyData, reason: RemedyReason) -> Mantra {
        Mantra(
            text: data.mantra,
            meaning: data.mantraMeaning,
            planet: data.planet.rawValue,
            planetVedName: data.planet.vedName,
            deity: data.deity,
            repetitions: 108,
            totalCount: mantraTotalCount(for: data.planet),
            bestTime: mantraBestTime(for: data.planet),
            bestDay: data.day,
            duration: "40 days minimum",
            reason: reason,
            benefits: mantraBenefits(for: data.planet)
        )
    }

    private func createCharity(for data: PlanetRemedyData, reason: RemedyReason) -> Charity {
        Charity(
            item: data.charityItems.first ?? "Items",
            itemDescription: data.charityItems.joined(separator: ", "),
            planet: data.planet.rawValue,
            planetVedName: data.planet.vedName,
            day: data.day,
            beneficiary: data.charityBeneficiary,
            frequency: "Weekly",
            reason: reason,
            alternatives: Array(data.charityItems.dropFirst())
        )
    }

    private func createFastingDay(for data: PlanetRemedyData, reason: RemedyReason) -> FastingDay {
        FastingDay(
            day: data.day,
            planet: data.planet.rawValue,
            planetVedName: data.planet.vedName,
            whatToAvoid: fastingAvoidList(for: data.planet),
            whatToEat: data.fastingFood,
            breakFastTime: "After sunset",
            frequency: "Weekly",
            duration: "At least 11 weeks",
            reason: reason,
            deity: data.deity
        )
    }

    private func createPlanetPuja(for data: PlanetRemedyData, reason: RemedyReason) -> Puja {
        Puja(
            name: "\(data.planet.rawValue) Graha Shanti",
            sanskritName: "\(data.planet.vedName) Shanti Puja",
            deity: data.deity,
            planet: data.planet.rawValue,
            planetVedName: data.planet.vedName,
            purpose: "To strengthen \(data.planet.rawValue) and receive its blessings",
            timing: "\(data.day) during \(data.planet.rawValue) hora",
            frequency: "Once or as needed",
            estimatedDuration: "2-3 hours",
            reason: reason,
            benefits: pujaBenefits(for: data.planet),
            templeRecommendations: templeRecommendations(for: data.planet)
        )
    }

    // MARK: - Planet-Specific Data Helpers

    private func gemstoneWeight(for planet: VedicPlanet) -> String {
        switch planet {
        case .sun: return "3-5 carats"
        case .moon: return "4-6 carats"
        case .mars: return "5-7 carats"
        case .mercury: return "3-5 carats"
        case .jupiter: return "4-5 carats"
        case .venus: return "0.5-1 carat"
        case .saturn: return "4-5 carats"
        case .rahu: return "5-7 carats"
        case .ketu: return "3-5 carats"
        }
    }

    private func gemstonePrecautions(for planet: VedicPlanet) -> [String] {
        var precautions = [
            "Consult a qualified astrologer before wearing",
            "Ensure the gemstone is natural and untreated",
            "Energize the stone with proper mantras before wearing"
        ]

        switch planet {
        case .saturn:
            precautions.append("Blue Sapphire requires careful trial period - wear for 3 days first")
        case .rahu, .ketu:
            precautions.append("Shadow planet gemstones need expert guidance")
        case .mars:
            precautions.append("Not recommended if Mars is malefic in your chart")
        default:
            break
        }

        return precautions
    }

    private func mantraTotalCount(for planet: VedicPlanet) -> Int {
        switch planet {
        case .sun: return 7000
        case .moon: return 11000
        case .mars: return 10000
        case .mercury: return 9000
        case .jupiter: return 19000
        case .venus: return 16000
        case .saturn: return 23000
        case .rahu: return 18000
        case .ketu: return 17000
        }
    }

    private func mantraBestTime(for planet: VedicPlanet) -> String {
        switch planet {
        case .sun: return "Sunrise"
        case .moon: return "Evening or night"
        case .mars: return "Morning"
        case .mercury: return "Morning"
        case .jupiter: return "Early morning"
        case .venus: return "Morning or evening"
        case .saturn: return "Evening"
        case .rahu: return "Night"
        case .ketu: return "Brahma Muhurta"
        }
    }

    private func mantraBenefits(for planet: VedicPlanet) -> [String] {
        switch planet {
        case .sun:
            return ["Leadership qualities", "Government favor", "Health and vitality", "Father's blessings"]
        case .moon:
            return ["Mental peace", "Emotional stability", "Mother's blessings", "Popularity"]
        case .mars:
            return ["Courage and confidence", "Property matters", "Victory over enemies", "Physical strength"]
        case .mercury:
            return ["Intelligence and wit", "Communication skills", "Business success", "Education"]
        case .jupiter:
            return ["Wisdom and knowledge", "Spiritual growth", "Wealth and prosperity", "Children's well-being"]
        case .venus:
            return ["Love and relationships", "Artistic abilities", "Material comforts", "Married life harmony"]
        case .saturn:
            return ["Career stability", "Discipline", "Justice", "Longevity"]
        case .rahu:
            return ["Worldly success", "Foreign connections", "Unconventional gains", "Breaking limitations"]
        case .ketu:
            return ["Spiritual liberation", "Intuition", "Healing abilities", "Past-life karma resolution"]
        }
    }

    private func fastingAvoidList(for planet: VedicPlanet) -> [String] {
        switch planet {
        case .sun: return ["Salt", "Non-vegetarian food", "Alcohol"]
        case .moon: return ["Salt", "Grains", "Non-vegetarian"]
        case .mars: return ["Non-vegetarian", "Masoor dal", "Alcohol"]
        case .mercury: return ["Green vegetables (some traditions)", "Non-vegetarian"]
        case .jupiter: return ["Non-vegetarian", "Banana", "Salt"]
        case .venus: return ["Sour foods", "Non-vegetarian", "Alcohol"]
        case .saturn: return ["Salt", "Non-vegetarian", "Mustard oil"]
        case .rahu: return ["Non-vegetarian", "Onion", "Garlic"]
        case .ketu: return ["Non-vegetarian", "Tamasic foods"]
        }
    }

    private func pujaBenefits(for planet: VedicPlanet) -> [String] {
        switch planet {
        case .sun:
            return ["Success in career", "Good health", "Government recognition"]
        case .moon:
            return ["Mental peace", "Good relationships", "Emotional healing"]
        case .mars:
            return ["Courage", "Property gains", "Victory in competitions"]
        case .mercury:
            return ["Business success", "Educational excellence", "Communication skills"]
        case .jupiter:
            return ["Wisdom", "Prosperity", "Spiritual progress"]
        case .venus:
            return ["Happy married life", "Material pleasures", "Artistic success"]
        case .saturn:
            return ["Career growth", "Justice", "Long life"]
        case .rahu:
            return ["Success in foreign lands", "Unexpected gains", "Fame"]
        case .ketu:
            return ["Spiritual awakening", "Liberation", "Healing"]
        }
    }

    private func templeRecommendations(for planet: VedicPlanet) -> [String] {
        switch planet {
        case .sun:
            return ["Konark Sun Temple, Odisha", "Suryanar Kovil, Tamil Nadu", "Modhera Sun Temple, Gujarat"]
        case .moon:
            return ["Somnath Temple, Gujarat", "Chandranath Temple", "Thingaloor Kailasanathar Temple"]
        case .mars:
            return ["Mangalnath Temple, Ujjain", "Vaitheeswaran Kovil, Tamil Nadu", "Hanuman Temples"]
        case .mercury:
            return ["Thiruvenkadu Budhan Temple, Tamil Nadu", "Swetharanyeswarar Temple"]
        case .jupiter:
            return ["Alangudi Guru Temple, Tamil Nadu", "Apatsahayesvarar Temple", "Dakshineswar Kali Temple"]
        case .venus:
            return ["Kanjanur Sukran Temple, Tamil Nadu", "Lakshmi Temples", "Srisailam"]
        case .saturn:
            return ["Thirunallar Saneeswaran Temple", "Shani Shingnapur, Maharashtra", "Yama Dharmaraja Temple"]
        case .rahu:
            return ["Thirunageswaram Rahu Temple", "Kalahasti Temple", "Sri Kalahasti"]
        case .ketu:
            return ["Keezhperumpallam Ketu Temple", "Kailasanathar Temple", "Rameshwaram"]
        }
    }

    // MARK: - Deduplication

    private func removeDuplicateGemstones(_ gemstones: [Gemstone]) -> [Gemstone] {
        var seen = Set<String>()
        return gemstones.filter { gemstone in
            let key = "\(gemstone.planet)-\(gemstone.name)"
            if seen.contains(key) {
                return false
            }
            seen.insert(key)
            return true
        }
    }

    private func removeDuplicateMantras(_ mantras: [Mantra]) -> [Mantra] {
        var seen = Set<String>()
        return mantras.filter { mantra in
            let key = mantra.text
            if seen.contains(key) {
                return false
            }
            seen.insert(key)
            return true
        }
    }

    private func removeDuplicateCharities(_ charities: [Charity]) -> [Charity] {
        var seen = Set<String>()
        return charities.filter { charity in
            let key = "\(charity.planet)-\(charity.item)"
            if seen.contains(key) {
                return false
            }
            seen.insert(key)
            return true
        }
    }

    private func removeDuplicateFastingDays(_ fastingDays: [FastingDay]) -> [FastingDay] {
        var seen = Set<String>()
        return fastingDays.filter { fasting in
            let key = "\(fasting.planet)-\(fasting.day)"
            if seen.contains(key) {
                return false
            }
            seen.insert(key)
            return true
        }
    }

    private func removeDuplicatePujas(_ pujas: [Puja]) -> [Puja] {
        var seen = Set<String>()
        return pujas.filter { puja in
            let key = puja.name
            if seen.contains(key) {
                return false
            }
            seen.insert(key)
            return true
        }
    }
}
