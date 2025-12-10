import SwiftUI

struct AddFriendsView: View {
    @State private var searchQuery = ""
    @State private var searchResults: [UserProfile] = []
    @State private var isSearching = false
    @State private var message = ""
    
    // ADD THESE INSIDE THE STRUCT
    @State private var pendingRequestCount = 0
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(searchResults) { user in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user.displayName)
                                    .font(.headline)
                                Text("@\(user.username)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Button {
                                Task {
                                    await sendFriendRequest(to: user.id)
                                }
                            } label: {
                                Image(systemName: "person.badge.plus")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                } header: {
                    if !searchResults.isEmpty {
                        Text("Results")
                    }
                }
                
                if !message.isEmpty {
                    Section {
                        Text(message)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Add Friends")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        FriendRequestsView()
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "person.badge.clock")
                            
                            if pendingRequestCount > 0 {
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
            .searchable(text: $searchQuery, prompt: "Search by username")
            .onChange(of: searchQuery) { _, newValue in
                if newValue.count >= 2 {
                    Task {
                        await searchUsers()
                    }
                }
            }
            .task {
                await loadPendingCount()
            }
            .overlay {
                if isSearching {
                    ProgressView()
                } else if searchQuery.isEmpty {
                    ContentUnavailableView(
                        "Search for Friends",
                        systemImage: "magnifyingglass",
                        description: Text("Enter a username to find friends")
                    )
                } else if searchResults.isEmpty && !searchQuery.isEmpty {
                    ContentUnavailableView(
                        "No Results",
                        systemImage: "person.slash",
                        description: Text("No users found matching '\(searchQuery)'")
                    )
                }
            }
        }
    }
    
    // FUNCTIONS INSIDE THE STRUCT
    private func searchUsers() async {
        guard searchQuery.count >= 2 else { return }
        
        isSearching = true
        message = ""
        
        do {
            searchResults = try await CloudManager.shared.searchUsers(query: searchQuery)
        } catch {
            message = "Search failed: \(error.localizedDescription)"
        }
        
        isSearching = false
    }
    
    private func sendFriendRequest(to userId: String) async {
        do {
            try await CloudManager.shared.sendFriendRequest(to: userId)
            message = "Friend request sent!"
        } catch {
            message = "Failed to send request: \(error.localizedDescription)"
        }
    }
    
    private func loadPendingCount() async {
        do {
            let requests = try await CloudManager.shared.getPendingFriendRequests()
            pendingRequestCount = requests.count
        } catch {
            print("Failed to load pending count: \(error)")
        }
    }
}
