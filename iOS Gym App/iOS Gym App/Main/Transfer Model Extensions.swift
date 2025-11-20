//
//  Transfer Model Extensions.swift
//  iOS Gym App
//
//  Extensions to convert SwiftData models to Transfer models
//  NOTE: This file should only be included in targets that have SwiftData models (iOS app)
//

import Foundation
import SwiftData

// MARK: - Conversion Extensions

extension Exercise {
    /// Convert SwiftData Exercise to Transfer model
    /// Uses the most recent workout data as target if available
    func toTransfer() -> ExerciseTransfer {
        // Calculate target sets and reps from most recent data
        let targetSets = reps.last?.count ?? 3
        let targetReps = reps.last?.first ?? 10
        let targetWeight = weights.last?.first
        
        // Create UUID - use a combination of name hash for consistency
        // This avoids accessing persistentModelID which can cause crashes
        let nameHash = abs(name.hashValue)
        let uuid = UUID(uuidString: String(format: "%08X-0000-0000-0000-%012X", nameHash & 0xFFFFFFFF, nameHash)) ?? UUID()
        
        return ExerciseTransfer(
            id: uuid,
            name: name,
            muscleWorked: muscleWorked,
            equipment: equipment,
            targetSets: targetSets,
            targetReps: targetReps,
            targetWeight: targetWeight
        )
    }
}

extension Workout {
    /// Convert SwiftData Workout to Transfer model
    func toTransfer() -> WorkoutTransfer {
        let exerciseTransfers = (exercises ?? []).map { $0.toTransfer() }
        
        // Create UUID - use a combination of name and created date hash
        let nameHash = abs(name.hashValue)
        let dateHash = abs(created.timeIntervalSince1970.hashValue)
        let combinedHash = nameHash ^ dateHash
        let uuid = UUID(uuidString: String(format: "%08X-0000-0000-0000-%012X", combinedHash & 0xFFFFFFFF, combinedHash)) ?? UUID()
        
        return WorkoutTransfer(
            id: uuid,
            name: name,
            exercises: exerciseTransfers,
            splitName: split?.name
        )
    }
}

extension Split {
    /// Convert SwiftData Split to Transfer model
    func toTransfer() -> SplitTransfer {
        let workoutTransfers = (workouts ?? []).map { $0.toTransfer() }
        
        // Create UUID - use a combination of name and created date hash
        let nameHash = abs(name.hashValue)
        let dateHash = abs(created.timeIntervalSince1970.hashValue)
        let combinedHash = nameHash ^ dateHash
        let uuid = UUID(uuidString: String(format: "%08X-0000-0000-0000-%012X", combinedHash & 0xFFFFFFFF, combinedHash)) ?? UUID()
        
        return SplitTransfer(
            id: uuid,
            name: name,
            workouts: workoutTransfers,
            active: active
        )
    }
}

extension WorkoutSession {
    /// Convert SwiftData WorkoutSession to Transfer model
    func toTransfer() -> WorkoutSessionTransfer? {
        guard let workout = workout else { return nil }
        
        // Create UUIDs using name and date hashes
        let sessionNameHash = abs(name.hashValue)
        let sessionDateHash = abs(started.timeIntervalSince1970.hashValue)
        let sessionCombined = sessionNameHash ^ sessionDateHash
        let sessionUuid = UUID(uuidString: String(format: "%08X-0000-0000-0000-%012X", sessionCombined & 0xFFFFFFFF, sessionCombined)) ?? UUID()
        
        let workoutNameHash = abs(workout.name.hashValue)
        let workoutDateHash = abs(workout.created.timeIntervalSince1970.hashValue)
        let workoutCombined = workoutNameHash ^ workoutDateHash
        let workoutUuid = UUID(uuidString: String(format: "%08X-0000-0000-0000-%012X", workoutCombined & 0xFFFFFFFF, workoutCombined)) ?? UUID()
        
        let entryTransfers = (exercises ?? []).compactMap { entry -> SessionEntryTransfer? in
            guard let exercise = entry.exercise else { return nil }
            
            // Create entry UUID
            let repsHash = entry.reps.reduce(0, { $0 ^ $1 })
            let weightHash = entry.weight.reduce(0.0, +).hashValue
            let entryCombined = repsHash ^ weightHash
            let entryUuid = UUID(uuidString: String(format: "%08X-0000-0000-0000-%012X", abs(entryCombined) & 0xFFFFFFFF, abs(entryCombined))) ?? UUID()
            
            // Create exercise UUID
            let exerciseHash = abs(exercise.name.hashValue)
            let exerciseUuid = UUID(uuidString: String(format: "%08X-0000-0000-0000-%012X", exerciseHash & 0xFFFFFFFF, exerciseHash)) ?? UUID()
            
            return SessionEntryTransfer(
                id: entryUuid,
                exerciseId: exerciseUuid,
                reps: entry.reps,
                weight: entry.weight
            )
        }
        
        return WorkoutSessionTransfer(
            id: sessionUuid,
            name: name,
            started: started,
            completed: completed,
            workoutId: workoutUuid,
            entries: entryTransfers
        )
    }
}
