import SwiftUI
import SwiftData

@Model
final class Workout: Codable {
    
    var name: String = ""
    
    @Relationship(deleteRule: .nullify)
    var exercises: [Exercise]? = []
    @Relationship(deleteRule: .nullify)
    var split: Split?
    var created: Date = Date()
    var modified: Date = Date()
    
    var color: Color {
        guard let exercises else {
            return Constants.mainAppTheme
        }
        let color = exercises.map({ $0.color })
        return color.averageColor()
    }
    
    var sessions: [WorkoutSession]? = []
    
    var tags: [MuscleGroup] {
        var allTags: [MuscleGroup] = []
        for exercise in exercises ?? [] {
            if let tag = exercise.muscleGroup, allTags.contains(where: { $0.id == tag.id }) == false {
                allTags.append(tag)
            }
        }
        return allTags
    }
    
    init(name: String, exercises: [Exercise]) {
        self.name = name
        self.exercises = exercises
    }
    
    enum CodingKeys: String, CodingKey {
        case name, exercises, split
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(exercises, forKey: .exercises)
        try container.encode(split, forKey: .split)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        exercises = try container.decodeIfPresent([Exercise].self, forKey: .exercises)
        split = try container.decodeIfPresent(Split.self, forKey: .split)
    }
    
}
