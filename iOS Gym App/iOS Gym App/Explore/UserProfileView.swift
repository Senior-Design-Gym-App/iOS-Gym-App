//
//  UserProfileView.swift
//  iOS Gym App
//
//  Created by 鄭承典 on 11/4/25.
//

import SwiftUI
import UIKit

struct UserProfileView: View {
    var profile: UserProfileContent = .demo
    var userId: String? = nil  // Optional: ID of the profile being viewed

    @EnvironmentObject var authManager: AuthManager
    @State private var currentProfile: UserProfileContent = .empty
    @State private var hasLoadedProfile = false
    @State private var showProfilePreview = false
    @State private var showCoverPreview = false
    
    private let bannerHeight: CGFloat = 140
    private let avatarSize: CGFloat = Constants.mediumIconSize
    private let infoCornerRadius = Constants.cornerRadius + 2
    private let cardCornerRadius = Constants.homeRadius
    private let statCardCornerRadius = Constants.cornerRadius
    private let recentCardCornerRadius = Constants.cornerRadius + 2
    private let horizontalSpacing = Constants.customLabelPadding * 3

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                cover
                profileCard
                recent
                    .padding(.horizontal)
                    .padding(.top, 16)
            }
        }
        .navigationTitle("@\(currentProfile.username)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Only show edit button if viewing own profile
            if isOwnProfile {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        AccountEditView(
                            profile: $currentProfile
                        )
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .onAppear(perform: loadProfileIfNeeded)
        .onChange(of: profile, initial: false) { _, newValue in
            currentProfile = newValue
            // If viewing own profile, reload from cloud to get latest data
            if isOwnProfile && authManager.isAuthenticated {
                Task {
                    await loadOwnProfileFromCloud()
                }
            }
        }
        .fullScreenCover(isPresented: $showProfilePreview) {
            ZStack {
                Color.black.ignoresSafeArea()
                if let profileImage = currentProfile.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFit()
                        .background(Color.black)
                        .ignoresSafeArea()
                }
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { showProfilePreview = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.9))
                        }
                    }
                    .padding()
                    Spacer()
                }
            }
        }
        .fullScreenCover(isPresented: $showCoverPreview) {
            ZStack {
                Color.black.ignoresSafeArea()
                if let coverImage = currentProfile.coverImage {
                    Image(uiImage: coverImage)
                        .resizable()
                        .scaledToFit()
                        .background(Color.black)
                        .ignoresSafeArea()
                }
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { showCoverPreview = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.9))
                        }
                    }
                    .padding()
                    Spacer()
                }
            }
        }
    }

    // MARK: - Sections
    private var cover: some View {
        ZStack(alignment: .bottomLeading) {
            ZStack {
                if let coverImage = currentProfile.coverImage {
                    Image(uiImage: coverImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: bannerHeight)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: bannerHeight)
                }
                LinearGradient(colors: [.black.opacity(0.2), .black.opacity(0.05)], startPoint: .top, endPoint: .bottom)
            }
            .frame(height: bannerHeight)
            .contentShape(Rectangle())
            .onLongPressGesture {
                if currentProfile.coverImage != nil {
                    showCoverPreview = true
                }
            }
            HStack(alignment: .bottom, spacing: horizontalSpacing) {
                ZStack {
                    if let profileImage = currentProfile.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Circle()
                            .fill(Color(.systemGray6))
                    }
                }
                .frame(width: avatarSize, height: avatarSize)
                .clipShape(Circle())
                .overlay {
                    if currentProfile.profileImage == nil {
                        Image(systemName: "person.fill")
                            .font(.system(size: avatarSize / 2.2))
                            .foregroundStyle(.secondary)
                    }
                }
                .contentShape(Circle())
                .onLongPressGesture {
                    if currentProfile.profileImage != nil {
                        showProfilePreview = true
                    }
                }
                .offset(y: 48)
                VStack(alignment: .leading, spacing: 6) {
                    Text(currentProfile.displayName)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                    Text(currentProfile.bio)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: infoCornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .opacity(0.7)
                )
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .padding(.bottom, 48)
    }

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundStyle(.secondary)
                Text(currentProfile.location)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            // Follow button only shown when viewing other users' profiles
            // Removed for now - can be added back when implementing social features

            HStack(spacing: 12) {
                ForEach(currentProfile.stats, id: \.0) { label, value in
                    VStack {
                        Text(value)
                            .font(.headline)
                        Text(label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: statCardCornerRadius, style: .continuous)
                            .fill(Color(.systemGray6))
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .stroke(Color(.separator))
        )
        .padding(.horizontal)
    }

    private var recent: some View {
        VStack(alignment: .leading, spacing: Constants.customLabelPadding * 2) {
            Text("Recent Workouts")
                .font(.headline)
            ForEach(currentProfile.recentWorkouts, id: \.self) { workout in
                HStack(spacing: Constants.customLabelPadding * 2) {
                    RoundedRectangle(cornerRadius: statCardCornerRadius, style: .continuous)
                        .fill(Color(.systemGray6))
                        .frame(width: 56, height: 56)
                        .overlay { Image(systemName: "dumbbell").foregroundStyle(.primary) }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(workout)
                            .font(.body.weight(.semibold))
                        Text("Tap to view details")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").foregroundStyle(.secondary)
                }
                .padding(12)
            .background(
                RoundedRectangle(cornerRadius: recentCardCornerRadius, style: .continuous)
                    .fill(Color(.systemGray6))
            )
            }
        }
    }

    private func loadProfileIfNeeded() {
        guard !hasLoadedProfile else { return }
        currentProfile = profile
        
        // If viewing own profile and authenticated, try to load from cloud
        if isOwnProfile && authManager.isAuthenticated {
            Task {
                await loadOwnProfileFromCloud()
            }
        }
        
        hasLoadedProfile = true
    }
    
    private func loadOwnProfileFromCloud() async {
        let cloudManager = CloudManager.shared
        cloudManager.setAuthManager(authManager)
        
        do {
            let userProfile = try await cloudManager.getCurrentUserProfile()
            let cloudProfile = UserProfileContent(from: userProfile)
            
            // Load images from Keychain
            if let profileImageData = KeychainHelper.standard.retrieveData(key: "userProfileImage"),
               let image = UIImage(data: profileImageData) {
                currentProfile.profileImage = image
            } else {
                currentProfile.profileImage = cloudProfile.profileImage
            }
            
            if let coverImageData = KeychainHelper.standard.retrieveData(key: "userCoverImage"),
               let image = UIImage(data: coverImageData) {
                currentProfile.coverImage = image
            } else {
                currentProfile.coverImage = cloudProfile.coverImage
            }
            
            // Update other fields from cloud
            currentProfile.username = cloudProfile.username
            currentProfile.displayName = cloudProfile.displayName
            currentProfile.bio = cloudProfile.bio
            currentProfile.location = cloudProfile.location
            currentProfile.stats = cloudProfile.stats
        } catch {
            print("❌ Failed to load profile from cloud: \(error)")
        }
    }
    
    // Check if viewing own profile
    private var isOwnProfile: Bool {
        // If userId is provided, compare with current user's ID
        if let userId = userId, let currentUserId = authManager.currentUser {
            return userId == currentUserId
        }
        
        // Otherwise, compare username/displayName with current user's attributes
        let currentUsername = authManager.userAttributes["username"] ?? authManager.userAttributes["preferred_username"]
        let currentDisplayName = authManager.userAttributes["name"] ?? authManager.userAttributes["displayName"]
        
        // Check if the profile's username or displayName matches current user
        return currentProfile.username == currentUsername ||
               currentProfile.displayName == currentDisplayName ||
               currentProfile.username == currentDisplayName ||
               currentProfile.displayName == currentUsername
    }
}

