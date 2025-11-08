import SwiftData
import SwiftUI
import Foundation

@Model
final class WorkoutSession {
    
    @Transient
    var id = UUID()
    
    var name: String = ""
    var started: Date = Date()
    var completed: Date?
    var selectedGymID: String?
    
    var workout: Workout?
    var color: Color {
        if let workout {
            workout.color
        } else {
            Constants.mainAppTheme
        }
    }
    
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
    
    @Transient
    var id = UUID()
    
    var reps: [Int] = []
    var weight: [Double] = []
    var setEntry: [SetData] {
        let count = min(reps.count, weight.count)
        var all: [SetData] = []
        for i in 0..<count {
            let new = SetData(set: i, rest: i, reps: reps[i], weight: weight[i])
            all.append(new)
        }
        return all
    }
    
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
