//
//  Workout Provider.swift
//  iOS Gym App
//
//  Created by Troy Madden on 11/6/25.
//

import WidgetKit
import SwiftUI
import Foundation

// MARK: - Entry Model

struct WorkoutEntry: TimelineEntry {
    let date: Date
    let workouts: [WorkoutWidgetData]
    let nextWorkoutIndex: Int? // Index of the next workout to do
    let splitName: String?
}

// MARK: - Sample Data (for Preview)

let sampleWorkouts: [WorkoutWidgetData] = [
    WorkoutWidgetData(id: "1", name: "Chest Day", duration: 45),
    WorkoutWidgetData(id: "2", name: "Leg Day", duration: 60),
    WorkoutWidgetData(id: "3", name: "HIIT", duration: 30)
]

// MARK: - Timeline Provider

struct WorkoutProvider: TimelineProvider {
    func placeholder(in context: Context) -> WorkoutEntry {
        print("🔵 Widget: placeholder called")
        return WorkoutEntry(
            date: Date(), 
            workouts: sampleWorkouts,
            nextWorkoutIndex: 0,
            splitName: "Example Split"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WorkoutEntry) -> ()) {
        print("🔵 Widget: getSnapshot called (isPreview: \(context.isPreview))")
        
        // In preview mode, use sample data
        if context.isPreview {
            completion(WorkoutEntry(
                date: Date(),
                workouts: sampleWorkouts,
                nextWorkoutIndex: 0,
                splitName: "Example Split"
            ))
            return
        }
        
        let (workouts, nextIndex, splitName) = loadActiveSplit()
        completion(WorkoutEntry(
            date: Date(), 
            workouts: workouts,
            nextWorkoutIndex: nextIndex,
            splitName: splitName
        ))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WorkoutEntry>) -> ()) {
        print("🔵 Widget: getTimeline called")
        let (workouts, nextIndex, splitName) = loadActiveSplit()
        print("🔵 Widget: Loaded \(workouts.count) workouts from split '\(splitName ?? "none")'")
        print("🔵 Widget: Next workout index: \(nextIndex?.description ?? "none")")
        
        let entry = WorkoutEntry(
            date: Date(), 
            workouts: workouts,
            nextWorkoutIndex: nextIndex,
            splitName: splitName
        )
        
        // Use .never policy since widget updates are triggered manually via WidgetCenter.shared.reloadAllTimelines()
        // This is called automatically by WidgetDataManager when splits/workouts change
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
        print("🔵 Widget: Timeline completed")
    }

    // MARK: - Data Loading

    /// Load the active split and return all workouts with the next workout index
    /// This matches the logic from SessionHomeView.predictNextWorkout()
    private func loadActiveSplit() -> (workouts: [WorkoutWidgetData], nextIndex: Int?, splitName: String?) {
        print("🔵 Widget: Loading active split...")
        let defaults = UserDefaults(suiteName: "group.com.yourcompany.reptheset")
        
        guard let defaults = defaults else {
            print("❌ Widget: Failed to access App Group UserDefaults")
            return ([], nil, nil)
        }
        
        // Load active split
        guard let splitData = defaults.data(forKey: "activeSplit") else {
            print("⚠️ Widget: No active split data found")
            return ([], nil, nil)
        }
        
        guard let split = try? JSONDecoder().decode(SplitTransfer.self, from: splitData) else {
            print("❌ Widget: Failed to decode split data")
            return ([], nil, nil)
        }
        
        guard !split.workouts.isEmpty else {
            print("⚠️ Widget: Split has no workouts")
            return ([], nil, split.name)
        }
        
        // Filter out workouts with no exercises (they can't be started)
        let validWorkouts = split.workouts.filter { !$0.exercises.isEmpty }
        
        if validWorkouts.count < split.workouts.count {
            print("⚠️ Widget: Filtered out \(split.workouts.count - validWorkouts.count) workout(s) with no exercises")
        }
        
        guard !validWorkouts.isEmpty else {
            print("⚠️ Widget: No valid workouts found (all have 0 exercises)")
            return ([], nil, split.name)
        }
        
        // Convert valid workouts to widget data
        let workoutData = validWorkouts.map { workout in
            WorkoutWidgetData(
                id: workout.id.uuidString,
                name: workout.name,
                duration: workout.exercises.count * 3 // Rough estimate: 3 min per exercise
            )
        }
        
        // Predict next workout using the same logic as iOS app
        // Create a modified split with only valid workouts for prediction
        let validSplit = SplitTransfer(
            id: split.id,
            name: split.name,
            workouts: validWorkouts,
            active: split.active
        )
        let nextIndex = predictNextWorkoutIndex(split: validSplit, defaults: defaults)
        
        if let index = nextIndex {
            print("✅ Widget: Successfully loaded \(workoutData.count) workouts")
            print("✅ Widget: Next workout is '\(workoutData[index].name)' (index \(index))")
        } else {
            print("✅ Widget: Successfully loaded \(workoutData.count) workouts")
            print("⚠️ Widget: Could not determine next workout")
        }
        
        return (workoutData, nextIndex, split.name)
    }
    
    /// Predict the next workout based on most recently completed session
    /// This mirrors the logic from SessionHomeView.predictNextWorkout()
    private func predictNextWorkoutIndex(split: SplitTransfer, defaults: UserDefaults) -> Int? {
        // Load completed sessions data
        guard let sessionsData = defaults.data(forKey: "completedSessions"),
              let sessions = try? JSONDecoder().decode([CompletedSessionInfo].self, from: sessionsData) else {
            print("🔵 Widget: No completed sessions found, defaulting to first workout")
            return 0 // No sessions completed yet, return first workout
        }
        
        print("🔵 Widget: Found \(sessions.count) total completed sessions")
        
        // Find the most recently completed session for workouts in this split
        let workoutIds = Set(split.workouts.map { $0.id })
        let relevantSessions = sessions.filter { workoutIds.contains($0.workoutId) }
        
        print("🔵 Widget: \(relevantSessions.count) sessions match this split's workouts")
        
        guard let mostRecentSession = relevantSessions.max(by: { $0.completedDate < $1.completedDate }) else {
            print("🔵 Widget: No relevant completed sessions, defaulting to first workout")
            return 0 // No completed sessions for this split, return first workout
        }
        
        // Find the index of the last completed workout
        guard let lastWorkoutIndex = split.workouts.firstIndex(where: { $0.id == mostRecentSession.workoutId }) else {
            print("⚠️ Widget: Could not find last completed workout in split")
            print("⚠️ Widget: Looking for workout ID: \(mostRecentSession.workoutId)")
            print("⚠️ Widget: Split has these workout IDs: \(split.workouts.map { $0.id })")
            return 0
        }
        
        // Return the next workout (or wrap around to first)
        let nextIndex = (lastWorkoutIndex + 1) % split.workouts.count
        print("🔵 Widget: Last completed: '\(split.workouts[lastWorkoutIndex].name)' on \(mostRecentSession.completedDate)")
        
        return nextIndex
    }
}
