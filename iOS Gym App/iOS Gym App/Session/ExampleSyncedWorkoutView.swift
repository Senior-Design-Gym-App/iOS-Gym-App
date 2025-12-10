//
//  ExampleSyncedWorkoutView.swift
//  iOS Gym App
//
//  Example of a workout control view with full cross-device sync
//  This is a reference implementation - adapt to your existing UI
//

import SwiftUI

struct ExampleSyncedWorkoutView: View {
    @Environment(SessionManager.self) private var sm
    @Environment(\.modelContext) private var context
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: - Current Exercise Info
                if let currentExercise = sm.currentExercise {
                    currentExerciseCard(currentExercise)
                }
                
                // MARK: - Set Controls
                setControlsSection
                
                // MARK: - Navigation Buttons
                navigationButtons
                
                // MARK: - Session Controls
                sessionControls
            }
            .padding()
        }
        .navigationTitle("Active Workout")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Current Exercise Card
    
    @ViewBuilder
    private func currentExerciseCard(_ sessionData: SessionData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(sessionData.exercise.name)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                Text("Set \(sm.currentSet) of \(sm.totalSets)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if sm.elapsedTime > 0 {
                    Text(formatTime(sm.elapsedTime))
                        .font(.headline)
                        .foregroundStyle(.blue)
                }
            }
            
            // Show completed sets
            if !sessionData.entry.reps.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Completed Sets:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    ForEach(Array(sessionData.entry.reps.enumerated()), id: \.offset) { index, reps in
                        HStack {
                            Text("Set \(index + 1):")
                                .font(.caption)
                            Text("\(reps) reps @ \(sessionData.entry.weight[index], specifier: "%.1f") lbs")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(sessionData.exercise.color.opacity(0.2))
        .cornerRadius(12)
    }
    
    // MARK: - Set Controls (THE IMPORTANT PART!)
    
    private var setControlsSection: some View {
        VStack(spacing: 16) {
            Text("Current Set")
                .font(.headline)
            
            // Reps Control - Uses sync binding!
            VStack(alignment: .leading, spacing: 8) {
                Text("Reps")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Button {
                        if sm.reps > 1 {
                            sm.updateReps(sm.reps - 1)
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                    }
                    .disabled(sm.reps <= 1)
                    
                    Text("\(sm.reps)")
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(minWidth: 60)
                    
                    Button {
                        sm.updateReps(sm.reps + 1)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                    }
                }
                
                // Alternative: Use the binding directly with a Stepper
                Stepper("Reps: \(sm.reps)", value: sm.repsBinding(), in: 1...100)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Weight Control - Uses sync binding!
            VStack(alignment: .leading, spacing: 8) {
                Text("Weight (lbs)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Button {
                        if sm.weight > 0 {
                            sm.updateWeight(sm.weight - 5)
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                    }
                    .disabled(sm.weight <= 0)
                    
                    Text("\(sm.weight, specifier: "%.1f")")
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(minWidth: 80)
                    
                    Button {
                        sm.updateWeight(sm.weight + 5)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                    }
                }
                
                // Alternative: Text field with binding
                TextField("Weight", value: sm.weightBinding(), format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Rest Time Control - Uses sync binding!
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Rest Time")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(sm.rest) seconds")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Slider(value: sm.restBindingDouble(), in: 0...300, step: 15)
                
                HStack {
                    Text("0s")
                        .font(.caption)
                    Spacer()
                    Text("5min")
                        .font(.caption)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Navigation Buttons
    
    private var navigationButtons: some View {
        VStack(spacing: 12) {
            // Log Set Button (calls NextSet which syncs)
            Button {
                sm.NextSet()
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Log Set")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundStyle(.white)
                .cornerRadius(12)
            }
            
            HStack(spacing: 12) {
                // Previous Set (syncs)
                Button {
                    sm.PreviousSet()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Previous")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundStyle(.primary)
                    .cornerRadius(12)
                }
                .disabled(sm.currentSet <= 1)
                
                // Next Exercise (syncs)
                Button {
                    sm.NextWorkout()
                } label: {
                    HStack {
                        Text("Next Exercise")
                        Image(systemName: "chevron.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                }
                .disabled(sm.upcomingExercises.isEmpty)
            }
        }
    }
    
    // MARK: - Session Controls
    
    private var sessionControls: some View {
        VStack(spacing: 12) {
            // End Workout Button (syncs)
            Button(role: .destructive) {
                sm.endSession()
            } label: {
                HStack {
                    Image(systemName: "stop.circle.fill")
                    Text("End Workout")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .foregroundStyle(.red)
                .cornerRadius(12)
            }
            
            // Sync Status
            HStack {
                Image(systemName: WatchConnectivityManager.shared.isReachable ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(WatchConnectivityManager.shared.isReachable ? .green : .orange)
                
                Text(WatchConnectivityManager.shared.isReachable ? "Watch Connected" : "Watch Not Reachable")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if sm.syncWithWatch {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundStyle(.blue)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ExampleSyncedWorkoutView()
            .environment(SessionManager())
    }
}

/*
 
 KEY POINTS DEMONSTRATED IN THIS FILE:
 
 1. ✅ Using sm.repsBinding(), sm.weightBinding(), sm.restBindingDouble()
    - These automatically sync when changed
    - Works with Steppers, TextFields, Sliders
    - NOTE: These are functions that return bindings, so use parentheses!
 
 2. ✅ Using sm.updateReps(), sm.updateWeight(), sm.updateRest()
    - When you need manual control (like +/- buttons)
    - Also automatically syncs
 
 3. ✅ Using sm.NextSet(), sm.PreviousSet(), sm.NextWorkout()
    - These already sync, no changes needed
 
 4. ✅ Using sm.endSession()
    - Properly ends session and syncs to other device
 
 5. ✅ Showing sync status
    - Using WatchConnectivityManager.shared.isReachable
    - Shows user if devices are connected
 
 ADAPT THIS TO YOUR UI:
 - Use your existing design/layout
 - Keep the sync patterns (bindings and update methods)
 - Add any additional UI elements you need
 - Test on two devices!
 
 */
