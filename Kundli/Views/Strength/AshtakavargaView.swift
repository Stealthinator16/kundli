import SwiftUI

struct AshtakavargaView: View {
    let ashtakavargaData: AshtakavargaData

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Ashtakavarga")
                            .font(.kundliTitle2)
                            .foregroundColor(.kundliTextPrimary)

                        Text("Eight-fold strength analysis")
                            .font(.kundliSubheadline)
                            .foregroundColor(.kundliTextSecondary)
                    }
                    .padding(.top, 16)

                    // Sarva Ashtakavarga summary
                    sarvaAshtakavargaSummary

                    // Sign strength grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sarva Ashtakavarga by Sign")
                            .font(.kundliHeadline)
                            .foregroundColor(.kundliTextPrimary)

                        signStrengthGrid
                    }
                    .padding(.horizontal)

                    // Bhinna Ashtakavarga grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Bhinna Ashtakavarga Grid")
                            .font(.kundliHeadline)
                            .foregroundColor(.kundliTextPrimary)

                        bhinnaAshtakavargaGrid
                    }
                    .padding(.horizontal)

                    // Sign analysis
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sign Analysis")
                            .font(.kundliHeadline)
                            .foregroundColor(.kundliTextPrimary)

                        ForEach(ashtakavargaData.signAnalysis) { analysis in
                            SignAnalysisCard(analysis: analysis)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                        .frame(height: 20)
                }
                .padding(16)
            }
        }
        .navigationTitle("Ashtakavarga")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    // MARK: - Sarva Summary
    private var sarvaAshtakavargaSummary: some View {
        CardView {
            VStack(spacing: 16) {
                HStack {
                    Text("Total Points")
                        .font(.kundliHeadline)
                        .foregroundColor(.kundliTextPrimary)

                    Spacer()

                    Text("\(ashtakavargaData.totalPoints)")
                        .font(.kundliTitle2)
                        .foregroundColor(.kundliPrimary)
                }

                HStack(spacing: 20) {
                    // Strongest sign
                    if let strongest = ashtakavargaData.strongestSign {
                        VStack(spacing: 4) {
                            Text(ZodiacSign.allCases[strongest.index].rawValue)
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliSuccess)

                            Text("\(strongest.points) pts")
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)

                            Text("Strongest")
                                .font(.kundliCaption2)
                                .foregroundColor(.kundliTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    Divider()
                        .frame(height: 40)
                        .background(Color.white.opacity(0.1))

                    // Weakest sign
                    if let weakest = ashtakavargaData.weakestSign {
                        VStack(spacing: 4) {
                            Text(ZodiacSign.allCases[weakest.index].rawValue)
                                .font(.kundliSubheadline)
                                .foregroundColor(.kundliError)

                            Text("\(weakest.points) pts")
                                .font(.kundliCaption)
                                .foregroundColor(.kundliTextSecondary)

                            Text("Weakest")
                                .font(.kundliCaption2)
                                .foregroundColor(.kundliTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    // MARK: - Sign Strength Grid
    private var signStrengthGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
            ForEach(0..<12, id: \.self) { index in
                let points = ashtakavargaData.sarvaPoints(for: index)
                SignPointCell(
                    signIndex: index,
                    points: points
                )
            }
        }
    }

    // MARK: - Bhinna Grid
    private var bhinnaAshtakavargaGrid: some View {
        VStack(spacing: 0) {
            // Header row with signs
            HStack(spacing: 0) {
                Text("")
                    .frame(width: 50)

                ForEach(0..<12, id: \.self) { index in
                    Text(ZodiacSign.allCases[index].abbreviation)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.kundliTextSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 4)

            // Planet rows
            let planets = ["Sun", "Moon", "Mars", "Mercury", "Jupiter", "Venus", "Saturn"]
            ForEach(planets, id: \.self) { planet in
                HStack(spacing: 0) {
                    Text(planet.prefix(3))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.kundliTextSecondary)
                        .frame(width: 50, alignment: .leading)

                    ForEach(0..<12, id: \.self) { signIndex in
                        let points = ashtakavargaData.points(for: planet, in: signIndex)
                        BhinnaCell(points: points)
                    }
                }
            }

            // Sarva row
            HStack(spacing: 0) {
                Text("SAV")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.kundliPrimary)
                    .frame(width: 50, alignment: .leading)

                ForEach(0..<12, id: \.self) { signIndex in
                    let points = ashtakavargaData.sarvaPoints(for: signIndex)
                    Text("\(points)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(sarvaColor(points: points))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 4)
            .background(Color.kundliPrimary.opacity(0.1))
        }
        .background(Color.kundliCardBg)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private func sarvaColor(points: Int) -> Color {
        if points >= 30 { return .kundliSuccess }
        if points >= 25 { return .kundliWarning }
        return .kundliError
    }
}

// MARK: - Sign Point Cell
struct SignPointCell: View {
    let signIndex: Int
    let points: Int

    var body: some View {
        VStack(spacing: 4) {
            Text(ZodiacSign.allCases[signIndex].abbreviation)
                .font(.kundliCaption)
                .foregroundColor(.kundliTextSecondary)

            Text("\(points)")
                .font(.kundliHeadline)
                .foregroundColor(pointsColor)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(pointsColor.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(pointsColor.opacity(0.3), lineWidth: 1)
        )
    }

    private var pointsColor: Color {
        if points >= 30 { return .kundliSuccess }
        if points >= 25 { return .kundliWarning }
        return .kundliError
    }
}

// MARK: - Bhinna Cell
struct BhinnaCell: View {
    let points: Int

    var body: some View {
        Text("\(points)")
            .font(.system(size: 11))
            .foregroundColor(cellColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(cellColor.opacity(0.1))
    }

    private var cellColor: Color {
        if points >= 5 { return .kundliSuccess }
        if points >= 3 { return .kundliWarning }
        return .kundliError
    }
}

// MARK: - Sign Analysis Card
struct SignAnalysisCard: View {
    let analysis: SignStrengthAnalysis

    var body: some View {
        CardView(padding: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(analysis.signName)
                        .font(.kundliSubheadline)
                        .foregroundColor(.kundliTextPrimary)

                    Text(analysis.recommendation)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                        .lineLimit(2)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(analysis.sarvaPoints)")
                        .font(.kundliTitle3)
                        .foregroundColor(strengthColor)

                    Text(analysis.strength.rawValue)
                        .font(.kundliCaption2)
                        .foregroundColor(strengthColor)
                }
            }
        }
    }

    private var strengthColor: Color {
        switch analysis.strength {
        case .strong: return .kundliSuccess
        case .moderate: return .kundliWarning
        case .weak: return .kundliError
        }
    }
}

#Preview {
    NavigationStack {
        AshtakavargaView(ashtakavargaData: AshtakavargaData(
            bhinnaAshtakavarga: [
                "Sun": [4, 3, 5, 2, 6, 3, 4, 5, 3, 4, 5, 4],
                "Moon": [5, 4, 3, 4, 5, 4, 3, 4, 5, 3, 4, 5],
                "Mars": [3, 4, 5, 3, 4, 5, 4, 3, 4, 5, 3, 4],
                "Mercury": [4, 5, 4, 5, 3, 4, 5, 4, 3, 4, 5, 4],
                "Jupiter": [5, 4, 3, 4, 5, 3, 4, 5, 4, 3, 4, 5],
                "Venus": [4, 3, 5, 4, 3, 5, 4, 3, 5, 4, 3, 5],
                "Saturn": [3, 4, 3, 4, 5, 4, 3, 4, 5, 4, 3, 4]
            ],
            sarvaAshtakavarga: [28, 27, 28, 26, 31, 28, 27, 28, 29, 27, 27, 31],
            planetTotals: ["Sun": 48, "Moon": 49, "Mars": 47, "Mercury": 50, "Jupiter": 49, "Venus": 48, "Saturn": 46],
            signAnalysis: []
        ))
    }
}
