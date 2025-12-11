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
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        List {
            ForEach(friends) { friend in
                NavigationLink {
                    // Navigate to friend's profile with their userId
                    UserProfileView(
                        profile: createProfileContent(from: friend),
                        userId: friend.userId
                    )
                    .environmentObject(authManager)
                } label: {
                    FriendRowView(friend: friend)
                }
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
    
    // Helper to create UserProfileContent from Friend
    private func createProfileContent(from friend: Friend) -> UserProfileContent {
        var profile = UserProfileContent.empty
        profile.username = friend.username ?? "unknown"
        profile.displayName = friend.displayName ?? "Unknown"
        profile.bio = friend.bio ?? ""
        // Stats will be loaded from the cloud when the profile view appears
        return profile
    }
}

// MARK: - Friend Row View
struct FriendRowView: View {
    let friend: Friend
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar placeholder
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                }
            
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
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
