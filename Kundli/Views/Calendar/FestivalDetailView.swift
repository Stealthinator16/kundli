import SwiftUI

struct FestivalDetailView: View {
    let festival: FestivalInstance
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.kundliBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection

                        // Date info
                        dateInfoCard

                        // Description
                        if !festival.festival.description.isEmpty {
                            descriptionCard
                        }

                        // Significance
                        if !festival.festival.significance.isEmpty {
                            significanceCard
                        }

                        // Traditions
                        if !festival.festival.traditions.isEmpty {
                            traditionsCard
                        }

                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(16)
                }
            }
            .navigationTitle(festival.festival.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.kundliPrimary)
                }
            }
            .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 80, height: 80)

                Image(systemName: festival.festival.icon)
                    .font(.system(size: 32))
                    .foregroundColor(categoryColor)
            }

            // Name
            VStack(spacing: 4) {
                Text(festival.festival.name)
                    .font(.kundliTitle2)
                    .foregroundColor(.kundliTextPrimary)

                if festival.festival.vedName != festival.festival.name {
                    Text(festival.festival.vedName)
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextSecondary)
                }
            }

            // Category badge
            HStack(spacing: 8) {
                Text(festival.festival.category.rawValue)
                    .font(.kundliCaption)
                    .foregroundColor(categoryColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(categoryColor.opacity(0.2))
                    )

                if let deity = festival.festival.deity {
                    Text(deity)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                        )
                }
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Date Info Card

    private var dateInfoCard: some View {
        CardView {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.kundliPrimary)

                    Text("Date")
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextSecondary)

                    Spacer()

                    Text(festival.formattedDate)
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextPrimary)
                }

                if let daysUntil = festival.daysUntil {
                    Divider()
                        .background(Color.white.opacity(0.1))

                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.kundliPrimary)

                        Text("Days Until")
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextSecondary)

                        Spacer()

                        Text("\(daysUntil) day\(daysUntil == 1 ? "" : "s")")
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliPrimary)
                    }
                } else if festival.isToday {
                    Divider()
                        .background(Color.white.opacity(0.1))

                    HStack {
                        Spacer()
                        Text("Today!")
                            .font(.kundliHeadline)
                            .foregroundColor(.kundliPrimary)
                        Spacer()
                    }
                }

                // Lunar date info if available
                if let tithi = festival.festival.tithi, let lunarMonth = festival.festival.lunarMonth {
                    Divider()
                        .background(Color.white.opacity(0.1))

                    HStack {
                        Image(systemName: "moon.stars")
                            .foregroundColor(.kundliPrimary)

                        Text("Lunar Date")
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextSecondary)

                        Spacer()

                        Text("\(tithi), \(lunarMonth.rawValue)")
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextPrimary)
                    }
                }
            }
        }
    }

    // MARK: - Description Card

    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("About", icon: "info.circle")

            CardView {
                Text(festival.festival.description)
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliTextPrimary)
                    .lineSpacing(4)
            }
        }
    }

    // MARK: - Significance Card

    private var significanceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Significance", icon: "sparkles")

            CardView {
                Text(festival.festival.significance)
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliTextPrimary)
                    .lineSpacing(4)
            }
        }
    }

    // MARK: - Traditions Card

    private var traditionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Traditions & Customs", icon: "leaf")

            CardView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(festival.festival.traditions, id: \.self) { tradition in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.kundliSuccess)
                                .font(.system(size: 14))
                                .padding(.top, 2)

                            Text(tradition)
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliTextPrimary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.kundliPrimary)

            Text(title)
                .font(.kundliHeadline)
                .foregroundColor(.kundliTextPrimary)
        }
    }

    private var categoryColor: Color {
        switch festival.festival.category {
        case .major: return .kundliPrimary
        case .religious: return .orange
        case .fasting: return .green
        case .auspicious: return .kundliInfo
        case .regional: return .purple
        case .newYear: return .red
        case .grahaPravesh: return .kundliPrimary
        }
    }
}

#Preview {
    let sampleFestival = FestivalInstance(
        festival: Festival(
            name: "Diwali",
            vedName: "Deepavali",
            description: "Festival of Lights celebrating the victory of light over darkness",
            category: .major,
            deity: "Lakshmi, Ganesha",
            significance: "Celebrates Lord Rama's return to Ayodhya",
            traditions: ["Lighting diyas", "Rangoli", "Fireworks", "Lakshmi Puja"]
        ),
        date: Date(),
        year: 2024
    )

    return FestivalDetailView(festival: sampleFestival)
}
