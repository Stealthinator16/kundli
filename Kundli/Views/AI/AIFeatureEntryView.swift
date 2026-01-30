//
//  AIFeatureEntryView.swift
//  Kundli
//
//  Entry point view for AI features - Report vs Chat selection.
//

import SwiftUI
import SwiftData

struct AIFeatureEntryView: View {
    let savedKundli: SavedKundli
    @State private var reportViewModel = AIReportViewModel()
    @State private var chatViewModel = AIChatViewModel()

    private var kundliReports: [AIReport] {
        AIResponseCache.shared.getReports(for: savedKundli.id)
    }

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    featureCardsSection
                    if !kundliReports.isEmpty {
                        recentReportsSection
                    }
                    apiKeyStatusSection
                }
                .padding()
            }
        }
        .navigationTitle("AI Insights")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            reportViewModel.loadCachedReports(for: savedKundli.id)
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 12) {
            // AI Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.kundliPrimary.opacity(0.3), Color.kundliPrimary.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: "sparkles")
                    .font(.system(size: 36))
                    .foregroundColor(.kundliPrimary)
            }

            VStack(spacing: 4) {
                Text("AI Insights")
                    .font(.kundliTitle)
                    .foregroundColor(.kundliTextPrimary)

                HStack(spacing: 4) {
                    Image(systemName: "sparkle")
                        .font(.kundliCaption)
                    Text("Powered by Claude")
                        .font(.kundliSubheadline)
                }
                .foregroundColor(.kundliTextSecondary)
            }

            Text("Get personalized astrological insights for \(savedKundli.name)")
                .font(.kundliBody)
                .foregroundColor(.kundliTextTertiary)
                .multilineTextAlignment(.center)
        }
    }

    private var featureCardsSection: some View {
        HStack(spacing: 16) {
            // Generate Reports Card
            NavigationLink(destination: ReportTypeSelectionView(savedKundli: savedKundli)) {
                FeatureCard(
                    icon: "doc.text.fill",
                    title: "Generate Reports",
                    description: "Detailed analysis for career, health, relationships & more",
                    gradient: [Color(hex: "3d5a80"), Color(hex: "293241")]
                )
            }

            // Chat Card
            NavigationLink(destination: ChatView(savedKundli: savedKundli, viewModel: chatViewModel)) {
                FeatureCard(
                    icon: "bubble.left.and.bubble.right.fill",
                    title: "Chat with AI",
                    description: "Ask questions about your birth chart",
                    gradient: [Color(hex: "5a5a8f"), Color(hex: "3a3a5f")]
                )
            }
        }
    }

    private var recentReportsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Reports")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                Spacer()

                NavigationLink(destination: ReportTypeSelectionView(savedKundli: savedKundli)) {
                    Text("View All")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliPrimary)
                }
            }

            ForEach(kundliReports.prefix(3)) { report in
                NavigationLink(destination: AIReportView(
                    savedKundli: savedKundli,
                    reportType: report.reportType,
                    viewModel: reportViewModel
                )) {
                    RecentReportRow(report: report)
                }
            }
        }
    }

    private var apiKeyStatusSection: some View {
        Group {
            if !AIKeyManager.shared.hasAPIKey {
                CardView {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.kundliWarning)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("API Key Required")
                                .font(.kundliSubheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.kundliTextPrimary)

                            Text("Configure your Claude API key to use AI features")
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)
                        }

                        Spacer()

                        NavigationLink(destination: AISettingsView()) {
                            Text("Setup")
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliPrimary)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Feature Card

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let gradient: [Color]

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }

            VStack(spacing: 4) {
                Text(title)
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                Text(description)
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
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

// MARK: - Recent Report Row

struct RecentReportRow: View {
    let report: AIReport

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: report.reportType.gradientColors.start),
                                Color(hex: report.reportType.gradientColors.end)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)

                Image(systemName: report.reportType.icon)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }

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

#Preview {
    NavigationStack {
        AIFeatureEntryView(
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
