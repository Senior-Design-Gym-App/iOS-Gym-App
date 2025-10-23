import SwiftUI

struct SessionSetControlView: View {
    
    let sessionManager: SessionManager
    
    @AppStorage("showTimer") private var showTimer: Bool = true
    @AppStorage("weightChangeType") private var weightChangeType: WeightChangeType = .ten
    
    var body: some View {
        @Bindable var sessionManager = sessionManager
        HStack {
            Spacer()
            PreviousSetButton()
            Spacer()
            if showTimer {
                PlayPauseButton()
                Spacer()
            }
            NextSetButton(reps: $sessionManager.reps, weight: $sessionManager.weight)
            Spacer()
        }
    }
    
    private func PreviousSetButton() -> some View {
        Button {
            sessionManager.PreviousSet()
        } label: {
            Label("Previous Set", systemImage: "backward.fill")
                .labelStyle(.iconOnly)
                .font(.title3)
                .fontWeight(.black)
        }.disabled(sessionManager.currentWorkout?.entry.weight.isEmpty == true || sessionManager.currentWorkout == nil)
    }
    
    private func NextSetButton(reps: Binding<Int>, weight: Binding<Double>) -> some View {
        Menu {
            Picker("Weight Adjustment AMount", selection: $weightChangeType) {
                ForEach(WeightChangeType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .menuActionDismissBehavior(.disabled)
            Section {
                Stepper(value: weight, step: weightChangeType.weightChange) {
                    Text("Weight: \(weight.wrappedValue, specifier: "%.1f")")
                }
                Stepper("Reps: \(reps.wrappedValue)", value: reps)
            } header: {
                if let setCount = sessionManager.currentWorkout?.entry.weight.count {
                    Text("Set \(setCount)")
                }
            }
            Button(role: .confirm) {
                sessionManager.NextSet()
            } label: {
                Label("Next Set", systemImage: "forward")
            }
            Button(role: .confirm) {
                sessionManager.NextSet()
                sessionManager.SessionNextWorkout()
            } label: {
                Label("Next Workout", systemImage: "forward.end")
                Text("Will end current Set")
            }
        } label: {
            Label("Next Set", systemImage: "forward.fill")
                .labelStyle(.iconOnly)
                .font(.title3)
                .fontWeight(.black)
        }
        .menuOrder(.fixed)
    }
    
    private func PlayPauseButton() -> some View {
        Button {
            if sessionManager.timer != nil {
                sessionManager.PauseTimer()
            } else {
//                if let currentWorkout = sessionManager.currentWorkout {
//                    sessionManager.ResumeTimer(workout: currentWorkout.workout, currentSet: currentWorkout.entry.weight.count)
//                }
            }
        } label: {
            Label("Play Pause", systemImage: "pause")
                .labelStyle(.iconOnly)
                .font(.largeTitle)
                .fontWeight(.black)
        }.disabled(sessionManager.currentWorkout == nil)
    }
    
}
