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
    @State private var demoProfile = UserProfileContent.demo
    private let gridSpacing = Constants.customLabelPadding * 3
    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: gridSpacing),
            GridItem(.flexible(), spacing: gridSpacing)
        ]
    }
    var body: some View {
        LazyVGrid(columns: columns, spacing: gridSpacing) {
            NavigationLink(destination: { UserProfileView(profile: demoProfile) }, label: {
                ExploreCard(title: "View Profile", subtitle: "Sample profile", systemImage: "person.crop.circle")
            })
            NavigationLink(destination: { UserSearchView() }, label: {
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
    }
}

private struct ExploreCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    
    private let cardCornerRadius = Constants.homeRadius
    private let cardPadding: CGFloat = 16
    private let cardHeight: CGFloat = 120
    private let iconSize: CGFloat = 32
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundStyle(.primary)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .padding(cardPadding)
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



