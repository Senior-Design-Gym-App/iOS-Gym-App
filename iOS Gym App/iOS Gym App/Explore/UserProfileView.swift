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

    @State private var currentProfile: UserProfileContent = .empty
    @State private var hasLoadedProfile = false
    
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
        .navigationTitle("@\(currentProfile.displayName)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
        .onAppear(perform: loadProfileIfNeeded)
        .onChange(of: profile, initial: false) { _, newValue in
            currentProfile = newValue
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
                .offset(y: 48)
                VStack(alignment: .leading, spacing: 6) {
                    Text(currentProfile.username)
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
        hasLoadedProfile = true
    }
}

struct UserProfileContent: Equatable {
    var username: String = "Demo User"
    var displayName: String = "demo_user"
    var bio: String = "Love training and tracking progress."
    var location: String = "San Francisco, CA"
    var coverImage: UIImage? = nil
    var profileImage: UIImage? = nil
    var stats: [(String, String)] = [("Workouts", "124"), ("Followers", "1.2k"), ("Following", "180")]
    var recentWorkouts: [String] = ["Push Day A", "Legs A", "Upper Power"]
    var isPrivate: Bool = false

    static var empty: UserProfileContent { UserProfileContent(username: "", displayName: "") }
    static var demo: UserProfileContent { UserProfileContent() }
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

