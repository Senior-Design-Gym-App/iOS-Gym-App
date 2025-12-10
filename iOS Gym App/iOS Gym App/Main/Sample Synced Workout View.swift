//
//  Sample Synced Workout View.swift
//  
//  Example implementation showing how to use the synced SessionManager
//

import SwiftUI

// MARK: - iOS Implementation

struct SyncedWorkoutView: View {
    @State private var sessionManager = SessionManager()
    @State private var connectivity = WatchConnectivityManager.shared
    let workout: Workout
    
    var body: some View {
        VStack(spacing: 20) {
            // Connection status indicator
            connectionStatusView
            
            if let current = sessionManager.currentExercise {
                currentExerciseView(current)
            } else {
                emptyStateView
            }
        }
        .padding()
        .onAppear {
            startWorkoutSession()
        }
        .onDisappear {
            sessionManager.endSession()
        }
    }
    
    private var connectionStatusView: some View {
        HStack {
            Circle()
                .fill(connectivity.isReachable ? Color.green : Color.orange)
                .frame(width: 10, height: 10)
            
            Text(connectivity.isReachable ? "⌚️ Watch Connected" : "⌚️ Watch Syncing...")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if sessionManager.syncWithWatch {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding(.horizontal)
    }
    
    private func currentExerciseView(_ current: SessionData) -> some View {
        VStack(spacing: 24) {
            // Exercise name
            Text(current.exercise.name)
                .font(.title)
                .fontWeight(.bold)
            
            // Set counter
            Text("Set \(sessionManager.currentSet) of \(sessionManager.totalSets)")
                .font(.title2)
                .foregroundColor(.secondary)
            
            // Progress indicator
            ProgressView(value: Double(sessionManager.currentSet), total: Double(sessionManager.totalSets))
                .tint(.blue)
            
            Divider()
            
            // Reps control
            VStack {
                Text("Reps")
                    .font(.headline)
                
                HStack {
                    Button {
                        sessionManager.updateReps(max(1, sessionManager.reps - 1))
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                    }
                    
                    Text("\(sessionManager.reps)")
                        .font(.system(size: 48, weight: .bold))
                        .frame(minWidth: 100)
                    
                    Button {
                        sessionManager.updateReps(sessionManager.reps + 1)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                    }
                }
            }
            
            // Weight control
            VStack {
                Text("Weight")
                    .font(.headline)
                
                HStack {
                    Button {
                        sessionManager.updateWeight(max(0, sessionManager.weight - 2.5))
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                    }
                    
                    Text("\(sessionManager.weight, specifier: "%.1f") kg")
                        .font(.system(size: 36, weight: .semibold))
                        .frame(minWidth: 150)
                    
                    Button {
                        sessionManager.updateWeight(sessionManager.weight + 2.5)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                    }
                }
            }
            
            Divider()
            
            // Rest timer
            if sessionManager.rest > 0 {
                VStack {
                    Text("Rest Time")
                        .font(.headline)
                    
                    Text(timeString(from: sessionManager.elapsedTime))
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(sessionManager.elapsedTime >= Double(sessionManager.rest) ? .green : .orange)
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 16) {
                if sessionManager.currentSet > 1 {
                    Button {
                        sessionManager.PreviousSet()
                    } label: {
                        Label("Previous Set", systemImage: "arrow.left.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                
                Button {
                    sessionManager.NextSet()
                } label: {
                    Label("Next Set", systemImage: "arrow.right.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            
            // Next exercise button
            if !sessionManager.upcomingExercises.isEmpty {
                Button {
                    sessionManager.NextWorkout()
                } label: {
                    Label("Next Exercise", systemImage: "forward.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("No Active Exercise")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add exercises to begin")
                .foregroundColor(.secondary)
        }
    }
    
    private func startWorkoutSession() {
        sessionManager.startSession(workout: workout)
        
        // Queue all exercises from the workout
        if let exercises = workout.exercises {
            for exercise in exercises {
                sessionManager.QueueExercise(exercise: exercise)
            }
        }
    }
    
    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - watchOS Implementation

#if os(watchOS)
struct WatchSyncedWorkoutView: View {
    @State private var sessionManager = WatchSessionManager()
    @State private var connectivity = WatchConnectivityManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if sessionManager.isSessionActive {
                    activeSessionView
                } else {
                    emptyStateView
                }
            }
            .padding()
        }
        .alert("Cannot Start Workout", isPresented: $sessionManager.showEmptyWorkoutAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This workout has no exercises. Add exercises on your iPhone before starting.")
        }
    }
    
    private var activeSessionView: some View {
        VStack(spacing: 12) {
            // Connection status
            HStack {
                Circle()
                    .fill(connectivity.isReachable ? Color.green : Color.orange)
                    .frame(width: 6, height: 6)
                Text(connectivity.isReachable ? "Synced" : "Syncing...")
                    .font(.caption2)
            }
            .foregroundColor(.secondary)
            
            // Exercise name
            Text(sessionManager.currentExerciseName)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            // Set counter
            Text("Set \(sessionManager.currentSet)/\(sessionManager.totalSets)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Divider()
            
            // Reps
            VStack(spacing: 4) {
                Text("Reps")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Button {
                        sessionManager.updateReps(max(1, sessionManager.currentReps - 1))
                    } label: {
                        Image(systemName: "minus.circle.fill")
                    }
                    
                    Text("\(sessionManager.currentReps)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(minWidth: 40)
                    
                    Button {
                        sessionManager.updateReps(sessionManager.currentReps + 1)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            
            // Weight
            VStack(spacing: 4) {
                Text("Weight")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Button {
                        sessionManager.updateWeight(max(0, sessionManager.currentWeight - 2.5))
                    } label: {
                        Image(systemName: "minus.circle.fill")
                    }
                    
                    Text("\(sessionManager.currentWeight, specifier: "%.1f")")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(minWidth: 50)
                    
                    Button {
                        sessionManager.updateWeight(sessionManager.currentWeight + 2.5)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            
            Divider()
            
            // Action buttons
            VStack(spacing: 8) {
                Button {
                    sessionManager.nextSet()
                } label: {
                    Label("Next Set", systemImage: "arrow.right.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                if sessionManager.currentSet > 1 {
                    Button {
                        sessionManager.previousSet()
                    } label: {
                        Label("Previous", systemImage: "arrow.left.circle")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            Text("No Active Session")
                .font(.headline)
            
            Text("Start a workout on iPhone")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
#endif

// MARK: - Settings View for Sync Control

struct WorkoutSyncSettingsView: View {
    @AppStorage("syncWithWatch") private var syncWithWatch: Bool = true
    @State private var connectivity = WatchConnectivityManager.shared
    
    var body: some View {
        Form {
            Section {
                Toggle("Sync with Apple Watch", isOn: $syncWithWatch)
                
                if syncWithWatch {
                    HStack {
                        Text("Status")
                        Spacer()
                        statusIndicator
                    }
                }
            } header: {
                Text("Watch Connectivity")
            } footer: {
                Text("When enabled, your workout sessions will sync in real-time with your Apple Watch.")
            }
            
            Section {
                if connectivity.isWatchPaired {
                    Label("Watch Paired", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Label("No Watch Paired", systemImage: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
                
                if connectivity.isWatchAppInstalled {
                    Label("Watch App Installed", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Label("Watch App Not Installed", systemImage: "info.circle")
                        .foregroundColor(.orange)
                }
                
                if connectivity.isReachable {
                    Label("Watch Reachable", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Label("Watch Not Reachable", systemImage: "info.circle")
                        .foregroundColor(.orange)
                }
            } header: {
                Text("Connection Details")
            }
        }
        .navigationTitle("Watch Sync")
    }
    
    private var statusIndicator: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(connectivity.isReachable ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
            Text(connectivity.isReachable ? "Connected" : "Background Sync")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview("iOS Workout View") {
    NavigationStack {
        // SyncedWorkoutView(workout: sampleWorkout)
        Text("Add your workout here")
    }
}

#if os(watchOS)
#Preview("watchOS Workout View") {
    WatchSyncedWorkoutView()
}
#endif

#Preview("Settings") {
    NavigationStack {
        WorkoutSyncSettingsView()
    }
}
