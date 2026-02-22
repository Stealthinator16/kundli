import SwiftUI

/// Preview component showing upcoming marriage dates
struct MarriageMuhurtaPreview: View {
    @State private var upcomingDates: [MarriageMuhurta] = []
    @State private var isLoading = true

    private let muhurtaService = MarriageMuhurtaService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Finding auspicious dates...")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                }
            } else if upcomingDates.isEmpty {
                Text("No upcoming dates found")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)
            } else {
                ForEach(upcomingDates.prefix(3)) { muhurta in
                    HStack(spacing: 12) {
                        // Date badge
                        VStack(spacing: 0) {
                            Text(muhurta.shortDate)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.kundliPrimary)
                        }
                        .frame(width: 50)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.kundliPrimary.opacity(0.15))
                        )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(muhurta.weekday)
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextPrimary)

                            Text(muhurta.nakshatra)
                                .font(.system(size: 10))
                                .foregroundColor(.kundliTextSecondary)
                        }

                        Spacer()

                        // Quality badge
                        Text(muhurta.qualityRating.rawValue)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(muhurta.qualityRating.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(muhurta.qualityRating.color.opacity(0.2))
                            )
                    }
                }
            }
        }
        .onAppear {
            loadDates()
        }
    }

    private func loadDates() {
        isLoading = true
        Task {
            let dates = muhurtaService.getUpcomingMarriageMuhurtas(limit: 3)
            await MainActor.run {
                upcomingDates = dates
                isLoading = false
            }
        }
    }
}

/// Full list view of marriage muhurtas
struct MarriageMuhurtaListView: View {
    @State private var muhurtas: [MarriageMuhurta] = []
    @State private var isLoading = true
    @State private var selectedMuhurta: MarriageMuhurta?

    private let muhurtaService = MarriageMuhurtaService.shared

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            if isLoading {
                loadingView
            } else if muhurtas.isEmpty {
                emptyView
            } else {
                muhurtaList
            }
        }
        .navigationTitle("Marriage Muhurtas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            loadMuhurtas()
        }
        .sheet(item: $selectedMuhurta) { muhurta in
            MarriageMuhurtaDetailSheet(muhurta: muhurta)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .kundliPrimary))
                .scaleEffect(1.2)

            Text("Finding auspicious dates...")
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextSecondary)
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.kundliTextSecondary)

            Text("No Dates Found")
                .font(.kundliTitle3)
                .foregroundColor(.kundliTextPrimary)

            Text("Unable to calculate marriage muhurtas")
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextSecondary)

            Button { loadMuhurtas() } label: {
                Label("Retry", systemImage: "arrow.clockwise")
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliPrimary)
            }
            .padding(.top, 8)
        }
    }

    private var muhurtaList: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header card
                headerCard

                // Info card
                infoCard

                // Muhurta list
                VStack(spacing: 12) {
                    ForEach(muhurtas) { muhurta in
                        MarriageMuhurtaCard(muhurta: muhurta) {
                            selectedMuhurta = muhurta
                        }
                    }
                }

                Spacer()
                    .frame(height: 20)
            }
            .padding(16)
        }
    }

    private var headerCard: some View {
        CardView {
            VStack(spacing: 12) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.pink)

                Text("Vivah Muhurta")
                    .font(.kundliTitle3)
                    .foregroundColor(.kundliTextPrimary)

                Text("Auspicious dates for marriage ceremony")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var infoCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Label("How dates are selected", systemImage: "info.circle.fill")
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliPrimary)

                Text("Marriage muhurtas are calculated based on Vedic astrology principles including favorable nakshatras (Rohini, Uttara Phalguni, Anuradha), auspicious tithis, beneficial yoga, and suitable weekdays.")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)

                Divider()
                    .background(Color.white.opacity(0.1))

                HStack(spacing: 8) {
                    FactorChipView(text: "Nakshatra", icon: "star.fill", accentColor: .pink)
                    FactorChipView(text: "Tithi", icon: "moon.fill", accentColor: .pink)
                    FactorChipView(text: "Yoga", icon: "sparkles", accentColor: .pink)
                }
            }
        }
    }

    private func loadMuhurtas() {
        isLoading = true
        Task {
            let dates = muhurtaService.getUpcomingMarriageMuhurtas(limit: 12)
            await MainActor.run {
                muhurtas = dates
                isLoading = false
            }
        }
    }
}

// MARK: - Marriage Muhurta Card

