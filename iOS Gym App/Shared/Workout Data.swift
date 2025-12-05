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
    private var orderString: String = ""
    
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
    
    var sortedExercises: [Exercise] {
        guard let exercises else {
            return []
        }

        guard !orderString.isEmpty,
              let data = orderString.data(using: .utf8),
              let ids = try? JSONDecoder().decode([PersistentIdentifier].self, from: data)
        else {
            return exercises
        }

        var ordered: [Exercise] = []
        var usedExercises = Set<Exercise>()

        for id in ids {
            if let exercise = exercises.first(where: { $0.id == id }) {
                ordered.append(exercise)
                usedExercises.insert(exercise)
            }
        }

        let remaining = exercises.filter { !usedExercises.contains($0) }
        return ordered + remaining
    }
    
    func encodeIDs(ids: [PersistentIdentifier]) {
        do {
            let data = try JSONEncoder().encode(ids)
            orderString = String(decoding: data, as: UTF8.self)
        } catch {
            print("Failed to encode IDs:", error)
        }
    }
    
    init(name: String, exercises: [Exercise]) {
        self.name = name
        self.exercises = exercises
    }
    
    enum CodingKeys: String, CodingKey {
        case name, exercises, split
    }
    
    func encode(to encoder: Encoder) throws {
        //print("ENCODING WORKOUT:", name)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        //print(" -> encoded name")

        try container.encode(exercises, forKey: .exercises)
        //print(" -> encoded exercises")

        try container.encode(split, forKey: .split)
        //print(" -> encoded split")
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        exercises = try container.decodeIfPresent([Exercise].self, forKey: .exercises)
        split = try container.decodeIfPresent(Split.self, forKey: .split)
    }
    
}
/*
 Make a couple exercies
 Different workouts into different splits
 encode one of the splits
 */
