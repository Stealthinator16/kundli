//
//  AIResponseCache.swift
//  Kundli
//
//  Caches AI-generated reports for offline access.
//

import Foundation

final class AIResponseCache {
    static let shared = AIResponseCache()

    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private var cacheDirectory: URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let cacheDir = paths[0].appendingPathComponent("AICache", isDirectory: true)

        if !fileManager.fileExists(atPath: cacheDir.path) {
            try? fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        }

        return cacheDir
    }

    private var reportsDirectory: URL {
        let dir = cacheDirectory.appendingPathComponent("Reports", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private init() {}

    // MARK: - Report Caching

    func saveReport(_ report: AIReport) {
        let fileName = reportFileName(kundliId: report.kundliId, reportType: report.reportType)
        let fileURL = reportsDirectory.appendingPathComponent(fileName)

        do {
            let data = try encoder.encode(report)
            try data.write(to: fileURL)
        } catch {
            print("Failed to cache report: \(error.localizedDescription)")
        }
    }

    func getReport(kundliId: UUID, reportType: AIReportType) -> AIReport? {
        let fileName = reportFileName(kundliId: kundliId, reportType: reportType)
        let fileURL = reportsDirectory.appendingPathComponent(fileName)

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode(AIReport.self, from: data)
        } catch {
            print("Failed to load cached report: \(error.localizedDescription)")
            return nil
        }
    }

    func getReports(for kundliId: UUID) -> [AIReport] {
        var reports: [AIReport] = []

        for reportType in AIReportType.allCases {
            if let report = getReport(kundliId: kundliId, reportType: reportType) {
                reports.append(report)
            }
        }

        return reports.sorted { $0.generatedAt > $1.generatedAt }
    }

    func getAllReports() -> [AIReport] {
        var reports: [AIReport] = []

        guard let fileURLs = try? fileManager.contentsOfDirectory(
            at: reportsDirectory,
            includingPropertiesForKeys: nil
        ) else {
            return reports
        }

        for fileURL in fileURLs where fileURL.pathExtension == "json" {
            if let data = try? Data(contentsOf: fileURL),
               let report = try? decoder.decode(AIReport.self, from: data) {
                reports.append(report)
            }
        }

        return reports.sorted { $0.generatedAt > $1.generatedAt }
    }

    func deleteReport(_ report: AIReport) {
        let fileName = reportFileName(kundliId: report.kundliId, reportType: report.reportType)
        let fileURL = reportsDirectory.appendingPathComponent(fileName)

        try? fileManager.removeItem(at: fileURL)
    }

    func clearReports(for kundliId: UUID) {
        for reportType in AIReportType.allCases {
            let fileName = reportFileName(kundliId: kundliId, reportType: reportType)
            let fileURL = reportsDirectory.appendingPathComponent(fileName)
            try? fileManager.removeItem(at: fileURL)
        }
    }

    // MARK: - Clear All

    func clearAll() {
        try? fileManager.removeItem(at: cacheDirectory)
    }

    // MARK: - Cache Info

    var cacheSize: String {
        guard let contents = try? fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else {
            return "0 KB"
        }

        var totalSize: Int64 = 0

        for url in contents {
            if let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                totalSize += Int64(size)
            }
        }

        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalSize)
    }

    // MARK: - Private Methods

    private func reportFileName(kundliId: UUID, reportType: AIReportType) -> String {
        return "\(kundliId.uuidString)_\(reportType.rawValue.replacingOccurrences(of: " ", with: "_")).json"
    }
}
