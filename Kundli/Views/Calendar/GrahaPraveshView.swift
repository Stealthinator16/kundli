import SwiftUI

/// View for displaying upcoming Graha Pravesh (house-warming) auspicious dates
struct GrahaPraveshView: View {
    @State private var grahaPraveshDates: [GrahaPraveshDate] = []
    @State private var isLoading = true
    @State private var selectedDate: GrahaPraveshDate?
    @State private var showDetailSheet = false

    private let grahaPraveshService = GrahaPraveshService.shared

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            if isLoading {
                loadingView
            } else if grahaPraveshDates.isEmpty {
                emptyView
            } else {
                datesList
            }
        }
        .navigationTitle("Graha Pravesh Dates")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            loadDates()
        }
        .sheet(isPresented: $showDetailSheet) {
            if let date = selectedDate {
                GrahaPraveshDetailSheet(grahaPraveshDate: date)
            }
        }
    }

    // MARK: - Loading View

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

    // MARK: - Empty View

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "house.fill")
                .font(.system(size: 60))
                .foregroundColor(.kundliTextSecondary)

            Text("No Dates Found")
                .font(.kundliTitle3)
                .foregroundColor(.kundliTextPrimary)

            Text("Unable to calculate Graha Pravesh dates")
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextSecondary)
        }
    }

    // MARK: - Dates List

    private var datesList: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header card
                headerCard

                // Info card
                infoCard

                // Dates
                VStack(spacing: 12) {
                    ForEach(grahaPraveshDates) { date in
                        GrahaPraveshDateCard(date: date) {
                            selectedDate = date
                            showDetailSheet = true
                        }
                    }
                }

                Spacer()
                    .frame(height: 20)
            }
            .padding(16)
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        CardView {
            VStack(spacing: 12) {
                Image(systemName: "house.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.kundliPrimary)

                Text("Griha Pravesh Muhurta")
                    .font(.kundliTitle3)
                    .foregroundColor(.kundliTextPrimary)

                Text("Auspicious dates for house-warming ceremony")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Info Card

    private var infoCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Label("About Graha Pravesh", systemImage: "info.circle.fill")
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliPrimary)

                Text("Graha Pravesh is the ceremony of entering a new home for the first time. Performing this ritual on an auspicious day is believed to bring prosperity, peace, and positive energy to the household.")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)

                Divider()
                    .background(Color.white.opacity(0.1))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Auspicious factors considered:")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)

                    HStack(spacing: 8) {
                        factorChip("Nakshatra", icon: "star.fill")
                        factorChip("Tithi", icon: "moon.fill")
                        factorChip("Weekday", icon: "calendar")
                    }
                }
            }
        }
    }

    private func factorChip(_ text: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.system(size: 11))
        }
        .foregroundColor(.kundliPrimary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.kundliPrimary.opacity(0.15))
        )
    }

    // MARK: - Load Data

    private func loadDates() {
        isLoading = true

        DispatchQueue.global(qos: .userInitiated).async {
            let dates = grahaPraveshService.getUpcomingGrahaPraveshDates(limit: 12)

            DispatchQueue.main.async {
                grahaPraveshDates = dates
                isLoading = false
            }
        }
    }
}

// MARK: - Graha Pravesh Date Card

struct GrahaPraveshDateCard: View {
    let date: GrahaPraveshDate
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            CardView {
                HStack(spacing: 16) {
                    // Date badge
                    VStack(spacing: 2) {
                        Text(monthAbbrev)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.kundliPrimary)

                        Text(dayNumber)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.kundliTextPrimary)

                        Text(date.weekday.prefix(3))
                            .font(.system(size: 10))
                            .foregroundColor(.kundliTextSecondary)
                    }
                    .frame(width: 50)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.kundliPrimary.opacity(0.1))
                    )

                    // Info
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Graha Pravesh Muhurta")
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextPrimary)

                        HStack(spacing: 12) {
                            Label(date.nakshatra, systemImage: "star.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.kundliTextSecondary)

                            Label(date.tithi, systemImage: "moon.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.kundliTextSecondary)
                        }

                        // Quality badge
                        HStack {
                            Circle()
                                .fill(qualityColor)
                                .frame(width: 8, height: 8)

                            Text(date.qualityRating.rawValue)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(qualityColor)
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
        return formatter.string(from: date.date).uppercased()
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date.date)
    }

    private var qualityColor: Color {
        switch date.qualityRating {
        case .excellent: return .kundliPrimary
        case .veryGood: return .kundliSuccess
        case .good: return .kundliInfo
        case .fair: return .kundliTextSecondary
        }
    }
}

// MARK: - Graha Pravesh Detail Sheet

struct GrahaPraveshDetailSheet: View {
    let grahaPraveshDate: GrahaPraveshDate
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

                        // Reasons
                        if !grahaPraveshDate.reasons.isEmpty {
                            reasonsCard
                        }

                        // Traditions
                        traditionsCard

                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Graha Pravesh Details")
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
                Image(systemName: "house.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.kundliPrimary)

                Text(grahaPraveshDate.formattedDate)
                    .font(.kundliTitle3)
                    .foregroundColor(.kundliTextPrimary)

                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("Nakshatra")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)
                        Text(grahaPraveshDate.nakshatra)
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextPrimary)
                    }

                    Divider()
                        .frame(height: 30)

                    VStack(spacing: 4) {
                        Text("Tithi")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)
                        Text(grahaPraveshDate.tithi)
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

                    Text(grahaPraveshDate.qualityRating.rawValue)
                        .font(.kundliSubheadline)
                        .foregroundColor(qualityColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(qualityColor.opacity(0.2))
                        )
                }

                Text(grahaPraveshDate.qualityRating.description)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)

                // Quality score bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(qualityColor)
                            .frame(width: geometry.size.width * CGFloat(grahaPraveshDate.qualityScore) / 10, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
    }

    private var reasonsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Label("Why this date is auspicious", systemImage: "checkmark.seal.fill")
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliSuccess)

                ForEach(grahaPraveshDate.reasons, id: \.self) { reason in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.kundliPrimary)
                            .padding(.top, 4)

                        Text(reason)
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)
                    }
                }
            }
        }
    }

    private var traditionsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Label("Graha Pravesh Traditions", systemImage: "flame.fill")
                    .font(.kundliSubheadline)
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 8) {
                    traditionItem("Perform Ganesh Puja and Vastu Puja")
                    traditionItem("Boil milk until it overflows (symbolizes abundance)")
                    traditionItem("Light a lamp at the entrance")
                    traditionItem("Enter with the right foot first")
                    traditionItem("Carry holy water (Ganga Jal) inside")
                    traditionItem("Place Tulsi plant in the new home")
                }
            }
        }
    }

    private func traditionItem(_ text: String) -> some View {
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

    private var qualityColor: Color {
        switch grahaPraveshDate.qualityRating {
        case .excellent: return .kundliPrimary
        case .veryGood: return .kundliSuccess
        case .good: return .kundliInfo
        case .fair: return .kundliTextSecondary
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        GrahaPraveshView()
    }
}
