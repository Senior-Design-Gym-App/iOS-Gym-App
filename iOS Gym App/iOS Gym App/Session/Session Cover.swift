import SwiftUI
import SwiftData

struct SessionCover: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State var session: WorkoutSession
    @Environment(SessionManager.self) private var sessionManager: SessionManager
    //    @State private var sessionManager = SessionManager()
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 10)
            Capsule()
            //                .padding(.top, 20)
                .frame(width: 65, height: 5)
            TabView {
                Tab("Current", systemImage: "circle") {
                    SessionInfo(session: session)
                }
                Tab("Queue", systemImage: "circle") {
                    SessionWorkoutQueueView()
                }
            }
            
            .tabViewStyle(.page(indexDisplayMode: .always))
            Spacer()
            VStack {
                SessionCurrentExerciseView(sessionManager: sessionManager)
                    .padding(.top)
                SessionSetControlView(sessionName: session.name, endAction: EndSession, deleteAction: DeleteSession, renameAction: RenameSession, sessionManager: sessionManager)
                    .padding(.horizontal)
            }
            
            .background(
                Rectangle()
                    .fill(.regularMaterial)
                    .clipShape(.rect(corners: .concentric, isUniform: true))
            )
            .padding()
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private func EndSession() -> Void {
        sessionManager.NextSet()
        sessionManager.NextWorkout()
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
        sessionManager.currentExercise = nil
        sessionManager.session = nil
        sessionManager.upcomingExercises.removeAll()
        sessionManager.completedExercises.removeAll()
        sessionManager.FinishTimer()
        sessionManager.EndLiveActivity()
    }
    
    private func Dismiss() -> Void {
        dismiss()
    }
    
    private func RenameSession(name: String) -> Void {
        session.name = name
    }
    
}
