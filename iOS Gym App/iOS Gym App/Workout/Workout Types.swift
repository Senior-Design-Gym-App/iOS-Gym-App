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

struct SetData: Identifiable, Hashable, Codable {
    
    var id = UUID()
    let set: Int
    let rest: Int
    let reps: Int
    let weight: Double
    
    var setDouble: Double {
        Double(set) + 1.0
    }
    
}

struct SetChangeData: Identifiable, Hashable {
    
    let id = UUID()
    let changeDate: Date
    let setData: [SetData]
    
}

enum MuscleGroup: String, CaseIterable, Identifiable {
    
    case chest           = "Chest"
    case back            = "Back"
    case legs            = "Legs"
    case shoulders       = "Shoulders"
    case biceps          = "Biceps"
    case triceps         = "Triceps"
    case core            = "Core"
    case forearm         = "Forearm"
    case general         = "General"
    case unknown         = "Unknown"

    var id: String { rawValue }
    
    var colorPalette: Color {
        switch self {
        case .chest:
            AppColors.slateBlue.color
        case .back:
            AppColors.unitedNationsBlue.color
        case .legs:
            AppColors.pictonBlue.color
        case .shoulders:
            AppColors.aero.color
        case .biceps:
            AppColors.skyBlue.color
        case .triceps:
            AppColors.tiffanyBlue.color
        case .core:
            AppColors.turquoise.color
        case .forearm:
            AppColors.aquamarine.color
        case .general:
            Color.white
        case .unknown:
            Color.white
        }
    }
    
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
    
    // Shoulders
    case shoulder           = "Shoulders"
    case anteriorDeltoid    = "Anterior Deltoid"
    case lateralDeltoid     = "Lateral Deltoid"
    case posteriorDeltoid   = "Posterior Deltoid"
    case rotatorCuff        = "Rotator Cuff"
    case supraspinatus      = "Supraspinatus"
    case subscapularis      = "Subscapularis"
    
    // Biceps
    case bicep              = "Biceps"
    case bicepsBrachii      = "Biceps Brachii"
    case brachialis         = "Brachialis"
    case brachioradialis    = "Brachioradialis"
    
    // Triceps
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
    
    // Forearm
    case forearm                = "Forearm"
    case flexorCarpiRadialis    = "Flexor Carpi Radialis"
    case flexorCarpiUlnaris     = "Flexor Carpi Ulnaris"
    case palmarisLongus         = "Palmaris Longus"
    case flexorDigitorumSuperficialis = "Flexor Digitorum Superficialis"
    case flexorDigitorumProfundus      = "Flexor Digitorum Profundus"
    case extensorCarpiRadialisLongus   = "Extensor Carpi Radialis Longus"
    case extensorCarpiUlnaris          = "Extensor Carpi Ulnaris"
    case extensorDigitorum             = "Extensor Digitorum"
    case extensorPollicisLongus        = "Extensor Pollicis Longus"
    case pronatorTeres                 = "Pronator Teres"
    case supinator                     = "Supinator"
    
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
        case .flexorCarpiRadialis, .flexorCarpiUlnaris, .palmarisLongus,
             .flexorDigitorumSuperficialis, .flexorDigitorumProfundus,
             .extensorCarpiRadialisLongus, .extensorCarpiUlnaris, .extensorDigitorum,
             .extensorPollicisLongus, .pronatorTeres, .supinator:
            .forearm
        case .chest, .back, .legs, .shoulder, .bicep, .tripcep, .core, .forearm:
            .general
        }
    }
    
    var specific: MuscleGroup {
        switch self {
        case .chest, .pectoralisMajor, .pectoralisMinor, .serratusAnterior:
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
        case .forearm,
             .flexorCarpiRadialis, .flexorCarpiUlnaris, .palmarisLongus,
             .flexorDigitorumSuperficialis, .flexorDigitorumProfundus,
             .extensorCarpiRadialisLongus, .extensorCarpiUlnaris, .extensorDigitorum,
             .extensorPollicisLongus, .pronatorTeres, .supinator:
            .forearm
        }
    }
}

enum WorkoutEquipment: String, CaseIterable, Identifiable {
    
    // MARK: - Bodyweight
    case bodyWeight      = "Body Weight"
    case weightedVest    = "Weighted Vest"
    case pullupBar       = "Pullup Bar"
    
    // MARK: - Free Weights
    case dumbbells       = "Dumbbells"
    case barbell         = "Barbell"
    case kettlebell      = "Kettlebell"
    case resistanceBands = "Resistance Bands"
    case medicineBall    = "Medicine Ball"
    case trapBar         = "Trap Bar"
    case ezBar           = "EZ Bar"
    
    // MARK: - Machines
    case plateLoadedMachine = "Plate-Loaded Machine"
    case pinLoadedMachine   = "Pin-Loaded Machine"
    case smithMachine       = "Smith Machine"
    case sled               = "Sled"
    
    // MARK: - Cable Attachments
    case cable          = "Cable Tower"
    case ropeAttachment = "Rope Attachment"
    case dGrip          = "D-Grip"
    case dualDGrip      = "Dual D-Grip"
    case vBar           = "V-Bar"
    case ankleStrap     = "Ankle Strap"
    case straightBar    = "Straight Bar"
    
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
        case .pinLoadedMachine:
            "slider.horizontal.3"
        case .sled:
            "figure.highintensity.intervaltraining"
        case .weightedVest:
            "jacket"
        case .pullupBar:
            "figure.play"
        case .cable:
            "cable.coaxial"
        case .trapBar:
            "hexagon"
        case .ezBar:
            "w.circle"
        case .plateLoadedMachine:
            "ring.circle"
        case .smithMachine:
            "rectangle.split.3x3"
        case .ropeAttachment:
            "scribble"
        case .dGrip:
            "d.circle"
        case .dualDGrip:
            "circle.grid.2x1"
        case .vBar:
            "chevron.up"
        case .ankleStrap:
            "shoe"
        case .straightBar:
            "minus"
        }
    }
    
    var category: EquipmentCategory {
        switch self {
        case .bodyWeight, .weightedVest, .pullupBar:
            .bodyweight
        case .dumbbells, .barbell, .kettlebell, .resistanceBands, .medicineBall, .trapBar, .ezBar:
            .freeWeight
        case .plateLoadedMachine, .pinLoadedMachine, .smithMachine, .sled:
            .machine
        case .cable, .ropeAttachment, .dGrip, .dualDGrip, .vBar, .ankleStrap, .straightBar:
            .cableAttachment
        }
    }
    
}

enum EquipmentCategory: String, CaseIterable {
    case bodyweight      = "Bodyweight"
    case freeWeight      = "Free Weight"
    case machine         = "Machine"
    case cableAttachment = "Cable Attachment"
    case accessory       = "Accessory"
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
