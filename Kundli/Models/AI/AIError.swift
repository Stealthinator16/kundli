//
//  AIError.swift
//  Kundli
//
//  AI-related error types for handling API failures and validation errors.
//

import Foundation

enum AIError: LocalizedError {
    case noAPIKey
    case invalidAPIKey
    case rateLimited(retryAfter: TimeInterval?)
    case networkError(underlying: Error)
    case invalidResponse
    case decodingError(underlying: Error)
    case serverError(statusCode: Int, message: String?)
    case contextTooLong
    case serviceUnavailable
    case insufficientKundliData
    case unknown(message: String)

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "API key not configured. Please add your Claude API key in Settings."
        case .invalidAPIKey:
            return "Invalid API key. Please check your Claude API key in Settings."
        case .rateLimited(let retryAfter):
            if let seconds = retryAfter {
                let minutes = Int(ceil(seconds / 60))
                return "Rate limited. Please try again in \(minutes) minute\(minutes == 1 ? "" : "s")."
            }
            return "Rate limited. Please try again later."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Received an invalid response from the AI service."
        case .decodingError:
            return "Failed to process the AI response."
        case .serverError(let code, let message):
            if let msg = message {
                return "Server error (\(code)): \(msg)"
            }
            return "Server error (\(code)). Please try again later."
        case .contextTooLong:
            return "The conversation is too long. Please start a new chat."
        case .serviceUnavailable:
            return "AI service is temporarily unavailable. Please try again later."
        case .insufficientKundliData:
            return "Insufficient chart data to generate insights."
        case .unknown(let message):
            return message
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .noAPIKey, .invalidAPIKey:
            return "Go to Settings > AI Settings to configure your API key."
        case .rateLimited:
            return "Wait a moment and try again."
        case .networkError:
            return "Check your internet connection and try again."
        case .contextTooLong:
            return "Start a new conversation to continue."
        case .serviceUnavailable, .serverError:
            return "The service may be experiencing issues. Try again in a few minutes."
        default:
            return "Try again or contact support if the issue persists."
        }
    }

    var isRecoverable: Bool {
        switch self {
        case .rateLimited, .networkError, .serviceUnavailable, .serverError:
            return true
        case .noAPIKey, .invalidAPIKey:
            return true // User can fix by adding/updating key
        default:
            return false
        }
    }
}
