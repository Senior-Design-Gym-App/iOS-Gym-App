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
    @State private var showingUploadSheet = false

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
            .toolbar {
                if authManager.isAuthenticated {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingUploadSheet = true
                        } label: {
                            Label("Upload", systemImage: "square.and.arrow.up")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingUploadSheet) {
                UploadWorkoutsView()
                    .environmentObject(authManager)
            }
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
            
            Text("Sign in to access cloud workouts")
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

// MARK: - Upload Workouts View

struct UploadWorkoutsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    @Query(sort: \Workout.name) private var localWorkouts: [Workout]
    
    @State private var selectedWorkouts: Set<Workout.ID> = []
    @State private var uploadStatus: [Workout.ID: UploadStatus] = [:]
    @State private var isUploading = false
    @State private var searchText = ""
    
    private let cloudManager = CloudManager.shared
    
    enum UploadStatus {
        case idle
        case uploading
        case success
        case error(String)
        
        var icon: String {
            switch self {
            case .idle: return "circle"
            case .uploading: return "circle.dotted"
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .idle: return .secondary
            case .uploading: return .blue
            case .success: return .green
            case .error: return .red
            }
        }
    }
    
    var filteredWorkouts: [Workout] {
        if searchText.isEmpty {
            return localWorkouts
        } else {
            return localWorkouts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Status bar
                if isUploading {
                    uploadProgressBar
                }
                
                // Workouts list
                if filteredWorkouts.isEmpty {
                    ContentUnavailableView(
                        "No Local Workouts",
                        systemImage: "figure.strengthtraining.traditional",
                        description: Text("Create workouts locally first before uploading to cloud")
                    )
                } else {
                    List(filteredWorkouts) { workout in
                        WorkoutUploadRow(
                            workout: workout,
                            isSelected: selectedWorkouts.contains(workout.id),
                            status: uploadStatus[workout.id] ?? .idle
                        ) {
                            toggleSelection(workout)
                        }
                    }
                    .listStyle(.plain)
                    .searchable(text: $searchText, prompt: "Search workouts")
                }
            }
            .navigationTitle("Upload Workouts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isUploading)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task { await uploadSelectedWorkouts() }
                    } label: {
                        if isUploading {
                            ProgressView()
                        } else {
                            Text("Upload (\(selectedWorkouts.count))")
                        }
                    }
                    .disabled(selectedWorkouts.isEmpty || isUploading)
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button {
                            if selectedWorkouts.count == filteredWorkouts.count {
                                selectedWorkouts.removeAll()
                            } else {
                                selectedWorkouts = Set(filteredWorkouts.map { $0.id })
                            }
                        } label: {
                            Text(selectedWorkouts.count == filteredWorkouts.count ? "Deselect All" : "Select All")
                        }
                        
                        Spacer()
                        
                        Text("\(selectedWorkouts.count) of \(filteredWorkouts.count) selected")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .onAppear {
            cloudManager.setAuthManager(authManager)
        }
    }
    
    private var uploadProgressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Uploading...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(uploadedCount)/\(selectedWorkouts.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: Double(uploadedCount), total: Double(selectedWorkouts.count))
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var uploadedCount: Int {
        uploadStatus.values.filter { status in
            if case .success = status { return true }
            return false
        }.count
    }
    
    private func toggleSelection(_ workout: Workout) {
        if selectedWorkouts.contains(workout.id) {
            selectedWorkouts.remove(workout.id)
        } else {
            selectedWorkouts.insert(workout.id)
        }
    }
    
    private func uploadSelectedWorkouts() async {
        isUploading = true
        
        // Reset status for selected workouts
        for id in selectedWorkouts {
            uploadStatus[id] = .idle
        }
        
        // Upload each selected workout
        for id in selectedWorkouts {
            guard let workout = localWorkouts.first(where: { $0.id == id }) else { continue }
            
            uploadStatus[id] = .uploading
            
            do {
                let workoutId = try await cloudManager.createWorkout(workout)
                uploadStatus[id] = .success
                print("✅ Uploaded workout: \(workout.name) with ID: \(workoutId)")
            } catch {
                uploadStatus[id] = .error(error.localizedDescription)
                print("❌ Failed to upload workout: \(workout.name) - \(error)")
            }
            
            // Small delay between uploads
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }
        
        isUploading = false
        
        // Auto-dismiss after successful upload
        let allSuccess = uploadStatus.values.allSatisfy { status in
            if case .success = status { return true }
            return false
        }
        
        if allSuccess {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            dismiss()
        }
    }
}

// MARK: - Workout Upload Row

struct WorkoutUploadRow: View {
    let workout: Workout
    let isSelected: Bool
    let status: UploadWorkoutsView.UploadStatus
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .blue : .secondary)
                    .font(.title3)
                
                // Workout info
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    if let exercises = workout.exercises {
                        Text("\(exercises.count) exercises")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Tags
                    if !workout.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
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
                
                // Upload status
                VStack(spacing: 4) {
                    Image(systemName: status.icon)
                        .foregroundStyle(status.color)
                        .font(.title3)
                    
                    if case .error(let message) = status {
                        Text("Error")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .disabled({
            if case .uploading = status {
                return true
            }
            return false
        }())
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

#Preview {
    CloudWorkoutsView()
        .environmentObject(AuthManager())
}
