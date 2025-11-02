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
    var filteredWorkouts: [String] {
        guard !query.isEmpty else { return mockWorkouts }
        return mockWorkouts.filter { $0.localizedCaseInsensitiveContains(query) }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Categories")
                    .font(.headline)
                    .padding(.horizontal)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                                .font(.subheadline.weight(.medium))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.12)))
                        }
                    }
                    .padding(.horizontal)
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("Workouts")
                        .font(.headline)
                        .padding(.horizontal)
                    ForEach(filteredWorkouts, id: \.self) { workout in
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.15))
                                .frame(width: 56, height: 56)
                                .overlay { Image(systemName: "dumbbell").font(.headline) }
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


