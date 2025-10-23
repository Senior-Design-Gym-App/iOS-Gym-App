import SwiftUI
import SwiftData

struct WeightEntry: Hashable, Identifiable, Codable, Equatable {
    var id: Int { index }
    let index: Int
    let value: Double
    let date: Date
}

enum HealthKitType {
    case bodyWeight
    case bodyFat
}

struct SharedProgressData: Codable, Equatable, Hashable {
    
    let unit: String
    let name: String
    let sharedDate: Date
    let pr: [WeightEntry]
    let reps: [WeightEntry]
    
}

enum DataChangeType {
    
    case increase
    case decrease
    case same
    case firstEntry
    
}

enum UpdateType {
    
    case weights
    case reps
    case sets
    case setsAndReps
    case setsAndWeight
    case repsAndWeight
    case all
    case none
    
}
