//
//  FriendsListView.swift
//  iOS Gym App
//
//  Created by Zachary Andrew Kolano on 12/9/25.
//


import SwiftUI

struct FriendsListView: View {
    @State private var friends: [Friend] = []
    @State private var isLoading = false
    
    var body: some View {
        List {
            ForEach(friends) { friend in
                VStack(alignment: .leading, spacing: 4) {
                    Text(friend.displayName ?? "Unknown")
                        .font(.headline)
                    Text("@\(friend.username ?? "unknown")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let bio = friend.bio, !bio.isEmpty {
                        Text(bio)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Friends")
        .overlay {
            if isLoading {
                ProgressView()
            } else if friends.isEmpty {
                ContentUnavailableView(
                    "No Friends Yet",
                    systemImage: "person.2",
                    description: Text("Add friends to see them here")
                )
            }
        }
        .refreshable {
            await loadFriends()
        }
        .task {
            await loadFriends()
        }
    }
    
    private func loadFriends() async {
        isLoading = true
        
        do {
            friends = try await CloudManager.shared.getFriends()
            print("✅ Loaded \(friends.count) friends")
        } catch {
            print("❌ Failed to load friends: \(error)")
        }
        
        isLoading = false
    }
}