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
    
    var image: UIImage? {
        get {
            guard let imageData else { return nil }
            return UIImage(data: imageData)
        }
    }
    
    var color: Color {
        Constants.mainAppTheme
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
