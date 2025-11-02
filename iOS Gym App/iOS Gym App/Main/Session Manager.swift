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
    var rest: Int = 0
    var reps: Int = 0
    var weight: Double = 0
    
    var currentSet: Int {
        (currentWorkout?.entry.weight.count ?? 0) + 1
    }
    
    var totalSets: Int {
        currentWorkout?.exercise.recentSetData.count ?? 1
    }
    
    init() {
        EndLiveActivity()
    }
        
    func StartTimer(exercise: Exercise, entry: WorkoutSessionEntry) {
        FinishTimer()
        if rest > 0 {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [self] _ in
                self.UpdateTimer(restTime: rest)
                
                if Int(self.elapsedTime) >= rest {
                    self.FinishTimer()
                }
            })
            UpdateLiveActivity(exercise: exercise)
            NotificationManager.instance.ScheduleNotification(seconds: rest)
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
        elapsedTime = 0
    }
    
    func QueueExercise(exercise: Exercise) {
        let newEntry = WorkoutSessionEntry(reps: [], weight: [], session: nil, exercise: nil)
        let newQueueItem = SessionData(exercise: exercise, entry: newEntry)
        if currentWorkout == nil {
            if let first = exercise.recentSetData.first {
                reps = first.reps
                weight = first.weight
                rest = first.rest
                StartTimer(exercise: exercise, entry: newEntry)
            }
            currentWorkout = newQueueItem
        } else {
            upcomingWorkouts.append(newQueueItem)
        }
    }
    
    func NextWorkout() {
        if let next = upcomingWorkouts.first {
            
            if let current = currentWorkout {
                current.entry.exercise = current.exercise
                completedWorkouts.append(current.entry)
            }
            
            QueueExercise(exercise: next.exercise)
            upcomingWorkouts.removeFirst()
            
        }
    }
    
    func PreviousWorkout() {
        if let prevEntry = completedWorkouts.last {
            
            if let currentWorkout {
                upcomingWorkouts.insert(currentWorkout, at: 0)
                self.currentWorkout = nil
            }
            
            if let exercise = prevEntry.exercise {
                QueueExercise(exercise: exercise)
                prevEntry.exercise = nil
            }
            
            prevEntry.session = nil
            completedWorkouts.removeLast()
        }
    }
    
    func NextSet() {
        
        self.currentWorkout?.entry.reps.append(reps)
        self.currentWorkout?.entry.weight.append(weight)
        
        if let currentWorkout {
            
            let nextSetIndex = currentWorkout.entry.weight.count // This is now the index for the NEXT set (0-indexed)
            
            if nextSetIndex < currentWorkout.exercise.recentSetData.count {
                reps = currentWorkout.exercise.recentSetData[nextSetIndex].reps
            }
            
            if nextSetIndex < currentWorkout.exercise.recentSetData.count {
                weight = currentWorkout.exercise.recentSetData[nextSetIndex].weight
            }
            
            if nextSetIndex < currentWorkout.exercise.recentSetData.count {
                rest = currentWorkout.exercise.recentSetData[nextSetIndex].rest
            }
            
            StartTimer(exercise: currentWorkout.exercise, entry: currentWorkout.entry)
        }
    }
    
    func PreviousSet() {
        if let weight = currentWorkout?.entry.weight.last, let reps = currentWorkout?.entry.reps.last {
            self.weight = weight
            self.reps = reps
        }
        
        currentWorkout?.entry.weight.removeLast()
        currentWorkout?.entry.reps.removeLast()
        
        if let currentWorkout {
            
            let nextSetIndex = currentWorkout.entry.weight.count // This is now the index for the NEXT set (0-indexed)
            if nextSetIndex < currentWorkout.exercise.recentSetData.count {
                rest = currentWorkout.exercise.recentSetData[nextSetIndex].rest
            }
            StartTimer(exercise: currentWorkout.exercise, entry: currentWorkout.entry)
        }
        
    }
    
}
