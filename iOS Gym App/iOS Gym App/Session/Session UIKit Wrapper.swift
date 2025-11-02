import SwiftUI

struct SessionTabViewWrapper: View {
    
    @Environment(SessionManager.self) private var sessionManager: SessionManager
    @State private var currentSession: WorkoutSession?
    
    var body: some View {
        if sessionManager.session != nil {
            SessionTabUIKitView(currentSession: $currentSession)
//                .fullScreenSheet(item: $currentSession) { session, safeArea in
//                    SessionView(workoutSession: session)
//                        .foregroundStyle(.primary)
//                } background: {
//                    Color.primary
//                }
                .fullScreenCover(item: $currentSession) { session in
                    SessionCover(session: session)
                }
        } else {
            Text("No session")
        }
    }
    
}
