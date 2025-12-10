import ActivityKit
import SwiftUI

struct WorkoutTimer: ActivityAttributes {
    
    struct Attributes {}
    
    public struct ContentState: Codable, Hashable {
        
        let timerStart: Date
        let sessionName: String
        let sessionStartDate: Date
        let currentExercise: SessionData
        
    }
    
}

