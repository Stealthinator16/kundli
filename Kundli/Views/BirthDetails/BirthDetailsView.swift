import SwiftUI

struct BirthDetailsView: View {
    @State private var viewModel = KundliViewModel()
    @State private var showCitySearch = false
    @State private var navigateToChart = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            ScrollView {
                formContent
            }

            loadingOverlay
        }
        .navigationTitle("Birth Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $showCitySearch) {
            CitySearchView(
                searchText: $viewModel.citySearchText,
                selectedCity: $viewModel.selectedCity,
                cities: viewModel.searchResults
            ) {
                viewModel.searchCities()
            }
        }
        .navigationDestination(isPresented: $navigateToChart) {
            if viewModel.kundli != nil {
                BirthChartView(viewModel: viewModel)
            }
        }
        .onChange(of: viewModel.kundli) { _, newValue in
            if newValue != nil {
                navigateToChart = true
            }
        }
    }

    private var formContent: some View {
        VStack(spacing: 24) {
            headerSection
            formFieldsSection
            generateButtonSection
            sampleDataButton
        }
        .padding(16)
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(.kundliPrimary)

            Text("Enter Birth Details")
                .font(.kundliTitle2)
                .foregroundColor(.kundliTextPrimary)

            Text("Accurate details help create precise Kundli")
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    private var formFieldsSection: some View {
        VStack(spacing: 20) {
            nameField
            dateOfBirthField
            timeOfBirthField
            birthPlaceField
            genderField
        }
        .padding(.horizontal, 4)
    }

    private var nameField: some View {
        FormFieldWrapper(title: "Full Name") {
            TextField("Enter name", text: $viewModel.name)
                .textFieldStyle(KundliTextFieldStyle())
        }
    }

    private var dateOfBirthField: some View {
        FormFieldWrapper(title: "Date of Birth") {
            DatePicker(
                "",
                selection: $viewModel.dateOfBirth,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .tint(.kundliPrimary)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(datePickerBackground)
        }
    }

    private var timeOfBirthField: some View {
        FormFieldWrapper(title: "Time of Birth") {
            DatePicker(
                "",
                selection: $viewModel.timeOfBirth,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .tint(.kundliPrimary)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(datePickerBackground)
        }
    }

    private var datePickerBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }

    private var birthPlaceField: some View {
        FormFieldWrapper(title: "Birth Place") {
            Button {
                showCitySearch = true
            } label: {
                HStack {
                    Text(viewModel.selectedCity?.displayName ?? "Select city")
                        .font(.kundliBody)
                        .foregroundColor(viewModel.selectedCity == nil ? .kundliTextSecondary : .kundliTextPrimary)

                    Spacer()

                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.kundliTextSecondary)
                }
                .padding(14)
                .background(datePickerBackground)
            }
            .buttonStyle(.plain)
        }
    }

    private var genderField: some View {
        FormFieldWrapper(title: "Gender") {
            Picker("", selection: $viewModel.gender) {
                ForEach(BirthDetails.Gender.allCases, id: \.self) { gender in
                    Text(gender.rawValue).tag(gender)
                }
            }
            .pickerStyle(.segmented)
            .tint(.kundliPrimary)
        }
    }

    private var generateButtonSection: some View {
        GoldButton(
            title: viewModel.isGenerating ? "Generating..." : "Generate Kundli",
            icon: viewModel.isGenerating ? nil : "sparkles"
        ) {
            viewModel.generateKundli()
        }
        .disabled(!viewModel.isFormValid || viewModel.isGenerating)
        .opacity(viewModel.isFormValid ? 1 : 0.6)
        .padding(.top, 8)
    }

    private var sampleDataButton: some View {
        Button {
            viewModel.loadSampleKundli()
            navigateToChart = true
        } label: {
            Text("Use Sample Data (Demo)")
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var loadingOverlay: some View {
        if viewModel.isGenerating {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .kundliPrimary))
                    .scaleEffect(1.5)

                Text("Generating Kundli...")
                    .font(.kundliSubheadline)
                    .foregroundColor(.white)
            }
        }
    }
}

struct FormFieldWrapper<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)

            content
        }
    }
}

#Preview {
    NavigationStack {
        BirthDetailsView()
    }
}
