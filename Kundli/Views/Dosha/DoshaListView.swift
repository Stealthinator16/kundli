import SwiftUI

struct DoshaListView: View {
    let doshas: [Dosha]
    @State private var expandedDoshaId: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Doshas")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                Spacer()

                if !activeDoshas.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                        Text("\(activeDoshas.count) active")
                            .font(.kundliCaption)
                    }
                    .foregroundColor(.kundliWarning)
                }
            }

            if doshas.isEmpty {
                noDoshaView
            } else {
                // Active doshas first
                if !activeDoshas.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Active Doshas")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliError)
                            .padding(.top, 4)

                        ForEach(activeDoshas) { dosha in
                            DoshaCard(
                                dosha: dosha,
                                isExpanded: expandedDoshaId == dosha.id,
                                onTap: { toggleExpanded(dosha.id) }
                            )
                        }
                    }
                }

                // Cancelled doshas
                if !cancelledDoshas.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cancelled Doshas")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliSuccess)
                            .padding(.top, 8)

                        ForEach(cancelledDoshas) { dosha in
                            DoshaCard(
                                dosha: dosha,
                                isExpanded: expandedDoshaId == dosha.id,
                                onTap: { toggleExpanded(dosha.id) }
                            )
                        }
                    }
                }
            }
        }
    }

    private var noDoshaView: some View {
        CardView {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.kundliSuccess)

                VStack(alignment: .leading, spacing: 4) {
                    Text("No Major Doshas")
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextPrimary)

                    Text("This chart is free from major doshas")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                }

                Spacer()
            }
        }
    }

    private var activeDoshas: [Dosha] {
        doshas.filter { !$0.isCancelled }
    }

    private var cancelledDoshas: [Dosha] {
        doshas.filter { $0.isCancelled }
    }

    private func toggleExpanded(_ id: UUID) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if expandedDoshaId == id {
                expandedDoshaId = nil
            } else {
                expandedDoshaId = id
            }
        }
    }
}

// MARK: - Dosha Card
struct DoshaCard: View {
    let dosha: Dosha
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                Button(action: onTap) {
                    HStack {
                        // Severity indicator
                        VStack {
                            Image(systemName: dosha.isCancelled ? "checkmark.circle.fill" : severityIcon)
                                .font(.system(size: 20))
                                .foregroundColor(severityColor)
                        }
                        .frame(width: 32)

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 8) {
                                Text(dosha.name)
                                    .font(.kundliHeadline)
                                    .foregroundColor(.kundliTextPrimary)

                                if dosha.isCancelled {
                                    Text("Cancelled")
                                        .font(.kundliCaption2)
                                        .foregroundColor(.kundliBackground)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(
                                            Capsule()
                                                .fill(Color.kundliSuccess)
                                        )
                                }
                            }

                            Text(dosha.sanskritName)
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)
                        }

                        Spacer()

                        // Severity badge
                        if !dosha.isCancelled {
                            DoshaSeverityBadge(severity: dosha.severity)
                        }

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.kundliTextSecondary)
                    }
                }
                .buttonStyle(.plain)

                // Expanded content
                if isExpanded {
                    Divider()
                        .background(Color.white.opacity(0.1))

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)

                        Text(dosha.description)
                            .font(.kundliBody)
                            .foregroundColor(.kundliTextPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Forming planets
                    if !dosha.formingPlanets.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Forming Planets")
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)

                            HStack(spacing: 8) {
                                ForEach(dosha.formingPlanets, id: \.self) { planet in
                                    Text(planet)
                                        .font(.kundliCaption)
                                        .foregroundColor(.kundliTextPrimary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(Color.kundliError.opacity(0.2))
                                        )
                                }
                            }
                        }
                    }

                    // Effects
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Effects")
                            .font(.kundliCaption)
                            .foregroundColor(.kundliTextSecondary)

                        Text(dosha.effects)
                            .font(.kundliBody)
                            .foregroundColor(.kundliWarning)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Cancellation rules (if any active)
                    if !dosha.cancellations.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Cancellation Rules")
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)

                            ForEach(dosha.cancellations, id: \.rule) { cancellation in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: cancellation.isActive ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 14))
                                        .foregroundColor(cancellation.isActive ? .kundliSuccess : .kundliTextSecondary)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(cancellation.rule)
                                            .font(.kundliCaption)
                                            .foregroundColor(cancellation.isActive ? .kundliSuccess : .kundliTextPrimary)

                                        if cancellation.isActive {
                                            Text(cancellation.description)
                                                .font(.kundliCaption2)
                                                .foregroundColor(.kundliTextSecondary)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Remedies
                    if !dosha.remedies.isEmpty && !dosha.isCancelled {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 14))
                                    .foregroundColor(.kundliPrimary)

                                Text("Remedies")
                                    .font(.kundliCaption)
                                    .foregroundColor(.kundliPrimary)
                            }

                            ForEach(dosha.remedies, id: \.self) { remedy in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .foregroundColor(.kundliTextSecondary)

                                    Text(remedy)
                                        .font(.kundliCaption)
                                        .foregroundColor(.kundliTextPrimary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.kundliPrimary.opacity(0.1))
                        )
                    }
                }
            }
        }
    }

    private var severityIcon: String {
        switch dosha.severity {
        case .high: return "exclamationmark.triangle.fill"
        case .medium: return "exclamationmark.circle.fill"
        case .low: return "info.circle.fill"
        case .cancelled: return "checkmark.circle.fill"
        }
    }

    private var severityColor: Color {
        switch dosha.severity {
        case .high: return .kundliError
        case .medium: return .kundliWarning
        case .low: return .kundliInfo
        case .cancelled: return .kundliSuccess
        }
    }
}

