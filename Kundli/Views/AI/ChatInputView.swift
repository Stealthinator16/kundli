//
//  ChatInputView.swift
//  Kundli
//
//  Text input view with send button for chat interface.
//

import SwiftUI

struct ChatInputView: View {
    @Binding var text: String
    let isLoading: Bool
    let onSend: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            // Text input
            TextField("Ask about your chart...", text: $text, axis: .vertical)
                .font(.kundliBody)
                .foregroundColor(.kundliTextPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.kundliCardBg)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .lineLimit(1...5)
                .focused($isFocused)
                .disabled(isLoading)

            // Send button
            Button(action: onSend) {
                ZStack {
                    Circle()
                        .fill(canSend ? LinearGradient.kundliGold : LinearGradient(colors: [Color.kundliCardBg, Color.kundliCardBg], startPoint: .top, endPoint: .bottom))
                        .frame(width: 44, height: 44)

                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(canSend ? .white : .kundliTextTertiary)
                    }
                }
            }
            .disabled(!canSend || isLoading)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            Color.kundliBackground
                .shadow(color: .black.opacity(0.2), radius: 10, y: -5)
        )
    }

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Compact Input View (for inline use)

struct CompactChatInputView: View {
    @Binding var text: String
    let placeholder: String
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            TextField(placeholder, text: $text)
                .font(.kundliSubheadline)
                .foregroundColor(.kundliTextPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.kundliBackground)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )

            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(canSend ? .kundliPrimary : .kundliTextTertiary)
            }
            .disabled(!canSend)
        }
    }

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        VStack {
            Spacer()

            ChatInputView(
                text: .constant(""),
                isLoading: false,
                onSend: {}
            )
        }
    }
}
