//
//  WorkoutSearchView.swift
//  iOS Gym App
//
//  Created by 鄭承典 on 11/4/25.
//

import SwiftUI
import SwiftData

struct WorkoutSearchView: View {
    @EnvironmentObject var authManager: AuthManager
    @Query(sort: \Workout.name) private var localWorkouts: [Workout]
    
    @State private var query: String = ""
    @State private var selectedMuscleGroups: Set<MuscleGroup> = []
    @State private var cloudWorkouts: [Workout] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchSource: SearchSource = .local
    
    private let cloudManager = CloudManager.shared
    
    private let chipCornerRadius = Constants.cornerRadius
    private let chipSpacing = Constants.customLabelPadding * 2
    private let cardCornerRadius = Constants.cornerRadius + 2
    private let iconSize: CGFloat = 56
    private let primaryTint = Constants.mainAppTheme
    
    enum SearchSource {
        case local
        case cloud
    }
    
    var allWorkouts: [Workout] {
        searchSource == .local ? localWorkouts : cloudWorkouts
    }
    
    var filteredWorkouts: [Workout] {
        var workouts = allWorkouts
        
        // Filter by search query
        if !query.isEmpty {
            workouts = workouts.filter { $0.name.localizedCaseInsensitiveContains(query) }
        }
        
        // Filter by selected muscle groups
        if !selectedMuscleGroups.isEmpty {
            workouts = workouts.filter { workout in
                let workoutTags = Set(workout.tags)
                return !workoutTags.isDisjoint(with: selectedMuscleGroups)
            }
        }
        
        return workouts
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Search source toggle
                Picker("Source", selection: $searchSource) {
                    Text("Local").tag(SearchSource.local)
                    if authManager.isAuthenticated {
                        Text("Cloud").tag(SearchSource.cloud)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: searchSource) { _, newValue in
                    if newValue == .cloud && cloudWorkouts.isEmpty {
                        Task { await fetchCloudWorkouts() }
                    }
                }
                
                // Muscle group filters
                VStack(alignment: .leading, spacing: 12) {
                    ReusedViews.Labels.Header(text: "Filter by Muscle Group")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: chipSpacing) {
                            ForEach(MuscleGroup.allCases.filter { $0 != .general && $0 != .unknown }, id: \.self) { muscleGroup in
                                Button {
                                    if selectedMuscleGroups.contains(muscleGroup) {
                                        selectedMuscleGroups.remove(muscleGroup)
                                    } else {
                                        selectedMuscleGroups.insert(muscleGroup)
                                    }
                                } label: {
                                    Text(muscleGroup.rawValue)
                                        .font(.subheadline.weight(.medium))
                                        .padding(.vertical, chipSpacing)
                                        .padding(.horizontal, Constants.titlePadding * 2)
                                        .background(
                                            RoundedRectangle(cornerRadius: chipCornerRadius)
                                                .fill(selectedMuscleGroups.contains(muscleGroup)
                                                    ? muscleGroup.colorPalette.opacity(0.2)
                                                    : Color.secondary.opacity(0.12))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: chipCornerRadius)
                                                .stroke(selectedMuscleGroups.contains(muscleGroup)
                                                    ? muscleGroup.colorPalette
                                                    : Color.clear, lineWidth: 2)
                                        )
                                        .foregroundStyle(selectedMuscleGroups.contains(muscleGroup)
                                            ? muscleGroup.colorPalette
                                            : .primary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: selectedMuscleGroups) { _, _ in
                        if searchSource == .cloud && authManager.isAuthenticated {
                            Task { await fetchCloudWorkouts() }
                        }
                    }
                    
                    // Clear filters button
                    if !selectedMuscleGroups.isEmpty {
                        Button {
                            selectedMuscleGroups.removeAll()
                            if searchSource == .cloud && authManager.isAuthenticated {
                                Task { await fetchCloudWorkouts() }
                            }
                        } label: {
                            Text("Clear Filters")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Workouts list
                VStack(alignment: .leading, spacing: 12) {
                    ReusedViews.Labels.Header(text: "Workouts (\(filteredWorkouts.count))")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding()
                    } else if filteredWorkouts.isEmpty {
                        ContentUnavailableView(
                            searchSource == .cloud ? "No Cloud Workouts" : "No Local Workouts",
                            systemImage: "dumbbell",
                            description: Text(searchSource == .cloud
                                ? "Try adjusting your filters or search query"
                                : "Create workouts locally first")
                        )
                    } else {
                        ForEach(filteredWorkouts) { workout in
                            WorkoutSearchRow(workout: workout)
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                        }
                    }
                    
                    if let error = errorMessage {
                        Text("Error: \(error)")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.top)
        }
        .navigationTitle("Search Workouts")
        .searchable(text: $query, prompt: "Workout name")
        .task {
            if searchSource == .cloud && authManager.isAuthenticated && cloudWorkouts.isEmpty {
                await fetchCloudWorkouts()
            }
        }
    }
    
    private func fetchCloudWorkouts() async {
        guard authManager.isAuthenticated else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // If muscle groups are selected, use them as filters
            let tags = selectedMuscleGroups.isEmpty ? nil : selectedMuscleGroups.map { $0.rawValue }
            let workouts = try await cloudManager.fetchPublicWorkouts(tags: tags)
            await MainActor.run {
                cloudWorkouts = workouts
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

// MARK: - Workout Search Row

struct WorkoutSearchRow: View {
    let workout: Workout
    
    private let cardCornerRadius = Constants.cornerRadius + 2
    private let iconSize: CGFloat = 56
    private let primaryTint = Constants.mainAppTheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Workout icon/color
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .fill(workout.color.opacity(0.2))
                .frame(width: iconSize, height: iconSize)
                .overlay {
                    Image(systemName: "dumbbell")
                        .font(.headline)
                        .foregroundStyle(workout.color)
                }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(workout.name)
                    .font(.body.weight(.semibold))
                
                if let exercises = workout.exercises, !exercises.isEmpty {
                    Text("\(exercises.count) exercises")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Muscle group tags
                if !workout.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(workout.tags, id: \.self) { tag in
                                Text(tag.rawValue)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(tag.colorPalette.opacity(0.2))
                                    .foregroundStyle(tag.colorPalette)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
    }
}




