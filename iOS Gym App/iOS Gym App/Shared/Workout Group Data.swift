import SwiftData
import FoundationModels

@Model
final class WorkoutGroup: Codable {
    
    var groupName: String = ""
    
    @Relationship(deleteRule: .nullify)
    var workouts: [Workout]? = []
    @Relationship(deleteRule: .nullify)
    var workoutRoutine: [WorkoutRoutine]? = []
    
    init(groupName: String, workouts: [Workout]) {
        self.groupName = groupName
        self.workouts = workouts
    }
    
    enum CodingKeys: String, CodingKey {
        case groupName
        case workouts
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        groupName = try container.decode(String.self, forKey: .groupName)
        workouts = try container.decode([Workout].self, forKey: .workouts)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(groupName, forKey: .groupName)
        try container.encode(workouts, forKey: .workouts)
    }
    
}
