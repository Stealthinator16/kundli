import SwiftUI

struct QuickLink: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
}

struct QuickLinksRow: View {
    let links: [QuickLink]
    var onTap: ((QuickLink) -> Void)? = nil

    static let defaultLinks: [QuickLink] = [
        QuickLink(title: "Kundli", icon: "square.grid.2x2.fill", color: .kundliPrimary),
        QuickLink(title: "Matching", icon: "heart.fill", color: .pink),
        QuickLink(title: "Dasha", icon: "chart.line.uptrend.xyaxis", color: .purple),
        QuickLink(title: "Remedies", icon: "sparkles", color: .orange),
        QuickLink(title: "Panchang", icon: "calendar", color: .blue),
        QuickLink(title: "Muhurta", icon: "clock.fill", color: .green),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Services")
                .font(.kundliHeadline)
                .foregroundColor(.kundliTextPrimary)
                .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(links) { link in
                        QuickLinkItem(link: link) {
                            onTap?(link)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

struct QuickLinkItem: View {
    let link: QuickLink
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(link.color.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: link.icon)
                        .font(.system(size: 22))
                        .foregroundColor(link.color)
                }

                Text(link.title)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        QuickLinksRow(links: QuickLinksRow.defaultLinks)
            .padding()
    }
}
