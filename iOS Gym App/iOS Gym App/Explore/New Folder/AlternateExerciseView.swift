//
//  AlternateExerciseView.swift
//  iOS Gym App
//
//  Created by Zachary Andrew Kolano on 12/8/25.
//

import SwiftUI
import SwiftData

struct AlternateExerciseView: View {
    
    let session: WorkoutSession
    @Environment(SessionManager.self) private var sessionManager: SessionManager
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var userPreferences: String = ""
    @State private var isGenerating: Bool = false
    @State private var errorMessage: String?
    @State private var alternateExercise: Exercise?
    @State private var explanation: String?
    
    private let aiFunctions = AIFunctions()
    
    var currentExercise: Exercise? {
        sessionManager.currentExercise?.exercise
    }
    
    var workout: Workout? {
        session.workout
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.blue.gradient)
                        .padding(.top)
                    
                    Text("Find Alternate Exercise")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if let current = currentExercise {
                        Text("Replace: \(current.name)")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Current workout context
                if let workout = workout {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Workout: \(workout.name)")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                if let exercises = workout.exercises {
                                    ForEach(exercises, id: \.id) { exercise in
                                        VStack {
                                            Text(exercise.name)
                                                .font(.caption)
                                                .lineLimit(1)
                                            if let muscle = exercise.muscleWorked {
                                                Text(muscle)
                                                    .font(.caption2)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        .padding(8)
                                        .background(exercise.id == currentExercise?.id ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Preferences input
                VStack(alignment: .leading, spacing: 12) {
                    Text("Any preferences?")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    TextField("e.g., no equipment, easier, same muscle group...", text: $userPreferences, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...4)
                        .padding(.horizontal)
                    
                    Text("Optional: Tell the AI what you're looking for")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                
                // Generate button
                Button {
                    Task { await generateAlternate() }
                } label: {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .scaleEffect(0.8)
                        }
                        Text(isGenerating ? "Finding Alternate..." : "Find Alternate")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isGenerating || currentExercise == nil)
                .padding(.horizontal)
                
                // Error message
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Result section
                if let alternate = alternateExercise, let explanation = explanation {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Suggested Exercise", systemImage: "star.fill")
                                    .font(.headline)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(alternate.name)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    
                                    if let muscle = alternate.muscleWorked {
                                        Text("Targets: \(muscle)")
                                            .font(.callout)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    if let equipment = alternate.equipment {
                                        Text("Equipment: \(equipment)")
                                            .font(.callout)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    HStack(spacing: 16) {
                                        if let reps = alternate.reps.first?.first {
                                            Text("\(reps) reps")
                                                .font(.caption)
                                        }
                                        if let sets = alternate.reps.first?.count {
                                            Text("\(sets) sets")
                                                .font(.caption)
                                        }
                                        if let rest = alternate.rest.first?.first {
                                            Text("\(rest)s rest")
                                                .font(.caption)
                                        }
                                    }
                                    .foregroundStyle(.secondary)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Why this exercise?", systemImage: "lightbulb")
                                    .font(.headline)
                                
                                Text(explanation)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isGenerating)
                }
                
                if alternateExercise != nil {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Use This") {
                            if let alternate = alternateExercise {
                                replaceCurrentExercise(with: alternate)
                                dismiss()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Alternate Exercise")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func generateAlternate() async {
        guard let workout = workout, let current = currentExercise else {
            errorMessage = "No current exercise to replace"
            return
        }
        
        isGenerating = true
        errorMessage = nil
        alternateExercise = nil
        explanation = nil
        
        do {
            let result = try await aiFunctions.getAlternateExercise(
                for: workout,
                replacing: current.name,
                userPreferences: userPreferences.isEmpty ? nil : userPreferences
            )
            
            // Insert the new exercise into context
            context.insert(result.exercise)
            
            alternateExercise = result.exercise
            explanation = result.explanation
            
            print("✅ Found alternate: \(result.exercise.name)")
            
        } catch {
            errorMessage = "Failed to find alternate: \(error.localizedDescription)"
            print("❌ Error: \(error)")
        }
        
        isGenerating = false
    }
    
    private func replaceCurrentExercise(with newExercise: Exercise) {
        guard let currentSessionData = sessionManager.currentExercise else {
            print("❌ No current exercise to replace")
            return
        }
        
        // Get the current entry data
        let currentEntry = currentSessionData.entry
        
        // Create a new WorkoutSessionEntry with the new exercise
        // Preserve all existing session data (completed sets)
        let newEntry = WorkoutSessionEntry(
            reps: currentEntry.reps,        // Keep completed reps
            weight: currentEntry.weight,    // Keep completed weights
            session: currentEntry.session,  // Keep session reference
            exercise: newExercise           // NEW exercise
        )
        
        // Insert the new entry into context
        context.insert(newEntry)
        
        // Create new SessionData wrapper
        let newSessionData = SessionData(
            exercise: newExercise,
            entry: newEntry
        )
        
        // Update the session manager to use the new SessionData
        sessionManager.currentExercise = newSessionData
        
        print("🔄 Updated sessionManager.currentExercise to: \(newExercise.name)")
        print("🔄 Current exercise in manager: \(sessionManager.currentExercise?.exercise.name ?? "nil")")
        
        // Update the session's exercises array if needed
        if let session = currentEntry.session {
            if var exercises = session.exercises {
                // Remove the old entry if it was already added
                exercises.removeAll(where: { $0.id == currentEntry.id })
                session.exercises = exercises
            }
        }
        
        // Update session manager's rest/reps/weight to match the new exercise
        if let firstSet = newExercise.recentSetData.setData.first {
            sessionManager.reps = firstSet.reps
            sessionManager.weight = firstSet.weight
            sessionManager.rest = firstSet.rest
        }
        
        print("🔄 About to call StartTimer with new exercise: \(newExercise.name)")
        
        // Restart the timer with new exercise data
        sessionManager.StartTimer(exercise: newExercise, entry: newEntry)
        
        // Delete the old entry
        context.delete(currentEntry)
        
        print("✅ Replaced current exercise with \(newExercise.name)")
        print("   Preserved \(currentEntry.reps.count) completed sets")
        print("📝 This is a one-time swap - the original workout is unchanged")
        
        try? context.save()
        
        // Force sync the updated exercise to the watch
        // Use a small delay to ensure all state changes are complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak sessionManager] in
            sessionManager?.syncExerciseQueueChanged()
            print("⌚️ Synced alternate exercise to watch")
        }
    }
}
