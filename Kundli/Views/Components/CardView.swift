import SwiftUI

struct CardView<Content: View>: View {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 16
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.kundliCardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
    }
}

struct GlassCard<Content: View>: View {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 16
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

struct GradientCard<Content: View>: View {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 16
    var colors: [Color] = [Color(hex: "3d3520"), Color(hex: "342d18")]
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
    }
}

struct InfoCard: View {
    let title: String
    let value: String
    var icon: String? = nil

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 12))
                            .foregroundColor(.kundliTextSecondary)
                    }
                    Text(title)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                }

                Text(value)
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct StatusBadge: View {
    let status: PlanetStatus

    var body: some View {
        Text(status.rawValue)
            .font(.kundliCaption2)
            .foregroundColor(status == .retrograde ? .kundliBackground : .white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(status.color)
            )
    }
}

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        VStack(spacing: 16) {
            CardView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Card Title")
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliTextPrimary)
                    Text("This is a sample card content")
                        .font(.kundliBody)
                        .foregroundColor(.kundliTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            GlassCard {
                Text("Glass Card Content")
                    .foregroundColor(.white)
            }

            HStack(spacing: 12) {
                InfoCard(title: "Tithi", value: "Shukla Navami", icon: "moon.fill")
                InfoCard(title: "Nakshatra", value: "Rohini", icon: "star.fill")
            }

            HStack(spacing: 8) {
                StatusBadge(status: .direct)
                StatusBadge(status: .retrograde)
                StatusBadge(status: .exalted)
                StatusBadge(status: .debilitated)
            }
        }
        .padding()
    }
}
