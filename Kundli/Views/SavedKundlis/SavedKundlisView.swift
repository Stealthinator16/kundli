import SwiftUI
import SwiftData

struct SavedKundlisView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedKundli.updatedAt, order: .reverse) private var savedKundlis: [SavedKundli]

    @State private var showDeleteAlert = false
    @State private var kundliToDelete: SavedKundli?
    @State private var selectedKundli: SavedKundli?
    @State private var showKundliDetail = false

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            if savedKundlis.isEmpty {
                emptyState
            } else {
                kundliList
            }
        }
        .navigationTitle("Saved Kundlis")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert("Delete Kundli", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let kundli = kundliToDelete {
                    deleteKundli(kundli)
                }
            }
        } message: {
            Text("Are you sure you want to delete this kundli? This action cannot be undone.")
        }
        .navigationDestination(isPresented: $showKundliDetail) {
            if let kundli = selectedKundli {
                SavedKundliDetailView(savedKundli: kundli)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 60))
                .foregroundColor(.kundliTextSecondary)

            Text("No Saved Kundlis")
                .font(.kundliTitle3)
                .foregroundColor(.kundliTextPrimary)

            Text("Create a new kundli to see it here")
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextSecondary)
        }
    }

    private var kundliList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(savedKundlis) { kundli in
                    SavedKundliRow(kundli: kundli) {
                        selectedKundli = kundli
                        showKundliDetail = true
                    } onDelete: {
                        kundliToDelete = kundli
                        showDeleteAlert = true
                    }
                }
            }
            .padding(16)
        }
    }

    private func deleteKundli(_ kundli: SavedKundli) {
        withAnimation {
            modelContext.delete(kundli)
        }
    }
}

struct SavedKundliRow: View {
    let kundli: SavedKundli
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Avatar
                Circle()
                    .fill(Color.kundliPrimary.opacity(0.2))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Text(kundli.initials)
                            .font(.kundliHeadline)
                            .foregroundColor(.kundliPrimary)
                    )

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(kundli.name)
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliTextPrimary)

                    Text(kundli.formattedDateTime)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)

                    Text(kundli.birthCity)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                        .lineLimit(1)
                }

                Spacer()

                // Ascendant badge
                if !kundli.ascendantSign.isEmpty {
                    VStack(spacing: 2) {
                        Text(kundli.ascendantSign)
                            .font(.kundliCaption)
                            .foregroundColor(.kundliPrimary)
                        Text("Lagna")
                            .font(.system(size: 9))
                            .foregroundColor(.kundliTextSecondary)
                    }
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
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.kundliCardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                onTap()
            } label: {
                Label("View Kundli", systemImage: "eye")
            }

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct SavedKundliDetailView: View {
    let savedKundli: SavedKundli
    @State private var viewModel = KundliViewModel()

    var body: some View {
        BirthChartView(viewModel: viewModel)
            .onAppear {
                loadKundli()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AIFeatureEntryView(savedKundli: savedKundli)) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.kundliPrimary)
                    }
                }
            }
    }

    private func loadKundli() {
        // Load the saved kundli data into the view model
        viewModel.birthDetails = savedKundli.toBirthDetails()

        // Generate mock chart data (in real app, this would be stored/calculated)
        let planets = MockDataService.shared.samplePlanets()
        let ascendant = Ascendant(
            sign: ZodiacSign(rawValue: savedKundli.ascendantSign) ?? .scorpio,
            degree: savedKundli.ascendantDegree,
            minutes: 0,
            seconds: 0,
            nakshatra: savedKundli.ascendantNakshatra,
            nakshatraPada: 1,
            lord: "Mars"
        )

        viewModel.kundli = Kundli(
            id: savedKundli.id,
            birthDetails: savedKundli.toBirthDetails(),
            planets: planets,
            ascendant: ascendant
        )

        viewModel.dashaPeriods = MockDataService.shared.sampleDashaPeriods()
    }
}

#Preview {
    NavigationStack {
        SavedKundlisView()
    }
    .modelContainer(for: SavedKundli.self, inMemory: true)
}
