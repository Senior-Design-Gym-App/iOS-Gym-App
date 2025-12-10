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
    @State private var expandedWorkouts: Set<Workout.ID> = []
    
    // ADD THESE
    @State private var searchText = ""
    @State private var selectedMuscleFilter: MuscleGroup? = nil
    @State private var showingFilterSheet = false

    @Query(sort: \Workout.name) private var localWorkouts: [Workout]
    
    private let cloudManager = CloudManager.shared
    
    // ADD THIS - Filtered workouts
    var filteredWorkouts: [Workout] {
        var workouts = cloudWorkouts
        
        // Apply search filter
        if !searchText.isEmpty {
            workouts = workouts.filter { workout in
                workout.name.localizedCaseInsensitiveContains(searchText) ||
                (workout.exercises?.contains(where: { exercise in
                    exercise.name.localizedCaseInsensitiveContains(searchText)
                }) ?? false)
            }
        }
        
        // Apply muscle group filter
        if let muscleFilter = selectedMuscleFilter {
            workouts = workouts.filter { workout in
                workout.tags.contains(muscleFilter)
            }
        }
        
        return workouts
    }
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // Authentication Status
                if authManager.isAuthenticated {
                    // Status message
                    Text(status)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                    
                    // Action buttons
                    //actionButtonsSection
                    
                    // Workouts list
                    workoutsListSection
                } else {
                    unauthenticatedView
                }
            }
            .padding()
            .navigationTitle("Cloud Workouts")
            .searchable(text: $searchText, prompt: "Search workouts or exercises")  // ADD THIS
            .toolbar {
                if authManager.isAuthenticated {
                    // ADD THIS
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showingFilterSheet = true
                        } label: {
                            Label("Filter", systemImage: selectedMuscleFilter != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        }
                    }
                    
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
            .sheet(isPresented: $showingFilterSheet) {
                MuscleFilterSheet(selectedMuscle: $selectedMuscleFilter)
            }
            .onAppear {
                cloudManager.setAuthManager(authManager)
            }
            .task {
                // Auto-load workouts if authenticated and list is empty
                if authManager.isAuthenticated && cloudWorkouts.isEmpty {
                    await fetchPublicWorkouts()
                }
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
        VStack(spacing: 8) {
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
            }
            .padding(.horizontal)
            
            // Info about Fetch Public Workouts
            Text("Browse workouts shared by other users")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
    }
    
    private var workoutsListSection: some View {
            List {
                if filteredWorkouts.isEmpty {
                    if searchText.isEmpty && selectedMuscleFilter == nil {
                        ContentUnavailableView(
                            "No Workouts",
                            systemImage: "figure.strengthtraining.traditional",
                            description: Text("Tap 'Fetch Public Workouts' to load workouts from the cloud")
                        )
                    } else {
                        ContentUnavailableView(
                            "No Results",
                            systemImage: "magnifyingglass",
                            description: Text("No workouts match your search or filter")
                        )
                    }
                } else {
                    ForEach(filteredWorkouts) { workout in
                        WorkoutCloudRow(
                            workout: workout,
                            isExpanded: expandedWorkouts.contains(workout.id)
                        ) {
                            withAnimation {
                                if expandedWorkouts.contains(workout.id) {
                                    expandedWorkouts.remove(workout.id)
                                } else {
                                    expandedWorkouts.insert(workout.id)
                                }
                            }
                        } onSave: {
                            Task { await saveToLocal(workout) }
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    private var filterChipsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let muscle = selectedMuscleFilter {
                    HStack(spacing: 4) {
                        Text(muscle.rawValue)
                            .font(.caption)
                        
                        Button {
                            selectedMuscleFilter = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(muscle.colorPalette.opacity(0.2))
                    .foregroundStyle(muscle.colorPalette)
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal)
        }
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
struct WorkoutCloudRow: View {
    let workout: Workout
    let isExpanded: Bool
    let onToggle: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header - Tappable to expand/collapse
            Button(action: onToggle) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(workout.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        if let exercises = workout.exercises {
                            Text("\(exercises.count) exercises")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
            .buttonStyle(.plain)
            
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
            
            // Expanded exercise details
            if isExpanded, let exercises = workout.exercises {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    
                    ForEach(Array(exercises.enumerated()), id: \.offset) { index, exercise in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("\(index + 1).")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 20, alignment: .leading)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(exercise.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    HStack(spacing: 12) {
                                        if let muscle = exercise.muscleWorked {
                                            Label(muscle, systemImage: "figure.arms.open")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        if let equipment = exercise.equipment {
                                            Label(equipment, systemImage: "dumbbell")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                            
                            // Show set data from most recent session
                            let setData = exercise.recentSetData.setData
                            if !setData.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 4) {
                                        ForEach(Array(setData.enumerated()), id: \.offset) { setIndex, set in
                                            VStack(spacing: 2) {
                                                Text("Set \(setIndex + 1)")
                                                    .font(.caption2)
                                                    .foregroundStyle(.secondary)
                                                
                                                Text("\(set.reps) × \(Int(set.weight))lbs")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                                
                                                Text("\(set.rest)s rest")
                                                    .font(.caption2)
                                                    .foregroundStyle(.secondary)
                                            }
                                            .padding(6)
                                            .background(Color(.systemGray6))
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                        }
                                    }
                                }
                                .padding(.leading, 24)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        if index < exercises.count - 1 {
                            Divider()
                                .padding(.leading, 24)
                        }
                    }
                }
            }
            
            // Save button
            Button {
                onSave()
            } label: {
                Label("Save to My Workouts", systemImage: "square.and.arrow.down")
                    .font(.callout)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .padding(.top, 6)
        }
        .padding(.vertical, 8)
    }
}
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
struct MuscleFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedMuscle: MuscleGroup?
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        selectedMuscle = nil
                        dismiss()
                    } label: {
                        HStack {
                            Text("All Workouts")
                            Spacer()
                            if selectedMuscle == nil {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
                
                Section("Filter by Muscle Group") {
                    ForEach(MuscleGroup.allCases, id: \.self) { muscle in
                        Button {
                            selectedMuscle = muscle
                            dismiss()
                        } label: {
                            HStack {
                                Text(muscle.rawValue)
                                    .foregroundStyle(muscle.colorPalette)
                                Spacer()
                                if selectedMuscle == muscle {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter Workouts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
    
    #Preview {
        CloudWorkoutsView()
            .environmentObject(AuthManager())
    }
