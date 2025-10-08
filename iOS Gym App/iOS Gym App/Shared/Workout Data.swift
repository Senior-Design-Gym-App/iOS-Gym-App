import SwiftData
import Foundation
import Observation

@Model
final class Workout: Codable {
    
    var name: String = ""
    var muscleWorked: String = ""
    var rest: Int = 0
    var reps: [Int] = []
    var weights: [Double] = []
    
    @Relationship(deleteRule: .nullify)
    var groups: [WorkoutGroup]?
    @Relationship(deleteRule: .cascade)
    var updateData: WorkoutUpdate?
    @Relationship(deleteRule: .cascade)
    var sessionEntries: [WorkoutSessionEntry]? = []
    
    init(name: String, rest: Int, order: Int, muscleWorked: String, weights: [Double], reps: [Int], updateData: WorkoutUpdate?) {
        self.name = name
        self.rest = rest
        self.muscleWorked = muscleWorked
        self.weights = weights
        self.reps = reps
        self.updateData = updateData
    }
    
    enum CodingKeys: String, CodingKey {
        case name, other, sets, rest, order, muscleWorked, weights, reps
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.rest = try container.decode(Int.self, forKey: .rest)
        self.reps = try container.decode([Int].self, forKey: .reps)
        self.muscleWorked = try container.decode(String.self, forKey: .muscleWorked)
        self.weights = try container.decode([Double].self, forKey: .weights)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(rest, forKey: .rest)
        try container.encode(reps, forKey: .reps)
        try container.encode(muscleWorked, forKey: .muscleWorked)
        try container.encode(weights, forKey: .weights)
    }
    
}
