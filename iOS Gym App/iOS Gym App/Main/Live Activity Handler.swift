import Observation
import Foundation
import ActivityKit

extension SessionManager {
    
    func UpdateLiveActivity(exercise: Exercise) {
        if let currentExercise {
            if exerciseTimer?.content.state != nil {
                
                let updatedState = WorkoutTimer.ContentState(timerStart: Date.now, sessionName: session?.name ?? "Session", sessionStartDate: sessionStartDate ,currentExercise: currentExercise)
                
                Task {
                    await exerciseTimer?.update(ActivityContent(state: updatedState, staleDate: nil))
                }
                
            } else {
                let startTime = Date.now
                let attributes = WorkoutTimer()
                                
                let initialState = WorkoutTimer.ContentState(timerStart: Date.now, sessionName: session?.name ?? "Session", sessionStartDate: sessionStartDate ,currentExercise: currentExercise)
                
                do {
                    exerciseTimer = try Activity.request(attributes: attributes, content: ActivityContent(state: initialState, staleDate: startTime.addingTimeInterval(TimeInterval(60 * 60))))
                } catch {
                    print("Error starting live activity: \(error)")
                }
                
            }
        } else {
            print("no state")
        }
    }
    
    func EndLiveActivity() {
        guard let currentState = currentExercise else { return }
        
        let finalState = WorkoutTimer.ContentState(timerStart: Date.now, sessionName: session?.name ?? "Session", sessionStartDate: sessionStartDate ,currentExercise: currentState)
        
        Task {
            await exerciseTimer?.end(ActivityContent(state: finalState, staleDate: nil), dismissalPolicy: .immediate)
        }
    }
    
}
