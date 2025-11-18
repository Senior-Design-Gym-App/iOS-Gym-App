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
    
    private let avatarSize: CGFloat = Constants.smallIconSize
    private let primaryTint = Constants.mainAppTheme
    private let rowSpacing = Constants.customLabelPadding * 2
    
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
                    HStack(spacing: rowSpacing) {
                        Circle()
                            .fill(primaryTint.opacity(0.2))
                            .frame(width: avatarSize, height: avatarSize)
                            .overlay {
                                Image(systemName: "person.fill")
                                    .foregroundStyle(primaryTint)
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



