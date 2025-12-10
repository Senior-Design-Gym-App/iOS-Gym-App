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
    private let cardSpacing = Constants.customLabelPadding * 2
    
    var body: some View {
        VStack(spacing: cardSpacing) {
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
