import SwiftData
import Foundation
import Observation

@Model
final class Workout {
    
    var name: String = ""
    var muscleWorked: String = ""
    var rest: [Int] = []
    var reps: [Int] = []
    var weights: [Double] = []
    var equipment: String?
    
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
    
    var setData: [SetEntry] {
        var data: [SetEntry] = []
        for i in 0..<reps.count {
            data.append(SetEntry(rest: rest[i], reps: reps[i], weight: weights[i]))
        }
        return data
    }
    
    var workoutEquipment: WorkoutEquipment? {
        if let equipment {
            WorkoutEquipment(rawValue: equipment)
        } else {
            nil
        }
    }
    
    @Relationship(deleteRule: .nullify)
    var days: [WorkoutDay]?
    @Relationship(deleteRule: .cascade)
    var updateData: WorkoutUpdate?
    @Relationship(deleteRule: .cascade)
    var sessionEntries: [WorkoutSessionEntry]? = []
    
    init(name: String, rest: [Int], muscleWorked: String, weights: [Double], reps: [Int], updateData: WorkoutUpdate?, equipment: String?) {
        self.name = name
        self.rest = rest
        self.muscleWorked = muscleWorked
        self.weights = weights
        self.reps = reps
        self.updateData = updateData
        self.equipment = equipment
    }
        
}