// MARK: - Dosha Severity Badge
struct DoshaSeverityBadge: View {
    let severity: DoshaSeverity

    var body: some View {
        Text(severity.rawValue)
            .font(.kundliCaption2)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(severityColor)
            )
    }

    private var severityColor: Color {
        switch severity {
        case .high: return .kundliError
        case .medium: return .kundliWarning
        case .low: return .kundliInfo
        case .cancelled: return .kundliSuccess
        }
    }
}

// MARK: - Full Screen Dosha View
struct DoshaDetailView: View {
    let doshas: [Dosha]

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Summary card
                    CardView {
                        HStack(spacing: 20) {
                            doshaSummaryItem(
                                count: doshas.filter { !$0.isCancelled }.count,
                                label: "Active",
                                color: .kundliError,
                                icon: "exclamationmark.triangle.fill"
                            )

                            Divider()
                                .frame(height: 40)
                                .background(Color.white.opacity(0.1))

                            doshaSummaryItem(
                                count: doshas.filter { $0.isCancelled }.count,
                                label: "Cancelled",
                                color: .kundliSuccess,
                                icon: "checkmark.circle.fill"
                            )
                        }
                        .frame(maxWidth: .infinity)
                    }

                    DoshaListView(doshas: doshas)
                }
                .padding(16)
            }
        }
        .navigationTitle("Doshas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func doshaSummaryItem(count: Int, label: String, color: Color, icon: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text("\(count)")
                    .font(.kundliTitle2)
            }
            .foregroundColor(color)

            Text(label)
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        ScrollView {
            DoshaListView(doshas: [
                .manglik(
                    severity: .medium,
                    formingPlanets: ["Mars"],
                    cancellations: [
                        DoshaCancellation(
                            rule: "Mars in own sign",
                            isActive: false,
                            description: "Mars is not in its own sign"
                        ),
                        DoshaCancellation(
                            rule: "Jupiter aspects Mars",
                            isActive: true,
                            description: "Jupiter's aspect reduces Manglik effects"
                        )
                    ],
                    fromLagna: true,
                    fromMoon: false,
                    fromVenus: false
                ),
                .kaalSarp(
                    severity: .high,
                    yogaType: "Anant",
                    formingPlanets: ["Rahu", "Ketu"],
                    isPartial: false
                )
            ])
            .padding()
        }
    }
}
