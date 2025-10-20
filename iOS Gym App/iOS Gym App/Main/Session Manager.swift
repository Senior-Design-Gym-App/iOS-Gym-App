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
    
    var sessionStarted: Bool = false
    var id: PersistentIdentifier?
    @ObservationIgnored var session: WorkoutSession?
    var currentWorkout: SessionData?
    var upcomingWorkouts: [SessionData] = []
    var completedWorkouts: [WorkoutSessionEntry] = []
    var reps: Int = 0
    var weight: Double = 0
        
    func StartTimer(workout: Workout, entry: WorkoutSessionEntry, currentSet: Int) {
        FinishTimer()
        
        let currentSetData = workout.setData[currentSet - 1]
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            self.UpdateTimer(restTime: currentSetData.rest)
            
            if Int(self.elapsedTime) >= currentSetData.rest {
                self.FinishTimer()
            }
            
        })
        UpdateLiveActivity(workout: workout, currentSet: entry.weight.count + 1)
        if currentSetData.rest > 0 {
            NotificationManager.instance.ScheduleNotification(seconds: currentSetData.rest)
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
    
    func QueueWorkout(workout: Workout) {
        let newEntry = WorkoutSessionEntry(reps: [], weight: [], session: nil, originalWorkout: nil)
        let newQueueItem = SessionData(workout: workout, entry: newEntry)
        if currentWorkout == nil {
            reps = workout.reps.first!
            weight = workout.weights.first!
            currentWorkout = newQueueItem
        } else {
            upcomingWorkouts.append(newQueueItem)
        }
    }
    
    func SessionNextWorkout() {
        if let next = upcomingWorkouts.first, let current = currentWorkout {
            
            current.entry.originalWorkout = current.workout // add relationship once item is done
            completedWorkouts.append(current.entry)
            currentWorkout = next
            upcomingWorkouts.removeFirst()
            
            reps = next.workout.reps.first!
            weight = next.workout.weights.first!
            
        }
    }
    
    func SessionPreviousWorkout() {
        guard let prevEntry = completedWorkouts.last,
              let prevOriginalWorkout = prevEntry.originalWorkout else {
            return
        }
        
        // remove association as it is no longer completed
        prevEntry.originalWorkout = nil
        prevEntry.session = nil
        if let current = currentWorkout {
            upcomingWorkouts.insert(SessionData(workout: current.workout, entry: current.entry), at: 0)
        }
        
        currentWorkout = SessionData(workout: prevOriginalWorkout, entry: prevEntry)
        
        completedWorkouts.removeLast()
        
        if !prevEntry.reps.isEmpty && !prevEntry.weight.isEmpty,
           prevEntry.weight.count > 0 {
            let lastSetIndex = prevEntry.weight.count
            
            if lastSetIndex < prevEntry.reps.count {
                reps = prevEntry.reps[lastSetIndex]
            } else {
                reps = prevEntry.reps.last ?? prevOriginalWorkout.reps.last ?? 1
            }
            
            if lastSetIndex < prevEntry.weight.count {
                weight = prevEntry.weight[lastSetIndex]
            } else {
                weight = prevEntry.weight.last ?? prevOriginalWorkout.weights.last ?? 0
            }
        } else {
            reps = prevOriginalWorkout.reps.first ?? 1
            weight = prevOriginalWorkout.weights.first ?? 0
        }
    }
    
    func NextSet() {
        if let currentWorkout {
            
            self.currentWorkout?.entry.reps.append(reps)
            self.currentWorkout?.entry.weight.append(weight)
            
            let nextSetIndex = currentWorkout.entry.weight.count // This is now the index for the NEXT set (0-indexed)
            
            if nextSetIndex < currentWorkout.workout.reps.count {
                reps = currentWorkout.workout.reps[nextSetIndex]
            } else {
                reps = currentWorkout.workout.reps.last ?? reps         // out of range, default to current value
            }
            
            if nextSetIndex < currentWorkout.workout.weights.count {
                weight = currentWorkout.workout.weights[nextSetIndex]
            } else {
                weight = currentWorkout.workout.weights.last ?? weight  // out of range, default to current value
            }
        }
    }
    
    func PreviousSet() {
        currentWorkout?.entry.weight.removeLast()
        currentWorkout?.entry.reps.removeLast()
    }

    
}

