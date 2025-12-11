//
//  FeedView.swift
//  iOS Gym App
//
//  Created by Zachary Andrew Kolano on 12/8/25.
//

import SwiftUI

struct FeedView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var showCreatePost = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(posts) { post in
                    PostRow(post: post)
                }
            }
            .navigationTitle("Feed")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreatePost = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .refreshable {
                await loadFeed()
            }
            .overlay {
                if posts.isEmpty {
                    ContentUnavailableView(
                        "No Posts Yet",
                        systemImage: "text.bubble",
                        description: Text("Add friends to see their posts here")
                    )
                }
            }
            .sheet(isPresented: $showCreatePost) {
                CreatePostView {
                    await loadFeed()
                }
            }
            .task {
                await loadFeed()
            }
        }
    }
    
    private func loadFeed() async {
        isLoading = true
        
        do {
            posts = try await CloudManager.shared.getFeed()
        } catch {
            print("Failed to load feed: \(error)")
        }
        
        isLoading = false
    }
}

struct PostRow: View {
    let post: Post
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()
    var timeAgoA: String {
        guard let date = formatter.date(from: post.createdAt) else { return post.createdAt }
        let yuh = DateHandler().RelativeTime(from: date)
        return DateHandler().RelativeTime(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.displayName ?? "Unknown User")
                        .font(.headline)
                    Text("@\(post.username ?? "unknown")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(timeAgoA)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(post.text)
                .font(.body)
        }
        .padding(.vertical, 4)
    }
}


struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var postText = ""
    @State private var isPosting = false
    
    let onPostCreated: () async -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                TextEditor(text: $postText)
                    .frame(height: 150)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding()
                
                Spacer()
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
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
        }
    }
    
    private func createPost() async {
        isPosting = true
        
        do {
            _ = try await CloudManager.shared.createPost(text: postText)
            await onPostCreated()
            dismiss()
        } catch {
            print("Failed to create post: \(error)")
        }
        
        isPosting = false
    }
}

#Preview {
    FeedView()
}
