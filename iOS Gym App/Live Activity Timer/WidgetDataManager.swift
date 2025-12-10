//
//  WidgetDataManager.swift
//  iOS Gym App
//
//  Helper for managing widget data updates
//

import Foundation
import WidgetKit

/// Manager for updating widget data via shared UserDefaults
class WidgetDataManager {
    static let shared = WidgetDataManager()
    
    private let appGroupID = "group.com.yourcompany.reptheset"
    private let queue = DispatchQueue(label: "com.reptheset.widgetdata", qos: .userInitiated)
    
    private var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    private init() {
        // Verify app group access on initialization
        if defaults == nil {
            print("⚠️ Warning: Unable to access app group '\(appGroupID)'. Check entitlements.")
        }
    }
    
    // MARK: - Active Split Management
    
    /// Save the active split to be displayed in widgets
    func setActiveSplit(_ split: SplitTransfer?) {
        queue.async { [weak self] in
            guard let self = self, let defaults = self.defaults else {
                print("❌ Failed to access UserDefaults for app group")
                return
            }
            
            if let split = split {
                do {
                    let data = try JSONEncoder().encode(split)
                    defaults.set(data, forKey: "activeSplit")
                    print("✅ Saved active split: \(split.name)")
                } catch {
                    print("❌ Failed to encode active split: \(error)")
                }
            } else {
                defaults.removeObject(forKey: "activeSplit")
                defaults.removeObject(forKey: "lastCompletedWorkoutIndex")
                print("✅ Cleared active split")
            }
            
            self.reloadWidgets()
        }
    }
    
    /// Get the current active split
    func getActiveSplit() -> SplitTransfer? {
        // Don't use queue.sync if already on the queue - can cause deadlock
        // Just access directly since UserDefaults is thread-safe
        guard let defaults = defaults,
              let data = defaults.data(forKey: "activeSplit") else {
            return nil
        }
        
        return try? JSONDecoder().decode(SplitTransfer.self, from: data)
    }
    
    // MARK: - Workout Progress Tracking
    
    /// Mark a workout as completed and save session completion info
    /// This updates the widget to show the next workout in the split
    func markWorkoutCompleted(workoutId: UUID, completedDate: Date = Date()) {
        queue.async { [weak self] in
            guard let self = self, let defaults = self.defaults else {
                return
            }
            
            // Load existing completed sessions
            var sessions: [CompletedSessionInfo] = []
            if let data = defaults.data(forKey: "completedSessions"),
               let decoded = try? JSONDecoder().decode([CompletedSessionInfo].self, from: data) {
                sessions = decoded
            }
            
            // Add new completed session
            let newSession = CompletedSessionInfo(workoutId: workoutId, completedDate: completedDate)
            sessions.append(newSession)
            
            // Keep only the last 100 sessions to avoid bloat
            if sessions.count > 100 {
                sessions = Array(sessions.suffix(100))
            }
            
            // Save back to UserDefaults
            if let encoded = try? JSONEncoder().encode(sessions) {
                defaults.set(encoded, forKey: "completedSessions")
                print("✅ Saved completed workout session (total: \(sessions.count))")
            }
            
            self.reloadWidgets()
        }
    }
    
    /// Get the next workout in the active split based on completion history
    func getNextWorkoutInSplit() -> WorkoutTransfer? {
        // Don't use queue.sync - UserDefaults is thread-safe
        // Calling getActiveSplit() from queue.sync would cause deadlock
        guard let split = getActiveSplit(), !split.workouts.isEmpty else {
            return nil
        }
        
        guard let defaults = defaults else { return split.workouts.first }
        
        // Load completed sessions
        guard let data = defaults.data(forKey: "completedSessions"),
              let sessions = try? JSONDecoder().decode([CompletedSessionInfo].self, from: data) else {
            return split.workouts.first // No sessions, return first workout
        }
        
        // Find most recent session for workouts in this split
        let workoutIds = Set(split.workouts.map { $0.id })
        let relevantSessions = sessions.filter { workoutIds.contains($0.workoutId) }
        
        guard let mostRecent = relevantSessions.max(by: { $0.completedDate < $1.completedDate }) else {
            return split.workouts.first
        }
        
        // Find index and return next workout
        if let lastIndex = split.workouts.firstIndex(where: { $0.id == mostRecent.workoutId }) {
            let nextIndex = (lastIndex + 1) % split.workouts.count
            return split.workouts[nextIndex]
        }
        
        return split.workouts.first
    }
    
    /// Reset split progress by clearing all completed sessions
    func resetSplitProgress() {
        queue.async { [weak self] in
            guard let self = self, let defaults = self.defaults else { return }
            
            defaults.removeObject(forKey: "completedSessions")
            print("✅ Reset split progress (cleared all completed sessions)")
            self.reloadWidgets()
        }
    }
    
