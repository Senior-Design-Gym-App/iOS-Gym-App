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
    let restTimes: [Int]?  // Rest time for each set in seconds
    
    init(id: UUID = UUID(), 
         name: String, 
         muscleWorked: String? = nil,
         equipment: String? = nil,
         targetSets: Int,
         targetReps: Int,
         targetWeight: Double? = nil,
         restTimes: [Int]? = nil) {
        self.id = id
        self.name = name
        self.muscleWorked = muscleWorked
        self.equipment = equipment
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.targetWeight = targetWeight
        self.restTimes = restTimes
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

// MARK: - Real-Time Session Sync Models

/// Lightweight model for real-time session updates during active workout
struct LiveSessionUpdate: Codable {
    let sessionId: UUID
    let currentExercise: LiveExerciseState?
    let upcomingExerciseIds: [UUID]
    let completedExerciseIds: [UUID]
    let timestamp: Date
    let workoutStartTime: Date?  // When the workout actually started
    let upcomingExerciseNames: [String]  // Names of upcoming exercises for display
    
    init(sessionId: UUID,
         currentExercise: LiveExerciseState?,
         upcomingExerciseIds: [UUID],
         completedExerciseIds: [UUID],
         timestamp: Date = Date(),
         workoutStartTime: Date? = nil,
         upcomingExerciseNames: [String] = []) {
        self.sessionId = sessionId
        self.currentExercise = currentExercise
        self.upcomingExerciseIds = upcomingExerciseIds
        self.completedExerciseIds = completedExerciseIds
        self.timestamp = timestamp
        self.workoutStartTime = workoutStartTime
        self.upcomingExerciseNames = upcomingExerciseNames
    }
}

/// State of the currently active exercise
struct LiveExerciseState: Codable {
    let exerciseId: UUID
    let exerciseName: String
    let currentSet: Int
    let totalSets: Int
    let currentReps: Int
    let currentWeight: Double
    let restTime: Int
    let elapsedTime: TimeInterval
    let completedReps: [Int]
    let completedWeights: [Double]
    
    init(exerciseId: UUID,
         exerciseName: String,
         currentSet: Int,
         totalSets: Int,
         currentReps: Int,
         currentWeight: Double,
         restTime: Int,
         elapsedTime: TimeInterval,
         completedReps: [Int],
         completedWeights: [Double]) {
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.currentSet = currentSet
        self.totalSets = totalSets
        self.currentReps = currentReps
        self.currentWeight = currentWeight
        self.restTime = restTime
        self.elapsedTime = elapsedTime
        self.completedReps = completedReps
        self.completedWeights = completedWeights
    }
}

/// Actions that can be performed on a session
enum SessionAction: String, Codable {
    case startSession
    case endSession
    case cancelSession  // Delete/cancel without saving
    case nextSet
    case previousSet
    case nextExercise
    case previousExercise
    case updateReps
    case updateWeight
    case updateRest
    case timerTick
    case timerStarted  // Timer was reset/started on remote device
}

// MARK: - Widget Data Models

/// Lightweight model for widget display
struct WorkoutWidgetData: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let duration: Int
}

/// Information about completed sessions for determining "up next" workout
struct CompletedSessionInfo: Codable, Identifiable {
    let id: UUID
    let workoutId: UUID
    let completedDate: Date
    
    init(id: UUID = UUID(), workoutId: UUID, completedDate: Date) {
        self.id = id
        self.workoutId = workoutId
        self.completedDate = completedDate
    }
}
