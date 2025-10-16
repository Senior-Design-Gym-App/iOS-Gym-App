import Foundation

enum WorkoutSortTypes: String, CaseIterable, Identifiable {
    
    case alphabetical       = "A-Z"
    case created            = "Created"
    case modified           = "Modified"
    case pinned             = "Pinned"
    case tags               = "Tags"
    case muscleGroups       = "Muscles Worked"
    
    var id : String { rawValue }
    
}

enum WorkoutViewTypes: String, CaseIterable, Identifiable {
    
    case verticalList      = "Vertical List"
    case grid              = "Grid"
    case horizontalList    = "Horizontal List"
    
    var id : String { rawValue }
    
    var imageName: String {
        switch self {
        case .verticalList:
            "list.bullet"
        case .grid:
            "square.grid.2x2"
        case .horizontalList:
            "rectangle.grid.3x2"
        }
    }
    
}

struct SetEntry: Identifiable, Hashable {
    
    let id = UUID()
    var reps: Int
    var weight: Double
    
}

struct MuscleInfo {
    
    let muscle: any Muscle
    let group: MuscleGroup
    
}

enum MuscleGroup: String, CaseIterable, Identifiable {
    case chest
    case back
    case legs
    case shoulders
    case arms
    case core

    var id: String { rawValue }
}

protocol Muscle: CaseIterable, Identifiable, RawRepresentable where RawValue == String {
    var group: MuscleGroup { get }
}

extension Muscle {
    var id: String { rawValue }
}

enum BackMuscle: String, CaseIterable, Muscle {
    case lats
    case traps
    case rhomboids
    case erectorSpinae
    
    var group: MuscleGroup { .back }
}

enum ChestMuscle: String, CaseIterable, Muscle {
    case pectoralisMajor
    case pectoralisMinor
    
    var group: MuscleGroup { .chest }
}

enum LegMuscle: String, CaseIterable, Muscle {
    case quadriceps
    case hamstrings
    case glutes
    case calves
    
    var group: MuscleGroup { .legs }
}
