//
//  ChatConversation.swift
//  Kundli
//
//  SwiftData model for persisting chat conversation history.
//

import Foundation
import SwiftData

@Model
final class ChatConversation {
    var id: UUID
    var kundliId: UUID
    var kundliName: String
    var title: String
    var messagesData: Data?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        kundliId: UUID,
        kundliName: String,
        title: String = "New Chat",
        messages: [ChatMessage] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.kundliId = kundliId
        self.kundliName = kundliName
        self.title = title
        self.messagesData = try? JSONEncoder().encode(messages)
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Computed Properties

    var messages: [ChatMessage] {
        get {
            guard let data = messagesData else { return [] }
            return (try? JSONDecoder().decode([ChatMessage].self, from: data)) ?? []
        }
        set {
            messagesData = try? JSONEncoder().encode(newValue)
            updatedAt = Date()
        }
    }

    var messageCount: Int {
        messages.count
    }

    var lastMessage: ChatMessage? {
        messages.last
    }

    var preview: String {
        if let last = lastMessage {
            let prefix = last.isUser ? "You: " : ""
            let content = last.content.prefix(50)
            return "\(prefix)\(content)\(last.content.count > 50 ? "..." : "")"
        }
        return "No messages yet"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: updatedAt)
    }

    var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: updatedAt, relativeTo: Date())
    }

    // MARK: - Methods

    func addMessage(_ message: ChatMessage) {
        var currentMessages = messages
        currentMessages.append(message)
        messages = currentMessages
    }

    func clearMessages() {
        messages = []
    }

    func generateTitle() {
        // Generate title from first user message
        if let firstUserMessage = messages.first(where: { $0.isUser }) {
            let content = firstUserMessage.content
            if content.count > 30 {
                title = String(content.prefix(30)) + "..."
            } else {
                title = content
            }
        }
    }
}
