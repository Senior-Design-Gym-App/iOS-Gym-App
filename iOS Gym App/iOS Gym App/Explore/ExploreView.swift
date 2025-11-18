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
        ReusedViews.Labels.Header(text: title)
            .font(.largeTitle.weight(.bold))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ExploreGrid: View {
    @State private var demoProfile = UserProfileContent.demo
    private let gridSpacing = Constants.customLabelPadding * 3
    private var columns: [GridItem] { [GridItem(.flexible(), spacing: gridSpacing)] }
    var body: some View {
        LazyVGrid(columns: columns, spacing: gridSpacing) {
            NavigationLink(destination: { UserProfileView(profile: demoProfile) }, label: {
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
    
    private let cardCornerRadius = Constants.homeRadius
    private let cardPadding = Constants.bigImagePadding
    private let cardHeight: CGFloat = 140
    private let iconFrame: CGFloat = Constants.smallIconSize + 10
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .fill(Color(.systemGray6))
                .frame(height: cardHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                        .stroke(Color(.separator), lineWidth: 1)
                )
            HStack(spacing: Constants.customLabelPadding * 3) {
                Image(systemName: systemImage)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(width: iconFrame, height: iconFrame)
                VStack(alignment: .leading, spacing: Constants.customLabelPadding + 1) {
                    Text(title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(cardPadding)
        }
    }
}


