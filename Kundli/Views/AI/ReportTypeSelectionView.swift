//
//  ReportTypeSelectionView.swift
//  Kundli
//
//  Grid view for selecting report types to generate.
//

import SwiftUI

struct ReportTypeSelectionView: View {
    let savedKundli: SavedKundli
    @State private var viewModel = AIReportViewModel()
    @State private var selectedReportType: AIReportType?
    @State private var navigateToReport: Bool = false

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    headerSection

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(AIReportType.allCases) { reportType in
                            ReportTypeCard(
                                reportType: reportType,
                                cachedReport: viewModel.cachedReports.first { $0.reportType == reportType }
                            ) {
                                selectedReportType = reportType
                                navigateToReport = true
                            }
                        }
                    }
                    .padding(.horizontal)

                    if !viewModel.cachedReports.isEmpty {
                        recentReportsSection
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Generate Reports")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            viewModel.loadCachedReports(for: savedKundli.id)
        }
        .navigationDestination(isPresented: $navigateToReport) {
            if let reportType = selectedReportType {
                AIReportView(
                    savedKundli: savedKundli,
                    reportType: reportType,
                    viewModel: viewModel
                )
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Choose a Report")
                .font(.kundliTitle2)
                .foregroundColor(.kundliTextPrimary)

            Text("Select an area of life to analyze based on \(savedKundli.name)'s birth chart")
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top)
    }

    private var recentReportsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Reports")
                .font(.kundliHeadline)
                .foregroundColor(.kundliTextPrimary)
                .padding(.horizontal)

            ForEach(viewModel.cachedReports.prefix(3)) { report in
                Button {
                    selectedReportType = report.reportType
                    viewModel.currentReport = report
                    navigateToReport = true
                } label: {
                    HStack {
                        Image(systemName: report.reportType.icon)
                            .foregroundColor(.kundliPrimary)
                            .frame(width: 32)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(report.reportType.rawValue)
                                .font(.kundliBody)
                                .foregroundColor(.kundliTextPrimary)

                            Text(report.relativeDate)
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextTertiary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextTertiary)
                    }
                    .padding()
                    .background(Color.kundliCardBg)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Report Type Card

struct ReportTypeCard: View {
    let reportType: AIReportType
    let cachedReport: AIReport?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
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
                        .frame(width: 56, height: 56)

                    Image(systemName: reportType.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }

                VStack(spacing: 4) {
                    Text(reportType.shortTitle)
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliTextPrimary)

                    Text(reportType.description)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }

                if let report = cachedReport {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.kundliCaption)
                        Text(report.relativeDate)
                            .font(.kundliCaption)
                    }
                    .foregroundColor(.kundliSuccess)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.kundliCardBg)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

#Preview {
    NavigationStack {
        ReportTypeSelectionView(
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
            )
        )
    }
}
