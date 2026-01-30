//
//  ChatView.swift
//  Kundli
//
//  Main chat interface for AI conversations.
//

import SwiftUI
import SwiftData

struct ChatView: View {
    let savedKundli: SavedKundli
    @Bindable var viewModel: AIChatViewModel

    @Environment(\.modelContext) private var modelContext
    @State private var scrollProxy: ScrollViewProxy?

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                if !viewModel.hasAPIKey {
                    noAPIKeyView
                } else if viewModel.currentConversation == nil {
                    conversationListView
                } else {
                    chatContentView
                }
            }
        }
        .navigationTitle("Chat with AI")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            if viewModel.currentConversation != nil {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            viewModel.startNewConversation(for: savedKundli, context: modelContext)
                        } label: {
                            Label("New Chat", systemImage: "plus")
                        }

                        Button(role: .destructive) {
                            if let conversation = viewModel.currentConversation {
                                viewModel.deleteConversation(conversation, context: modelContext)
                            }
                        } label: {
                            Label("Delete Chat", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.kundliPrimary)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadConversations(for: savedKundli.id, context: modelContext)
            // Auto-start new conversation if none exist
            if viewModel.conversations.isEmpty {
                viewModel.startNewConversation(for: savedKundli, context: modelContext)
            }
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.showError },
            set: { if !$0 { viewModel.clearError() } }
        )) {
            Button("OK", role: .cancel) {}
            if case .noAPIKey = viewModel.error {
                NavigationLink("Settings") {
                    AISettingsView()
                }
            }
        } message: {
            if let error = viewModel.error {
                Text(error.errorDescription ?? "An error occurred")
            }
        }
    }

    // MARK: - Views

    private var noAPIKeyView: some View {
        VStack(spacing: 24) {
            Image(systemName: "key.fill")
                .font(.system(size: 48))
                .foregroundColor(.kundliPrimary)

            VStack(spacing: 8) {
                Text("API Key Required")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                Text("Configure your Claude API key to start chatting with the AI astrologer.")
                    .font(.kundliBody)
                    .foregroundColor(.kundliTextSecondary)
                    .multilineTextAlignment(.center)
            }

            NavigationLink(destination: AISettingsView()) {
                Text("Configure API Key")
                    .font(.kundliHeadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(LinearGradient.kundliGold)
                    .cornerRadius(12)
            }
        }
        .padding()
    }

    private var conversationListView: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 8) {
                Text("Chat History")
                    .font(.kundliTitle2)
                    .foregroundColor(.kundliTextPrimary)

                Text("Continue a previous conversation or start a new one")
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliTextSecondary)
            }
            .padding(.top)

            // New chat button
            GoldButton(title: "Start New Chat", icon: "plus") {
                viewModel.startNewConversation(for: savedKundli, context: modelContext)
            }
            .padding(.horizontal)

            // Conversation list
            if !viewModel.conversations.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.conversations) { conversation in
                            ConversationRow(conversation: conversation) {
                                viewModel.selectConversation(conversation)
                            } onDelete: {
                                viewModel.deleteConversation(conversation, context: modelContext)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                Spacer()
                Text("No previous conversations")
                    .font(.kundliBody)
                    .foregroundColor(.kundliTextTertiary)
                Spacer()
            }
        }
    }

    private var chatContentView: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Welcome message if empty
                        if viewModel.messages.isEmpty {
                            welcomeSection
                        }

                        // Messages
                        ForEach(viewModel.messages) { message in
                            ChatBubbleView(message: message)
                                .id(message.id)
                        }

                        // Streaming response
                        if viewModel.isSending && !viewModel.partialResponse.isEmpty {
                            StreamingBubbleView(partialContent: viewModel.partialResponse)
                        } else if viewModel.isSending {
                            TypingIndicatorView()
                        }

                        // Spacer at bottom
                        Color.clear.frame(height: 1)
                            .id("bottom")
                    }
                    .padding(.vertical)
                }
                .onAppear {
                    scrollProxy = proxy
                }
                .onChange(of: viewModel.messages.count) {
                    withAnimation {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
                .onChange(of: viewModel.partialResponse) {
                    withAnimation {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }

            // Input
            ChatInputView(
                text: $viewModel.inputText,
                isLoading: viewModel.isSending
            ) {
                Task {
                    await viewModel.sendMessage(savedKundli: savedKundli)
                }
            }
        }
    }

    private var welcomeSection: some View {
        VStack(spacing: 20) {
            // AI Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.kundliPrimary, Color.kundliPrimaryDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: "sparkles")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }

            VStack(spacing: 8) {
                Text("AI Astrologer")
                    .font(.kundliTitle3)
                    .foregroundColor(.kundliTextPrimary)

                Text("Ask questions about \(savedKundli.name)'s birth chart")
                    .font(.kundliBody)
                    .foregroundColor(.kundliTextSecondary)
                    .multilineTextAlignment(.center)
            }

            // Suggested questions
            if !viewModel.suggestedQuestions.isEmpty {
                SuggestedQuestionsView(
                    questions: viewModel.suggestedQuestions
                ) { question in
                    Task {
                        await viewModel.sendSuggestedQuestion(question, savedKundli: savedKundli)
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - Conversation Row

struct ConversationRow: View {
    let conversation: ChatConversation
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.kundliPrimary.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .foregroundColor(.kundliPrimary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(conversation.title)
                        .font(.kundliBody)
                        .foregroundColor(.kundliTextPrimary)
                        .lineLimit(1)

                    Text(conversation.preview)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextSecondary)
                        .lineLimit(1)

                    Text(conversation.relativeDate)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextTertiary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextTertiary)
            }
            .padding()
            .background(Color.kundliCardBg)
            .cornerRadius(12)
        }
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatView(
            savedKundli: SavedKundli(
                id: UUID(),
                name: "Test User",
                dateOfBirth: Date(),
                timeOfBirth: Date(),
                birthCity: "Mumbai",
                latitude: 19.076,
                longitude: 72.8777,
                timezone: "Asia/Kolkata",
                gender: "male",
                ascendantSign: "Aries",
                ascendantDegree: 15.5,
                ascendantNakshatra: "Ashwini"
            ),
            viewModel: AIChatViewModel()
        )
    }
}
