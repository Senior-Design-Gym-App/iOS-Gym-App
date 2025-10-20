import Foundation
import SwiftData

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

struct SetEntry: Identifiable, Hashable, Codable {
    
    var id = UUID()
    var rest: Int
    var reps: Int
    var weight: Double
    
}

struct MuscleInfo {
    
    let muscle: any Muscle
    let group: MuscleGroup
    
}

enum MuscleGroup: String, CaseIterable, Identifiable {
    
    case chest           = "Chest"
    case back            = "Back"
    case legs            = "Legs"
    case shoulders       = "Shoulders"
    case biceps          = "Biceps"
    case triceps         = "Triceps"
    case core            = "Core"

    var id: String { rawValue }
}

protocol Muscle: CaseIterable, Identifiable, Hashable ,RawRepresentable where RawValue == String {
    var group: MuscleGroup { get }
}

extension Muscle {
    var id: String { rawValue }
}

enum ChestMuscle: String, CaseIterable, Muscle {
    
    case pectoralisMajor    = "Pectoralis Major"
    case pectoralisMinor    = "Pectoralis Minor"
    case serratusAnterior   = "Serratus Anterior"

    var group: MuscleGroup { .chest }
    
}

enum BackMuscle: String, CaseIterable, Muscle {
    
    case lats               = "Latissimus Dorsi"
    case traps              = "Trapezius"
    case rhomboids          = "Rhomboids"
    case erectorSpinae      = "Erector Spinae"
    case teresMajor         = "Teres Major"
    case teresMinor         = "Teres Minor"
    case infraspinatus      = "Infraspinatus"

    var group: MuscleGroup { .back }

}

enum LegMuscle: String, CaseIterable, Muscle {
    
    case quadriceps         = "Quadriceps"
    case hamstrings         = "Hamstrings"
    case glutes             = "Glutes"
    case calves             = "Calves"
    case adductors          = "Adductors"
    case abductors          = "Abductors"
    case hipFlexors         = "Hip Flexors"
    case tibialisAnterior   = "Tibialis Anterior"

    var group: MuscleGroup { .legs }

}

enum ShoulderMuscle: String, CaseIterable, Muscle {
    
    case anteriorDeltoid    = "Anterior Deltoid"
    case lateralDeltoid     = "Lateral Deltoid"
    case posteriorDeltoid   = "Posterior Deltoid"
    case rotatorCuff        = "Rotator Cuff"
    case supraspinatus      = "Supraspinatus"
    case subscapularis      = "Subscapularis"

    var group: MuscleGroup { .shoulders }

}

enum BicepMuscle: String, CaseIterable, Muscle {
    
    case bicepsBrachii      = "Biceps Brachii"
    case brachialis         = "Brachialis"
    case brachioradialis    = "Brachioradialis"

    var group: MuscleGroup { .biceps }

}

enum TricepMuscle: String, CaseIterable, Muscle {
    
    case tricepsLongHead    = "Long Head"
    case tricepsLateralHead = "Lateral Head"
    case tricepsMedialHead  = "Medial Head"

    var group: MuscleGroup { .triceps }

}

enum CoreMuscle: String, CaseIterable, Muscle {
    
    case rectusAbdominis    = "Rectus Abdominis"
    case obliques           = "Obliques"
    case transverseAbdominis = "Transverse Abdominis"
    case lowerBack          = "Lower Back"
    case pelvicFloor        = "Pelvic Floor"

    var group: MuscleGroup { .core }

}

enum WorkoutEquipment: String, CaseIterable, Identifiable {
    
    case bodyWeight      = "Body Weight"
    case dumbbells      = "Dumbbells"
    case barbell        = "Barbell"
    case kettlebell      = "Kettlebell"
    case resistanceBands = "Resistance Bands"
    case medicineBall    = "Medicine Ball"
    case machine         = "Machine"
    case sled            = "Sled"
    case weightedVest    = "Weighted Vest"
    case pullupBar       = "Pullup Bar"
    case cable           = "Cable"
    
    var id: String { rawValue }
    
    var imageName: String {
        switch self {
        case .bodyWeight:
            "figure.core.training"
        case .dumbbells:
            "dumbbell"
        case .barbell:
            "figure.strengthtraining.traditional"
        case .kettlebell:
            "scalemass"
        case .resistanceBands:
            "figure.strengthtraining.functional"
        case .medicineBall:
            "rotate.3d"
        case .machine:
            "server.rack"
        case .sled:
            "figure.highintensity.intervaltraining"
        case .weightedVest:
            "jacket"
        case .pullupBar:
            "figure.play"
        case .cable:
            "cable.coaxial"
        }
    }
    
}

enum RecentWorkoutItem: Hashable, Identifiable {
    
    case day(WorkoutDay)
    case split(WorkoutSplit)
    
    var created: Date {
        switch self {
        case .day(let day):
            return day.created
        case .split(let split):
            return split.created
        }
    }
    
    var id: String {
        switch self {
        case .day(let day):
            return "day-\(day.persistentModelID)"
        case .split(let split):
            return "split-\(split.persistentModelID)"
        }
    }
    
}
