import SwiftData
import Foundation

@Model
final class WorkoutSession {
    
    var name: String = ""
    var started: Date = Date()
    var completed: Date?
    var selectedGymID: String?
    
    var workout: Workout?
    
    @Relationship(deleteRule: .cascade)
    var exercises: [WorkoutSessionEntry]? = []
    
    init(name: String, started: Date, completed: Date? = nil, workout: Workout) {
        self.name = name
        self.started = started
        self.completed = completed
        self.workout = workout
    }
    
}

@Model
final class WorkoutSessionEntry {
    
    var reps: [Int] = []
    var weight: [Double] = []
    
    @Relationship(deleteRule: .nullify)
    var session: WorkoutSession?
    @Relationship(deleteRule: .nullify)
    var exercise: Exercise?
    
    init(reps: [Int], weight: [Double], session: WorkoutSession?, exercise: Exercise?) {
        self.reps = reps
        self.weight = weight
        self.session = session
        self.exercise = exercise
    }
    
}
