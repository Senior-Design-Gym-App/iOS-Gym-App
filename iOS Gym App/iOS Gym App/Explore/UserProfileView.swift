//
//  UserProfileView.swift
//  iOS Gym App
//
//  Created by 鄭承典 on 11/4/25.
//

import SwiftUI

struct UserProfileView: View {
    let username: String
    var isCurrentUser: Bool = false
    @State private var isFollowing: Bool = false
    private let bio: String = "Love training and tracking progress."
    private let location: String = "San Francisco, CA"
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
        .navigationTitle("@\(username)")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections
    private var cover: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [.black.opacity(0.2), .black.opacity(0.05)], startPoint: .top, endPoint: .bottom)
                .background(
                    Rectangle()
                        .fill(Color(.systemGray5))
                )
                .frame(height: 140)
            HStack(alignment: .bottom, spacing: 16) {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 96, height: 96)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.secondary)
                    }
                    .offset(y: 48)
                VStack(alignment: .leading, spacing: 6) {
                    Text(username)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(bio)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
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

            if !isCurrentUser {
                HStack(spacing: 12) {
                    Button(isFollowing ? "Following" : "Follow") { withAnimation(.spring()) { isFollowing.toggle() } }
                        .buttonStyle(.borderedProminent)
                    Spacer()
                }
            }

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
