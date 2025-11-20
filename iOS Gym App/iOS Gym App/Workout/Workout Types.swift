import Foundation
import SwiftUI

enum WorkoutSortTypes: String, CaseIterable, Identifiable {
    
    case alphabetical       = "A-Z"
    case created            = "Created"
    case modified           = "Modified"
    
    var id : String { rawValue }
    
}

enum WorkoutViewTypes: String, CaseIterable, Identifiable {
    
    case grid              = "Grid"
    case verticalList      = "List"
    
    var id : String { rawValue }
    
    var imageName: String {
        switch self {
        case .verticalList:
            "list.bullet"
        case .grid:
            "square.grid.2x2"
        }
    }
    
}

struct SetChangeData: Identifiable, Hashable {
    
    let id = UUID()
    let changeDate: Date
    let setData: [SetData]
    
}

enum WorkoutItemType: String {
    
    case exercise   = "Exercise"
    case workout    = "Workout"
    case split      = "Split"
    case session    = "Session"
    
    var editType: String {
        switch self {
        case .exercise:
            return "Edit Sets"
        case .workout:
            return "Edit Exercises"
        case .split:
            return "Edit Workouts"
            case .session:
            return "Edit Workouts"
        }
    }
    
    var addType: String {
        switch self {
        case .exercise:
            return "Add Sets"
        case .workout:
            return "Add Exercises"
        case .split:
            return "Add Workouts"
        case .session:
            return "Add Session"
        }
    }
    
    var listLabel: String {
        switch self {
        case .exercise:
            return "Set"
        case .workout:
            return "Exercise"
        case .split:
            return "Workout"
        case .session:
            return "Sessions"
        }
    }
    
    var deleteOption: String {
        switch self {
        case .exercise:
            return "This will be removed from all sessions and all history will be lost."
        case .workout:
            return "This will be removed from all sessions and all splits. The exercises will not be deleted."
        case .split:
            return "This will be removed but all the workouts will still remain."
        case .session:
            return "This will be removed from your sessions and all session progress will be lost."
        }
    }
    
}
