//
//  ExploreView.swift
//  iOS Gym App
//
//  Created by Aaron on 10/23/25.
//

import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ExploreGrid()
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .navigationTitle("Explore")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: { GlobalSearchView() }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
        }
    }
}

private struct ExploreGrid: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var currentUserProfile: UserProfileContent = .demo
    @State private var isLoadingProfile = false
    private let cardSpacing = Constants.customLabelPadding * 2
    
    private let cloudManager = CloudManager.shared
    
    var body: some View {
        VStack(spacing: cardSpacing) {
            NavigationLink(destination: { 
                UserProfileView(
                    profile: currentUserProfile,
                    userId: authManager.currentUser
                )
                .environmentObject(authManager)
            }, label: {
                ExploreCard(title: "View Profile", subtitle: "My profile", systemImage: "person.crop.circle")
            })
            NavigationLink(destination: { 
                UserSearchView()
                    .environmentObject(authManager)
            }, label: {
                ExploreCard(title: "Users", subtitle: "Find people", systemImage: "person.2.fill")
            })
            NavigationLink(destination: { CloudWorkoutsView() }, label: {
                ExploreCard(title: "Workouts", subtitle: "Discover plans", systemImage: "dumbbell.fill")
            })
            NavigationLink(destination: { AIAskView() }, label: {
                ExploreCard(title: "Ask AI", subtitle: "Get guidance", systemImage: "sparkles")
            })
//            NavigationLink(destination: { AccountCreateView() }, label: {
//                ExploreCard(title: "Create Account", subtitle: "Join now", systemImage: "person.badge.plus.fill")
//            })
        }
        .task {
            await loadCurrentUserProfile()
        }
        .onAppear {
            cloudManager.setAuthManager(authManager)
            // Reload profile when view appears (e.g., returning from other tabs)
            Task {
                await loadCurrentUserProfile()
            }
        }
    }
    
    private func loadCurrentUserProfile() async {
        guard authManager.isAuthenticated else {
            // If not authenticated, use demo profile
            currentUserProfile = .demo
            return
        }
        
        isLoadingProfile = true
        
        // First, load from local storage (UserDefaults) - this is the most recent
        loadFromUserDefaults()
        
        // Get timestamp of local data
        let localLastUpdated = UserDefaults.standard.double(forKey: "userProfileLastUpdated")
        let hasLocalData = localLastUpdated > 0
        
        // Try to load from cloud
        do {
            let userProfile = try await cloudManager.getCurrentUserProfile()
            let cloudProfile = UserProfileContent(from: userProfile)
            
            // Only use cloud data if we don't have local data, or if local data is older
            // (In practice, we'll prioritize local data since it's what the user just saved)
            if !hasLocalData {
                // No local data, use cloud data
                currentUserProfile = cloudProfile
                // Save cloud data to UserDefaults as backup
                UserDefaults.standard.set(currentUserProfile.displayName, forKey: "userProfileName")
                UserDefaults.standard.set(currentUserProfile.username, forKey: "userProfileDisplayName")
                UserDefaults.standard.set(currentUserProfile.bio, forKey: "userProfileBio")
                UserDefaults.standard.set(currentUserProfile.location, forKey: "userProfileLocation")
            } else {
                // We have local data, keep it (it's more recent)
                // But update stats and other fields from cloud if needed
                currentUserProfile.stats = cloudProfile.stats
                print("ℹ️ Using local profile data (more recent than cloud)")
            }
        } catch {
            print("❌ Failed to load user profile from cloud: \(error)")
            // If cloud load fails, we already have local data loaded, so just continue
            if !hasLocalData {
                // No local data and cloud failed, use demo
                currentUserProfile = .demo
            }
        }
        
        // Always load images from Keychain (they persist locally)
        if let profileImageData = KeychainHelper.standard.retrieveData(key: "userProfileImage"),
           let image = UIImage(data: profileImageData) {
            currentUserProfile.profileImage = image
        }
        
        if let coverImageData = KeychainHelper.standard.retrieveData(key: "userCoverImage"),
           let image = UIImage(data: coverImageData) {
            currentUserProfile.coverImage = image
        }
        
        isLoadingProfile = false
    }
    
    private func loadFromUserDefaults() {
        // Load from UserDefaults backup (local storage - most recent)
        if let savedName = UserDefaults.standard.string(forKey: "userProfileName"), !savedName.isEmpty {
            currentUserProfile.displayName = savedName
        }
        if let savedUsername = UserDefaults.standard.string(forKey: "userProfileDisplayName"), !savedUsername.isEmpty {
            currentUserProfile.username = savedUsername
        }
        if let savedBio = UserDefaults.standard.string(forKey: "userProfileBio") {
            currentUserProfile.bio = savedBio
        }
        if let savedLocation = UserDefaults.standard.string(forKey: "userProfileLocation") {
            currentUserProfile.location = savedLocation
        }
        
        // Load images from Keychain
        if let profileImageData = KeychainHelper.standard.retrieveData(key: "userProfileImage"),
           let image = UIImage(data: profileImageData) {
            currentUserProfile.profileImage = image
        }
        
        if let coverImageData = KeychainHelper.standard.retrieveData(key: "userCoverImage"),
           let image = UIImage(data: coverImageData) {
            currentUserProfile.coverImage = image
        }
        
        // Only use demo if no saved data exists
        if currentUserProfile.displayName.isEmpty && currentUserProfile.username.isEmpty {
            currentUserProfile = .demo
        }
    }
}

private struct ExploreCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    
    private let cardCornerRadius = Constants.homeRadius
    private let cardPadding: CGFloat = 20
    private let cardHeight: CGFloat = 100
    private let iconSize: CGFloat = 28
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: systemImage)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundStyle(.primary)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(Color(.systemGray5))
                )
            
            // Text content
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .padding(.horizontal, cardPadding)
        .background(
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .fill(Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }
}



#Preview {
    ExploreView()
}
