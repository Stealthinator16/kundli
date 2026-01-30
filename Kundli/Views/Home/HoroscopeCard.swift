import SwiftUI

struct HoroscopeCard: View {
    let horoscope: DailyHoroscope
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Daily Horoscope")
                            .font(.kundliCaption)
                            .foregroundColor(.white.opacity(0.7))

                        HStack(spacing: 8) {
                            Text(horoscope.sign.rawValue)
                                .font(.kundliTitle2)
                                .foregroundColor(.white)

                            Text(horoscope.sign.symbol)
                                .font(.system(size: 24))
                        }
                    }

                    Spacer()

                    // Rating stars
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= horoscope.overallRating ? "star.fill" : "star")
                                .font(.system(size: 12))
                                .foregroundColor(.kundliPrimary)
                        }
                    }
                }

                // Prediction text
                Text(horoscope.prediction)
                    .font(.kundliSubheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                // Footer
                HStack {
                    HStack(spacing: 16) {
                        labelValue("Lucky No.", "\(horoscope.luckyNumber)")
                        labelValue("Lucky Color", horoscope.luckyColor)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Text("Full Prediction")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliPrimary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                            .foregroundColor(.kundliPrimary)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "4a3f1f"),
                                Color(hex: "342d18")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.kundliPrimary.opacity(0.4),
                                        Color.kundliPrimary.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func labelValue(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.kundliCaption2)
                .foregroundColor(.white.opacity(0.5))
            Text(value)
                .font(.kundliFootnote)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        HoroscopeCard(
            horoscope: MockDataService.shared.dailyHoroscope(for: .scorpio)
        )
        .padding()
    }
}
