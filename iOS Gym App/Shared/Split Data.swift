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
    
}
