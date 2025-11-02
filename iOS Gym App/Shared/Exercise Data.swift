import SwiftData
import Foundation
import Observation

@Model
final class Exercise {
    
    var name: String = ""
    var muscleWorked: String?
    
    var updateDates: [Date] = []
    var rest: [[Int]] = []
    var reps: [[Int]] = []
    var weights: [[Double]] = []
    
    var equipment: String?
    var created = Date()
    var modified = Date()
    
    @Relationship(deleteRule: .nullify)
    var workouts: [Workout]?
    @Relationship(deleteRule: .cascade)
    var sessionEntries: [WorkoutSessionEntry]? = []
    
    init(name: String, rest: [[Int]], muscleWorked: String?, weights: [[Double]], reps: [[Int]], equipment: String?) {
        self.name = name
        self.rest = rest
        self.muscleWorked = muscleWorked
        self.weights = weights
        self.reps = reps
        self.equipment = equipment
    }
    
    var muscleInfo: MuscleGroup? {
        if let muscleWorked {
            Muscle(rawValue: muscleWorked)?.specific
        } else {
            nil
        }
    }
    
    var workoutEquipment: WorkoutEquipment? {
        if let equipment {
            WorkoutEquipment(rawValue: equipment)
        } else {
            nil
        }
    }
        
}
