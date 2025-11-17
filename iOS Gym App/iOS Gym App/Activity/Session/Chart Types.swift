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

struct DonutData: Identifiable, Hashable {
    
    let id = UUID()
    let muscle: MuscleGroup
    var sets: Int
    
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
