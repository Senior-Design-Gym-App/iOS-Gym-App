//
//  CreateWorkoutPostView.swift
//  iOS Gym App
//
//  Created by Zachary Andrew Kolano on 12/9/25.
//


import SwiftUI

struct CreateWorkoutPostView: View {
    let session: WorkoutSession
    let elapsedTime: TimeInterval
    let defaultText: String
    let onPostCreated: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var postText: String
    @State private var isPosting = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    init(session: WorkoutSession, elapsedTime: TimeInterval, defaultText: String, onPostCreated: @escaping () -> Void) {
        self.session = session
        self.elapsedTime = elapsedTime
        self.defaultText = defaultText
        self.onPostCreated = onPostCreated
        _postText = State(initialValue: defaultText)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Workout summary card
                VStack(alignment: .leading, spacing: 8) {
                    Text(session.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Label("\(session.exercises?.count ?? 0) exercises", systemImage: "figure.strengthtraining.traditional")
                        Spacer()
                        Label(formatElapsedTime(), systemImage: "clock")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                
                // Text editor
                VStack(alignment: .leading) {
                    Text("Share your workout")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    TextEditor(text: $postText)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Post Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") {
                        // Skip posting and just finish
                        onPostCreated()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        Task {
                            await createPost()
                        }
                    }
                    .disabled(postText.isEmpty || isPosting)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func formatElapsedTime() -> String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func createPost() async {
        isPosting = true
        
        do {
            _ = try await CloudManager.shared.createPost(text: postText)
            print("✅ Post created successfully")
            
            // Dismiss and finish session
            dismiss()
            onPostCreated()
        } catch {
            errorMessage = "Failed to create post: \(error.localizedDescription)"
            showError = true
            print("❌ Failed to create post: \(error)")
        }
        
        isPosting = false
    }
}
