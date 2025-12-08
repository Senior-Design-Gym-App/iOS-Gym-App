import SwiftUI
import SwiftData

struct SessionCover: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State var session: WorkoutSession
    @Environment(SessionManager.self) private var sessionManager: SessionManager
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showAlternateExercise = false
    
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .frame(width: 65, height: 5)
            
            // ADD THIS CUSTOM HEADER WITH TAB BUTTONS
            HStack {
                Text("Session")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    showAlternateExercise = true
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.title3)
                        .foregroundStyle(.blue)
                }
                .disabled(sessionManager.currentExercise == nil)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            TabView {
                Tab("Current", systemImage: "circle") {
                    SessionInfo(session: session)
                }
                Tab("Queue", systemImage: "circle") {
                    SessionWorkoutQueueView()
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            
            VStack {
                SessionCurrentExerciseView(sessionManager: sessionManager)
                    .padding(.top)
                SessionSetControlView(sessionName: session.name, endAction: EndSession, deleteAction: DeleteSession, renameAction: RenameSession, sessionManager: sessionManager)
                    .padding(.horizontal, 5)
            }
            .background(
                Rectangle()
                    .fill(colorScheme == .light ? Color.white : Color(uiColor: .systemGroupedBackground))
                    .clipShape(.rect(corners: .concentric, isUniform: true))
            )
            .padding(.bottom)
            .padding(.horizontal)
        }
        .ignoresSafeArea(edges: .bottom)
        .background(Color(uiColor: .systemGroupedBackground))
        .sheet(isPresented: $showAlternateExercise) {
            AlternateExerciseView(session: session)
                .environment(sessionManager)
        }
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
