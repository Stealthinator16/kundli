//
//  AIChatViewModel.swift
//  Kundli
//
//  ViewModel for managing chat state, messages, and history.
//

import Foundation
import SwiftData
import os

@Observable
class AIChatViewModel {
    // MARK: - State

    var currentConversation: ChatConversation?
    var conversations: [ChatConversation] = []
    var isSending: Bool = false
    var partialResponse: String = ""
    var error: AIError?
    var inputText: String = ""
    var suggestedQuestions: [String] = []

    // MARK: - Private Properties

    private let chatService = AIChatService.shared
    private let keyManager = AIKeyManager.shared

    // MARK: - Computed Properties

    var hasAPIKey: Bool {
        keyManager.hasAPIKey
    }

    var messages: [ChatMessage] {
        currentConversation?.messages ?? []
    }

    var showError: Bool {
        error != nil
    }

    var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending
    }

    // MARK: - Public Methods

    func startNewConversation(for savedKundli: SavedKundli, context: ModelContext) {
        let conversation = ChatConversation(
            kundliId: savedKundli.id,
            kundliName: savedKundli.name
        )
        context.insert(conversation)
        currentConversation = conversation

        // Load suggested questions
        suggestedQuestions = chatService.getSuggestedQuestions(for: savedKundli)
    }

    func loadConversations(for kundliId: UUID, context: ModelContext) {
        let descriptor = FetchDescriptor<ChatConversation>(
            predicate: #Predicate { $0.kundliId == kundliId },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )

        do {
            conversations = try context.fetch(descriptor)
        } catch {
            AppLogger.ai.error("Failed to fetch conversations: \(error.localizedDescription)")
            conversations = []
        }
    }

    func selectConversation(_ conversation: ChatConversation) {
        currentConversation = conversation
        partialResponse = ""
        error = nil
    }

    func sendMessage(savedKundli: SavedKundli, useStreaming: Bool = true) async {
        guard let conversation = currentConversation else { return }
        guard canSend else { return }

        let content = inputText.trimmingCharacters(in: .whitespacesAndNewlines)

        await MainActor.run {
            inputText = ""
            isSending = true
            error = nil
            partialResponse = ""
        }

        do {
            if useStreaming {
                _ = try await chatService.sendMessageWithStreaming(
                    content: content,
                    in: conversation,
                    savedKundli: savedKundli
                ) { [weak self] partial in
                    Task { @MainActor in
                        self?.partialResponse = partial
                    }
                }
            } else {
                _ = try await chatService.sendMessage(
                    content: content,
                    in: conversation,
                    savedKundli: savedKundli
                )
            }

            let messageCount = conversation.messages.count

            await MainActor.run {
                isSending = false
                partialResponse = ""
                // Clear suggested questions after first message
                if messageCount > 1 {
                    suggestedQuestions = []
                }
            }
        } catch let aiError as AIError {
            await MainActor.run {
                error = aiError
                isSending = false
            }
        } catch {
            await MainActor.run {
                self.error = .unknown(message: error.localizedDescription)
                isSending = false
            }
        }
    }

    func sendSuggestedQuestion(_ question: String, savedKundli: SavedKundli) async {
        inputText = question
        await sendMessage(savedKundli: savedKundli)
    }

    func deleteConversation(_ conversation: ChatConversation, context: ModelContext) {
        context.delete(conversation)
        conversations.removeAll { $0.id == conversation.id }

        if currentConversation?.id == conversation.id {
            currentConversation = nil
        }
    }

    func clearError() {
        error = nil
    }

    func reset() {
        currentConversation = nil
        isSending = false
        partialResponse = ""
        error = nil
        inputText = ""
        suggestedQuestions = []
    }
}
