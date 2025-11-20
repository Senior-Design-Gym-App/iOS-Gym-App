//
//  Transfer Models.swift
//  iOS Gym App
//
//  Codable models for sharing data between iOS and watchOS
//

import Foundation

// MARK: - Transfer Models (Codable, lightweight for Watch Connectivity)

struct ExerciseTransfer: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let muscleWorked: String?
    let equipment: String?
    let targetSets: Int
    let targetReps: Int
    let targetWeight: Double?
    
    init(id: UUID = UUID(), 
         name: String, 
         muscleWorked: String? = nil,
         equipment: String? = nil,
         targetSets: Int,
         targetReps: Int,
         targetWeight: Double? = nil) {
        self.id = id
        self.name = name
        self.muscleWorked = muscleWorked
        self.equipment = equipment
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.targetWeight = targetWeight
    }
}

struct WorkoutTransfer: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let exercises: [ExerciseTransfer]
    let splitName: String?
    
    init(id: UUID = UUID(), 
         name: String, 
         exercises: [ExerciseTransfer],
         splitName: String? = nil) {
        self.id = id
        self.name = name
        self.exercises = exercises
        self.splitName = splitName
    }
}

struct SplitTransfer: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let workouts: [WorkoutTransfer]
    let active: Bool
    
    init(id: UUID = UUID(),
         name: String,
         workouts: [WorkoutTransfer],
         active: Bool = false) {
        self.id = id
        self.name = name
        self.workouts = workouts
        self.active = active
    }
}

struct WorkoutSessionTransfer: Codable, Identifiable {
    let id: UUID
    let name: String
    let started: Date
    let completed: Date?
    let workoutId: UUID
    let entries: [SessionEntryTransfer]
    
    init(id: UUID = UUID(),
         name: String,
         started: Date,
         completed: Date? = nil,
         workoutId: UUID,
         entries: [SessionEntryTransfer]) {
        self.id = id
        self.name = name
        self.started = started
        self.completed = completed
        self.workoutId = workoutId
        self.entries = entries
    }
}

struct SessionEntryTransfer: Codable, Identifiable {
    let id: UUID
    let exerciseId: UUID
    let reps: [Int]
    let weight: [Double]
    
    init(id: UUID = UUID(),
         exerciseId: UUID,
         reps: [Int],
         weight: [Double]) {
        self.id = id
        self.exerciseId = exerciseId
        self.reps = reps
        self.weight = weight
    }
}