struct MarriageMuhurtaCard: View {
    let muhurta: MarriageMuhurta
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            CardView {
                HStack(spacing: 16) {
                    // Date badge
                    VStack(spacing: 2) {
                        Text(monthAbbrev)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.pink)

                        Text(dayNumber)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.kundliTextPrimary)

                        Text(muhurta.weekday.prefix(3))
                            .font(.system(size: 10))
                            .foregroundColor(.kundliTextSecondary)
                    }
                    .frame(width: 50)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.pink.opacity(0.1))
                    )

                    // Info
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Vivah Muhurta")
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextPrimary)

                        HStack(spacing: 12) {
                            Label(muhurta.nakshatra, systemImage: "star.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.kundliTextSecondary)

                            Label(muhurta.tithi, systemImage: "moon.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.kundliTextSecondary)
                        }

                        // Quality badge
                        HStack {
                            Circle()
                                .fill(muhurta.qualityRating.color)
                                .frame(width: 8, height: 8)

                            Text(muhurta.qualityRating.rawValue)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(muhurta.qualityRating.color)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.kundliTextSecondary)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var monthAbbrev: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: muhurta.date).uppercased()
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: muhurta.date)
    }
}

// MARK: - Marriage Muhurta Detail Sheet

struct MarriageMuhurtaDetailSheet: View {
    let muhurta: MarriageMuhurta
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.kundliBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Date header
                        dateHeader

                        // Quality info
                        qualityCard

                        // Best time
                        bestTimeCard

                        // Auspicious factors
                        if !muhurta.auspiciousFactors.isEmpty {
                            auspiciousFactorsCard
                        }

                        // Caution factors
                        if !muhurta.cautionFactors.isEmpty {
                            cautionFactorsCard
                        }

                        // Marriage tips
                        marriageTipsCard

                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Marriage Muhurta Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.kundliPrimary)
                }
            }
        }
    }

    private var dateHeader: some View {
        CardView {
            VStack(spacing: 16) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.pink)

                Text(muhurta.formattedDate)
                    .font(.kundliTitle3)
                    .foregroundColor(.kundliTextPrimary)

                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("Nakshatra")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)
                        Text(muhurta.nakshatra)
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextPrimary)
                    }

                    Divider()
                        .frame(height: 30)

                    VStack(spacing: 4) {
                        Text("Tithi")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)
                        Text(muhurta.tithi)
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextPrimary)
                    }

                    Divider()
                        .frame(height: 30)

                    VStack(spacing: 4) {
                        Text("Yoga")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)
                        Text(muhurta.yoga)
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextPrimary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var qualityCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Auspiciousness")
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextPrimary)

                    Spacer()

                    Text(muhurta.qualityRating.rawValue)
                        .font(.kundliSubheadline)
                        .foregroundColor(muhurta.qualityRating.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(muhurta.qualityRating.color.opacity(0.2))
                        )
                }

                Text(muhurta.qualityRating.description)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)

                // Quality score bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(muhurta.qualityRating.color)
                            .frame(width: geometry.size.width * CGFloat(muhurta.qualityScore) / 12, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
    }

    private var bestTimeCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Label("Best Time for Ceremony", systemImage: "clock.fill")
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliPrimary)

                Text(muhurta.bestTimeOfDay)
                    .font(.kundliBody)
                    .foregroundColor(.kundliTextPrimary)

                Text("The ceremony should ideally start during this muhurta for maximum auspiciousness.")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)
            }
        }
    }

    private var auspiciousFactorsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Label("Auspicious Factors", systemImage: "checkmark.seal.fill")
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliSuccess)

                ForEach(muhurta.auspiciousFactors, id: \.self) { factor in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.kundliPrimary)
                            .padding(.top, 4)

                        Text(factor)
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)
                    }
                }
            }
        }
    }

    private var cautionFactorsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Label("Points to Consider", systemImage: "exclamationmark.triangle.fill")
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliWarning)

                ForEach(muhurta.cautionFactors, id: \.self) { factor in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(.kundliWarning)
                            .padding(.top, 6)

                        Text(factor)
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)
                    }
                }
            }
        }
    }

    private var marriageTipsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Label("Marriage Ceremony Tips", systemImage: "lightbulb.fill")
                    .font(.kundliSubheadline)
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 8) {
                    tipItem("Perform Ganesh Puja before the ceremony")
                    tipItem("Ensure both families consult their astrologers")
                    tipItem("Keep the wedding rituals during the auspicious muhurta")
                    tipItem("Avoid starting the ceremony during Rahu Kaal")
                    tipItem("The 'Saat Pheras' should be during the main muhurta")
                }
            }
        }
    }

    private func tipItem(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundColor(.kundliTextSecondary)
                .padding(.top, 6)

            Text(text)
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)
        }
    }

}

// MARK: - Preview

#Preview {
    NavigationStack {
        MarriageMuhurtaListView()
    }
}
