import SwiftUI

struct SessionData: Identifiable, Hashable, Equatable {
    
    let id = UUID()
    let workout: Workout
    var entry: WorkoutSessionEntry
    
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

enum SessionViewOption: String, CaseIterable, Identifiable {
    
    case entry           = "Entry"
    case queue           = "Queue"
    
    var id : String { rawValue }
    
}
