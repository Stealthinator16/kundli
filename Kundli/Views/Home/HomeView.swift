import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var showBirthDetails = false
    @State private var showSavedKundlis = false
    @State private var showHoroscopeDetail = false
    @State private var showSettings = false
    @State private var animateContent = false

    @Query(sort: \SavedKundli.updatedAt, order: .reverse) private var savedKundlis: [SavedKundli]

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.kundliBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : -10)

                        // Daily Horoscope Card
                        HoroscopeCard(horoscope: viewModel.dailyHoroscope) {
                            showHoroscopeDetail = true
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)

                        // Panchang Grid
                        PanchangGrid(panchang: viewModel.panchang)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)

                        // Rahu Kaal Banner
                        RahuKaalBanner(panchang: viewModel.panchang)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)

                        // Quick Links
                        QuickLinksRow(links: QuickLinksRow.defaultLinks) { link in
                            handleQuickLink(link)
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)

                        // Saved Kundlis section
                        savedKundlisSection
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)

                        // Bottom padding for button
                        Spacer()
                            .frame(height: 80)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .refreshable {
                    viewModel.refreshData()
                }

                // Floating Create Button
                VStack {
                    Spacer()

                    GoldButton(title: "Create New Kundli", icon: "plus.circle.fill") {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        showBirthDetails = true
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 30)
                    .background(
                        LinearGradient(
                            colors: [
                                Color.kundliBackground.opacity(0),
                                Color.kundliBackground
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 100)
                        .allowsHitTesting(false),
                        alignment: .bottom
                    )
                }
            }
            .navigationDestination(isPresented: $showBirthDetails) {
                BirthDetailsView()
            }
            .navigationDestination(isPresented: $showSavedKundlis) {
                SavedKundlisView()
            }
            .navigationDestination(isPresented: $showHoroscopeDetail) {
                HoroscopeDetailView(horoscope: viewModel.dailyHoroscope)
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                    animateContent = true
                }
            }
        }
    }

    private var headerSection: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(
                    LinearGradient.kundliGold
                )
                .frame(width: 44, height: 44)
                .overlay(
                    Text(savedKundlis.first?.initials ?? "U")
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliBackground)
                )

            // Greeting
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.greeting)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)

                Text(savedKundlis.first?.name.components(separatedBy: " ").first ?? "User")
                    .font(.kundliTitle3)
                    .foregroundColor(.kundliTextPrimary)
            }

            Spacer()

            // Settings gear
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.kundliTextSecondary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.05))
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private var savedKundlisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Saved Kundlis")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                Spacer()

                if !savedKundlis.isEmpty {
                    Button {
                        showSavedKundlis = true
                    } label: {
                        Text("View All (\(savedKundlis.count))")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliPrimary)
                    }
                    .buttonStyle(.plain)
                }
            }

            if savedKundlis.isEmpty {
                // Empty state
                CardView {
                    VStack(spacing: 12) {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 32))
                            .foregroundColor(.kundliTextSecondary)

                        Text("No saved kundlis yet")
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextSecondary)

                        Text("Create your first kundli to see it here")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
            } else {
                // Show first 2 saved kundlis
                ForEach(savedKundlis.prefix(2)) { kundli in
                    NavigationLink {
                        SavedKundliDetailView(savedKundli: kundli)
                    } label: {
                        SavedKundliRowCompact(kundli: kundli)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func handleQuickLink(_ link: QuickLink) {
        switch link.title {
        case "Kundli":
            showBirthDetails = true
        default:
            break
        }
    }
}

struct SavedKundliRowCompact: View {
    let kundli: SavedKundli

    var body: some View {
        CardView {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.kundliPrimary.opacity(0.2))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text(kundli.initials)
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliPrimary)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(kundli.name)
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextPrimary)

                    Text(kundli.formattedDateTime)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                }

                Spacer()

                if !kundli.ascendantSign.isEmpty {
                    Text(kundli.ascendantSign)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.kundliPrimary.opacity(0.1))
                        )
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.kundliTextSecondary)
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: SavedKundli.self, inMemory: true)
}
