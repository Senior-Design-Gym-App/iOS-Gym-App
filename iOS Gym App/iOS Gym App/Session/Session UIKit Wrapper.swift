import SwiftUI

struct SessionTabViewWrapper: View {
    @Environment(SessionManager.self) private var sessionManager: SessionManager
    @State private var currentSession: WorkoutSession?
    
    var body: some View {
        if sessionManager.currentWorkout != nil {
            SessionTabUIKitView(currentSession: $currentSession)
                .fullScreenCover(item: $currentSession) { session in
                    SessionView(workoutSession: session)
                        .foregroundStyle(.primary)
                }
        } else {
            EmptyView()
        }
    }
}
