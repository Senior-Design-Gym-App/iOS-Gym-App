import SwiftUI
import SwiftData

@Model
final class WorkoutDay {
    
    var name: String = ""
    
    @Relationship(deleteRule: .nullify)
    var workouts: [Workout]? = []
    @Relationship(deleteRule: .nullify)
    var split: WorkoutSplit?
    var colorHex: String?
    var created: Date = Date()
    
    var sessions: [WorkoutSession]? = []
    
    var tags: [MuscleGroup] {
        var allTags: [MuscleGroup] = []
        for workout in workouts ?? [] {
            if let tag = workout.muscleInfo?.group, allTags.contains(where: { $0.id == tag.id }) == false {
                allTags.append(tag)
            }
        }
        return allTags
    }
    
    var color: Color {
        if let colorHex {
            return Color(hex: colorHex)
        } else {
            return Constants.mainAppTheme
        }
    }
    
    init(groupName: String, workouts: [Workout]) {
        self.name = groupName
        self.workouts = workouts
    }
    
}