    /// Clear completed sessions for a specific workout
    func clearWorkoutHistory(workoutId: UUID) {
        queue.async { [weak self] in
            guard let self = self, let defaults = self.defaults else { return }
            
            if let data = defaults.data(forKey: "completedSessions"),
               var sessions = try? JSONDecoder().decode([CompletedSessionInfo].self, from: data) {
                
                let originalCount = sessions.count
                sessions.removeAll { $0.workoutId == workoutId }
                
                if let encoded = try? JSONEncoder().encode(sessions) {
                    defaults.set(encoded, forKey: "completedSessions")
                    print("✅ Cleared \(originalCount - sessions.count) sessions for workout")
                }
                
                self.reloadWidgets()
            }
        }
    }
    
    // MARK: - Pinned Workouts
    
    /// Save pinned workouts for quick access
    func setPinnedWorkouts(_ workouts: [WorkoutWidgetData]) {
        queue.async { [weak self] in
            guard let self = self, let defaults = self.defaults else {
                print("❌ Failed to access UserDefaults for app group")
                return
            }
            
            do {
                let data = try JSONEncoder().encode(workouts)
                defaults.set(data, forKey: "pinnedWorkouts")
                print("✅ Saved \(workouts.count) pinned workouts")
                self.reloadWidgets()
            } catch {
                print("❌ Failed to encode pinned workouts: \(error)")
            }
        }
    }
    
    // MARK: - Widget Reload
    
    /// Request all widgets to reload their timelines
    func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
        print("🔄 Requested widget reload")
    }
    
    /// Refresh the active split data and reload widgets
    /// Call this when the active split's workouts have been modified
    func refreshActiveSplit(_ split: SplitTransfer) {
        queue.async { [weak self] in
            guard let self = self, let defaults = self.defaults else {
                print("❌ Failed to access UserDefaults for app group")
                return
            }
            
            do {
                let data = try JSONEncoder().encode(split)
                defaults.set(data, forKey: "activeSplit")
                print("✅ Refreshed active split: \(split.name)")
                self.reloadWidgets()
            } catch {
                print("❌ Failed to encode active split: \(error)")
            }
        }
    }
}

// MARK: - Convenience Extensions

extension WidgetDataManager {
    /// Convert a WorkoutTransfer to WorkoutWidgetData
    func convertToWidgetData(_ workout: WorkoutTransfer) -> WorkoutWidgetData {
        WorkoutWidgetData(
            id: workout.id.uuidString,
            name: workout.name,
            duration: workout.exercises.count * 3 // Rough estimate
        )
    }
    
    /// Convert multiple workouts to widget data
    func convertToWidgetData(_ workouts: [WorkoutTransfer]) -> [WorkoutWidgetData] {
        workouts.map { convertToWidgetData($0) }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    /// Posted when widget data should be updated
    static let widgetDataDidChange = Notification.Name("widgetDataDidChange")
}

// MARK: - Debug Helpers

#if DEBUG
extension WidgetDataManager {
    /// Print current widget state for debugging
    func debugPrintState() {
        print("🔍 Widget Debug State:")
        if let split = getActiveSplit() {
            print("   Active Split: \(split.name)")
            print("   Workouts: \(split.workouts.count)")
            split.workouts.enumerated().forEach { index, workout in
                print("     \(index + 1). \(workout.name) (\(workout.exercises.count) exercises)")
                print("        ID: \(workout.id)")
            }
            
            // Show completed sessions
            if let defaults = defaults,
               let data = defaults.data(forKey: "completedSessions"),
               let sessions = try? JSONDecoder().decode([CompletedSessionInfo].self, from: data) {
                print("   Completed Sessions: \(sessions.count)")
                
                // Show all completed sessions
                sessions.sorted(by: { $0.completedDate > $1.completedDate }).prefix(5).forEach { session in
                    print("     - Workout ID: \(session.workoutId), Date: \(session.completedDate)")
                }
                
                let workoutIds = Set(split.workouts.map { $0.id })
                let relevantSessions = sessions.filter { workoutIds.contains($0.workoutId) }
                
                print("   Relevant Sessions (matching split): \(relevantSessions.count)")
                
                if let mostRecent = relevantSessions.max(by: { $0.completedDate < $1.completedDate }) {
                    if let workout = split.workouts.first(where: { $0.id == mostRecent.workoutId }) {
                        print("   Last Completed: \(workout.name)")
                    } else {
                        print("   ⚠️ Last completed workout ID not found in current split!")
                        print("      Looking for: \(mostRecent.workoutId)")
                    }
                }
                
                if let nextWorkout = getNextWorkoutInSplit() {
                    print("   Next Workout: \(nextWorkout.name)")
                } else {
                    print("   ⚠️ Could not determine next workout")
                }
            } else {
                print("   No completed sessions")
                print("   Next Workout: \(split.workouts.first?.name ?? "Unknown") (first workout)")
            }
        } else {
            print("   No active split")
        }
    }
}
#endif
