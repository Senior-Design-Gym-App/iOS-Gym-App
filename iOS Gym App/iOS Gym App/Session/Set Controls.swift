import SwiftUI

struct SessionCurrentExerciseView: View {
    
    let sessionManager: SessionManager
    
    @AppStorage("showTimer") private var showTimer: Bool = true
    @AppStorage("weightChangeType") private var weightChangeType: WeightChangeType = .ten
    
    var body: some View {
        @Bindable var sessionManager = sessionManager
        HStack {
            Spacer()
            EquipmentIcon()
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
            TimerInfo()
            Spacer()
        }
    }
    
    private func PreviousSetButton() -> some View {
        Menu {
            Button {
                withAnimation {
                    sessionManager.PreviousWorkout()
                }
            } label: {
                Label("Previous Exercise", systemImage: "backward.end")
                if let previous = sessionManager.completedExercises.last?.exercise {
                    Text(previous.name)
                }
            }.disabled((sessionManager.completedExercises.isEmpty && sessionManager.currentExercise == nil)  )
            Divider()
            Button {
                withAnimation {
                    sessionManager.PreviousSet()
                }
            } label: {
                Label("Previous Set", systemImage: "backward")
                Text("Set \(sessionManager.currentSet - 1)")
            }.disabled(sessionManager.currentExercise == nil || sessionManager.currentSet == 0)
            Button {
                withAnimation {
                    sessionManager.UnselectWorkout()
                }
            } label: {
                Label("Unselect Exercise", systemImage: "pause")
                Text("Adds current workout to queue")
            }.disabled(sessionManager.currentExercise == nil)
        } label: {
            Label("Previous Options", systemImage: "backward.fill")
                .labelStyle(.iconOnly)
                .font(.title3)
                .fontWeight(.black)
        }
    }
    
    private func NextSetButton() -> some View {
        Menu {
            Button(role: .confirm) {
                withAnimation {
                    sessionManager.NextSet()
                    sessionManager.NextWorkout()
                }
            } label: {
                Label("Next Exercise", systemImage: "forward.end")
                if let next = sessionManager.upcomingExercises.first {
                    Text(next.exercise.name)
                }
            }.disabled(sessionManager.upcomingExercises.isEmpty)
            Divider()
            Button(role: .confirm) {
                withAnimation {
                    sessionManager.NextSet()
                }
            } label: {
                Label("Next Set", systemImage: "forward")
                Text("Set \(sessionManager.currentSet + 1)")
            }.disabled(sessionManager.currentExercise == nil)
        } label: {
            Label("Next Options", systemImage: "forward.fill")
                .labelStyle(.iconOnly)
                .font(.title3)
                .fontWeight(.black)
        }
    }
    
    private func TimerInfo() -> some View {
        Menu {
            Button {
                withAnimation {
                    if let currentWorkout = sessionManager.currentExercise {
                        sessionManager.StartTimer(exercise: currentWorkout.exercise, entry: currentWorkout.entry)
                    }
                }
            } label: {
                Label("Restart Timer", systemImage: "restart")
            }.disabled(sessionManager.currentExercise == nil)
            Text("\(sessionManager.rest)s Rest")
        } label: {
            Gauge(value: sessionManager.elapsedTime, in: 0...TimeInterval(sessionManager.rest)) {
            } currentValueLabel: {
                Text(TimeRemainingText())
            }
            .gaugeStyle(.accessoryCircularCapacity)
        }
    }
    
    private func TimeRemainingText() -> String {
        let remaining = max(0, sessionManager.rest - Int(sessionManager.elapsedTime))
        let minutes = remaining / 60
        let remainingSeconds = remaining % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    private func EquipmentIcon() -> some View {
        Menu {
            if let currentExercise = sessionManager.currentExercise?.exercise {
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
                Label("Equipment", systemImage: sessionManager.currentExercise?.exercise.workoutEquipment?.imageName ?? "questionmark")
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.primary)
                    .font(.title3)
            }
        }
        .buttonStyle(.borderless)
    }
    
    private func CurrentExerciseInfo() -> some View {
        Text(sessionManager.currentExercise?.exercise.name ?? "Suspended")
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
