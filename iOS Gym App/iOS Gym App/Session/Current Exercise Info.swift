import SwiftUI
import ActivityKit

struct SessionCurrentExerciseView: View {
    
    let sessionManager: SessionManager
    
    @AppStorage("showTimer") private var showTimer: Bool = true
    @AppStorage("weightChangeType") private var weightChangeType: WeightChangeType = .ten
    
    var body: some View {
        @Bindable var sessionManager = sessionManager
        HStack {
            Spacer()
            GroupBox {
                EquipmentIcon()
            }.clipShape(.circle)
            Spacer()
            VStack {
                CurrentExerciseInfo()
                    .padding(.bottom)
                HStack {
                    Spacer()
                    PreviousSetButton()
                    Spacer()
                    NextSetButton()
                    Spacer()
                }
            }
            Spacer()
            GroupBox {
                TimerInfo()
            }.clipShape(.circle)
            Spacer()
        }
    }
    
    private func PreviousSetButton() -> some View {
        Menu {
            Button {
                sessionManager.PreviousWorkout()
            } label: {
                Text("Previous Workout")
            }.disabled(sessionManager.completedWorkouts.isEmpty)
            Divider()
            Button {
                sessionManager.PreviousSet()
            } label: {
                Text("Previous Set")
            }.disabled(sessionManager.currentWorkout == nil || sessionManager.currentSet == 0)
        } label: {
            Label("Previous Set", systemImage: "backward.fill")
                .labelStyle(.iconOnly)
                .font(.title3)
                .fontWeight(.black)
        }
    }
    
    private func NextSetButton() -> some View {
        Menu {
            Button(role: .confirm) {
                sessionManager.NextSet()
                sessionManager.NextWorkout()
            } label: {
                Label("Next Workout", systemImage: "forward.end")
            }.disabled(sessionManager.upcomingWorkouts.isEmpty)
            Divider()
            Button(role: .confirm) {
                sessionManager.NextSet()
            } label: {
                Label("Next Set", systemImage: "forward")
            }.disabled(sessionManager.currentWorkout == nil)
        } label: {
            Label("Next Set", systemImage: "forward.fill")
                .labelStyle(.iconOnly)
                .font(.title3)
                .fontWeight(.black)
        }
    }
    
    private func TimerInfo() -> some View {
        Menu {
            Button {
                if let currentWorkout = sessionManager.currentWorkout {
                    sessionManager.StartTimer(exercise: currentWorkout.exercise, entry: currentWorkout.entry)
                }
            } label: {
                Label("Restart Timer", systemImage: "restart")
            }.disabled(sessionManager.currentWorkout == nil)
            Text("\(sessionManager.rest)s Rest")
        } label: {
            Gauge(value: sessionManager.progress, in: 0...1.0) {
            } currentValueLabel: {
                Text(TimeRemainingText())
            }
            .gaugeStyle(.accessoryCircularCapacity)
        }
    }
    
    private func TimeRemainingText() -> String {
        if let activityState = sessionManager.exerciseTimer?.content.state {
            let endTime = activityState.timerStart.addingTimeInterval(Double(activityState.setEntry.rest))
            let remaining = endTime.timeIntervalSince(Date.now)
            let seconds = max(0, Int(remaining))
            
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return String(format: "%d:%02d", minutes, remainingSeconds)
        }
        
        return "0:00"
    }
    
    private func EquipmentIcon() -> some View {
        Menu {
            if let currentExercise = sessionManager.currentWorkout?.exercise {
                Text("Updated \(DateHandler().RelativeTime(from: currentExercise.modified))")
                Text(currentExercise.workoutEquipment?.rawValue ?? "Unknown Equipment")
                if let currentExerciseMuscleInfo = currentExercise.muscle {
                    Text("\(currentExerciseMuscleInfo.rawValue)")
                }
            } else {
                Text("No Exercise Selected")
            }
            Text("Set \(sessionManager.currentSet) of \(sessionManager.totalSets)")
        } label: {
            ZStack {
                Gauge(value: Float(sessionManager.currentSet), in: 0...(Float(sessionManager.totalSets))) { }
                    .gaugeStyle(.accessoryCircularCapacity)
                Label("Equipment", systemImage: sessionManager.currentWorkout?.exercise.workoutEquipment?.imageName ?? "questionmark")
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.primary)
                    .font(.title3)
            }
        }
        .buttonStyle(.borderless)
    }
    
    private func CurrentExerciseInfo() -> some View {
        Text(sessionManager.currentWorkout?.exercise.name ?? "No Workout Selected")
            .font(.title3)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
    }
    
    private func RestartTimerButton(current: SessionData) -> some View {
        Button {
            sessionManager.StartTimer(exercise: current.exercise, entry: current.entry)
        } label: {
            Label("Restart Timer", systemImage: "arrow.trianglehead.2.counterclockwise")
        }
    }
    
}
