import SwiftUI

extension WorkoutSession {
    
    var recentSetData: [RecentExerciseData] {
        guard let sessionData = exercises else { return [] }
        
        var recentUpdate: [RecentExerciseData] = []
        
        for data in sessionData {
            guard let exercise = data.exercise else { continue }
            if let updateData = exercise.updateData
                .filter({ $0.changeDate < started })
                .sorted(by: { $0.changeDate > $1.changeDate })
                .first {
                recentUpdate.append(RecentExerciseData(exercise: exercise, mostRecentSetData: updateData)
                )
            }
        }
        
        return recentUpdate
    }
    
}

struct RecentExerciseData: Identifiable, Hashable {
    
    let id = UUID()
    let exercise: Exercise
    let mostRecentSetData: SetChangeData
    
}

struct DonutData: Identifiable {
    var id: MuscleGroup { muscle }  // Use muscle as the stable ID
    let muscle: MuscleGroup
    let sets: Int
}

enum ChartGraphType: String, CaseIterable, Identifiable {
    
    case session = "Session"
    case expected = "Expected"
    case average = "Average"
    case current  = "Current"
    
    var id : String { self.rawValue }
    
    var description: String {
        switch self {
        case .session:
            "This Session"
        case .average:
            "Prior 5 Sessions"
        case .current:
            "Current"
        case .expected:
            "Expected"
        }
    }
    
    var color: Color {
        switch self {
        case .session:
            WorkoutCharColors.celadon1.color
        case .expected:
            WorkoutCharColors.mint2.color
        case .average:
            WorkoutCharColors.zomp2.color
        case .current:
            WorkoutCharColors.pineGreen.color
        }
    }
    
}

enum DonutDisplayType: String, Identifiable, CaseIterable {
    
    case sets = "Sets"
    case reps = "Reps"
    case weight = "Weight"
    case volume = "Volume"
    
    var id: String { self.rawValue }
    
    var unit: String {
        switch self {
        case .sets:
            "Set"
        case .reps:
            "Rep"
        case .volume, .weight:
            Locale.current.measurementSystem == .metric ? "kg" : "lb"
        }
    }
    
}
