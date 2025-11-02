import Foundation

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

struct SetEntry: Identifiable, Hashable, Codable {
    
    var id = UUID()
    var index: Int
    var rest: Int
    var reps: Int
    var weight: Double
    
}

enum MuscleGroup: String, CaseIterable, Identifiable {
    
    case chest           = "Chest"
    case back            = "Back"
    case legs            = "Legs"
    case shoulders       = "Shoulders"
    case biceps          = "Biceps"
    case triceps         = "Triceps"
    case core            = "Core"
    case general         = "General"

    var id: String { rawValue }
}

enum Muscle: String, CaseIterable, Identifiable, Hashable {
    
    // Chest
    case chest              = "Chest"
    case pectoralisMajor    = "Pectoralis Major"
    case pectoralisMinor    = "Pectoralis Minor"
    case serratusAnterior   = "Serratus Anterior"
    
    // Back
    case back               = "Back"
    case lats               = "Latissimus Dorsi"
    case traps              = "Trapezius"
    case rhomboids          = "Rhomboids"
    case erectorSpinae      = "Erector Spinae"
    case teresMajor         = "Teres Major"
    case teresMinor         = "Teres Minor"
    case infraspinatus      = "Infraspinatus"
    
    // Legs
    case legs               = "Legs"
    case quadriceps         = "Quadriceps"
    case hamstrings         = "Hamstrings"
    case glutes             = "Glutes"
    case calves             = "Calves"
    case adductors          = "Adductors"
    case abductors          = "Abductors"
    case hipFlexors         = "Hip Flexors"
    case tibialisAnterior   = "Tibialis Anterior"
    
    // Shoulder
    case shoulder           = "Shoulders"
    case anteriorDeltoid    = "Anterior Deltoid"
    case lateralDeltoid     = "Lateral Deltoid"
    case posteriorDeltoid   = "Posterior Deltoid"
    case rotatorCuff        = "Rotator Cuff"
    case supraspinatus      = "Supraspinatus"
    case subscapularis      = "Subscapularis"
    
    // Bicep
    case bicep              = "Biceps"
    case bicepsBrachii      = "Biceps Brachii"
    case brachialis         = "Brachialis"
    case brachioradialis    = "Brachioradialis"
    
    // Tricep
    case tripcep            = "Triceps"
    case tricepsLongHead    = "Long Head"
    case tricepsLateralHead = "Lateral Head"
    case tricepsMedialHead  = "Medial Head"
    
    // Core
    case core               = "Core"
    case rectusAbdominis    = "Rectus Abdominis"
    case obliques           = "Obliques"
    case transverseAbdominis = "Transverse Abdominis"
    case lowerBack          = "Lower Back"
    case pelvicFloor        = "Pelvic Floor"
    
    var id: String { rawValue }
    
    var general: MuscleGroup {
        switch self {
        case .pectoralisMajor, .pectoralisMinor, .serratusAnterior:
                .chest
        case .lats, .traps, .rhomboids, .erectorSpinae, .teresMajor, .teresMinor, .infraspinatus:
                .back
        case .quadriceps, .hamstrings, .glutes, .calves, .adductors, .abductors, .hipFlexors, .tibialisAnterior:
                .legs
        case .anteriorDeltoid, .lateralDeltoid, .posteriorDeltoid, .rotatorCuff, .supraspinatus, .subscapularis:
                .shoulders
        case .bicepsBrachii, .brachialis, .brachioradialis:
                .biceps
        case .tricepsLongHead, .tricepsLateralHead, .tricepsMedialHead:
                .triceps
        case .rectusAbdominis, .obliques, .transverseAbdominis, .lowerBack, .pelvicFloor:
                .core
        case .chest, .back, .legs, .shoulder, .bicep, .tripcep, .core:
                .general
        }
    }
    
    var specific: MuscleGroup {
        switch self {
        case  .chest, .pectoralisMajor, .pectoralisMinor, .serratusAnterior:
                .chest
        case .back, .lats, .traps, .rhomboids, .erectorSpinae, .teresMajor, .teresMinor, .infraspinatus:
                .back
        case .legs, .quadriceps, .hamstrings, .glutes, .calves, .adductors, .abductors, .hipFlexors, .tibialisAnterior:
                .legs
        case .shoulder, .anteriorDeltoid, .lateralDeltoid, .posteriorDeltoid, .rotatorCuff, .supraspinatus, .subscapularis:
                .shoulders
        case .bicep, .bicepsBrachii, .brachialis, .brachioradialis:
                .biceps
        case .tripcep, .tricepsLongHead, .tricepsLateralHead, .tricepsMedialHead:
                .triceps
        case .core, .rectusAbdominis, .obliques, .transverseAbdominis, .lowerBack, .pelvicFloor:
                .core
        }
    }
    
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

enum WorkoutItemType: String {
    
    case exercise   = "Exercise"
    case workout    = "Workout"
    case split      = "Split"
    
    var editType: String {
        switch self {
        case .exercise:
            return "Edit Sets"
        case .workout:
            return "Edit Exercises"
        case .split:
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
        }
    }
    
}
