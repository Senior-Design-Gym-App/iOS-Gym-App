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
    @State private var recentWorkouts: [Workout] = []
    @State private var isLoadingWorkouts = false
    @State private var selectedWorkout: Workout? = nil
    @State private var showWorkoutDetail = false
    
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
            // Reload from cloud when profile changes
            Task {
                await loadProfileFromCloud()
            }
        }
        .sheet(item: $selectedWorkout) { workout in
            NavigationStack {
                WorkoutDetailView(workout: workout)
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
            Text(isOwnProfile ? "Recent Workouts" : "Public Workouts")
                .font(.headline)
            
            if isLoadingWorkouts {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else if recentWorkouts.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text(isOwnProfile ? "No recent workouts" : "No public workouts")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            } else {
                ForEach(recentWorkouts, id: \.id) { workout in
                    Button {
                        selectedWorkout = workout
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: Constants.customLabelPadding * 2) {
                                // Use workout color if available
                                RoundedRectangle(cornerRadius: statCardCornerRadius, style: .continuous)
                                    .fill(workout.color)
                                    .frame(width: 56, height: 56)
                                    .overlay {
                                        Image(systemName: "dumbbell")
                                            .foregroundStyle(.white)
                                    }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(workout.name)
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(.primary)
                                    
                                    if let exercises = workout.exercises, !exercises.isEmpty {
                                        Text("\(exercises.count) exercise\(exercises.count == 1 ? "" : "s")")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                            
                            // Muscle group tags
                            if !workout.tags.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 6) {
                                        ForEach(workout.tags, id: \.self) { tag in
                                            Text(tag.rawValue)
                                                .font(.caption2)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(tag.colorPalette.opacity(0.2))
                                                .foregroundStyle(tag.colorPalette)
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: recentCardCornerRadius, style: .continuous)
                                .fill(Color(.systemGray6))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func loadProfileIfNeeded() {
        guard !hasLoadedProfile else { return }
        currentProfile = profile
        
        // Load profile from cloud
        Task {
            await loadProfileFromCloud()
        }
        
        hasLoadedProfile = true
    }
    
    private func loadProfileFromCloud() async {
        print("🔍 loadProfileFromCloud called")
        
        let cloudManager = CloudManager.shared
        cloudManager.setAuthManager(authManager)
        
        isLoadingWorkouts = true
        
        do {
            print("🔍 Determining which profile to load...")
            print("   isOwnProfile: \(isOwnProfile)")
            print("   userId parameter: \(userId ?? "nil")")
            
            // Determine which profile to load
            let userProfile: UserProfile
            let profileUserId: String
            
            if isOwnProfile {
                // Load own profile
                print("📤 Loading own profile...")
                userProfile = try await cloudManager.getCurrentUserProfile()
                profileUserId = try await cloudManager.getCurrentUserId()
                print("✅ Loaded own profile - userId: \(profileUserId)")
            } else if let userId = userId {
                // Load friend's profile by userId
                print("📤 Loading friend's profile for userId: \(userId)")
                userProfile = try await cloudManager.getUserProfile(userId: userId)
                profileUserId = userId
                print("✅ Loaded friend's profile - userId: \(profileUserId)")
            } else {
                print("❌ No userId provided for friend profile")
                isLoadingWorkouts = false
                return
            }
            
            print("📊 Profile info:")
            print("   Username: \(userProfile.username)")
            print("   Display name: \(userProfile.displayName)")
            
            // Get accurate public workout count and recent workouts in one call
            print("📤 Fetching public workouts info...")
            let workoutsInfo = try await cloudManager.getPublicWorkoutsInfo(for: profileUserId)
            let publicWorkoutCount = workoutsInfo.count
            let fetchedRecentWorkouts = workoutsInfo.recentWorkouts
            
            print("✅ Public workout count: \(publicWorkoutCount)")
            print("✅ Recent workouts fetched: \(fetchedRecentWorkouts.count)")
            
            // Get friend count
            print("📤 Fetching friends list...")
            let friends = try await cloudManager.getFriends()
            let friendCount = friends.count
            print("✅ Friend count: \(friendCount)")
            
            // Create profile content with accurate stats
            var cloudProfile = UserProfileContent(from: userProfile)
            
            // Update stats with accurate counts
            if isOwnProfile {
                // For own profile, show total workouts and public workouts
                cloudProfile.stats = [
                    ("Workouts", "\(publicWorkoutCount)"),
                    ("Public", "\(publicWorkoutCount)"),
                    ("Friends", "\(friendCount)")
                ]
                print("📊 Own profile stats updated: \(cloudProfile.stats)")
            } else {
                // For other users, only show public workouts
                cloudProfile.stats = [
                    ("Workouts", "\(publicWorkoutCount)"),
                    ("Followers", "\(userProfile.followers)"),
                    ("Following", "\(userProfile.following)")
                ]
                print("📊 Friend profile stats updated: \(cloudProfile.stats)")
            }
            
            // Load images from Keychain (only for own profile)
            if isOwnProfile {
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
            } else {
                // For friends, use cloud profile images
                currentProfile.profileImage = cloudProfile.profileImage
                currentProfile.coverImage = cloudProfile.coverImage
            }
            
            // Update other fields from cloud
            currentProfile.username = cloudProfile.username
            currentProfile.displayName = cloudProfile.displayName
            currentProfile.bio = cloudProfile.bio
            currentProfile.stats = cloudProfile.stats
            
            print("✅ Profile updated, setting workouts...")
            
            // Set the recent workouts we already fetched
            if isOwnProfile {
                // For own profile, still fetch using fetchMyWorkouts to get all workouts
                await loadRecentWorkouts(cloudManager: cloudManager, profileUserId: profileUserId)
            } else {
                // For friend's profile, use the workouts we already fetched
                recentWorkouts = fetchedRecentWorkouts
                print("✅ Set \(recentWorkouts.count) recent workouts for friend profile")
                for (index, workout) in recentWorkouts.enumerated() {
                    print("   Workout \(index + 1): \(workout.name)")
                }
                isLoadingWorkouts = false
            }
            
        } catch {
            print("❌ Failed to load profile from cloud: \(error)")
            isLoadingWorkouts = false
        }
    }
    
    private func loadRecentWorkouts(cloudManager: CloudManager, profileUserId: String) async {
        print("🔍 loadRecentWorkouts called")
        print("   isOwnProfile: \(isOwnProfile)")
        print("   profileUserId: \(profileUserId)")
        
        do {
            let workouts: [Workout]
            
            if isOwnProfile {
                // Load own workouts (both public and private)
                print("📤 Fetching own workouts...")
                workouts = try await cloudManager.fetchMyWorkouts()
                print("✅ Fetched \(workouts.count) own workouts")
            } else {
                // Load friend's public workouts only using the profileUserId
                print("📤 Fetching public workouts for user: \(profileUserId)")
                workouts = try await cloudManager.fetchUserPublicWorkouts(userId: profileUserId)
                print("✅ Fetched \(workouts.count) public workouts")
            }
            
            // Get the 3 most recent workouts
            recentWorkouts = Array(workouts.prefix(3))
            print("✅ Loaded \(recentWorkouts.count) recent workouts for user \(profileUserId)")
            
            // Print workout names for debugging
            for (index, workout) in recentWorkouts.enumerated() {
                print("   Workout \(index + 1): \(workout.name)")
            }
            
        } catch {
            print("❌ Failed to load recent workouts: \(error)")
            recentWorkouts = []
        }
        
        isLoadingWorkouts = false
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

// MARK: - Workout Detail View
struct WorkoutDetailView: View {
    let workout: Workout
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Circle()
                            .fill(workout.color)
                            .frame(width: 32, height: 32)
                            .overlay {
                                Image(systemName: "dumbbell")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white)
                            }
                        Text(workout.name)
                            .font(.title2.bold())
                    }
                    
                    if let exercises = workout.exercises {
                        Text("\(exercises.count) exercise\(exercises.count == 1 ? "" : "s")")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Muscle group tags
                    if !workout.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(workout.tags, id: \.self) { tag in
                                    Text(tag.rawValue)
                                        .font(.caption2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(tag.colorPalette.opacity(0.2))
                                        .foregroundStyle(tag.colorPalette)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section("Exercises") {
                if let exercises = workout.exercises {
                    ForEach(Array(exercises.enumerated()), id: \.offset) { index, exercise in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("\(index + 1).")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 20, alignment: .leading)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(exercise.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    HStack(spacing: 12) {
                                        if let muscle = exercise.muscleWorked {
                                            Label(muscle, systemImage: "figure.arms.open")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        if let equipment = exercise.equipment {
                                            Label(equipment, systemImage: "dumbbell")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                            
                            // Show set data from most recent session
                            let setData = exercise.recentSetData.setData
                            if !setData.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 4) {
                                        ForEach(Array(setData.enumerated()), id: \.offset) { setIndex, set in
                                            VStack(spacing: 2) {
                                                Text("Set \(setIndex + 1)")
                                                    .font(.caption2)
                                                    .foregroundStyle(.secondary)
                                                
                                                Text("\(set.reps) × \(Int(set.weight))\(exercise.equipment ?? "lbs")")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                                
                                                Text("\(set.rest)s rest")
                                                    .font(.caption2)
                                                    .foregroundStyle(.secondary)
                                            }
                                            .padding(6)
                                            .background(Color(.systemGray6))
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Workout Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
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
        // Location removed - no longer used
        self.location = ""
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
