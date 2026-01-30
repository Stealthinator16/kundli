//
//  AIReportView.swift
//  Kundli
//
//  Full report display view with sections.
//

import SwiftUI

struct AIReportView: View {
    let savedKundli: SavedKundli
    let reportType: AIReportType
    @Bindable var viewModel: AIReportViewModel

    @State private var showShareSheet: Bool = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            if viewModel.isGenerating {
                generatingView
            } else if let report = viewModel.currentReport {
                reportContentView(report)
            } else if let error = viewModel.error {
                errorView(error)
            } else {
                generatePromptView
            }
        }
        .navigationTitle(reportType.shortTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            if viewModel.currentReport != nil {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.kundliPrimary)
                    }
                }
            }
        }
        .onAppear {
            // Check for cached report
            viewModel.loadCachedReport(
                kundliId: savedKundli.id,
                reportType: reportType
            )
        }
        .sheet(isPresented: $showShareSheet) {
            if let report = viewModel.currentReport {
                ShareSheet(items: [formatReportForSharing(report)])
            }
        }
    }

    // MARK: - Views

    private var generatingView: some View {
        VStack(spacing: 24) {
            // Animated indicator
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color.kundliPrimary.opacity(0.2), lineWidth: 4)
                        .frame(width: 80, height: 80)

                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.kundliPrimary, lineWidth: 4)
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(
                            .linear(duration: 1).repeatForever(autoreverses: false),
                            value: viewModel.isGenerating
                        )

                    Image(systemName: reportType.icon)
                        .font(.system(size: 32))
                        .foregroundColor(.kundliPrimary)
                }

                Text("Generating \(reportType.shortTitle) Report")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                Text("Analyzing planetary positions and influences...")
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliTextSecondary)
            }

            // Streaming preview
            if !viewModel.partialResponse.isEmpty {
                ScrollView {
                    Text(viewModel.partialResponse)
                        .font(.kundliBody)
                        .foregroundColor(.kundliTextSecondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 300)
                .background(Color.kundliCardBg)
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
        .padding()
    }

    private func reportContentView(_ report: AIReport) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: reportType.icon)
                            .font(.system(size: 24))
                            .foregroundColor(.kundliPrimary)

                        Text(reportType.rawValue)
                            .font(.kundliTitle2)
                            .foregroundColor(.kundliTextPrimary)
                    }

                    Text("For \(report.kundliName)")
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextSecondary)

                    Text("Generated \(report.formattedDate)")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextTertiary)
                }
                .padding()

                // Sections
                ForEach(report.sections) { section in
                    ReportSectionView(section: section)
                }
                .padding(.horizontal)

                // Regenerate button
                VStack(spacing: 12) {
                    Divider()
                        .background(Color.white.opacity(0.1))

                    Button {
                        Task {
                            await viewModel.generateReport(
                                for: savedKundli,
                                reportType: reportType
                            )
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Regenerate Report")
                        }
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliPrimary)
                    }
                    .padding(.bottom)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }

    private func errorView(_ error: AIError) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.kundliError)

            VStack(spacing: 8) {
                Text("Generation Failed")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                Text(error.errorDescription ?? "An error occurred")
                    .font(.kundliBody)
                    .foregroundColor(.kundliTextSecondary)
                    .multilineTextAlignment(.center)

                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextTertiary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal)

            if error.isRecoverable {
                GoldButton(title: "Try Again", icon: "arrow.clockwise") {
                    viewModel.clearError()
                    Task {
                        await viewModel.generateReport(
                            for: savedKundli,
                            reportType: reportType
                        )
                    }
                }
                .padding(.horizontal, 40)
            }

            if case .noAPIKey = error {
                NavigationLink(destination: AISettingsView()) {
                    Text("Configure API Key")
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliPrimary)
                }
            }
        }
        .padding()
    }

    private var generatePromptView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: reportType.gradientColors.start),
                                Color(hex: reportType.gradientColors.end)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: reportType.icon)
                    .font(.system(size: 44))
                    .foregroundColor(.white)
            }

            VStack(spacing: 8) {
                Text(reportType.rawValue)
                    .font(.kundliTitle2)
                    .foregroundColor(.kundliTextPrimary)

                Text(reportType.description)
                    .font(.kundliBody)
                    .foregroundColor(.kundliTextSecondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("This report analyzes:")
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliTextSecondary)

                ForEach(reportType.keyPlanets, id: \.self) { planet in
                    HStack(spacing: 8) {
                        Image(systemName: "sparkle")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliPrimary)
                        Text("\(planet)'s influence on \(reportType.shortTitle.lowercased())")
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextSecondary)
                    }
                }

                Text("Houses: \(reportType.relatedHouses.map { String($0) }.joined(separator: ", "))")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextTertiary)
                    .padding(.top, 4)
            }
            .padding()
            .background(Color.kundliCardBg)
            .cornerRadius(12)

            GoldButton(title: "Generate Report", icon: "sparkles") {
                Task {
                    await viewModel.generateReport(
                        for: savedKundli,
                        reportType: reportType
                    )
                }
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }

    // MARK: - Helpers

    private func formatReportForSharing(_ report: AIReport) -> String {
        var text = """
        \(report.reportType.rawValue) Report
        For: \(report.kundliName)
        Generated: \(report.formattedDate)

        """

        for section in report.sections {
            text += "\n\(section.title)\n"
            text += "\(section.content)\n"
        }

        text += "\n---\nGenerated by Kundli App"

        return text
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        AIReportView(
            savedKundli: SavedKundli(
                id: UUID(),
                name: "Test User",
                dateOfBirth: Date(),
                timeOfBirth: Date(),
                birthCity: "Mumbai",
                latitude: 19.076,
                longitude: 72.8777,
                timezone: "Asia/Kolkata",
                gender: "male",
                ascendantSign: "Aries",
                ascendantDegree: 15.5,
                ascendantNakshatra: "Ashwini"
            ),
            reportType: .career,
            viewModel: AIReportViewModel()
        )
    }
}
