import SwiftUI
import SwiftData

struct SessionCover: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State var session: WorkoutSession
    @Environment(SessionManager.self) private var sessionManager: SessionManager
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 10)
            Capsule()
//                .padding(.top, 20)
                .frame(width: 65, height: 5)
            TabView {
                Tab("Current", systemImage: "circle") {
                    Text("Time and heart rate here")
                }
                Tab("Queue", systemImage: "circle") {
                    SessionWorkoutQueueView()
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            Spacer()
            GroupBox {
                SessionCurrentExerciseView(sessionManager: sessionManager)
                SessionSetControlView(sessionName: session.name, endAction: EndSession, deleteAction: DeleteSession, sessionManager: sessionManager)
            }.frame(idealWidth: .infinity)
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private func EndSession() -> Void {
        sessionManager.NextSet()
        sessionManager.NextWorkout()
        session.completed = Date()
        sessionManager.EndLiveActivity()
        sessionManager.FinishTimer()
        try? context.save()
        ClearCurrentData()
        dismiss()
    }
    
    private func DeleteSession() -> Void {
        sessionManager.EndLiveActivity()
        sessionManager.FinishTimer()
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
