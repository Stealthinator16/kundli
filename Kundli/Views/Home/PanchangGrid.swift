import SwiftUI

struct PanchangGrid: View {
    let panchang: Panchang
    @State private var currentHora: HoraPeriod?

    // Default location (Delhi)
    private let latitude: Double = 28.6139
    private let longitude: Double = 77.2090

    var body: some View {
        VStack(spacing: 12) {
            // Title
            HStack {
                Text("Today's Panchang")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                Spacer()

                Text(formattedDate)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)
            }

            // 2x2 Grid + Hora
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                PanchangItem(
                    title: "Tithi",
                    value: panchang.tithi.fullName,
                    icon: "moon.stars.fill"
                )

                PanchangItem(
                    title: "Nakshatra",
                    value: panchang.nakshatra,
                    icon: "star.fill"
                )

                PanchangItem(
                    title: "Yoga",
                    value: panchang.yoga,
                    icon: "sparkles"
                )

                PanchangItem(
                    title: "Karana",
                    value: panchang.karana,
                    icon: "circle.hexagonpath.fill"
                )
            }

            // Current Hora row
            if let hora = currentHora {
                NavigationLink {
                    HoraView()
                } label: {
                    PanchangItem(
                        title: "Current Hora",
                        value: "\(hora.planet.rawValue) (\(hora.planet.symbol))",
                        icon: hora.planet.icon
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            loadCurrentHora()
        }
    }

    private func loadCurrentHora() {
        currentHora = HoraService.shared.getCurrentHora(
            latitude: latitude,
            longitude: longitude
        )
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: panchang.date)
    }
}

struct PanchangItem: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        CardView(padding: 14) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.kundliPrimary)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)

                    Text(value)
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextPrimary)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
        }
    }
}

struct RahuKaalBanner: View {
    let panchang: Panchang

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: panchang.isRahuKaalActive ? "exclamationmark.triangle.fill" : "clock.fill")
                .font(.system(size: 18))
                .foregroundColor(panchang.isRahuKaalActive ? .kundliWarning : .kundliTextSecondary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Rahu Kaal")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)

                Text(panchang.formattedRahuKaal)
                    .font(.kundliSubheadline)
                    .foregroundColor(panchang.isRahuKaalActive ? .kundliWarning : .kundliTextPrimary)
            }

            Spacer()

            if panchang.isRahuKaalActive {
                Text("Active Now")
                    .font(.kundliCaption2)
                    .foregroundColor(.kundliBackground)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.kundliWarning)
                    )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(panchang.isRahuKaalActive ?
                      Color.kundliWarning.opacity(0.1) :
                      Color.kundliCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            panchang.isRahuKaalActive ?
                            Color.kundliWarning.opacity(0.3) :
                            Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
        )
    }
}

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        VStack(spacing: 20) {
            PanchangGrid(panchang: MockDataService.shared.todayPanchang())

            RahuKaalBanner(panchang: MockDataService.shared.todayPanchang())
        }
        .padding()
    }
}
