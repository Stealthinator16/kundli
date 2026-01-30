//
//  ChatMessage.swift
//  Kundli
//
//  Chat message model for AI conversations.
//

import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let role: MessageRole
    let content: String
    let timestamp: Date

    init(
        id: UUID = UUID(),
        role: MessageRole,
        content: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    var isUser: Bool {
        role == .user
    }

    var isAssistant: Bool {
        role == .assistant
    }
}

enum MessageRole: String, Codable {
    case user
    case assistant
    case system

    var displayName: String {
        switch self {
        case .user:
            return "You"
        case .assistant:
            return "AI Astrologer"
        case .system:
            return "System"
        }
    }
}

// MARK: - Conversion for API

extension ChatMessage {
    func toPayload() -> ChatMessagePayload {
        ChatMessagePayload(role: role.rawValue, content: content)
    }
}

extension Array where Element == ChatMessage {
    func toPayloads() -> [ChatMessagePayload] {
        self.filter { $0.role != .system }
            .map { $0.toPayload() }
    }
}
