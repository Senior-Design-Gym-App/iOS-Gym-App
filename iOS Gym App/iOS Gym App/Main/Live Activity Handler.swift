import Observation
import Foundation
import ActivityKit

extension SessionManager {
    
    func UpdateLiveActivity(exercise: Exercise) {
        let set = SetEntry(index: 0, rest: rest, reps: reps, weight: weight)

        if exerciseTimer?.content.state != nil {
            
            let updatedState = WorkoutTimer.ContentState(currentSet: currentSet, timerStart: Date.now, setEntry: set, setCount: currentSet, exerciseName: exercise.name)
            
            Task {
                await exerciseTimer?.update(ActivityContent(state: updatedState, staleDate: nil))
            }
            
        } else {
            let startTime = Date.now
            let attributes = WorkoutTimer()

            let initialState = WorkoutTimer.ContentState(currentSet: currentSet, timerStart: Date.now, setEntry: set, setCount: exercise.weights.count, exerciseName: exercise.name)
            do {
                exerciseTimer = try Activity.request(attributes: attributes, content: ActivityContent(state: initialState, staleDate: startTime.addingTimeInterval(TimeInterval(60 * 60))))
            } catch {
                print("Error starting live activity: \(error)")
            }
            
        }
    }
    
    func EndLiveActivity() {
        guard let currentState = exerciseTimer?.content.state else { return }
        
        let finalState = WorkoutTimer.ContentState(
            currentSet: 999,
            timerStart: currentState.timerStart,
            setEntry: currentState.setEntry,
            setCount: currentState.setCount,
            exerciseName: currentState.exerciseName
        )
        
        Task {
            await exerciseTimer?.end(ActivityContent(state: finalState, staleDate: nil), dismissalPolicy: .default)
        }
    }
    
}
