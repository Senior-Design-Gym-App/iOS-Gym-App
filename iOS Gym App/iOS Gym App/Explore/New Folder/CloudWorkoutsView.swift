//
//  CloudWorkoutsView.swift
//  iOS Gym App
//
//  Created by Zachary Andrew Kolano on 12/4/25.
//

import SwiftUI
import SwiftData

struct CloudWorkoutsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthManager

    @State private var status: String = "Ready"
    @State private var isLoading = false
    @State private var cloudWorkouts: [Workout] = []
    @State private var selectedTags: Set<String> = []

    @Query(sort: \Workout.name) private var localWorkouts: [Workout]
    
    private let cloudManager = CloudManager.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // Authentication Status
                authStatusSection
                
                if authManager.isAuthenticated {
                    // Status message
                    Text(status)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                    
                    // Action buttons
                    actionButtonsSection
                    
                    // Workouts list
                    workoutsListSection
                } else {
                    unauthenticatedView
                }
            }
            .padding()
            .navigationTitle("Cloud Workouts")
            .onAppear {
                // Set the auth manager reference in CloudManager
                cloudManager.setAuthManager(authManager)
            }
        }
    }
    
    // MARK: - View Components
    
    private var authStatusSection: some View {
        Group {
            if authManager.isAuthenticated {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Signed in as \(authManager.currentUser ?? "User")")
                        .font(.caption)
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            Button {
                Task { await fetchPublicWorkouts() }
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(0.8)
                    }
                    Text("Fetch Public Workouts")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
            
            Button {
                Task { await syncMyWorkouts() }
            } label: {
                Label("Sync My Workouts", systemImage: "arrow.triangle.2.circlepath")
            }
            .buttonStyle(.bordered)
            .disabled(isLoading)
        }
        .padding(.horizontal)
    }
    
    private var workoutsListSection: some View {
        List {
            if cloudWorkouts.isEmpty {
                ContentUnavailableView(
                    "No Workouts",
                    systemImage: "figure.strengthtraining.traditional",
                    description: Text("Tap 'Fetch Public Workouts' to load workouts from the cloud")
                )
            } else {
                ForEach(cloudWorkouts) { workout in
                    WorkoutCloudRow(workout: workout) {
                        Task { await saveToLocal(workout) }
                    }
                }
            }
        }
        .listStyle(.plain)
    }
    
    private var unauthenticatedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cloud.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Sign in Required")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Sign in with Apple to access cloud workouts")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - Actions
    
    private func fetchPublicWorkouts() async {
        isLoading = true
        status = "Fetching public workouts..."

        do {
            let workouts = try await cloudManager.fetchPublicWorkouts()
            cloudWorkouts = workouts
            status = "Loaded \(workouts.count) public workouts"
        } catch {
            status = "Error: \(error.localizedDescription)"
            print("❌ Fetch error: \(error)")
        }

        isLoading = false
    }
    
    private func syncMyWorkouts() async {
        isLoading = true
        status = "Syncing your workouts..."
        
        do {
            let remoteWorkouts = try await cloudManager.fetchMyWorkouts()
            
            // Update local database
            for workout in remoteWorkouts {
                modelContext.insert(workout)
            }
            
            try modelContext.save()
            status = "Synced \(remoteWorkouts.count) workouts"
        } catch {
            status = "Sync error: \(error.localizedDescription)"
            print("❌ Sync error: \(error)")
        }
        
        isLoading = false
    }
    
    private func saveToLocal(_ workout: Workout) async {
        status = "Saving '\(workout.name)'..."
        
        do {
            // Insert the workout into local database
            modelContext.insert(workout)
            try modelContext.save()
            
            status = "Saved '\(workout.name)' locally"
            
            // Remove from cloud workouts list
            if let index = cloudWorkouts.firstIndex(where: { $0.id == workout.id }) {
                cloudWorkouts.remove(at: index)
            }
        } catch {
            status = "Save error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Workout Cloud Row

struct WorkoutCloudRow: View {
    let workout: Workout
    let onSave: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(workout.name)
                .font(.headline)
            
            if let exercises = workout.exercises {
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
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(tag.colorPalette.opacity(0.2))
                                .foregroundStyle(tag.colorPalette)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            
            // Save button
            Button {
                onSave()
            } label: {
                Label("Save to My Workouts", systemImage: "square.and.arrow.down")
                    .font(.caption)
            }
            .buttonStyle(.bordered)
            .padding(.top, 6)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Publish Workout Button

struct PublishWorkoutButton: View {
    let workout: Workout
    @State private var isPublishing = false
    @State private var message: String?
    
    private let cloudManager = CloudManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button {
                Task { await publishWorkout() }
            } label: {
                HStack {
                    if isPublishing {
                        ProgressView()
                            .scaleEffect(0.7)
                    }
                    Label("Publish to Cloud", systemImage: "cloud.fill")
                        .font(.caption)
                }
            }
            .buttonStyle(.bordered)
            .disabled(isPublishing)
            
            if let message = message {
                Text(message)
                    .font(.caption2)
                    .foregroundStyle(message.contains("Error") ? .red : .green)
            }
        }
    }
    
    private func publishWorkout() async {
        isPublishing = true
        message = nil
        
        do {
            // First create the workout in the cloud
            let workoutId = try await cloudManager.createWorkout(workout)
            
            // Then publish it to make it public
            try await cloudManager.publishWorkout(workoutId: workoutId)
            
            message = "✓ Published successfully"
        } catch {
            message = "Error: \(error.localizedDescription)"
            print("❌ Publish error: \(error)")
        }
        
        isPublishing = false
        
        // Clear message after 3 seconds
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            message = nil
        }
    }
}

#Preview {
    CloudWorkoutsView()
        .environmentObject(AuthManager())
}
