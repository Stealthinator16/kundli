//
//  AIReportViewModel.swift
//  Kundli
//
//  ViewModel for managing AI report generation state.
//

import Foundation

@Observable
class AIReportViewModel {
    // MARK: - State

    var isGenerating: Bool = false
    var currentReport: AIReport?
    var partialResponse: String = ""
    var error: AIError?
    var cachedReports: [AIReport] = []

    // MARK: - Private Properties

    private let reportService = AIReportService.shared
    private let keyManager = AIKeyManager.shared

    // MARK: - Computed Properties

    var hasAPIKey: Bool {
        keyManager.hasAPIKey
    }

    var showError: Bool {
        error != nil
    }

    // MARK: - Public Methods

    func generateReport(
        for savedKundli: SavedKundli,
        reportType: AIReportType,
        useStreaming: Bool = true
    ) async {
        guard !isGenerating else { return }

        let kundliId = savedKundli.id

        await MainActor.run {
            isGenerating = true
            error = nil
            partialResponse = ""
            currentReport = nil
        }

        do {
            let report: AIReport

            if useStreaming {
                report = try await reportService.generateReportWithStreaming(
                    for: savedKundli,
                    reportType: reportType
                ) { [weak self] partial in
                    Task { @MainActor in
                        self?.partialResponse = partial
                    }
                }
            } else {
                report = try await reportService.generateReport(
                    for: savedKundli,
                    reportType: reportType
                )
            }

            await MainActor.run {
                currentReport = report
                isGenerating = false
                // Refresh cached reports
                loadCachedReports(for: kundliId)
            }
        } catch let aiError as AIError {
            await MainActor.run {
                error = aiError
                isGenerating = false
            }
        } catch {
            await MainActor.run {
                self.error = .unknown(message: error.localizedDescription)
                isGenerating = false
            }
        }
    }

    func loadCachedReports(for kundliId: UUID) {
        cachedReports = reportService.getCachedReports(for: kundliId)
    }

    func loadCachedReport(kundliId: UUID, reportType: AIReportType) {
        if let report = reportService.getCachedReport(
            kundliId: kundliId,
            reportType: reportType
        ) {
            currentReport = report
        }
    }

    func deleteReport(_ report: AIReport) {
        reportService.deleteReport(report)
        cachedReports.removeAll { $0.id == report.id }
        if currentReport?.id == report.id {
            currentReport = nil
        }
    }

    func clearError() {
        error = nil
    }

    func reset() {
        isGenerating = false
        currentReport = nil
        partialResponse = ""
        error = nil
    }
}
