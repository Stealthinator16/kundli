import SwiftUI

struct GoldButton: View {
    let title: String
    var icon: String? = nil
    var isFullWidth: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.kundliHeadline)
            }
            .foregroundColor(.kundliBackground)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                LinearGradient.kundliGold
            )
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct SecondaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.kundliHeadline)
            }
            .foregroundColor(.kundliPrimary)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.kundliPrimary, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

struct SmallButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                }
                Text(title)
                    .font(.kundliFootnote)
            }
            .foregroundColor(.kundliPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.kundliPrimary.opacity(0.15))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        VStack(spacing: 20) {
            GoldButton(title: "Generate Kundli", icon: "sparkles") {
                print("Tapped")
            }

            SecondaryButton(title: "View Details", icon: "chevron.right") {
                print("Tapped")
            }

            SmallButton(title: "See More", icon: "arrow.right") {
                print("Tapped")
            }
        }
        .padding()
    }
}
