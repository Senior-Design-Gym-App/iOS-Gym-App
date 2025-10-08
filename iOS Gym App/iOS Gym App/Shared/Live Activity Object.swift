import ActivityKit
import SwiftUI

struct WorkoutTimer: ActivityAttributes {
    
    struct Attributes {}
    
    public struct ContentState: Codable, Hashable {
        
        let currentSet: Int
        let timerStart: Date
        
        let setCount: Int
        let restTime: Double
        let workoutName: String
        
    }
    
}

