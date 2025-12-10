//
//  WatchSyncViewModel.swift
//  iOS Gym App
//
//  Integrates WatchConnectivity with SwiftData
//

import SwiftUI
import SwiftData
internal import Combine

@MainActor
@Observable
final class WatchSyncViewModel {
    private var modelContext: ModelContext?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupNotificationObservers()
    }
    
    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        // Initial sync when app becomes active
        syncToWatch()
    }
    
    // MARK: - Sync to Watch
    
    /// Sync all data to watch
    func syncToWatch() {
        guard let context = modelContext else { return }
        
        do {
            // Fetch all workouts
            let descriptor = FetchDescriptor<Workout>(
                sortBy: [SortDescriptor(\.modified, order: .reverse)]
            )
            let workouts = try context.fetch(descriptor)
            
            // Fetch active split
            let splitDescriptor = FetchDescriptor<Split>(
                predicate: #Predicate { $0.active == true }
            )
            let activeSplits = try context.fetch(splitDescriptor)
            let activeSplit = activeSplits.first
            
            // Send to watch
            WatchConnectivityManager.shared.syncWorkouts(workouts)
            
            if let split = activeSplit {
                WatchConnectivityManager.shared.syncActiveSplit(split)
            }
            
            // Also update background context
            WatchConnectivityManager.shared.updateApplicationContext(
                workouts: workouts,
                activeSplit: activeSplit
            )
            
            print("✅ Synced \(workouts.count) workouts to watch")
        } catch {
            print("❌ Failed to fetch data for sync: \(error)")
        }
    }
    
    /// Sync specific workout (e.g., after editing)
    func syncWorkout(_ workout: Workout) {
        guard let context = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<Workout>()
            let workouts = try context.fetch(descriptor)
            WatchConnectivityManager.shared.syncWorkouts(workouts)
        } catch {
            print("❌ Failed to sync workout: \(error)")
        }
    }
    
    /// Sync active split (e.g., after changing)
    func syncActiveSplit() {
        guard let context = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<Split>(
                predicate: #Predicate { $0.active == true }
            )
            let splits = try context.fetch(descriptor)
            
            if let split = splits.first {
                WatchConnectivityManager.shared.syncActiveSplit(split)
            }
        } catch {
            print("❌ Failed to sync split: \(error)")
        }
    }
    
    // MARK: - Receive from Watch
    
    private func setupNotificationObservers() {
        // Watch requested workouts
        NotificationCenter.default.publisher(for: .watchRequestedWorkouts)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.syncToWatch()
            }
            .store(in: &cancellables)
        
        // Watch completed session
        NotificationCenter.default.publisher(for: .watchCompletedSession)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let session = notification.userInfo?["session"] as? WorkoutSessionTransfer else { return }
                self?.saveCompletedSession(session)
            }
            .store(in: &cancellables)
    }
    
    private func saveCompletedSession(_ sessionTransfer: WorkoutSessionTransfer) {
        guard let context = modelContext else { return }
        
        print("📱 ===== SAVE COMPLETED SESSION CALLED =====")
        print("📱 Transfer session ID: \(sessionTransfer.id)")
        print("📱 Transfer session name: \(sessionTransfer.name)")
        print("📱 Transfer started: \(sessionTransfer.started)")
        print("📱 Transfer completed: \(sessionTransfer.completed?.description ?? "nil")")
        
        do {
            // First, try to find existing session by sessionId
            let sessionDescriptor = FetchDescriptor<WorkoutSession>(
                predicate: #Predicate<WorkoutSession> { session in
                    session.sessionId == sessionTransfer.id
                }
            )
            let existingSessions = try context.fetch(sessionDescriptor)
            
            print("📱 Found \(existingSessions.count) existing sessions with matching sessionId")
            
            let session: WorkoutSession
            if let existingSession = existingSessions.first {
                // Update existing session
                session = existingSession
                session.completed = sessionTransfer.completed ?? Date()
                print("✅ Found existing session with ID \(sessionTransfer.id), updating completion")
            } else {
                // Create new session - find the workout first
                print("📱 No existing session found, creating new one")
                let workoutDescriptor = FetchDescriptor<Workout>()
                let workouts = try context.fetch(workoutDescriptor)
                
                // Try to find matching workout by name (since we generate UUIDs from hashes)
                guard let workout = workouts.first(where: { workout in
                    let workoutHash = abs(workout.name.hashValue ^ workout.created.timeIntervalSince1970.hashValue)
                    let transferHash = sessionTransfer.workoutId.uuidString.hashValue
                    return abs(workoutHash) == abs(transferHash) || workout.name == sessionTransfer.name
                }) ?? workouts.first else {
                    print("❌ Could not find workout matching the session")
                    return
                }
                
                print("🆕 Creating new session with ID \(sessionTransfer.id) for workout: \(workout.name)")
                
                session = WorkoutSession(
                    name: sessionTransfer.name,
                    started: sessionTransfer.started,
                    completed: sessionTransfer.completed ?? Date(),
                    workout: workout,
                    sessionId: sessionTransfer.id  // Use the transfer's ID
                )
                context.insert(session)
            }
            
            // Clear any existing entries for this session to avoid duplicates
            let allEntriesDescriptor = FetchDescriptor<WorkoutSessionEntry>()
            let allEntries = try context.fetch(allEntriesDescriptor)
            for e in allEntries where e.session === session {
                context.delete(e)
            }
            
            // Process each entry from the transfer
            for entryTransfer in sessionTransfer.entries {
                // Find matching exercise by ID (using our hash-based UUID generation)
                let exerciseDescriptor = FetchDescriptor<Exercise>()
                let exercises = try context.fetch(exerciseDescriptor)
                
                // Try to match exercise by generated UUID or fallback to name matching
                guard let exercise = exercises.first(where: { ex in
                    let exerciseHash = abs(ex.name.hashValue)
                    let transferHash = entryTransfer.exerciseId.uuidString.hashValue
                    return abs(exerciseHash) == abs(transferHash)
                }) ?? exercises.first else {
                    print("⚠️ Could not find matching exercise for entry")
                    continue
                }
                
                print("📱 Adding entry for exercise: \(exercise.name)")
                
                // Create session entry
                let entry = WorkoutSessionEntry(
                    reps: entryTransfer.reps,
                    weight: entryTransfer.weight,
                    session: session,
                    exercise: exercise
                )
                
                context.insert(entry)
            }
            
            try context.save()
            print("✅ Saved completed session with \(sessionTransfer.entries.count) entries (sessionId: \(sessionTransfer.id))")
            print("📱 ===== SAVE COMPLETED SESSION END =====")
            
        } catch {
            print("❌ Failed to save session: \(error)")
        }
    }
}

// MARK: - View Extension for Easy Access

extension View {
    /// Add this modifier to views that need to sync with watch
    func syncWithWatch(_ viewModel: WatchSyncViewModel, modelContext: ModelContext) -> some View {
        self.onAppear {
            viewModel.setup(modelContext: modelContext)
        }
    }
}

