import Observation
import Foundation
import ActivityKit

extension SessionManager {
    
    func UpdateLiveActivity(workout: Workout, currentSet: Int) {
        if exerciseTimer?.content.state != nil {
            
            let next = workout.setData[currentSet + 1]
            
            let updatedState = WorkoutTimer.ContentState(currentSet: currentSet, timerStart: Date.now, setEntry: next, setCount: workout.weights.count, workoutName: workout.name)
            
            Task {
                await exerciseTimer?.update(ActivityContent(state: updatedState, staleDate: nil))
            }
            
        } else {
            let startTime = Date.now
                        
            let attributes = WorkoutTimer()
            
            if let next = workout.setData.first {
                
                let initialState = WorkoutTimer.ContentState(currentSet: currentSet, timerStart: Date.now, setEntry: next, setCount: workout.weights.count, workoutName: workout.name)
                
                do {
                    exerciseTimer = try Activity.request(attributes: attributes, content: ActivityContent(state: initialState, staleDate: startTime.addingTimeInterval(TimeInterval(60 * 60))))
                } catch {
                    print("Error starting live activity: \(error)")
                }
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
            workoutName: currentState.workoutName
        )
        
        Task {
            await exerciseTimer?.end(ActivityContent(state: finalState, staleDate: nil), dismissalPolicy: .default)
        }
    }
    
}
