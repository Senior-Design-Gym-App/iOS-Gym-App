import SwiftUI
import SwiftData

@Model
final class Split: Codable {
    
    var name: String = ""
    @Relationship(deleteRule: .nullify)
    var workouts: [Workout]? = []
    var created: Date = Date.now
    var modified: Date = Date.now
    var imageData: Data?
    var active: Bool = false
    private var orderString: String = ""
    
    var image: UIImage? {
        get {
            guard let imageData else { return nil }
            return UIImage(data: imageData)
        }
    }
    
    var color: Color {
        Constants.mainAppTheme
    }
    
    var sortedWorkouts: [Workout] {
        guard let workouts else { return [] }
        
        guard !orderString.isEmpty, let data = orderString.data(using: .utf8), let ids = try? JSONDecoder().decode([PersistentIdentifier].self, from: data)
        else {
            return workouts
        }
        
        var ordered: [Workout] = []
        var usedWorkouts = Set<Workout>()
        
        for id in ids {
            if let workout = workouts.first(where: { $0.id == id }) {
                ordered.append(workout)
                usedWorkouts.insert(workout)
            }
        }
        
        let remaining = workouts.filter { !usedWorkouts.contains($0) }
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
    
    init(name: String, workouts: [Workout]? = nil, imageData: Data? = nil, active: Bool) {
        self.name = name
        self.workouts = workouts
        self.imageData = imageData
        self.active = active
    }
    
    enum CodingKeys: String, CodingKey {
        case name, workouts
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(workouts, forKey: .workouts)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        workouts = try container.decodeIfPresent([Workout].self, forKey: .workouts)
    }
    
}
