//
//  AIReport.swift
//  Kundli
//
//  Data model for AI-generated astrological reports.
//

import Foundation

struct AIReport: Identifiable, Codable {
    let id: UUID
    let kundliId: UUID
    let kundliName: String
    let reportType: AIReportType
    let sections: [AIReportSection]
    let generatedAt: Date
    let summary: String?

    init(
        id: UUID = UUID(),
        kundliId: UUID,
        kundliName: String,
        reportType: AIReportType,
        sections: [AIReportSection],
        generatedAt: Date = Date(),
        summary: String? = nil
    ) {
        self.id = id
        self.kundliId = kundliId
        self.kundliName = kundliName
        self.reportType = reportType
        self.sections = sections
        self.generatedAt = generatedAt
        self.summary = summary
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: generatedAt)
    }

    var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: generatedAt, relativeTo: Date())
    }
}

struct AIReportSection: Identifiable, Codable {
    let id: UUID
    let title: String
    let content: String
    let icon: String?
    let highlightType: HighlightType?

    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        icon: String? = nil,
        highlightType: HighlightType? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.icon = icon
        self.highlightType = highlightType
    }

    enum HighlightType: String, Codable {
        case positive
        case challenging
        case neutral
        case remedy

        var color: String {
            switch self {
            case .positive:
                return "4ade80" // Green
            case .challenging:
                return "f87171" // Red
            case .neutral:
                return "fbbf24" // Yellow
            case .remedy:
                return "60a5fa" // Blue
            }
        }
    }
}

// MARK: - Report Parsing

extension AIReport {
    /// Parse AI response into structured sections
    static func parse(
        response: String,
        kundliId: UUID,
        kundliName: String,
        reportType: AIReportType
    ) -> AIReport {
        var sections: [AIReportSection] = []
        var summary: String?

        // Split response by section markers (## headers in markdown)
        let lines = response.components(separatedBy: "\n")
        var currentTitle: String?
        var currentContent: [String] = []
        var currentIcon: String?
        var currentHighlight: AIReportSection.HighlightType?

        for line in lines {
            if line.hasPrefix("## ") {
                // Save previous section if exists
                if let title = currentTitle, !currentContent.isEmpty {
                    let content = currentContent.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                    sections.append(AIReportSection(
                        title: title,
                        content: content,
                        icon: currentIcon,
                        highlightType: currentHighlight
                    ))
                }

                // Start new section
                currentTitle = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                currentContent = []
                currentIcon = iconForSection(currentTitle ?? "")
                currentHighlight = highlightForSection(currentTitle ?? "")
            } else if line.hasPrefix("# ") && summary == nil {
                // First # header could be a summary title
                continue
            } else {
                currentContent.append(line)
            }
        }

        // Add last section
        if let title = currentTitle, !currentContent.isEmpty {
            let content = currentContent.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            sections.append(AIReportSection(
                title: title,
                content: content,
                icon: currentIcon,
                highlightType: currentHighlight
            ))
        }

        // If no sections were parsed, create a single section with all content
        if sections.isEmpty {
            sections.append(AIReportSection(
                title: "Analysis",
                content: response.trimmingCharacters(in: .whitespacesAndNewlines),
                icon: "doc.text",
                highlightType: .neutral
            ))
        }

        // Extract summary from first few sentences
        let firstSection = sections.first?.content ?? response
        let sentences = firstSection.components(separatedBy: ". ")
        if sentences.count > 2 {
            summary = sentences.prefix(2).joined(separator: ". ") + "."
        }

        return AIReport(
            kundliId: kundliId,
            kundliName: kundliName,
            reportType: reportType,
            sections: sections,
            summary: summary
        )
    }

    private static func iconForSection(_ title: String) -> String {
        let lowercased = title.lowercased()

        if lowercased.contains("strength") || lowercased.contains("positive") {
            return "star.fill"
        } else if lowercased.contains("challenge") || lowercased.contains("weakness") {
            return "exclamationmark.triangle.fill"
        } else if lowercased.contains("remedy") || lowercased.contains("recommendation") {
            return "lightbulb.fill"
        } else if lowercased.contains("timing") || lowercased.contains("period") || lowercased.contains("dasha") {
            return "clock.fill"
        } else if lowercased.contains("planet") {
            return "sparkle"
        } else if lowercased.contains("overview") || lowercased.contains("summary") {
            return "doc.text.fill"
        }

        return "circle.fill"
    }

    private static func highlightForSection(_ title: String) -> AIReportSection.HighlightType {
        let lowercased = title.lowercased()

        if lowercased.contains("strength") || lowercased.contains("positive") || lowercased.contains("favorable") {
            return .positive
        } else if lowercased.contains("challenge") || lowercased.contains("weakness") || lowercased.contains("difficult") {
            return .challenging
        } else if lowercased.contains("remedy") || lowercased.contains("recommendation") {
            return .remedy
        }

        return .neutral
    }
}
