import SwiftUI

struct SessionData: Identifiable, Hashable, Equatable {
    
    let id = UUID()
    let exercise: Exercise
    var entry: WorkoutSessionEntry
    
}

enum TimerType: String, CaseIterable, Identifiable {
    
    case liveActivities = "Live Activities"
    case notifications  = "Notifications"
    case timer          = "Timer Only"
    case none           = "None"
    
    var id : String { rawValue }
    
    var imageName: String {
        switch self {
        case .liveActivities: return "rectangle.3.group"
        case .notifications: return "bell.badge"
        case .timer: return "clock"
        case .none: return "circle.slash"
        }
    }
    
}

enum WeightChangeType: String, CaseIterable, Identifiable {
    
    case half            = "0.5"
    case twoAndAHalf     = "2.5"
    case ten             = "10"
    case twentyFive      = "25"
    
    var id : String { rawValue }
    
    var weightChange: Double {
        switch self {
        case .half: return 0.5
        case .twoAndAHalf: return 2.5
        case .ten: return 10
        case .twentyFive: return 25
        }
    }
    
}