struct UserProfileContent: Equatable {
    var username: String = "Demo User"
    var displayName: String = "demo_user"
    var bio: String = "Love training and tracking progress."
    var location: String = "West Lafayette, IN"
    var coverImage: UIImage? = nil
    var profileImage: UIImage? = nil
    var stats: [(String, String)] = [("Workouts", "124"), ("Followers", "1.2k"), ("Following", "180")]
    var recentWorkouts: [String] = ["Push Day A", "Legs A", "Upper Power"]
    var isPrivate: Bool = false

    static var empty: UserProfileContent { UserProfileContent(username: "", displayName: "") }
    static var demo: UserProfileContent { UserProfileContent() }
    
}
extension UserProfileContent {
    init(from backendProfile: UserProfile) {
        self.username = backendProfile.username
        self.displayName = backendProfile.displayName
        self.bio = backendProfile.bio
        self.location = backendProfile.location ?? "Unknown Location"
        self.coverImage = nil      // Will be loaded asynchronously
        self.profileImage = nil    // Will be loaded asynchronously
        self.stats = [
            ("Workouts", "\(backendProfile.workoutCount ?? 0)"),
            ("Followers", "\(backendProfile.followers)"),
            ("Following", "\(backendProfile.following)")
        ]
        self.recentWorkouts = []
        self.isPrivate = !backendProfile.isPublic
    }
    
    // Helper to create UserProfileContent with userId for comparison
    static func from(_ userProfile: UserProfile) -> (content: UserProfileContent, userId: String) {
        return (UserProfileContent(from: userProfile), userProfile.id)
    }
}

extension UserProfileContent {
    static func == (lhs: UserProfileContent, rhs: UserProfileContent) -> Bool {
        lhs.username == rhs.username &&
        lhs.displayName == rhs.displayName &&
        lhs.bio == rhs.bio &&
        lhs.location == rhs.location &&
        imagesEqual(lhs.coverImage, rhs.coverImage) &&
        imagesEqual(lhs.profileImage, rhs.profileImage) &&
        statsEqual(lhs.stats, rhs.stats) &&
        lhs.recentWorkouts == rhs.recentWorkouts &&
        lhs.isPrivate == rhs.isPrivate
    }

    private static func imagesEqual(_ lhs: UIImage?, _ rhs: UIImage?) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil):
            return true
        case let (l?, r?):
            return l === r
        default:
            return false
        }
    }

    private static func statsEqual(
        _ lhs: [(String, String)],
        _ rhs: [(String, String)]
    ) -> Bool {
        guard lhs.count == rhs.count else { return false }
        return zip(lhs, rhs).allSatisfy { left, right in
            left.0 == right.0 && left.1 == right.1
        }
    }
}

