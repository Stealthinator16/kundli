//
//  ReportSectionView.swift
//  Kundli
//
//  Individual section rendering for AI reports.
//

import SwiftUI

struct ReportSectionView: View {
    let section: AIReportSection
    @State private var isExpanded: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    // Icon with highlight color
                    ZStack {
                        Circle()
                            .fill(highlightColor.opacity(0.2))
                            .frame(width: 36, height: 36)

                        Image(systemName: section.icon ?? "circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(highlightColor)
                    }

                    Text(section.title)
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliTextPrimary)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextTertiary)
                }
                .padding()
                .background(Color.kundliCardBg)
            }

            // Content
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    // Render markdown-style content
                    ForEach(parseContent(), id: \.self) { paragraph in
                        if paragraph.hasPrefix("- ") || paragraph.hasPrefix("• ") {
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundColor(.kundliPrimary)
                                Text(String(paragraph.dropFirst(2)))
                                    .font(.kundliBody)
                                    .foregroundColor(.kundliTextSecondary)
                            }
                        } else if paragraph.hasPrefix("**") && paragraph.hasSuffix("**") {
                            Text(paragraph.replacingOccurrences(of: "**", with: ""))
                                .font(.kundliBody)
                                .fontWeight(.semibold)
                                .foregroundColor(.kundliTextPrimary)
                        } else if !paragraph.isEmpty {
                            Text(paragraph)
                                .font(.kundliBody)
                                .foregroundColor(.kundliTextSecondary)
                        }
                    }
                }
                .padding()
                .background(Color.kundliBackground)
            }
        }
        .background(Color.kundliCardBg)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(highlightColor.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private var highlightColor: Color {
        guard let highlight = section.highlightType else {
            return .kundliPrimary
        }

        return Color(hex: highlight.color)
    }

    private func parseContent() -> [String] {
        section.content
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}

// MARK: - Compact Section View (for summaries)

struct CompactReportSectionView: View {
    let section: AIReportSection

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: section.icon ?? "circle.fill")
                    .font(.kundliCaption)
                    .foregroundColor(highlightColor)

                Text(section.title)
                    .font(.kundliSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.kundliTextPrimary)
            }

            Text(section.content.prefix(150) + (section.content.count > 150 ? "..." : ""))
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)
                .lineLimit(3)
        }
        .padding()
        .background(Color.kundliCardBg)
        .cornerRadius(8)
    }

    private var highlightColor: Color {
        guard let highlight = section.highlightType else {
            return .kundliPrimary
        }
        return Color(hex: highlight.color)
    }
}

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        VStack(spacing: 16) {
            ReportSectionView(
                section: AIReportSection(
                    title: "Planetary Influences",
                    content: """
                    Your 10th house is ruled by Saturn, indicating a career that requires patience and perseverance.

                    - Sun in the 10th house brings leadership qualities
                    - Mercury's aspect enhances communication skills
                    - Jupiter's influence suggests growth in your profession

                    **Key Period:** The upcoming Saturn transit may bring significant career changes.
                    """,
                    icon: "sparkle",
                    highlightType: .positive
                )
            )

            ReportSectionView(
                section: AIReportSection(
                    title: "Challenges",
                    content: "Saturn's placement suggests some delays in career progression during your early years. Patience will be key.",
                    icon: "exclamationmark.triangle.fill",
                    highlightType: .challenging
                )
            )
        }
        .padding()
    }
}
