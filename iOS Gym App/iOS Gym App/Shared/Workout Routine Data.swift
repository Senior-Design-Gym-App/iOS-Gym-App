import SwiftUI
import SwiftData
import FoundationModels

@Model
final class WorkoutRoutine {
    
    var name: String = ""
    @Relationship(deleteRule: .nullify)
    var groups: [WorkoutGroup]? = []
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
    
    init(name: String, groups: [WorkoutGroup]? = nil, created: Date, modified: Date, imageData: Data? = nil, pinned: Bool) {
        self.name = name
        self.groups = groups
        self.created = created
        self.modified = modified
        self.imageData = imageData
        self.pinned = pinned
    }
    
}
