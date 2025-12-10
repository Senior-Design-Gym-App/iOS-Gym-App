import Observation
import SwiftUI
import Foundation
import ActivityKit
import SwiftData

@Observable
class SessionManager {
    
    // MARK: Live Activities
    var exerciseTimer: Activity<WorkoutTimer>? = nil
    var elapsedTime: TimeInterval = 0
    var timer: Timer? = nil
    @ObservationIgnored @AppStorage("timerType") private var timerType: TimerType = .liveActivities
    @ObservationIgnored @AppStorage("autoAdjustWeights") private var autoAdjustWeights: Bool = true
    var sessionStartDate: Date = Date()
    
    // MARK: Session Logic
    var session: WorkoutSession?
    var currentExercise: SessionData?
    var upcomingExercises: [SessionData] = []
    var completedExercises: [WorkoutSessionEntry] = []
    var rest: Int = 0
    var reps: Int = 0
    var weight: Double = 0
    
    var currentSet: Int {
        (currentExercise?.entry.weight.count ?? 0) + 1
    }
    
    var totalSets: Int {
        max(currentExercise?.exercise.recentSetData.setData.count ?? 1, currentSet)
    }
        
    func StartTimer(exercise: Exercise, entry: WorkoutSessionEntry) {
        FinishTimer()
        elapsedTime = 0
        if rest > 0 {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [self] _ in
                withAnimation {
                    elapsedTime += 1
                }
                
                if Int(self.elapsedTime) >= rest {
                    self.FinishTimer()
                }
            })
            switch timerType {
            case .liveActivities:
                UpdateLiveActivity(exercise: exercise)
            case .notifications:
                NotificationManager.instance.ScheduleNotification(seconds: rest)
            case .timer:
                return
            case .none:
                FinishTimer()
            }
        }
    }
    
    func FinishTimer() {
        timer?.invalidate()
        timer = nil
        elapsedTime = TimeInterval(rest)
    }
    
    func QueueExercise(exercise: Exercise) {
        let newEntry = WorkoutSessionEntry(reps: [], weight: [], session: nil, exercise: nil)
        let newQueueItem = SessionData(exercise: exercise, entry: newEntry)
        if currentExercise == nil {
            currentExercise = newQueueItem
            if let first = exercise.recentSetData.setData.first {
                reps = first.reps
                weight = first.weight
                rest = first.rest
                StartTimer(exercise: exercise, entry: newEntry)
            }
        } else {
            upcomingExercises.append(newQueueItem)
        }
    }
    
    func NextWorkout() {
        FinishTimer()
        if let current = currentExercise {
            current.entry.exercise = current.exercise
            current.entry.session = session
            completedExercises.append(current.entry)
            self.currentExercise = nil
        }
        
        if let next = upcomingExercises.first {
            
            QueueExercise(exercise: next.exercise)
            upcomingExercises.removeFirst()
            
        }
    }
    
    func PreviousWorkout() {
        FinishTimer()
        UnselectWorkout()
        if let prevEntry = completedExercises.last {
            
            if let exercise = prevEntry.exercise {
                QueueExercise(exercise: exercise)
                prevEntry.exercise = nil
            }
            
            prevEntry.session = nil
            completedExercises.removeLast()
        }
    }
    
    func NextSet() {
        FinishTimer()
        self.currentExercise?.entry.reps.append(reps)
        self.currentExercise?.entry.weight.append(weight)
        
        if let currentExercise {
            
            let nextSetIndex = currentExercise.entry.weight.count // This is now the index for the NEXT set (0-indexed)
            
            if nextSetIndex < currentExercise.exercise.recentSetData.setData.count {
                reps = currentExercise.exercise.recentSetData.setData[nextSetIndex].reps
            }
            
            if nextSetIndex < currentExercise.exercise.recentSetData.setData.count {
                let newWeight = currentExercise.exercise.recentSetData.setData[nextSetIndex].weight
                if nextSetIndex > 0, weight != newWeight, autoAdjustWeights {
                    weight = newWeight
                }
            }
            
            if nextSetIndex < currentExercise.exercise.recentSetData.setData.count {
                rest = currentExercise.exercise.recentSetData.setData[nextSetIndex].rest
            }
            
            StartTimer(exercise: currentExercise.exercise, entry: currentExercise.entry)
        }
    }
    
    func UnselectWorkout() {
        FinishTimer()
        if let currentExercise {
            upcomingExercises.insert(currentExercise, at: 0)
            self.currentExercise = nil
        }
    }
    
    func PreviousSet() {
        FinishTimer()
        if let weight = currentExercise?.entry.weight.last, let reps = currentExercise?.entry.reps.last {
            self.weight = weight
            self.reps = reps
        }
        
        currentExercise?.entry.weight.removeLast()
        currentExercise?.entry.reps.removeLast()
        
        if let currentExercise {
            
            let nextSetIndex = currentExercise.entry.weight.count // This is now the index for the NEXT set (0-indexed)
            if nextSetIndex < currentExercise.exercise.recentSetData.setData.count {
                rest = currentExercise.exercise.recentSetData.setData[nextSetIndex].rest
            }
            StartTimer(exercise: currentExercise.exercise, entry: currentExercise.entry)
        }
        
    }
    
}
