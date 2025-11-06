//
//  ExploreView.swift
//  iOS Gym App
//
//  Created by Aaron on 10/23/25.
//

import SwiftUI

struct ExploreView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SectionHeader(title: "Explore")
                    ExploreGrid()
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .navigationTitle("")
            .toolbarTitleDisplayMode(.inline)
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

private struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.largeTitle.weight(.bold))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ExploreGrid: View {
    private let columns = [GridItem(.flexible(), spacing: 16)]
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            NavigationLink(destination: { UserProfileView(username: "Demo User", displayName: "demo_user") }, label: {
                ExploreCard(title: "View Profile", subtitle: "Sample profile", systemImage: "person.crop.circle")
            })
            NavigationLink(destination: { UserSearchView() }, label: {
                ExploreCard(title: "Users", subtitle: "Find people", systemImage: "person.2.fill")
            })
            NavigationLink(destination: { WorkoutSearchView() }, label: {
                ExploreCard(title: "Workouts", subtitle: "Discover plans", systemImage: "dumbbell.fill")
            })
            NavigationLink(destination: { AIAskView() }, label: {
                ExploreCard(title: "Ask AI", subtitle: "Get guidance", systemImage: "sparkles")
            })
            NavigationLink(destination: { AccountCreateView() }, label: {
                ExploreCard(title: "Create Account", subtitle: "Join now", systemImage: "person.badge.plus.fill")
            })
        }
    }
}

private struct ExploreCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemGray6))
                .frame(height: 140)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(.separator), lineWidth: 1)
                )
            HStack(spacing: 16) {
                Image(systemName: systemImage)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(width: 60, height: 60)
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(20)
        }
    }
}


