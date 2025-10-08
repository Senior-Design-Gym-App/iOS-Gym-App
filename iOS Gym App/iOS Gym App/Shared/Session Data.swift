import SwiftData
import Foundation

@Model
final class WorkoutSession {
    
    var name: String = ""
    var started: Date = Date()
    var completed: Date?
    var selectedGymID: String?
    
    @Relationship(deleteRule: .cascade)
    var exercises: [WorkoutSessionEntry]? = []
    
    init(name: String, started: Date, completed: Date? = nil) {
        self.name = name
        self.started = started
        self.completed = completed
    }
    
}

@Model
final class WorkoutSessionEntry {
    
    var reps: [Int] = []
    var weight: [Double] = []
    
    @Relationship(deleteRule: .nullify)
    var session: WorkoutSession?
    @Relationship(deleteRule: .nullify)
    var originalWorkout: Workout?
    
    init(reps: [Int], weight: [Double], session: WorkoutSession?, originalWorkout: Workout?) {
        self.reps = reps
        self.weight = weight
        self.session = session
        self.originalWorkout = originalWorkout
    }
    
}
