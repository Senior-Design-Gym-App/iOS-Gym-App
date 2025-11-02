import SwiftUI
import SwiftData

struct SessionCover: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State var session: WorkoutSession
    @Environment(SessionManager.self) private var sessionManager: SessionManager
    
    var body: some View {
        VStack(spacing: 0) {
            TabView {
                Tab("Current", systemImage: "circle") {
                    Text("Time and heart rate here")
                }
                Tab("Queue", systemImage: "circle") {
                    SessionWorkoutQueueView()
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            GroupBox {
                SessionCurrentExerciseView(sessionManager: sessionManager)
                SessionSetControlView(endAction: EndSession, deleteAction: DeleteSession, sessionManager: sessionManager)
            }.frame(idealWidth: .infinity)
        }
        .onChange(of: sessionManager.completedWorkouts) {
            session.exercises = sessionManager.completedWorkouts
            try? context.save()
        }
    }
    
    private func EndSession() -> Void {
        session.completed = Date()
        try? context.save()
        ClearCurrentData()
        dismiss()
    }
    
    private func DeleteSession() -> Void {
        context.delete(session)
        try? context.save()
        ClearCurrentData()
        dismiss()
    }
    
    private func ClearCurrentData() {
        sessionManager.currentWorkout = nil
        sessionManager.session = nil
        sessionManager.upcomingWorkouts.removeAll()
        sessionManager.completedWorkouts.removeAll()
        sessionManager.FinishTimer()
        sessionManager.EndLiveActivity()
    }
    
    private func Dismiss() -> Void {
        dismiss()
    }

    
}
