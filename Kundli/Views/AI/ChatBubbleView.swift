//
//  ChatBubbleView.swift
//  Kundli
//
//  Message bubble styling for chat interface.
//

import SwiftUI
import UIKit

struct ChatBubbleView: View {
    let message: ChatMessage
    let isStreaming: Bool

    init(message: ChatMessage, isStreaming: Bool = false) {
        self.message = message
        self.isStreaming = isStreaming
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.isUser {
                Spacer(minLength: 60)
            } else {
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
                        .frame(width: 32, height: 32)

                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                // Message content
                Text(message.content)
                    .font(.kundliBody)
                    .foregroundColor(message.isUser ? .white : .kundliTextPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        message.isUser
                            ? AnyView(LinearGradient.kundliGold)
                            : AnyView(Color.kundliCardBg)
                    )
                    .cornerRadius(16)
                    .cornerRadius(message.isUser ? 16 : 4, corners: message.isUser ? [.bottomRight] : [.bottomLeft])

                // Timestamp
                HStack(spacing: 4) {
                    if isStreaming {
                        ProgressView()
                            .scaleEffect(0.6)
                            .tint(.kundliTextTertiary)
                    }
                    Text(message.formattedTime)
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextTertiary)
                }
            }

            if message.isUser {
                // User Avatar
                ZStack {
                    Circle()
                        .fill(Color.kundliCardBg)
                        .frame(width: 32, height: 32)

                    Image(systemName: "person.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.kundliTextSecondary)
                }
            } else {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Corner Radius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Streaming Bubble

struct StreamingBubbleView: View {
    let partialContent: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
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
                    .frame(width: 32, height: 32)

                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(partialContent)
                    .font(.kundliBody)
                    .foregroundColor(.kundliTextPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.kundliCardBg)
                    .cornerRadius(16)
                    .cornerRadius(4, corners: [.bottomLeft])

                HStack(spacing: 4) {
                    ProgressView()
                        .scaleEffect(0.6)
                        .tint(.kundliPrimary)
                    Text("Typing...")
                        .font(.kundliCaption)
                        .foregroundColor(.kundliTextTertiary)
                }
            }

            Spacer(minLength: 60)
        }
        .padding(.horizontal)
    }
}

// MARK: - Typing Indicator

struct TypingIndicatorView: View {
    @State private var animationPhase: Int = 0

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
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
                    .frame(width: 32, height: 32)

                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }

            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.kundliTextSecondary)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationPhase == index ? 1.2 : 0.8)
                        .animation(
                            .easeInOut(duration: 0.4)
                            .repeatForever()
                            .delay(Double(index) * 0.15),
                            value: animationPhase
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.kundliCardBg)
            .cornerRadius(16)
            .cornerRadius(4, corners: [.bottomLeft])

            Spacer(minLength: 60)
        }
        .padding(.horizontal)
        .onAppear {
            animationPhase = 1
        }
    }
}

#Preview {
    ZStack {
        Color.kundliBackground.ignoresSafeArea()

        VStack(spacing: 16) {
            ChatBubbleView(
                message: ChatMessage(
                    role: .user,
                    content: "What does my career look like?"
                )
            )

            ChatBubbleView(
                message: ChatMessage(
                    role: .assistant,
                    content: "Based on your chart, your 10th house is ruled by Saturn, indicating a career that requires patience and perseverance. With Sun in the 10th house, you have natural leadership qualities."
                )
            )

            TypingIndicatorView()
        }
    }
}
