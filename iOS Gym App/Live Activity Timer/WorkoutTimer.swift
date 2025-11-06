import Foundation
import ActivityKit

// Attributes for the workout/rest timer Live Activity
public struct WorkoutTimer: ActivityAttributes {
    // Static, non-changing properties for the activity
    public struct ContentState: Codable, Hashable {
        // Dynamic properties that can change over the life of the activity
        public var exerciseName: String
        public var timerStart: Date
        public var setEntry: SetEntry
        public var currentSet: Int
        public var setCount: Int

        public init(exerciseName: String, timerStart: Date, setEntry: SetEntry, currentSet: Int, setCount: Int) {
            self.exerciseName = exerciseName
            self.timerStart = timerStart
            self.setEntry = setEntry
            self.currentSet = currentSet
            self.setCount = setCount
        }
    }

    // If you have any immutable attributes for the activity, define them here.
    // Leaving empty for now.
    public init() {}
}

// Supporting type referenced by the UI (provides `rest` seconds)
public struct SetEntry: Codable, Hashable {
    public var rest: Int

    public init(rest: Int) {
        self.rest = rest
    }
}
