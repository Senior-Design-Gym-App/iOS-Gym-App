//
//  UserSearchView.swift
//  iOS Gym App
//
//  Created by 鄭承典 on 11/4/25.
//

import SwiftUI

enum UserViewMode: String, CaseIterable {
    case search = "Find Users"
    case friends = "Friends"
    case addFriends = "Add Friends"
}

struct UserSearchView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @State private var query: String = ""
    @State private var selectedMode: UserViewMode = .search
    
    // Real data from cloud
    @State private var searchResults: [UserProfile] = []
    @State private var friends: [Friend] = []
    @State private var pendingRequests: [FriendRequest] = []
    
    // Loading states
    @State private var isSearching = false
    @State private var isLoadingFriends = false
    @State private var isLoadingRequests = false
    @State private var message: String = ""
    
    private let cloudManager = CloudManager.shared
    private let avatarSize: CGFloat = Constants.smallIconSize
    private let primaryTint = Constants.mainAppTheme
    private let rowSpacing = Constants.customLabelPadding * 2
    
    var pendingRequestCount: Int {
        pendingRequests.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Mode selector
            Picker("Mode", selection: $selectedMode) {
                ForEach(UserViewMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: selectedMode) { _, _ in
                // Reload data when switching modes
                Task {
                    switch selectedMode {
                    case .friends:
                        await loadFriends()
                    case .addFriends:
                        await loadPendingRequests()
                    case .search:
                        break
                    }
                }
            }
            
            // Content based on selected mode
            switch selectedMode {
            case .search:
                searchUsersView
            case .friends:
                friendsView
            case .addFriends:
                addFriendsView
            }
        }
        .navigationTitle("Users")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if selectedMode == .addFriends && pendingRequestCount > 0 {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        FriendRequestsView()
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "person.badge.clock")
                            
                            Circle()
                                .fill(.red)
                                .frame(width: 16, height: 16)
                                .overlay {
                                    Text("\(pendingRequestCount)")
                                        .font(.caption2)
                                        .foregroundStyle(.white)
                                }
                                .offset(x: 8, y: -8)
                        }
                    }
                }
            }
        }
        .task {
            // Initial load
            await loadFriends()
            await loadPendingRequests()
            cloudManager.setAuthManager(authManager)
        }
    }
    
    // MARK: - Search Users View
    private var searchUsersView: some View {
        List {
            ForEach(searchResults) { user in
                NavigationLink {
                    UserProfileView(
                        profile: UserProfileContent(
                            username: user.username,
                            displayName: user.displayName
                        ),
                        userId: user.id
                    )
                    .environmentObject(authManager)
                } label: {
                    UserRow(user: user, isFriend: friends.contains { $0.userId == user.id })
                }
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $query, prompt: "Search username")
        .onChange(of: query) { _, newValue in
            if newValue.count >= 2 {
                Task {
                    await searchUsers()
                }
            } else {
                searchResults = []
            }
        }
        .overlay {
            if isSearching {
                ProgressView()
            } else if query.isEmpty {
                ContentUnavailableView(
                    "Search for Users",
                    systemImage: "magnifyingglass",
                    description: Text("Enter a username to find users")
                )
            } else if searchResults.isEmpty && !query.isEmpty {
                ContentUnavailableView(
                    "No Results",
                    systemImage: "person.slash",
                    description: Text("No users found matching '\(query)'")
                )
            }
        }
    }
    
    // MARK: - Friends View
    private var friendsView: some View {
        List {
            let filteredFriends = query.isEmpty ? friends : friends.filter { friend in
                (friend.displayName?.localizedCaseInsensitiveContains(query) ?? false) ||
                (friend.username?.localizedCaseInsensitiveContains(query) ?? false)
            }
            
            if filteredFriends.isEmpty && !isLoadingFriends {
                ContentUnavailableView(
                    query.isEmpty ? "No Friends" : "No Results",
                    systemImage: query.isEmpty ? "person.2.fill" : "magnifyingglass",
                    description: Text(query.isEmpty ? "Start adding friends to see them here" : "No friends found matching '\(query)'")
                )
            } else {
                ForEach(filteredFriends) { friend in
                    NavigationLink {
                        UserProfileView(
                            profile: UserProfileContent(
                                username: friend.username ?? "unknown",
                                displayName: friend.displayName ?? "Unknown"
                            ),
                            userId: friend.userId
                        )
                        .environmentObject(authManager)
                    } label: {
                        FriendRow(friend: friend)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $query, prompt: "Search friends")
        .refreshable {
            await loadFriends()
        }
        .overlay {
            if isLoadingFriends {
                ProgressView()
            }
        }
    }
    
    // MARK: - Add Friends View
    private var addFriendsView: some View {
        List {
            // Pending requests section
            if !pendingRequests.isEmpty {
                Section {
                    ForEach(pendingRequests) { request in
                        UserRowWithAction(
                            displayName: request.displayName ?? "Unknown",
                            username: request.username ?? "unknown",
                            actionLabel: "Accept",
                            actionColor: .green,
                            action: {
                                Task {
                                    await acceptFriendRequest(request)
                                }
                            }
                        )
                    }
                } header: {
                    Text("Pending Requests (\(pendingRequests.count))")
                }
            }
            
            // Search results section
            Section {
                if isSearching {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding()
                } else if searchResults.isEmpty && query.isEmpty {
                    ContentUnavailableView(
                        "Search for Friends",
                        systemImage: "magnifyingglass",
                        description: Text("Enter a username to find friends")
                    )
                } else if searchResults.isEmpty && !query.isEmpty {
                    ContentUnavailableView(
                        "No Results",
                        systemImage: "person.slash",
                        description: Text("No users found matching '\(query)'")
                    )
                } else {
                    ForEach(searchResults) { user in
                        // Check if already friend or pending
                        let isFriend = friends.contains { $0.userId == user.id }
                        let isPending = pendingRequests.contains { $0.userId == user.id }
                        
                        if !isFriend && !isPending {
                            UserRowWithAction(
                                displayName: user.displayName,
                                username: user.username,
                                actionLabel: "Add Friend",
                                actionColor: primaryTint,
                                action: {
                                    Task {
                                        await sendFriendRequest(to: user.id)
                                    }
                                }
                            )
                        }
                    }
                }
            } header: {
                if !searchResults.isEmpty {
                    Text("Search Results")
                }
            }
            
            // Message section
            if !message.isEmpty {
                Section {
                    Text(message)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $query, prompt: "Search users to add")
        .onChange(of: query) { _, newValue in
            if newValue.count >= 2 {
                Task {
                    await searchUsers()
                }
            } else {
                searchResults = []
            }
        }
        .refreshable {
            await loadPendingRequests()
        }
    }
    
    // MARK: - Helper Functions
    private func searchUsers() async {
        guard query.count >= 2 else {
            searchResults = []
            return
        }
        
        isSearching = true
        message = ""
        
        do {
            searchResults = try await cloudManager.searchUsers(query: query)
        } catch {
            message = "Search failed: \(error.localizedDescription)"
            searchResults = []
        }
        
        isSearching = false
    }
    
    private func loadFriends() async {
        isLoadingFriends = true
        
        do {
            friends = try await cloudManager.getFriends()
        } catch {
            print("❌ Failed to load friends: \(error)")
        }
        
        isLoadingFriends = false
    }
    
    private func loadPendingRequests() async {
        isLoadingRequests = true
        
        do {
            pendingRequests = try await cloudManager.getPendingFriendRequests()
        } catch {
            print("❌ Failed to load pending requests: \(error)")
        }
        
        isLoadingRequests = false
    }
    
    private func sendFriendRequest(to userId: String) async {
        do {
            try await cloudManager.sendFriendRequest(to: userId)
            message = "Friend request sent!"
            // Refresh pending requests
            await loadPendingRequests()
            // Remove from search results if it was there
            searchResults.removeAll { $0.id == userId }
        } catch {
            message = "Failed to send request: \(error.localizedDescription)"
        }
    }
    
    private func acceptFriendRequest(_ request: FriendRequest) async {
        do {
            try await cloudManager.acceptFriendRequest(from: request.userId)
            message = "Friend request accepted!"
            // Refresh both lists
            await loadPendingRequests()
            await loadFriends()
        } catch {
            message = "Failed to accept request: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Subviews
    private struct UserRow: View {
        let user: UserProfile
        let isFriend: Bool
        
        private let avatarSize: CGFloat = Constants.smallIconSize
        private let primaryTint = Constants.mainAppTheme
        private let rowSpacing = Constants.customLabelPadding * 2
        
        var body: some View {
            HStack(spacing: rowSpacing) {
                Circle()
                    .fill(primaryTint.opacity(0.2))
                    .frame(width: avatarSize, height: avatarSize)
                    .overlay {
                        Image(systemName: "person.fill")
                            .foregroundStyle(primaryTint)
                    }
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.displayName)
                        .font(.headline)
                    Text("@\(user.username)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if isFriend {
                        Text("Friend")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
                }
            }
        }
    }
    
    private struct FriendRow: View {
        let friend: Friend
        
        private let avatarSize: CGFloat = Constants.smallIconSize
        private let primaryTint = Constants.mainAppTheme
        private let rowSpacing = Constants.customLabelPadding * 2
        
        var body: some View {
            HStack(spacing: rowSpacing) {
                Circle()
                    .fill(primaryTint.opacity(0.2))
                    .frame(width: avatarSize, height: avatarSize)
                    .overlay {
                        Image(systemName: "person.fill")
                            .foregroundStyle(primaryTint)
                    }
                VStack(alignment: .leading, spacing: 4) {
                    Text(friend.displayName ?? "Unknown")
                        .font(.headline)
                    Text("@\(friend.username ?? "unknown")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let bio = friend.bio, !bio.isEmpty {
                        Text(bio)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
            }
        }
    }
    
    private struct UserRowWithAction: View {
        let displayName: String
        let username: String
        let actionLabel: String
        let actionColor: Color
        let action: () -> Void
        
        private let avatarSize: CGFloat = Constants.smallIconSize
        private let primaryTint = Constants.mainAppTheme
        private let rowSpacing = Constants.customLabelPadding * 2
        
        var body: some View {
            HStack(spacing: rowSpacing) {
                Circle()
                    .fill(primaryTint.opacity(0.2))
                    .frame(width: avatarSize, height: avatarSize)
                    .overlay {
                        Image(systemName: "person.fill")
                            .foregroundStyle(primaryTint)
                    }
                VStack(alignment: .leading, spacing: 2) {
                    Text(displayName)
                        .font(.headline)
                    Text("@\(username)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: action) {
                    Text(actionLabel)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(actionColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(actionColor.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
    }
}




