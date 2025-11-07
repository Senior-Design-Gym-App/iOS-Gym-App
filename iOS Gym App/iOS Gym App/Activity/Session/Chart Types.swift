import SwiftUI

extension WorkoutSession {
    
    var allmuscleSetData: [DonutData] {
        guard let exercises = exercises else { return [] }
        
        var muscleSetDict: [MuscleGroup: Int] = [:]
        
        for entry in exercises {
            
            let group: MuscleGroup
            
            if let exercise = entry.exercise, let muscleGroup = exercise.muscleGroup {
                group = muscleGroup
            } else {
                group = .unknown
            }
            
            let setCount = entry.setEntry.count
            muscleSetDict[group, default: 0] += setCount
            
            muscleSetDict[group, default: 0] += setCount
        }
        
        return muscleSetDict.map { DonutData(muscle: $0.key, sets: $0.value) }
    }
    
    var recentSetData: [RecentExerciseData] {
        guard let sessionData = exercises else { return [] }
        
        var recentUpdate: [RecentExerciseData] = []
        
        for data in sessionData {
            guard let exercise = data.exercise else { continue }
            if let updateData = exercise.updateData
                .filter({ $0.changeDate < started })
                .sorted(by: { $0.changeDate > $1.changeDate })
                .first {
                recentUpdate.append(RecentExerciseData(exercise: exercise, mostRecentSetData: updateData)
                )
            }
        }
        
        return recentUpdate
    }

}

struct RecentExerciseData: Identifiable, Hashable {
    
    let id = UUID()
    let exercise: Exercise
    let mostRecentSetData: SetChangeData
    
}

struct DonutData: Identifiable, Hashable {
    
    let id = UUID()
    let muscle: MuscleGroup
    var sets: Int
    
}
