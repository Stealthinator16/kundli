import SwiftUI

struct RemediesView: View {
    let viewModel: KundliViewModel?
    @State private var personalizedRemedies: PersonalizedRemedies?
    @State private var selectedType: RemedyType?
    @State private var isLoading = false

    init(viewModel: KundliViewModel? = nil) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    if isLoading {
                        loadingView
                    } else if let remedies = personalizedRemedies, !remedies.isEmpty {
                        // Personalized remedies
                        personalizedRemediesSection(remedies)
                    } else {
                        // Static fallback remedies
                        staticRemediesSection
                    }

                    // Disclaimer
                    disclaimerText

                    Spacer()
                        .frame(height: 20)
                }
                .padding(16)
            }
        }
        .navigationTitle("Remedies")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            generateRemedies()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(.kundliPrimary)

            Text("Astrological Remedies")
                .font(.kundliTitle2)
                .foregroundColor(.kundliTextPrimary)

            if personalizedRemedies != nil {
                Text("Personalized based on your birth chart")
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliTextSecondary)
            } else {
                Text("General suggestions based on Vedic astrology")
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliTextSecondary)
            }
        }
        .padding(.top, 20)
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .kundliPrimary))
                .scaleEffect(1.2)

            Text("Analyzing your chart...")
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextSecondary)
        }
        .frame(height: 200)
    }

    // MARK: - Personalized Remedies Section

    private func personalizedRemediesSection(_ remedies: PersonalizedRemedies) -> some View {
        VStack(spacing: 20) {
            // Summary card
            remedySummaryCard(remedies)

            // Gemstones
            if !remedies.gemstones.isEmpty {
                remedyTypeSection(
                    type: .gemstones,
                    count: remedies.gemstones.count
                ) {
                    ForEach(remedies.gemstones) { gemstone in
                        gemstoneCard(gemstone)
                    }
                }
            }

            // Mantras
            if !remedies.mantras.isEmpty {
                remedyTypeSection(
                    type: .mantras,
                    count: remedies.mantras.count
                ) {
                    ForEach(remedies.mantras) { mantra in
                        mantraCard(mantra)
                    }
                }
            }

            // Charity
            if !remedies.charities.isEmpty {
                remedyTypeSection(
                    type: .charity,
                    count: remedies.charities.count
                ) {
                    ForEach(remedies.charities) { charity in
                        charityCard(charity)
                    }
                }
            }

            // Fasting
            if !remedies.fastingDays.isEmpty {
                remedyTypeSection(
                    type: .fasting,
                    count: remedies.fastingDays.count
                ) {
                    ForEach(remedies.fastingDays) { fasting in
                        fastingCard(fasting)
                    }
                }
            }

            // Pujas
            if !remedies.pujas.isEmpty {
                remedyTypeSection(
                    type: .puja,
                    count: remedies.pujas.count
                ) {
                    ForEach(remedies.pujas) { puja in
                        pujaCard(puja)
                    }
                }
            }
        }
    }

    // MARK: - Summary Card

    private func remedySummaryCard(_ remedies: PersonalizedRemedies) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.system(size: 20))
                        .foregroundColor(.kundliPrimary)

                    Text("Remedy Summary")
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliTextPrimary)

                    Spacer()

                    Text("\(remedies.totalRemedies) total")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                // Breakdown
                HStack(spacing: 16) {
                    summaryItem(icon: "diamond.fill", count: remedies.gemstones.count, label: "Gems", color: .cyan)
                    summaryItem(icon: "waveform", count: remedies.mantras.count, label: "Mantras", color: .orange)
                    summaryItem(icon: "gift.fill", count: remedies.charities.count, label: "Charity", color: .green)
                    summaryItem(icon: "leaf.fill", count: remedies.fastingDays.count, label: "Fasts", color: .purple)
                    summaryItem(icon: "flame.fill", count: remedies.pujas.count, label: "Pujas", color: .red)
                }

                // High priority items
                let highPriorityCount = countHighPriorityRemedies(remedies)
                if highPriorityCount > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.kundliWarning)

                        Text("\(highPriorityCount) high priority \(highPriorityCount == 1 ? "remedy" : "remedies")")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliWarning)
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

    private func summaryItem(icon: String, count: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(count > 0 ? color : color.opacity(0.3))

            Text("\(count)")
                .font(.kundliSubheadline)
                .fontWeight(.semibold)
                .foregroundColor(count > 0 ? .kundliTextPrimary : .kundliTextSecondary)

            Text(label)
                .font(.kundliCaption2)
                .foregroundColor(.kundliTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func countHighPriorityRemedies(_ remedies: PersonalizedRemedies) -> Int {
        let gemsCount = remedies.gemstones.filter { $0.reason.severity == .high }.count
        let mantrasCount = remedies.mantras.filter { $0.reason.severity == .high }.count
        let charitiesCount = remedies.charities.filter { $0.reason.severity == .high }.count
        let fastingCount = remedies.fastingDays.filter { $0.reason.severity == .high }.count
        let pujasCount = remedies.pujas.filter { $0.reason.severity == .high }.count
        return gemsCount + mantrasCount + charitiesCount + fastingCount + pujasCount
    }

    // MARK: - Remedy Type Section

    private func remedyTypeSection<Content: View>(
        type: RemedyType,
        count: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack {
                Image(systemName: type.icon)
                    .font(.system(size: 20))
                    .foregroundColor(type.color)

                Text(type.rawValue)
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                Spacer()

                Text("\(count)")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(type.color.opacity(0.2))
                    )
            }

            // Section description
            Text(type.description)
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)

            // Content
            content()
        }
    }

    // MARK: - Gemstone Card

    private func gemstoneCard(_ gemstone: Gemstone) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                // Header with reason badge
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(gemstone.name)
                            .font(.kundliSubheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.kundliTextPrimary)

                        Text("(\(gemstone.sanskritName)) for \(gemstone.planetVedName)")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)
                    }

                    Spacer()

                    reasonBadge(gemstone.reason)
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                // Reason
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: gemstone.reason.type.icon)
                        .font(.system(size: 12))
                        .foregroundColor(gemstone.reason.type.color)

                    Text(gemstone.reason.description)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                }

                // Wearing instructions
                VStack(alignment: .leading, spacing: 6) {
                    instructionRow(icon: "scalemass", text: "Weight: \(gemstone.weight)")
                    instructionRow(icon: "circle.fill", text: "Metal: \(gemstone.metal)")
                    instructionRow(icon: "hand.raised", text: "\(gemstone.finger) finger, \(gemstone.hand) hand")
                    instructionRow(icon: "calendar", text: "Start on \(gemstone.dayToWear)")
                }

                // Alternative stones
                if !gemstone.alternativeStones.isEmpty {
                    HStack(spacing: 4) {
                        Text("Alternatives:")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)

                        Text(gemstone.alternativeStones.joined(separator: ", "))
                            .font(.kundliCaption)
                            .foregroundColor(.kundliPrimary)
                    }
                }
            }
        }
    }

    // MARK: - Mantra Card

    private func mantraCard(_ mantra: Mantra) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(mantra.planetVedName) Mantra")
                            .font(.kundliSubheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.kundliTextPrimary)

                        Text("For \(mantra.deity)")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)
                    }

                    Spacer()

                    reasonBadge(mantra.reason)
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                // Mantra text
                Text(mantra.text)
                    .font(.kundliSubheadline)
                    .italic()
                    .foregroundColor(.kundliPrimary)
                    .padding(.vertical, 8)

                // Meaning
                Text("Meaning: \(mantra.meaning)")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)

                // Instructions
                VStack(alignment: .leading, spacing: 6) {
                    instructionRow(icon: "repeat", text: "\(mantra.repetitions) times daily")
                    if let total = mantra.totalCount {
                        instructionRow(icon: "number", text: "Total: \(total.formatted()) times")
                    }
                    instructionRow(icon: "clock", text: "Best time: \(mantra.bestTime)")
                    instructionRow(icon: "calendar", text: "Best day: \(mantra.bestDay)")
                }
            }
        }
    }

    // MARK: - Charity Card

    private func charityCard(_ charity: Charity) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Donate \(charity.item)")
                            .font(.kundliSubheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.kundliTextPrimary)

                        Text("For \(charity.planetVedName)")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)
                    }

                    Spacer()

                    reasonBadge(charity.reason)
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                // Reason
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: charity.reason.type.icon)
                        .font(.system(size: 12))
                        .foregroundColor(charity.reason.type.color)

                    Text(charity.reason.description)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                }

                // Instructions
                VStack(alignment: .leading, spacing: 6) {
                    instructionRow(icon: "gift", text: charity.itemDescription)
                    instructionRow(icon: "calendar", text: "Day: \(charity.day)")
                    instructionRow(icon: "person.2", text: "To: \(charity.beneficiary)")
                    instructionRow(icon: "arrow.clockwise", text: "Frequency: \(charity.frequency)")
                }
            }
        }
    }

    // MARK: - Fasting Card

    private func fastingCard(_ fasting: FastingDay) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(fasting.day) Fasting")
                            .font(.kundliSubheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.kundliTextPrimary)

                        Text("For \(fasting.planetVedName)")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)
                    }

                    Spacer()

                    reasonBadge(fasting.reason)
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                // Instructions
                VStack(alignment: .leading, spacing: 6) {
                    instructionRow(icon: "xmark.circle", text: "Avoid: \(fasting.whatToAvoid.joined(separator: ", "))")
                    instructionRow(icon: "checkmark.circle", text: "Can eat: \(fasting.whatToEat.joined(separator: ", "))")
                    instructionRow(icon: "moon", text: "Break fast: \(fasting.breakFastTime)")
                    instructionRow(icon: "clock", text: "Duration: \(fasting.duration)")
                    instructionRow(icon: "hands.sparkles", text: "Worship: \(fasting.deity)")
                }
            }
        }
    }

    // MARK: - Puja Card

    private func pujaCard(_ puja: Puja) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(puja.name)
                            .font(.kundliSubheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.kundliTextPrimary)

                        Text(puja.sanskritName)
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)
                    }

                    Spacer()

                    reasonBadge(puja.reason)
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                // Purpose
                Text(puja.purpose)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)

                // Instructions
                VStack(alignment: .leading, spacing: 6) {
                    instructionRow(icon: "hands.sparkles", text: "Deity: \(puja.deity)")
                    instructionRow(icon: "clock", text: "Timing: \(puja.timing)")
                    instructionRow(icon: "arrow.clockwise", text: "Frequency: \(puja.frequency)")
                    instructionRow(icon: "hourglass", text: "Duration: \(puja.estimatedDuration)")
                }

                // Benefits
                if !puja.benefits.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Benefits:")
                            .font(.kundliCaption)
                            .fontWeight(.medium)
                            .foregroundColor(.kundliTextPrimary)

                        ForEach(puja.benefits, id: \.self) { benefit in
                            HStack(alignment: .top, spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.kundliSuccess)
                                    .padding(.top, 3)

                                Text(benefit)
                                    .font(.kundliCaption)
                                    .foregroundColor(.kundliTextSecondary)
                            }
                        }
                    }
                }

                // Temple recommendations
                if !puja.templeRecommendations.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Recommended Temples:")
                            .font(.kundliCaption)
                            .fontWeight(.medium)
                            .foregroundColor(.kundliTextPrimary)

                        Text(puja.templeRecommendations.joined(separator: ", "))
                            .font(.kundliCaption)
                            .foregroundColor(.kundliPrimary)
                    }
                }
            }
        }
    }

    // MARK: - Helper Views

    private func instructionRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.kundliPrimary)
                .frame(width: 16)

            Text(text)
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)
        }
    }

    private func reasonBadge(_ reason: RemedyReason) -> some View {
        Text(reason.severity.rawValue)
            .font(.kundliCaption2)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(reason.severity.color)
            )
    }

    // MARK: - Static Remedies Section (Fallback)

    private var staticRemediesSection: some View {
        VStack(spacing: 16) {
            ForEach(RemedyType.allCases, id: \.self) { category in
                staticRemedyCategoryCard(category: category)
            }
        }
    }

    private func staticRemedyCategoryCard(category: RemedyType) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: category.icon)
                        .font(.system(size: 24))
                        .foregroundColor(category.color)

                    Text(category.rawValue)
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliTextPrimary)

                    Spacer()
                }

                Text(category.description)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)

                ForEach(staticSampleRemedies(for: category), id: \.self) { remedy in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(category.color.opacity(0.5))
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)

                        Text(remedy)
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextSecondary)
                    }
                }
            }
        }
    }

    private func staticSampleRemedies(for category: RemedyType) -> [String] {
        switch category {
        case .gemstones:
            return [
                "Wear Ruby (Manikya) for Sun strength",
                "Pearl (Moti) recommended for Moon",
                "Yellow Sapphire (Pukhraj) for Jupiter"
            ]
        case .mantras:
            return [
                "Chant Surya Mantra 108 times daily",
                "Om Namah Shivaya for Saturn relief",
                "Hanuman Chalisa on Tuesdays"
            ]
        case .charity:
            return [
                "Donate wheat on Sundays",
                "Feed cows on Mondays",
                "Donate black items on Saturdays"
            ]
        case .fasting:
            return [
                "Fast on Mondays for Moon",
                "Thursday fasting for Jupiter",
                "Saturday fasting for Saturn"
            ]
        case .puja:
            return [
                "Navagraha Shanti Puja",
                "Rudrabhishek for malefic planets",
                "Lakshmi Puja for Venus"
            ]
        }
    }

    // MARK: - Disclaimer

    private var disclaimerText: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "info.circle")
                    .font(.system(size: 12))
                Text("Important")
                    .font(.kundliCaption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.kundliWarning)

            Text("These remedies are based on traditional Vedic astrology principles. Results may vary based on individual circumstances. Always consult a qualified astrologer for personalized guidance. Gemstones should be worn only after proper consultation.")
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.kundliWarning.opacity(0.1))
        )
    }

    // MARK: - Generate Remedies

    private func generateRemedies() {
        guard let viewModel = viewModel,
              let kundli = viewModel.kundli else {
            return
        }

        isLoading = true

        // Generate remedies in background
        Task {
            let remedies = RemedyGenerationService.shared.generateRemedies(
                planets: kundli.planets,
                doshas: viewModel.doshas,
                planetaryStrengths: viewModel.planetaryStrengths,
                activeDasha: viewModel.activeDasha,
                activeAntarDasha: viewModel.activeAntarDasha
            )

            await MainActor.run {
                self.personalizedRemedies = remedies
                self.isLoading = false
            }
        }
    }
}

#Preview {
    NavigationStack {
        RemediesView()
    }
}

#Preview("With ViewModel") {
    NavigationStack {
        RemediesView(viewModel: {
            let vm = KundliViewModel()
            vm.loadSampleKundli()
            return vm
        }())
    }
}
