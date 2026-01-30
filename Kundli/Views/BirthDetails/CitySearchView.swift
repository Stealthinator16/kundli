import SwiftUI

struct CitySearchView: View {
    @Binding var searchText: String
    @Binding var selectedCity: City?
    let cities: [City]
    let onSearch: () -> Void

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color.kundliBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.kundliTextSecondary)

                        TextField("Search city...", text: $searchText)
                            .font(.kundliBody)
                            .foregroundColor(.kundliTextPrimary)
                            .focused($isSearchFocused)
                            .onChange(of: searchText) { _, _ in
                                onSearch()
                            }

                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                                onSearch()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.kundliTextSecondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .padding()

                    // City list
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(cities) { city in
                                CityRow(city: city, isSelected: selectedCity?.id == city.id) {
                                    selectedCity = city
                                    searchText = city.displayName
                                    dismiss()
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.kundliPrimary)
                }
            }
            .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            isSearchFocused = true
        }
    }
}

struct CityRow: View {
    let city: City
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .kundliPrimary : .kundliTextSecondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(city.name)
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextPrimary)

                    Text("\(city.state), \(city.country)")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.kundliPrimary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                isSelected ?
                Color.kundliPrimary.opacity(0.1) :
                Color.clear
            )
        }
        .buttonStyle(.plain)

        Divider()
            .background(Color.white.opacity(0.1))
            .padding(.leading, 56)
    }
}

#Preview {
    @Previewable @State var searchText = ""
    @Previewable @State var selectedCity: City? = nil

    CitySearchView(
        searchText: $searchText,
        selectedCity: $selectedCity,
        cities: MockDataService.shared.cities
    ) {
        // Search
    }
}
