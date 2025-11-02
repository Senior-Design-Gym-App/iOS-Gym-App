//
//  ChatView.swift
//  iOS Gym App
//
//  Created by 鄭承典 on 11/4/25.
//

import SwiftUI

struct ChatView: View {
    let username: String
    @State private var input: String = ""
    @State private var messages: [Message] = [
        .init(id: UUID(), text: "Hey there!", isMe: false),
        .init(id: UUID(), text: "Hi! Big fan of your workouts.", isMe: true)
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(messages) { msg in
                            HStack {
                                if msg.isMe { Spacer(minLength: 40) }
                                Text(msg.text)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(msg.isMe ? Color.accentColor.opacity(0.15) : Color(.systemGray6))
                                    )
                                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color(.separator)))
                                if !msg.isMe { Spacer(minLength: 40) }
                            }
                            .id(msg.id)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 12)
                }
                .onChange(of: messages.count) { _ in
                    if let last = messages.last { withAnimation { proxy.scrollTo(last.id, anchor: .bottom) } }
                }
            }

            HStack(spacing: 10) {
                TextField("Message @\(username)", text: $input, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color(.systemGray6)))
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color(.separator)))
                Button(action: send) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.accentColor))
                }
                .buttonStyle(.plain)
                .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
        .navigationTitle("Message")
        .toolbarTitleDisplayMode(.inline)
    }

    private func send() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messages.append(.init(id: UUID(), text: trimmed, isMe: true))
        input = ""
    }
}

private struct Message: Identifiable, Hashable { let id: UUID; let text: String; let isMe: Bool }


