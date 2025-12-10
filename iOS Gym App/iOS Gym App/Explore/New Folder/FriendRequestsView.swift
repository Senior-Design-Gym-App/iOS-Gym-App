//
//  FriendRequestsView.swift
//  iOS Gym App
//
//  Created by Zachary Andrew Kolano on 12/9/25.
//


import SwiftUI

struct FriendRequestsView: View {
    @State private var pendingRequests: [FriendRequest] = []
    @State private var isLoading = false
    
    var body: some View {
        List {
            ForEach(pendingRequests) { request in
                HStack {
                    VStack(alignment: .leading) {
                        Text(request.displayName ?? "Unknown")
                            .font(.headline)
                        Text("@\(request.username ?? "unknown")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        Task {
                            await acceptRequest(request)
                        }
                    } label: {
                        Text("Accept")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .navigationTitle("Friend Requests")
        .overlay {
            if isLoading {
                ProgressView()
            } else if pendingRequests.isEmpty {
                ContentUnavailableView(
                    "No Pending Requests",
                    systemImage: "person.2.slash",
                    description: Text("You're all caught up!")
                )
            }
        }
        .refreshable {
            await loadRequests()
        }
        .task {
            await loadRequests()
        }
    }
    
    private func loadRequests() async {
        isLoading = true
        
        do {
            pendingRequests = try await CloudManager.shared.getPendingFriendRequests()
        } catch {
            print("Failed to load requests: \(error)")
        }
        
        isLoading = false
    }
    
    private func acceptRequest(_ request: FriendRequest) async {
        do {
            try await CloudManager.shared.acceptFriendRequest(from: request.userId)
            await loadRequests() // Refresh list
        } catch {
            print("Failed to accept request: \(error)")
        }
    }
}
