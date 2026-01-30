import SwiftUI

struct HoraView: View {
    @State private var horaData: HoraData?
    @State private var selectedPeriod: HoraPeriod?
    @State private var timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    // Default location (Delhi) - in production, use user's location
    private let latitude: Double = 28.6139
    private let longitude: Double = 77.2090

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Current Hora Card
                    if let currentPeriod = horaData?.currentPeriod {
                        currentHoraCard(period: currentPeriod)
                    }

                    // Day/Night Toggle
                    if let horaData = horaData {
                        // Day Horas
                        horaSection(
                            title: "Day Horas",
                            subtitle: "Sunrise to Sunset",
                            periods: horaData.dayPeriods,
                            icon: "sun.max.fill"
                        )

                        // Night Horas
                        horaSection(
                            title: "Night Horas",
                            subtitle: "Sunset to Sunrise",
                            periods: horaData.nightPeriods,
                            icon: "moon.stars.fill"
                        )
                    }

                    // Hora Legend
                    horaLegend

                    Spacer()
                        .frame(height: 20)
                }
                .padding(16)
            }
        }
        .navigationTitle("Hora")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            loadHoraData()
        }
        .onReceive(timer) { _ in
            loadHoraData()
        }
        .sheet(item: $selectedPeriod) { period in
            HoraPeriodDetailSheet(period: period)
        }
    }

    private func currentHoraCard(period: HoraPeriod) -> some View {
        CardView {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Hora")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)

                        HStack(spacing: 8) {
                            Image(systemName: period.planet.icon)
                                .font(.system(size: 24))
                                .foregroundColor(.kundliPrimary)

                            Text(period.planet.rawValue)
                                .font(.kundliTitle2)
                                .foregroundColor(.kundliTextPrimary)

                            Text("(\(period.planet.vedName))")
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliTextSecondary)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(period.isDay ? "Day" : "Night")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)

                        Text(period.remainingTime ?? "")
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliPrimary)
                    }
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.kundliPrimary)
                            .frame(width: geometry.size.width * period.progress)
                    }
                }
                .frame(height: 8)

                // Time range
                HStack {
                    Text(formatTime(period.startTime))
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)

                    Spacer()

                    Text(formatTime(period.endTime))
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                }

                // Nature badge
                HStack {
                    natureBadge(period.planet.nature)

                    Spacer()

                    Text("Hora #\(period.horaNumber)")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextTertiary)
                }
            }
        }
    }

    private func horaSection(title: String, subtitle: String, periods: [HoraPeriod], icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.kundliPrimary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliTextPrimary)

                    Text(subtitle)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                }

                Spacer()
            }

            LazyVStack(spacing: 8) {
                ForEach(periods) { period in
                    horaRow(period: period)
                        .onTapGesture {
                            selectedPeriod = period
                        }
                }
            }
        }
    }

    private func horaRow(period: HoraPeriod) -> some View {
        HStack(spacing: 12) {
            // Planet icon
            ZStack {
                Circle()
                    .fill(period.isActive ? Color.kundliPrimary.opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 40, height: 40)

                Image(systemName: period.planet.icon)
                    .font(.system(size: 16))
                    .foregroundColor(period.isActive ? .kundliPrimary : .kundliTextSecondary)
            }

            // Planet name and time
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(period.planet.rawValue)
                        .font(.kundliSubheadline)
                        .foregroundColor(period.isActive ? .kundliTextPrimary : .kundliTextSecondary)

                    if period.isActive {
                        Text("Active")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.kundliBackground)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.kundliPrimary))
                    }
                }

                Text(period.formattedTimeRange)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextTertiary)
            }

            Spacer()

            // Nature indicator
            Circle()
                .fill(natureColor(period.planet.nature))
                .frame(width: 8, height: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.kundliTextTertiary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(period.isActive ? Color.kundliPrimary.opacity(0.1) : Color.kundliCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            period.isActive ? Color.kundliPrimary.opacity(0.3) : Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
        )
        .opacity(period.isCompleted && !period.isActive ? 0.5 : 1.0)
    }

    private var horaLegend: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Hora Nature")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                HStack(spacing: 16) {
                    legendItem(color: .kundliSuccess, label: "Benefic")
                    legendItem(color: .kundliError, label: "Malefic")
                    legendItem(color: .kundliInfo, label: "Neutral")
                }
            }
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            Text(label)
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)
        }
    }

    private func natureBadge(_ nature: HoraNature) -> some View {
        Text(nature.rawValue)
            .font(.kundliCaption2)
            .foregroundColor(natureColor(nature))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(natureColor(nature).opacity(0.2))
            )
    }

    private func natureColor(_ nature: HoraNature) -> Color {
        switch nature {
        case .benefic: return .kundliSuccess
        case .malefic: return .kundliError
        case .neutral: return .kundliInfo
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    private func loadHoraData() {
        horaData = HoraService.shared.calculateHoraPeriods(
            date: Date(),
            latitude: latitude,
            longitude: longitude
        )
    }
}

// MARK: - Hora Period Detail Sheet

struct HoraPeriodDetailSheet: View {
    let period: HoraPeriod
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.kundliBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.kundliPrimary.opacity(0.2))
                                    .frame(width: 80, height: 80)

                                Image(systemName: period.planet.icon)
                                    .font(.system(size: 36))
                                    .foregroundColor(.kundliPrimary)
                            }

                            Text(period.planet.rawValue)
                                .font(.kundliTitle2)
                                .foregroundColor(.kundliTextPrimary)

                            Text(period.planet.vedName)
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliTextSecondary)
                        }
                        .padding(.top, 20)

                        // Time info
                        CardView {
                            VStack(spacing: 12) {
                                detailRow("Time", period.formattedTimeRange)
                                Divider().background(Color.white.opacity(0.1))
                                detailRow("Type", period.isDay ? "Day Hora" : "Night Hora")
                                Divider().background(Color.white.opacity(0.1))
                                detailRow("Hora Number", "#\(period.horaNumber)")
                                Divider().background(Color.white.opacity(0.1))
                                detailRow("Nature", period.planet.nature.rawValue)
                            }
                        }
                        .padding(.horizontal, 16)

                        // Auspicious activities
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Auspicious For")
                                .font(.kundliHeadline)
                                .foregroundColor(.kundliTextPrimary)
                                .padding(.horizontal, 16)

                            CardView {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(period.planet.auspiciousFor, id: \.self) { activity in
                                        HStack(spacing: 8) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.kundliSuccess)
                                                .font(.system(size: 14))

                                            Text(activity)
                                                .font(.kundliSubheadline)
                                                .foregroundColor(.kundliTextPrimary)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
            }
            .navigationTitle("Hora Details")
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

    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextSecondary)

            Spacer()

            Text(value)
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextPrimary)
        }
    }
}

extension HoraPeriod: Equatable {
    static func == (lhs: HoraPeriod, rhs: HoraPeriod) -> Bool {
        lhs.id == rhs.id
    }
}

#Preview {
    NavigationStack {
        HoraView()
    }
}
