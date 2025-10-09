import Observation
import Foundation
import ActivityKit

extension SessionManager {
    
    func UpdateLiveActivity(workout: Workout, currentSet: Int) {
        if exerciseTimer?.content.state != nil {
            
            let updatedState = WorkoutTimer.ContentState(currentSet: currentSet, timerStart: Date.now, setCount: workout.weights.count, restTime: Double(workout.rest), workoutName: workout.name)
            
            Task {
                await exerciseTimer?.update(ActivityContent(state: updatedState, staleDate: nil))
            }
            
        } else {
            let startTime = Date.now
                        
            let attributes = WorkoutTimer()
            
            let initialState = WorkoutTimer.ContentState(currentSet: currentSet, timerStart: Date.now, setCount: workout.weights.count, restTime: Double(workout.rest), workoutName: workout.name)

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
            setCount: currentState.setCount,
            restTime: currentState.restTime,
            workoutName: currentState.workoutName
        )
        
        Task {
            await exerciseTimer?.end(ActivityContent(state: finalState, staleDate: nil), dismissalPolicy: .default)
        }
    }
    
}
