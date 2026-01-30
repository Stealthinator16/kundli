//
//  AIChatService.swift
//  Kundli
//
//  Chat conversation management service for AI interactions.
//

import Foundation
import SwiftData

final class AIChatService {
    static let shared = AIChatService()

    private let aiService = AIService.shared
    private let promptBuilder = AIPromptBuilder.shared
    private let kundliService = KundliGenerationService.shared
    private let settingsService = SettingsService.shared

    private init() {}

    // MARK: - Send Message

    func sendMessage(
        content: String,
        in conversation: ChatConversation,
        savedKundli: SavedKundli
    ) async throws -> ChatMessage {
        // Add user message
        let userMessage = ChatMessage(role: .user, content: content)
        conversation.addMessage(userMessage)

        // Build context
        let birthDetails = savedKundli.toBirthDetails()
        let kundliData = try await kundliService.generateKundli(
            birthDetails: birthDetails,
            settings: settingsService.calculationSettings
        )

        let context = promptBuilder.buildKundliContext(
            from: savedKundli,
            with: kundliData
        )

        let systemPrompt = promptBuilder.buildChatSystemPrompt(kundliContext: context)

        // Prepare messages for API
        let apiMessages = conversation.messages.toPayloads()

        // Send to AI
        let response = try await aiService.sendMessage(
            systemPrompt: systemPrompt,
            messages: apiMessages,
            maxTokens: 2048
        )

        // Create assistant message
        let assistantMessage = ChatMessage(role: .assistant, content: response)
        conversation.addMessage(assistantMessage)

        // Update conversation title if it's the first exchange
        if conversation.messages.count <= 2 {
            conversation.generateTitle()
        }

        return assistantMessage
    }

    func sendMessageWithStreaming(
        content: String,
        in conversation: ChatConversation,
        savedKundli: SavedKundli,
        onPartialResponse: @escaping (String) -> Void
    ) async throws -> ChatMessage {
        // Add user message
        let userMessage = ChatMessage(role: .user, content: content)
        conversation.addMessage(userMessage)

        // Build context
        let birthDetails = savedKundli.toBirthDetails()
        let kundliData = try await kundliService.generateKundli(
            birthDetails: birthDetails,
            settings: settingsService.calculationSettings
        )

        let context = promptBuilder.buildKundliContext(
            from: savedKundli,
            with: kundliData
        )

        let systemPrompt = promptBuilder.buildChatSystemPrompt(kundliContext: context)

        // Prepare messages for API
        let apiMessages = conversation.messages.toPayloads()

        // Send to AI with streaming
        let response = try await aiService.streamMessage(
            systemPrompt: systemPrompt,
            messages: apiMessages,
            maxTokens: 2048,
            onPartialResponse: onPartialResponse
        )

        // Create assistant message
        let assistantMessage = ChatMessage(role: .assistant, content: response)
        conversation.addMessage(assistantMessage)

        // Update conversation title if it's the first exchange
        if conversation.messages.count <= 2 {
            conversation.generateTitle()
        }

        return assistantMessage
    }

    // MARK: - Suggested Questions

    func getSuggestedQuestions(for savedKundli: SavedKundli) -> [String] {
        return promptBuilder.suggestedQuestions(for: savedKundli)
    }
}
