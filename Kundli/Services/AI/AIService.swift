//
//  AIService.swift
//  Kundli
//
//  Core Claude API integration service with HTTP handling, authentication,
//  rate limiting, and streaming support.
//

import Foundation

final class AIService {
    static let shared = AIService()

    private let baseURL = URL(string: "https://api.anthropic.com/v1/messages")!
    private let model = "claude-sonnet-4-20250514"
    private let apiVersion = "2023-06-01"
    private let maxTokens = 4096

    private let keyManager = AIKeyManager.shared
    private let session: URLSession

    // Rate limiting
    private var lastRequestTime: Date?
    private let minimumRequestInterval: TimeInterval = 1.0 // 1 second between requests

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 120
        self.session = URLSession(configuration: configuration)
    }

    // MARK: - Public Methods

    func sendMessage(
        systemPrompt: String,
        messages: [ChatMessagePayload],
        maxTokens: Int? = nil
    ) async throws -> String {
        guard let apiKey = keyManager.getAPIKey() else {
            throw AIError.noAPIKey
        }

        // Rate limiting check
        try await enforceRateLimit()

        let request = try buildRequest(
            apiKey: apiKey,
            systemPrompt: systemPrompt,
            messages: messages,
            maxTokens: maxTokens ?? self.maxTokens
        )

        let (data, response) = try await session.data(for: request)

        return try handleResponse(data: data, response: response)
    }

    func streamMessage(
        systemPrompt: String,
        messages: [ChatMessagePayload],
        maxTokens: Int? = nil,
        onPartialResponse: @escaping (String) -> Void
    ) async throws -> String {
        guard let apiKey = keyManager.getAPIKey() else {
            throw AIError.noAPIKey
        }

        try await enforceRateLimit()

        var request = try buildRequest(
            apiKey: apiKey,
            systemPrompt: systemPrompt,
            messages: messages,
            maxTokens: maxTokens ?? self.maxTokens,
            stream: true
        )

        request.timeoutInterval = 120

        let (bytes, response) = try await session.bytes(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }

        if httpResponse.statusCode != 200 {
            throw mapHTTPError(statusCode: httpResponse.statusCode, data: nil)
        }

        var fullResponse = ""

        for try await line in bytes.lines {
            if line.hasPrefix("data: ") {
                let jsonString = String(line.dropFirst(6))

                if jsonString == "[DONE]" {
                    break
                }

                if let data = jsonString.data(using: .utf8),
                   let event = try? JSONDecoder().decode(StreamEvent.self, from: data) {
                    if let delta = event.delta?.text {
                        fullResponse += delta
                        onPartialResponse(fullResponse)
                    }
                }
            }
        }

        lastRequestTime = Date()
        return fullResponse
    }

    // MARK: - Private Methods

    private func buildRequest(
        apiKey: String,
        systemPrompt: String,
        messages: [ChatMessagePayload],
        maxTokens: Int,
        stream: Bool = false
    ) throws -> URLRequest {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(apiVersion, forHTTPHeaderField: "anthropic-version")

        let payload = MessageRequest(
            model: model,
            max_tokens: maxTokens,
            system: systemPrompt,
            messages: messages,
            stream: stream
        )

        request.httpBody = try JSONEncoder().encode(payload)

        return request
    }

    private func handleResponse(data: Data, response: URLResponse) throws -> String {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }

        lastRequestTime = Date()

        if httpResponse.statusCode == 200 {
            do {
                let messageResponse = try JSONDecoder().decode(MessageResponse.self, from: data)
                guard let textContent = messageResponse.content.first(where: { $0.type == "text" }),
                      let text = textContent.text else {
                    throw AIError.invalidResponse
                }
                return text
            } catch let error as DecodingError {
                throw AIError.decodingError(underlying: error)
            }
        } else {
            throw mapHTTPError(statusCode: httpResponse.statusCode, data: data)
        }
    }

    private func mapHTTPError(statusCode: Int, data: Data?) -> AIError {
        var serverMessage: String?

        if let data = data,
           let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
            serverMessage = errorResponse.error.message
        }

        switch statusCode {
        case 401:
            return .invalidAPIKey
        case 429:
            return .rateLimited(retryAfter: 60) // Default 60 seconds
        case 500...599:
            return .serverError(statusCode: statusCode, message: serverMessage)
        case 413:
            return .contextTooLong
        case 503:
            return .serviceUnavailable
        default:
            return .serverError(statusCode: statusCode, message: serverMessage)
        }
    }

    private func enforceRateLimit() async throws {
        if let lastRequest = lastRequestTime {
            let elapsed = Date().timeIntervalSince(lastRequest)
            if elapsed < minimumRequestInterval {
                let delay = minimumRequestInterval - elapsed
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
    }
}

// MARK: - Request/Response Models

struct ChatMessagePayload: Codable {
    let role: String
    let content: String
}

private struct MessageRequest: Codable {
    let model: String
    let max_tokens: Int
    let system: String
    let messages: [ChatMessagePayload]
    let stream: Bool
}

private struct MessageResponse: Codable {
    let id: String
    let content: [ContentBlock]
    let model: String
    let stop_reason: String?
    let usage: Usage

    struct ContentBlock: Codable {
        let type: String
        let text: String?
    }

    struct Usage: Codable {
        let input_tokens: Int
        let output_tokens: Int
    }
}

private struct ErrorResponse: Codable {
    let error: ErrorDetail

    struct ErrorDetail: Codable {
        let type: String
        let message: String
    }
}

private struct StreamEvent: Codable {
    let type: String
    let delta: Delta?

    struct Delta: Codable {
        let type: String?
        let text: String?
    }
}
