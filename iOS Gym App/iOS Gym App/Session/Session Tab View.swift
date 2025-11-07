import SwiftUI
import ActivityKit

struct SessionTabViewWrapper: View {
    
    @Namespace private var namespace
    @State private var currentSession: WorkoutSession?
    @Environment(SessionManager.self) private var sessionManager: SessionManager
    
    var body: some View {
        if sessionManager.session != nil {
            ValidSessionTabView()
                .matchedTransitionSource(id: "tab", in: namespace)
                .fullScreenCover(item: $currentSession) { session in
                    SessionCover(session: session)
                        .navigationTransition(.zoom(sourceID: "tab", in: namespace))
                }
        } else {
            Text("thanks apple for making another bug")
        }
    }
    
    private func ValidSessionTabView() -> some View {
        Button {
            currentSession = sessionManager.session
        } label: {
            HStack {
                if let currentWorkout = sessionManager.currentWorkout {
                    Image(systemName: currentWorkout.exercise.workoutEquipment?.imageName ?? Constants.defaultEquipmentIcon)
                        .foregroundStyle(Constants.labelColor)
                    VStack(alignment: .leading) {
                        Text(currentWorkout.exercise.name)
                            .foregroundStyle(Constants.labelColor)
                            .font(.callout)
                            .fontWeight(.bold)
                        Text("Set \(sessionManager.currentSet) of \(sessionManager.totalSets)")
                            .foregroundStyle(Constants.labelColor)
                            .font(.caption)
                            .fontWeight(.light)
                    }
                    Spacer()
                    Text(TimeRemainingText())
                } else {
                    Text("No current workout")
                }
            }.padding(.horizontal)
        }
    }
    
    private func WorkoutName() -> some View {
        if let currentWorkout = sessionManager.currentWorkout {
            Text(currentWorkout.exercise.name)
        } else {
            Text("No Workout Selected")
        }
    }
    
    private func TimeRemainingText() -> String {
        if let activityState = sessionManager.exerciseTimer?.content.state {
            let endTime = activityState.timerStart.addingTimeInterval(60)   // need to change later
            let remaining = endTime.timeIntervalSince(Date.now)
            let seconds = max(0, Int(remaining))
            
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return String(format: "%d:%02d", minutes, remainingSeconds)
        }
        
        return "0:00"
    }

    
}
