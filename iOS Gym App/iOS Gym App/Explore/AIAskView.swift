//
//  AIAskView.swift
//  iOS Gym App
//
//  Created by 鄭承典 on 11/4/25.
//

import SwiftUI

struct AIMessage: Identifiable {
    var id = UUID()
    var text: String
    var isUser: Bool
}

struct AIAskView: View {
    @State private var prompt: String = ""
    @State private var messages: [AIMessage] = [
        AIMessage(text: "Ask me anything about training, programming, or nutrition.", isUser: false)
    ]
    @State private var isLoading: Bool = false
    
    private let suggestions: [String] = [
        "Build me a 4-day push/pull split",
        "How to improve bench press?",
        "Recommend a mobility routine",
        "What should I do for fat loss?"
    ]
    
    private let chipCornerRadius = Constants.cornerRadius
    private let chipSpacing: CGFloat = Constants.customLabelPadding
    private let inputRadius: CGFloat = Constants.cornerRadius + 8
    private let primaryTint = Constants.mainAppTheme
    private let bubbleCornerRadius = Constants.cornerRadius + 4
    
    // Remove @State - just create the instance directly
    private let ai = AIFunctions()
    
    var body: some View {
        VStack(spacing: 0) {
            // Suggestions chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: chipSpacing) {
                    ForEach(suggestions, id: \.self) { item in
                        Button(action: {
                            prompt = item
                            sendMessage()
                        }) {
                            HStack(spacing: chipSpacing) {
                                Image(systemName: "sparkles")
                                    .font(.footnote)
                                Text(item)
                                    .font(.footnote)
                            }
                            .padding(.vertical, chipSpacing + 3)
                            .padding(.horizontal, Constants.titlePadding * 2)
                            .background(
                                RoundedRectangle(cornerRadius: chipCornerRadius, style: .continuous)
                                    .fill(Color(.systemGray6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: chipCornerRadius, style: .continuous)
                                    .stroke(Color(.separator))
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(isLoading)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }

            Divider()

            // Messages area
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(messages) { message in
                            ChatBubble(text: message.text, isUser: message.isUser)
                                .id(message.id)
                        }
                        
                        // Loading indicator
                        if isLoading {
                            AILoadingIndicator()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                }
                .onChange(of: messages.count) { _, _ in
                    // Auto-scroll to newest message
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Input bar
            HStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.secondary)
                    TextField("Ask anything…", text: $prompt, axis: .vertical)
                        .textInputAutocapitalization(.sentences)
                        .onSubmit {
                            sendMessage()
                        }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: inputRadius, style: .continuous)
                        .fill(Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: inputRadius, style: .continuous)
                        .stroke(Color(.separator))
                )

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Constants.buttonTheme)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(primaryTint))
                }
                .buttonStyle(.plain)
                .disabled(prompt.isEmpty || isLoading)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
        .navigationTitle("Ask AI")
        .toolbarTitleDisplayMode(.inline)
    }
    
    private func sendMessage() {
        let userMessage = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userMessage.isEmpty else { return }
        
        // Add user message
        messages.append(AIMessage(text: userMessage, isUser: true))
        prompt = ""
        isLoading = true
        
        // Call AI function
        Task {
            do {
                let response = try await ai.genericResponse(message: userMessage)
                print("AI Response: \(response)")
                
                // Add AI response
                await MainActor.run {
                    messages.append(AIMessage(text: response, isUser: false))
                    isLoading = false
                }
            } catch {
                // Handle error
                await MainActor.run {
                    messages.append(AIMessage(text: "Sorry, I encountered an error. Please try again.", isUser: false))
                    isLoading = false
                }
                print("AI Error: \(error)")
            }
        }
    }
}

private struct ChatBubble: View {
    let text: String
    let isUser: Bool
    
    private let cornerRadius = Constants.cornerRadius + 4
    private let userTint = Constants.mainAppTheme
    private let bubblePadding = Constants.titlePadding + 5
    
    var body: some View {
        HStack(alignment: .bottom) {
            if isUser { Spacer(minLength: 40) }
            Text(text)
                .padding(.vertical, bubblePadding)
                .padding(.horizontal, bubblePadding + 2)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(isUser ? userTint.opacity(0.15) : Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color(.separator))
                )
                .frame(maxWidth: 320, alignment: .leading)
            if !isUser { Spacer(minLength: 40) }
        }
    }
}

private struct AILoadingIndicator: View {
    @State private var isAnimating = false
    private let dotSize: CGFloat = 8
    private let dotSpacing: CGFloat = 6
    private let primaryTint = Constants.mainAppTheme
    private let bubbleCornerRadius = Constants.cornerRadius + 4
    private let bubblePadding = Constants.titlePadding + 5
    
    var body: some View {
        HStack(alignment: .bottom) {
            Spacer(minLength: 40)
            HStack(spacing: dotSpacing) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(primaryTint)
                        .frame(width: dotSize, height: dotSize)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .opacity(isAnimating ? 1.0 : 0.6)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }
            }
            .padding(.vertical, bubblePadding)
            .padding(.horizontal, bubblePadding + 2)
            .background(
                RoundedRectangle(cornerRadius: bubbleCornerRadius, style: .continuous)
                    .fill(Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: bubbleCornerRadius, style: .continuous)
                    .stroke(Color(.separator))
            )
            Spacer(minLength: 40)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    NavigationStack {
        AIAskView()
    }
}
