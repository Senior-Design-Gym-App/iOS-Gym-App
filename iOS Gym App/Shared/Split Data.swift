import SwiftUI
import SwiftData

@Model
final class Split {
    
    var name: String = ""
    @Relationship(deleteRule: .nullify)
    var workouts: [Workout]? = []
    var created: Date = Date.now
    var modified: Date = Date.now
    var imageData: Data?
    var pinned: Bool = false
    
    var image: UIImage? {
        get {
            guard let imageData else { return nil }
            return UIImage(data: imageData)
        }
    }
    
    init(name: String, workouts: [Workout]? = nil, created: Date, modified: Date, imageData: Data? = nil, pinned: Bool) {
        self.name = name
        self.workouts = workouts
        self.created = created
        self.modified = modified
        self.imageData = imageData
        self.pinned = pinned
    }
    
}
