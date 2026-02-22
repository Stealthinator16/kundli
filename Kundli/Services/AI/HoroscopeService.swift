import Foundation

final class HoroscopeService {
    static let shared = HoroscopeService()

    private let aiService = AIService.shared
    private let cacheKey = "cached_horoscope"

    private init() {}

    /// Get daily horoscope for a sign. Uses cached result if available for today.
    func getHoroscope(for sign: ZodiacSign, panchang: Panchang) async -> DailyHoroscope {
        // Check cache first
        if let cached = loadCached(for: sign) {
            return cached
        }

        // Try AI generation
        do {
            let horoscope = try await generateAIHoroscope(for: sign, panchang: panchang)
            save(horoscope, for: sign)
            return horoscope
        } catch {
            // Return a placeholder indicating AI is not configured
            return placeholderHoroscope(for: sign, error: error)
        }
    }

    /// Check if AI horoscope is available (API key configured)
    var isAIAvailable: Bool {
        AIKeyManager.shared.getAPIKey() != nil
    }

    // MARK: - Private

    private func generateAIHoroscope(for sign: ZodiacSign, panchang: Panchang) async throws -> DailyHoroscope {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        let dateString = dateFormatter.string(from: Date())

        let systemPrompt = """
        You are a Vedic astrologer. Generate a daily horoscope. \
        Return ONLY valid JSON with no markdown or extra text.
        """

        let userMessage = """
        Generate a daily horoscope for \(sign.rawValue) (\(sign.vedName)) on \(dateString).
        Today's Panchang: Tithi: \(panchang.tithi.name) (\(panchang.tithi.paksha.rawValue)), \
        Nakshatra: \(panchang.nakshatra), Yoga: \(panchang.yoga).
        Return JSON: {"prediction":"...","overallRating":N,"loveRating":N,"careerRating":N,"healthRating":N,"luckyNumber":N,"luckyColor":"..."}
        Ratings are 1-5. Keep prediction to 2-3 sentences. Be specific to the sign and today's cosmic weather.
        """

        let response = try await aiService.sendMessage(
            systemPrompt: systemPrompt,
            messages: [ChatMessagePayload(role: "user", content: userMessage)],
            maxTokens: 300
        )

        return try parseHoroscopeResponse(response, for: sign)
    }

    private func parseHoroscopeResponse(_ response: String, for sign: ZodiacSign) throws -> DailyHoroscope {
        // Extract JSON from response (handle potential markdown wrapping)
        let jsonString: String
        if let start = response.firstIndex(of: "{"),
           let end = response.lastIndex(of: "}") {
            jsonString = String(response[start...end])
        } else {
            throw AIError.invalidResponse
        }

        guard let data = jsonString.data(using: .utf8) else {
            throw AIError.invalidResponse
        }

        struct HoroscopeJSON: Codable {
            let prediction: String
            let overallRating: Int
            let loveRating: Int
            let careerRating: Int
            let healthRating: Int
            let luckyNumber: Int
            let luckyColor: String
        }

        let parsed = try JSONDecoder().decode(HoroscopeJSON.self, from: data)

        return DailyHoroscope(
            sign: sign,
            date: Date(),
            overallRating: min(5, max(1, parsed.overallRating)),
            loveRating: min(5, max(1, parsed.loveRating)),
            careerRating: min(5, max(1, parsed.careerRating)),
            healthRating: min(5, max(1, parsed.healthRating)),
            prediction: parsed.prediction,
            luckyNumber: parsed.luckyNumber,
            luckyColor: parsed.luckyColor
        )
    }

    private func placeholderHoroscope(for sign: ZodiacSign, error: Error) -> DailyHoroscope {
        let message: String
        if error is AIError, case AIError.noAPIKey = error {
            message = "Configure your Claude API key in Settings to get personalized daily horoscopes powered by AI and today's Panchang data."
        } else {
            message = "Unable to generate horoscope right now. Please check your internet connection and try again later."
        }

        return DailyHoroscope(
            sign: sign,
            date: Date(),
            overallRating: 0,
            loveRating: 0,
            careerRating: 0,
            healthRating: 0,
            prediction: message,
            luckyNumber: 0,
            luckyColor: "-"
        )
    }

    // MARK: - Cache (UserDefaults, per sign+date)

    private func cacheKeyFor(_ sign: ZodiacSign) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return "\(cacheKey)_\(sign.rawValue)_\(dateFormatter.string(from: Date()))"
    }

    private func save(_ horoscope: DailyHoroscope, for sign: ZodiacSign) {
        let key = cacheKeyFor(sign)
        let dict: [String: Any] = [
            "prediction": horoscope.prediction,
            "overallRating": horoscope.overallRating,
            "loveRating": horoscope.loveRating,
            "careerRating": horoscope.careerRating,
            "healthRating": horoscope.healthRating,
            "luckyNumber": horoscope.luckyNumber,
            "luckyColor": horoscope.luckyColor
        ]
        UserDefaults.standard.set(dict, forKey: key)
    }

    private func loadCached(for sign: ZodiacSign) -> DailyHoroscope? {
        let key = cacheKeyFor(sign)
        guard let dict = UserDefaults.standard.dictionary(forKey: key),
              let prediction = dict["prediction"] as? String,
              let overall = dict["overallRating"] as? Int,
              let love = dict["loveRating"] as? Int,
              let career = dict["careerRating"] as? Int,
              let health = dict["healthRating"] as? Int,
              let number = dict["luckyNumber"] as? Int,
              let color = dict["luckyColor"] as? String else {
            return nil
        }

        return DailyHoroscope(
            sign: sign,
            date: Date(),
            overallRating: overall,
            loveRating: love,
            careerRating: career,
            healthRating: health,
            prediction: prediction,
            luckyNumber: number,
            luckyColor: color
        )
    }
}
