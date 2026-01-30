//
//  AISettingsView.swift
//  Kundli
//
//  Settings view for configuring Claude API key and managing AI data.
//

import SwiftUI

struct AISettingsView: View {
    @State private var apiKey: String = ""
    @State private var isKeyVisible: Bool = false
    @State private var showSaveConfirmation: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var showClearDataConfirmation: Bool = false
    @State private var errorMessage: String?
    @State private var hasExistingKey: Bool = false

    private let keyManager = AIKeyManager.shared

    var body: some View {
        ZStack {
            Color.kundliBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    apiKeySection
                    helpSection
                    dataManagementSection
                }
                .padding()
            }
        }
        .navigationTitle("AI Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kundliCardBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            hasExistingKey = keyManager.hasAPIKey
            if hasExistingKey {
                apiKey = "••••••••••••••••••••"
            }
        }
        .alert("API Key Saved", isPresented: $showSaveConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your Claude API key has been securely saved.")
        }
        .alert("Delete API Key?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteAPIKey()
            }
        } message: {
            Text("This will remove your API key. You'll need to re-enter it to use AI features.")
        }
        .alert("Clear AI Data?", isPresented: $showClearDataConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                clearAIData()
            }
        } message: {
            Text("This will delete all cached AI reports and chat history. This cannot be undone.")
        }
    }

    // MARK: - Sections

    private var apiKeySection: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                Label("Claude API Key", systemImage: "key.fill")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                Text("Enter your Anthropic Claude API key to enable AI features.")
                    .font(.kundliSubheadline)
                    .foregroundColor(.kundliTextSecondary)

                HStack(spacing: 12) {
                    Group {
                        if isKeyVisible && !hasExistingKey {
                            TextField("sk-ant-...", text: $apiKey)
                                .textContentType(.password)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        } else {
                            SecureField(hasExistingKey ? "••••••••••••••••••••" : "sk-ant-...", text: $apiKey)
                                .textContentType(.password)
                        }
                    }
                    .font(.kundliBody)
                    .padding(12)
                    .background(Color.kundliBackground)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )

                    Button {
                        isKeyVisible.toggle()
                    } label: {
                        Image(systemName: isKeyVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.kundliTextSecondary)
                            .frame(width: 44, height: 44)
                    }
                }

                if let error = errorMessage {
                    Text(error)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliError)
                }

                HStack(spacing: 12) {
                    if hasExistingKey {
                        SecondaryButton(title: "Delete Key", icon: "trash") {
                            showDeleteConfirmation = true
                        }
                    }

                    GoldButton(title: hasExistingKey ? "Update Key" : "Save Key", icon: "checkmark") {
                        saveAPIKey()
                    }
                    .disabled(!canSave)
                    .opacity(canSave ? 1.0 : 0.5)
                }
            }
        }
    }

    private var helpSection: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Label("How to get an API key", systemImage: "questionmark.circle")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                VStack(alignment: .leading, spacing: 8) {
                    helpStep(number: "1", text: "Visit console.anthropic.com")
                    helpStep(number: "2", text: "Sign up or log in to your account")
                    helpStep(number: "3", text: "Go to API Keys section")
                    helpStep(number: "4", text: "Create a new API key")
                    helpStep(number: "5", text: "Copy and paste it above")
                }

                Text("Your API key is stored securely in the device Keychain and never leaves your device except for API calls.")
                    .font(.kundliCaption)
                    .foregroundColor(.kundliTextTertiary)
                    .padding(.top, 4)
            }
        }
    }

    private var dataManagementSection: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                Label("Data Management", systemImage: "cylinder.split.1x2")
                    .font(.kundliHeadline)
                    .foregroundColor(.kundliTextPrimary)

                Button {
                    showClearDataConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Clear All AI Data")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.kundliCaption)
                    }
                    .font(.kundliBody)
                    .foregroundColor(.kundliError)
                    .padding(.vertical, 8)
                }
            }
        }
    }

    // MARK: - Helper Views

    private func helpStep(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.kundliCaption)
                .fontWeight(.bold)
                .foregroundColor(.kundliPrimary)
                .frame(width: 20, height: 20)
                .background(Color.kundliPrimary.opacity(0.2))
                .clipShape(Circle())

            Text(text)
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextSecondary)
        }
    }

    // MARK: - Computed Properties

    private var canSave: Bool {
        let trimmed = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        // Allow saving if it's a new key (not the masked placeholder)
        if hasExistingKey && apiKey == "••••••••••••••••••••" {
            return false
        }
        return !trimmed.isEmpty && trimmed.count > 20
    }

    // MARK: - Actions

    private func saveAPIKey() {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)

        guard keyManager.validateAPIKeyFormat(trimmedKey) else {
            errorMessage = "Invalid API key format. Key should start with 'sk-ant-'"
            return
        }

        do {
            try keyManager.saveAPIKey(trimmedKey)
            errorMessage = nil
            hasExistingKey = true
            apiKey = "••••••••••••••••••••"
            showSaveConfirmation = true
        } catch {
            errorMessage = "Failed to save API key: \(error.localizedDescription)"
        }
    }

    private func deleteAPIKey() {
        keyManager.deleteAPIKey()
        apiKey = ""
        hasExistingKey = false
        errorMessage = nil
    }

    private func clearAIData() {
        // Clear cached reports and chat history
        AIResponseCache.shared.clearAll()
        // Note: Chat conversations will be cleared through SwiftData in a future update
    }
}

#Preview {
    NavigationStack {
        AISettingsView()
    }
}
