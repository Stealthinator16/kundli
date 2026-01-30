//
//  AIReportService.swift
//  Kundli
//
//  Orchestrates AI report generation using Claude API.
//

import Foundation

final class AIReportService {
    static let shared = AIReportService()

    private let aiService = AIService.shared
    private let promptBuilder = AIPromptBuilder.shared
    private let cache = AIResponseCache.shared
    private let kundliService = KundliGenerationService.shared
    private let settingsService = SettingsService.shared

    private init() {}

    // MARK: - Report Generation

    func generateReport(
        for savedKundli: SavedKundli,
        reportType: AIReportType,
        useCache: Bool = true
    ) async throws -> AIReport {
        // Check cache first
        if useCache, let cachedReport = cache.getReport(
            kundliId: savedKundli.id,
            reportType: reportType
        ) {
            return cachedReport
        }

        // Generate full kundli data for context
        let birthDetails = savedKundli.toBirthDetails()
        let kundliData = try await kundliService.generateKundli(
            birthDetails: birthDetails,
            settings: settingsService.calculationSettings
        )

        // Build context and prompt
        let context = promptBuilder.buildKundliContext(
            from: savedKundli,
            with: kundliData
        )

        let systemPrompt = promptBuilder.buildReportSystemPrompt(
            kundliContext: context,
            reportType: reportType
        )

        // Call AI service
        let response = try await aiService.sendMessage(
            systemPrompt: systemPrompt,
            messages: [
                ChatMessagePayload(
                    role: "user",
                    content: "Please generate a comprehensive \(reportType.rawValue) report for this birth chart."
                )
            ],
            maxTokens: 4096
        )

        // Parse response into structured report
        let report = AIReport.parse(
            response: response,
            kundliId: savedKundli.id,
            kundliName: savedKundli.name,
            reportType: reportType
        )

        // Cache the report
        cache.saveReport(report)

        return report
    }

    func generateReportWithStreaming(
        for savedKundli: SavedKundli,
        reportType: AIReportType,
        onPartialResponse: @escaping (String) -> Void
    ) async throws -> AIReport {
        // Generate full kundli data for context
        let birthDetails = savedKundli.toBirthDetails()
        let kundliData = try await kundliService.generateKundli(
            birthDetails: birthDetails,
            settings: settingsService.calculationSettings
        )

        // Build context and prompt
        let context = promptBuilder.buildKundliContext(
            from: savedKundli,
            with: kundliData
        )

        let systemPrompt = promptBuilder.buildReportSystemPrompt(
            kundliContext: context,
            reportType: reportType
        )

        // Call AI service with streaming
        let response = try await aiService.streamMessage(
            systemPrompt: systemPrompt,
            messages: [
                ChatMessagePayload(
                    role: "user",
                    content: "Please generate a comprehensive \(reportType.rawValue) report for this birth chart."
                )
            ],
            maxTokens: 4096,
            onPartialResponse: onPartialResponse
        )

        // Parse response into structured report
        let report = AIReport.parse(
            response: response,
            kundliId: savedKundli.id,
            kundliName: savedKundli.name,
            reportType: reportType
        )

        // Cache the report
        cache.saveReport(report)

        return report
    }

    // MARK: - Report Retrieval

    func getCachedReports(for kundliId: UUID) -> [AIReport] {
        return cache.getReports(for: kundliId)
    }

    func getCachedReport(kundliId: UUID, reportType: AIReportType) -> AIReport? {
        return cache.getReport(kundliId: kundliId, reportType: reportType)
    }

    func deleteReport(_ report: AIReport) {
        cache.deleteReport(report)
    }

    func clearReports(for kundliId: UUID) {
        cache.clearReports(for: kundliId)
    }
}
