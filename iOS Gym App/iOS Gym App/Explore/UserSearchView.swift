//
//  UserSearchView.swift
//  iOS Gym App
//
//  Created by 鄭承典 on 11/4/25.
//

import SwiftUI

struct UserSearchView: View {
    @State private var query: String = ""
    private let mockUsers: [String] = ["aaron", "matthew", "troy", "zach"]
    var filteredUsers: [String] {
        guard !query.isEmpty else { return mockUsers }
        return mockUsers.filter { $0.localizedCaseInsensitiveContains(query) }
    }
    var body: some View {
        List {
            ForEach(filteredUsers, id: \.self) { user in
                NavigationLink {
                    UserProfileView(profile: UserProfileContent(username: user.capitalized, displayName: user))
                } label: {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay {
                                Image(systemName: "person.fill")
                            }
                        VStack(alignment: .leading) {
                            Text(user)
                                .font(.headline)
                            Text("Tap to view profile")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Search Users")
        .searchable(text: $query, prompt: "Username")
    }
}



