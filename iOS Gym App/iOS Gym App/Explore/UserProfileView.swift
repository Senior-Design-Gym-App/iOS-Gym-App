//
//  UserProfileView.swift
//  iOS Gym App
//
//  Created by 鄭承典 on 11/4/25.
//
import SwiftUI
import UIKit

struct UserProfileView: View {
    @State private var username: String = "Demo User"
    @State private var displayName: String = "demo_user"
    @State private var coverImage: UIImage? = nil
    @State private var profileImage: UIImage? = nil
    @State private var bio: String = "Love training and tracking progress."
    @State private var location: String = "San Francisco, CA"
    
    init(username: String = "Demo User", displayName: String = "demo_user") {
        _username = State(initialValue: username)
        _displayName = State(initialValue: displayName)
    }
    private let stats: [(String, String)] = [("Workouts", "124"), ("Followers", "1.2k"), ("Following", "180")]
    private let recentWorkouts: [String] = ["Push Day A", "Legs A", "Upper Power"]

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
        .navigationTitle("@\(displayName)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    AccountEditView(
                        coverImage: $coverImage,
                        profileImage: $profileImage,
                        username: $username,
                        displayName: $displayName,
                        bio: $bio,
                        location: $location
                    )
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
    }

    // MARK: - Sections
    private var cover: some View {
        ZStack(alignment: .bottomLeading) {
            ZStack {
                if let coverImage = coverImage {
                    Image(uiImage: coverImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 140)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 140)
                }
                LinearGradient(colors: [.black.opacity(0.2), .black.opacity(0.05)], startPoint: .top, endPoint: .bottom)
            }
            .frame(height: 140)
            HStack(alignment: .bottom, spacing: 16) {
                ZStack {
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Circle()
                            .fill(Color(.systemGray6))
                    }
                }
                .frame(width: 96, height: 96)
                .clipShape(Circle())
                .overlay {
                    if profileImage == nil {
                        Image(systemName: "person.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.secondary)
                    }
                }
                .offset(y: 48)
                VStack(alignment: .leading, spacing: 6) {
                    Text(username)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                    Text(bio)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
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
                Text(location)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            // Follow button only shown when viewing other users' profiles
            // Removed for now - can be added back when implementing social features

            HStack(spacing: 12) {
                ForEach(stats, id: \.0) { label, value in
                    VStack {
                        Text(value)
                            .font(.headline)
                        Text(label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color(.systemGray6)))
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.systemBackground)))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color(.separator)))
        .padding(.horizontal)
    }

    private var recent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Workouts")
                .font(.headline)
            ForEach(recentWorkouts, id: \.self) { workout in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
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
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color(.systemGray6)))
            }
        }
    }
}

