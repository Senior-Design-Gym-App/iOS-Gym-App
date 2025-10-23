import Observation
import Foundation
import ActivityKit
import SwiftData

@Observable
class SessionManager {
    
    // MARK: Live Activities
    var progress: Float = 0
    var exerciseTimer: Activity<WorkoutTimer>? = nil
    var elapsedTime: TimeInterval = 0
    var timer: Timer? = nil
    
    // MARK: Session Logic
    var session: WorkoutSession?
    var currentWorkout: SessionData?
    var upcomingWorkouts: [SessionData] = []
    var completedWorkouts: [WorkoutSessionEntry] = []
    var reps: Int = 0
    var weight: Double = 0
    
    var isPaused = false
    private var remainingRestTime: Int? = nil
    
    func PauseTimer() {
        guard !isPaused else { return }
        isPaused = true
        timer?.invalidate()
        timer = nil
    }

    func ResumeTimer(exercise: Exercise, currentSet: Int) {
        guard isPaused else { return }
        isPaused = false
        
        let restTime = exercise.setData.last?[currentSet - 1].rest ?? 123
        
        // Calculate remaining rest time
        let remaining = restTime - Int(elapsedTime)
        guard remaining > 0 else {
            FinishTimer()
            return
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            self.UpdateTimer(restTime: restTime)
            
            if Int(self.elapsedTime) >= restTime {
                self.FinishTimer()
            }
        })
    }

        
    func StartTimer(exercise: Exercise, entry: WorkoutSessionEntry, currentSet: Int) {
        FinishTimer()
        
        let restTime = exercise.setData.last?[currentSet - 1].rest ?? 123
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            self.UpdateTimer(restTime: restTime)
            
            if Int(self.elapsedTime) >= restTime {
                self.FinishTimer()
            }
            
        })
        UpdateLiveActivity(exercise: exercise, currentSet: entry.weight.count + 1)
        if restTime > 0 {
            NotificationManager.instance.ScheduleNotification(seconds: restTime)
        }
    }

    private func UpdateTimer(restTime: Int) {
        guard let currentState = exerciseTimer?.content.state else { return }
        
        self.elapsedTime += 1
        let elapsed = Date.now.timeIntervalSince(currentState.timerStart)
        progress = Float(min(elapsed / Double(restTime), 1.0))
    }
    
    func FinishTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func QueueExercise(exercise: Exercise) {
        let newEntry = WorkoutSessionEntry(reps: [], weight: [], session: nil, exercise: nil)
        let newQueueItem = SessionData(exercise: exercise, entry: newEntry)
        if currentWorkout == nil {
            reps = exercise.setData.last?.last?.reps ?? 123
            weight = exercise.setData.last?.last?.weight ?? 123.0
            currentWorkout = newQueueItem
        } else {
            upcomingWorkouts.append(newQueueItem)
        }
    }
    
    func SessionNextWorkout() {
        if let next = upcomingWorkouts.first, let current = currentWorkout {
            
            current.entry.exercise = current.exercise // add relationship once item is done
            completedWorkouts.append(current.entry)
            currentWorkout = next
            upcomingWorkouts.removeFirst()
            
            reps = next.exercise.setData.last?.last?.reps ?? 123
            weight = next.exercise.setData.last?.last?.weight ?? 123.0
            
        }
    }
    
    func SessionPreviousWorkout() {
        guard let prevEntry = completedWorkouts.last,
              let prevOriginalWorkout = prevEntry.exercise else {
            return
        }
        
        // remove association as it is no longer completed
        prevEntry.exercise = nil
        prevEntry.session = nil
        if let current = currentWorkout {
            upcomingWorkouts.insert(SessionData(exercise: current.exercise, entry: current.entry), at: 0)
        }
        
        currentWorkout = SessionData(exercise: prevOriginalWorkout, entry: prevEntry)
        
        completedWorkouts.removeLast()
        
        if !prevEntry.reps.isEmpty && !prevEntry.weight.isEmpty,
           prevEntry.weight.count > 0 {
            let lastSetIndex = prevEntry.weight.count
            
            if lastSetIndex < prevEntry.reps.count {
                reps = prevEntry.reps[lastSetIndex]
            } else {
//                reps = prevEntry.reps.last ?? prevOriginalWorkout.reps.last ?? 1
            }
            
            if lastSetIndex < prevEntry.weight.count {
                weight = prevEntry.weight[lastSetIndex]
            } else {
//                weight = prevEntry.weight.last ?? prevOriginalWorkout.weights.last ?? 0
            }
        } else {
//            reps = prevOriginalWorkout.reps.first ?? 1
//            weight = prevOriginalWorkout.weights.first ?? 0
        }
    }
    
    func NextSet() {
        if let currentWorkout {
            
            self.currentWorkout?.entry.reps.append(reps)
            self.currentWorkout?.entry.weight.append(weight)
            
            let nextSetIndex = currentWorkout.entry.weight.count // This is now the index for the NEXT set (0-indexed)
            
            if nextSetIndex < currentWorkout.exercise.reps.count {
                reps = currentWorkout.exercise.reps.last![nextSetIndex]
            } else {
                reps = currentWorkout.exercise.reps.last?.last ?? reps        // out of range, default to current value
            }
            
            if nextSetIndex < currentWorkout.exercise.weights.count {
                weight = currentWorkout.exercise.weights.last![nextSetIndex]
            } else {
                weight = currentWorkout.exercise.weights.last?.last ?? weight  // out of range, default to current value
            }
        }
    }
    
    func PreviousSet() {
        currentWorkout?.entry.weight.removeLast()
        currentWorkout?.entry.reps.removeLast()
    }

    
}

