import SwiftUI
import SwiftData

@Model
final class Workout {
    
    var name: String = ""
    
    @Relationship(deleteRule: .nullify)
    var exercises: [Exercise]? = []
    @Relationship(deleteRule: .nullify)
    var split: Split?
    var created: Date = Date()
    
    var sessions: [WorkoutSession]? = []
    
    var tags: [MuscleGroup] {
        var allTags: [MuscleGroup] = []
        for exercise in exercises ?? [] {
            if let tag = exercise.muscleInfo?.group, allTags.contains(where: { $0.id == tag.id }) == false {
                allTags.append(tag)
            }
        }
        return allTags
    }
    
    init(groupName: String, exercises: [Exercise]) {
        self.name = groupName
        self.exercises = exercises
    }
    
}
