import SwiftUI

struct HoraCard: View {
    @State private var currentHora: HoraPeriod?
    @State private var timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    // Default location (Delhi) - in production, use user's location
    private let latitude: Double = 28.6139
    private let longitude: Double = 77.2090

    var body: some View {
        NavigationLink {
            HoraView()
        } label: {
            CardView {
                HStack(spacing: 12) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.kundliPrimary.opacity(0.2))
                            .frame(width: 44, height: 44)

                        if let hora = currentHora {
                            Image(systemName: hora.planet.icon)
                                .font(.system(size: 20))
                                .foregroundColor(.kundliPrimary)
                        } else {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.kundliPrimary)
                        }
                    }

                    // Content
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Hora")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)

                        if let hora = currentHora {
                            HStack(spacing: 4) {
                                Text(hora.planet.rawValue)
                                    .font(.kundliSubheadline)
                                    .foregroundColor(.kundliTextPrimary)

                                Text("(\(hora.planet.symbol))")
                                    .font(.kundliCaption)
                                    .foregroundColor(.kundliTextSecondary)
                            }
                        } else {
                            Text("Loading...")
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliTextSecondary)
                        }
                    }

                    Spacer()

                    // Right side - time remaining
                    if let hora = currentHora {
                        VStack(alignment: .trailing, spacing: 4) {
                            if let remaining = hora.remainingTime {
                                Text(remaining)
                                    .font(.kundliCaption)
                                    .foregroundColor(.kundliPrimary)
                            }

                            // Nature badge
                            Text(hora.planet.nature.rawValue)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(natureColor(hora.planet.nature))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(natureColor(hora.planet.nature).opacity(0.2))
                                )
                        }
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.kundliTextSecondary)
                }
            }
        }
        .buttonStyle(.plain)
        .onAppear {
            loadCurrentHora()
        }
        .onReceive(timer) { _ in
            loadCurrentHora()
        }
    }

    private func natureColor(_ nature: HoraNature) -> Color {
        switch nature {
        case .benefic: return .kundliSuccess
        case .malefic: return .kundliError
        case .neutral: return .kundliInfo
        }
    }

    private func loadCurrentHora() {
        currentHora = HoraService.shared.getCurrentHora(
            latitude: latitude,
            longitude: longitude
        )
    }
}

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        HoraCard()
            .padding()
    }
}
