//
//  AIPromptBuilder.swift
//  Kundli
//
//  Builds structured prompts for Claude API from Kundli data.
//

import Foundation

final class AIPromptBuilder {
    static let shared = AIPromptBuilder()

    private init() {}

    // MARK: - Report System Prompt

    func buildReportSystemPrompt(
        kundliContext: String,
        reportType: AIReportType
    ) -> String {
        """
        You are an expert Vedic astrologer providing personalized insights based on a birth chart.

        GUIDELINES:
        - Use authentic Vedic terminology with brief explanations for Sanskrit terms
        - Reference specific planetary placements from the provided chart data
        - Be balanced - mention both positive and challenging influences
        - Provide actionable guidance with traditional remedies where appropriate
        - Never make absolute predictions; use probabilistic language ("may experience", "potential for")
        - Reference Dasha periods for timing when relevant
        - Keep language warm but professional
        - Format your response with clear ## section headers

        FOCUS AREA: \(reportType.rawValue)
        Primary Houses: \(reportType.relatedHouses.map { String($0) }.joined(separator: ", "))
        Key Planets: \(reportType.keyPlanets.joined(separator: ", "))

        CHART DATA:
        \(kundliContext)

        Please provide a comprehensive analysis for \(reportType.rawValue) with the following sections:
        ## Overview
        Brief summary of the key themes for this area of life.

        ## Planetary Influences
        Analysis of relevant planets and their placements.

        ## Strengths
        Favorable configurations and positive indicators.

        ## Challenges
        Areas requiring attention and potential obstacles.

        ## Timing & Dasha Periods
        When favorable and challenging periods may occur.

        ## Remedies & Recommendations
        Traditional remedies and practical guidance.
        """
    }

    // MARK: - Chat System Prompt

    func buildChatSystemPrompt(kundliContext: String) -> String {
        """
        You are a knowledgeable Vedic astrologer assistant with access to the user's birth chart. Answer questions based on this specific chart data.

        GUIDELINES:
        - Be conversational but informative
        - Reference specific placements from the chart when answering
        - Use Vedic terminology with brief explanations
        - Be balanced - acknowledge both positive and challenging aspects
        - Never make absolute predictions; use probabilistic language
        - Keep responses focused and concise unless the user asks for detailed analysis
        - If asked about topics not in the chart, acknowledge the limitation

        CHART DATA:
        \(kundliContext)

        Answer the user's questions based on this chart. Be helpful and insightful while maintaining astrological authenticity.
        """
    }

    // MARK: - Kundli Context Builder

    func buildKundliContext(from savedKundli: SavedKundli) -> String {
        let context = """
        NATIVE DETAILS:
        Name: \(savedKundli.name)
        Date of Birth: \(savedKundli.formattedDate)
        Time of Birth: \(savedKundli.formattedTime)
        Place: \(savedKundli.birthCity)
        Coordinates: \(String(format: "%.4f", savedKundli.latitude))°N, \(String(format: "%.4f", abs(savedKundli.longitude)))°\(savedKundli.longitude >= 0 ? "E" : "W")

        ASCENDANT (LAGNA):
        Sign: \(savedKundli.ascendantSign)
        Degree: \(String(format: "%.2f", savedKundli.ascendantDegree))°
        Nakshatra: \(savedKundli.ascendantNakshatra)
        """

        // Note: Planets are regenerated from KundliData, not stored in SavedKundli

        return context
    }

    func buildKundliContext(
        from savedKundli: SavedKundli,
        with generatedData: KundliData
    ) -> String {
        var context = buildKundliContext(from: savedKundli)

        // Add more detailed data from KundliData
        context += "\n\nDETAILED PLANETARY POSITIONS:"
        for planet in generatedData.planets {
            context += """

            \(planet.name):
              Sign: \(planet.sign)
              House: \(planet.house)
              Degree: \(planet.degreeString)
              Nakshatra: \(planet.nakshatraWithPada)
              Status: \(planet.status.rawValue)
            """
        }

        // Add Dasha information
        if let activeDasha = generatedData.activeDasha {
            context += """

            CURRENT DASHA PERIOD:
            Mahadasha: \(activeDasha.planet)
            Period: \(formatDate(activeDasha.startDate)) - \(formatDate(activeDasha.endDate))
            """

            let antardashas = activeDasha.subPeriods
            if !antardashas.isEmpty {
                if let currentAntardasha = antardashas.first(where: {
                    Date() >= $0.startDate && Date() <= $0.endDate
                }) {
                    context += """

                    Current Antardasha: \(currentAntardasha.planet)
                    Period: \(formatDate(currentAntardasha.startDate)) - \(formatDate(currentAntardasha.endDate))
                    """
                }
            }
        }

        // Add Yogas
        if !generatedData.yogas.isEmpty {
            context += "\n\nYOGAS PRESENT:"
            for yoga in generatedData.yogas.prefix(10) {
                context += "\n- \(yoga.name): \(yoga.description)"
            }
        }

        // Add Doshas
        if !generatedData.doshas.isEmpty {
            context += "\n\nDOSHAS PRESENT:"
            for dosha in generatedData.doshas {
                context += "\n- \(dosha.name): \(dosha.description)"
            }
        }

        return context
    }

    // MARK: - Suggested Questions

    func suggestedQuestions(for savedKundli: SavedKundli) -> [String] {
        var questions: [String] = []

        // General questions
        questions.append("What are my key strengths according to my chart?")
        questions.append("What career paths suit me best?")
        questions.append("When is a favorable time for important decisions?")

        // Based on ascendant
        let ascendant = savedKundli.ascendantSign.lowercased()
        if ascendant.contains("aries") || ascendant.contains("mesha") {
            questions.append("How does Mars influence my personality?")
        } else if ascendant.contains("taurus") || ascendant.contains("vrishabha") {
            questions.append("How does Venus affect my relationships?")
        } else if ascendant.contains("gemini") || ascendant.contains("mithuna") {
            questions.append("How does Mercury influence my communication?")
        }

        // More general questions
        questions.append("What remedies can help improve my luck?")
        questions.append("What does my chart say about marriage?")
        questions.append("Are there any challenging periods coming up?")

        return Array(questions.prefix(6))
    }

    // MARK: - Helper Methods

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}
