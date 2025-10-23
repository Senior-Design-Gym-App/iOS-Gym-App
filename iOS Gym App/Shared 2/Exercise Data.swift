import SwiftData
import Foundation
import Observation

@Model
final class Exercise {
    
    var name: String = ""
    var muscleWorked: String = ""
    
    var updateDates: [Date] = []
    var rest: [[Int]] = []
    var reps: [[Int]] = []
    var weights: [[Double]] = []
    
    var equipment: String?
    var created: Date {
        updateDates.first ?? Date()
    }
    
    var muscleInfo: MuscleInfo? {
        guard !muscleWorked.isEmpty else { return nil }
        
        if let muscle = ChestMuscle(rawValue: muscleWorked) {
            return MuscleInfo(muscle: muscle, group: muscle.group)
        }
        
        if let muscle = BackMuscle(rawValue: muscleWorked) {
            return MuscleInfo(muscle: muscle, group: muscle.group)
        }
        
        if let muscle = LegMuscle(rawValue: muscleWorked) {
            return MuscleInfo(muscle: muscle, group: muscle.group)
        }
        
        if let muscle = ShoulderMuscle(rawValue: muscleWorked) {
            return MuscleInfo(muscle: muscle, group: muscle.group)
        }

        if let muscle = BicepMuscle(rawValue: muscleWorked) {
            return MuscleInfo(muscle: muscle, group: muscle.group)
        }

        if let muscle = TricepMuscle(rawValue: muscleWorked) {
            return MuscleInfo(muscle: muscle, group: muscle.group)
        }
        
        if let muscle = CoreMuscle(rawValue: muscleWorked) {
            return MuscleInfo(muscle: muscle, group: muscle.group)
        }
        
        return nil
    }
    
    var setData: [[SetEntry]] {
        guard !reps.isEmpty else { return [] }
        
        var allSessions: [[SetEntry]] = []
        
        for sessionIndex in 0..<reps.count {
            var sessionSets: [SetEntry] = []
            let sessionReps = reps[sessionIndex]
            let sessionRest = rest[sessionIndex]
            let sessionWeights = weights[sessionIndex]
            
            for setIndex in 0..<sessionReps.count {
                sessionSets.append(SetEntry(
                    rest: sessionRest[setIndex],
                    reps: sessionReps[setIndex],
                    weight: sessionWeights[setIndex]
                ))
            }
            allSessions.append(sessionSets)
        }
        
        return allSessions
    }
    
    var workoutEquipment: WorkoutEquipment? {
        if let equipment {
            WorkoutEquipment(rawValue: equipment)
        } else {
            nil
        }
    }
    
    @Relationship(deleteRule: .nullify)
    var workouts: [Workout]?
    @Relationship(deleteRule: .cascade)
    var sessionEntries: [WorkoutSessionEntry]? = []
    
    init(name: String, rest: [[Int]], muscleWorked: String, weights: [[Double]], reps: [[Int]], equipment: String?) {
        self.name = name
        self.rest = rest
        self.muscleWorked = muscleWorked
        self.weights = weights
        self.reps = reps
        self.equipment = equipment
    }
        
}
