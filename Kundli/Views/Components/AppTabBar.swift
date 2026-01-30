import SwiftUI

enum TabItem: String, CaseIterable {
    case chart = "Chart"
    case panchang = "Panchang"
    case matching = "Matching"
    case profile = "Profile"

    var icon: String {
        switch self {
        case .chart: return "square.grid.2x2"
        case .panchang: return "calendar"
        case .matching: return "heart.fill"
        case .profile: return "person.fill"
        }
    }

    var selectedIcon: String {
        switch self {
        case .chart: return "square.grid.2x2.fill"
        case .panchang: return "calendar"
        case .matching: return "heart.fill"
        case .profile: return "person.fill"
        }
    }
}

struct AppTabBar: View {
    @Binding var selectedTab: TabItem

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(
            Rectangle()
                .fill(Color.kundliCardBg)
                .overlay(
                    Rectangle()
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 1),
                    alignment: .top
                )
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tabButton(for tab: TabItem) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 22))
                    .foregroundColor(selectedTab == tab ? .kundliPrimary : .kundliTextSecondary)

                Text(tab.rawValue)
                    .font(.kundliCaption2)
                    .foregroundColor(selectedTab == tab ? .kundliPrimary : .kundliTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

struct TabBarContainer<Content: View>: View {
    @Binding var selectedTab: TabItem
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            AppTabBar(selectedTab: $selectedTab)
        }
        .background(Color.kundliBackground)
    }
}

#Preview {
    @Previewable @State var selectedTab: TabItem = .chart

    TabBarContainer(selectedTab: $selectedTab) {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            Text("Selected: \(selectedTab.rawValue)")
                .foregroundColor(.white)
        }
    }
}
