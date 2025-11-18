//
//  WorkoutSearchView.swift
//  iOS Gym App
//
//  Created by 鄭承典 on 11/4/25.
//

import SwiftUI

struct WorkoutSearchView: View {
    @State private var query: String = ""
    private let categories: [String] = ["Strength", "Hypertrophy", "Endurance", "Mobility", "Power"]
    private let mockWorkouts: [String] = ["Push Day A", "Pull Day B", "Legs A", "Full-Body Circuit", "Upper Power", "Lower Power", "Mobility Flow"]
    
    private let chipCornerRadius = Constants.cornerRadius
    private let chipSpacing = Constants.customLabelPadding * 2
    private let cardCornerRadius = Constants.cornerRadius + 2
    private let iconSize: CGFloat = 56
    private let primaryTint = Constants.mainAppTheme
    
    var filteredWorkouts: [String] {
        guard !query.isEmpty else { return mockWorkouts }
        return mockWorkouts.filter { $0.localizedCaseInsensitiveContains(query) }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ReusedViews.Labels.Header(text: "Categories")
                    .font(.headline)
                    .padding(.horizontal)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: chipSpacing) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                                .font(.subheadline.weight(.medium))
                                .padding(.vertical, chipSpacing)
                                .padding(.horizontal, Constants.titlePadding * 2)
                                .background(
                                    RoundedRectangle(cornerRadius: chipCornerRadius).fill(Color.secondary.opacity(0.12))
                                )
                        }
                    }
                    .padding(.horizontal)
                }
                VStack(alignment: .leading, spacing: 12) {
                    ReusedViews.Labels.Header(text: "Workouts")
                        .font(.headline)
                        .padding(.horizontal)
                    ForEach(filteredWorkouts, id: \.self) { workout in
                        HStack {
                            RoundedRectangle(cornerRadius: cardCornerRadius)
                                .fill(primaryTint.opacity(0.15))
                                .frame(width: iconSize, height: iconSize)
                                .overlay {
                                    Image(systemName: "dumbbell")
                                        .font(.headline)
                                        .foregroundStyle(primaryTint)
                                }
                            VStack(alignment: .leading) {
                                Text(workout)
                                    .font(.body.weight(.semibold))
                                Text("by Gym Community")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                    }
                }
            }
            .padding(.top)
        }
        .navigationTitle("Search Workouts")
        .searchable(text: $query, prompt: "Workout name")
    }
}



