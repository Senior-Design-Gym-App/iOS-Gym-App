import SwiftUI

struct SessionTabViewWrapper: View {
    
    @Namespace private var namespace
    @State private var currentSession: WorkoutSession?
    @Environment(SessionManager.self) private var sessionManager: SessionManager
    @State private var showNewSession = false
    
    var body: some View {
        NavigationStack {
            if sessionManager.session != nil {
                ValidSessionTabView()
                    .matchedTransitionSource(id: "tab", in: namespace)
                    .fullScreenCover(item: $currentSession) { session in
                        SessionCover(session: session)
                            .navigationTransition(.zoom(sourceID: "tab", in: namespace))
                    }
            } else {
                Button {
                    showNewSession = true
                } label: {
                    Label("Select a session to get started.", systemImage: "play")
                }
                .sheet(isPresented: $showNewSession) {
                    SessionHomeView()
                }
            }
        }
    }
    
    private func ValidSessionTabView() -> some View {
        Button {
            currentSession = sessionManager.session
        } label: {
            HStack {
                if let currentWorkout = sessionManager.currentExercise {
                    Image(systemName: currentWorkout.exercise.workoutEquipment?.imageName ?? Constants.exerciseIcon)
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
    
    private func TimeRemainingText() -> String {
        let remaining = max(0, sessionManager.rest - Int(sessionManager.elapsedTime))
        let minutes = remaining / 60
        let remainingSeconds = remaining % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
}
