import SwiftUI
import SwiftData

struct SessionView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionManager.self) private var sessionManager: SessionManager
    
    @State var workoutSession: WorkoutSession
    @State private var showQueue: Bool = false
    @State private var option: SessionViewOption = .entry
    
    var body: some View {
        NavigationStack {
            VStack {
//                Spacer()
                if showQueue {
                    SessionWorkoutQueueView()
                        .transition(.slide)
                } else {
                    SessionWorkoutControlView(sessionManager: sessionManager, dismiss: Dismiss, endSession: EndSession, deleteSession: DeleteSession)
                        .padding(.bottom, 25)
                        .transition(.slide)
                }
                SessionTimerView(sessionManager: sessionManager)
                    .padding(.bottom, 35)
                SessionSetControlView(sessionManager: sessionManager)
                    .padding(.bottom, 45)
                SessionEndOptionsView(sessionManager: sessionManager, showQueue: $showQueue)
                    .padding(.bottom, 15)
            }
            .navigationTitle(workoutSession.name)
            .navigationBarTitleDisplayMode(.inline)
//            .background(
//                LinearGradient(gradient: Gradient(colors: [.blue, .mint]), startPoint: .top, endPoint: .bottom)
//            )
        }
        .padding(.horizontal, 20)
        .onChange(of: sessionManager.completedWorkouts) {
            for workout in sessionManager.completedWorkouts {
                workout.session = workoutSession
            }
            workoutSession.exercises = sessionManager.completedWorkouts
            try? context.save()
        }
    }
    
    private func SaveName(newName: String) -> Void {
        workoutSession.name = newName
        try? context.save()
    }
    
    private func EndSession() -> Void {
        workoutSession.completed = Date()
        dismiss()
        try? context.save()
    }
    
    private func DeleteSession() -> Void {
        context.delete(workoutSession)
        dismiss()
        sessionManager.currentWorkout = nil
        sessionManager.session = nil
        sessionManager.upcomingWorkouts.removeAll()
        sessionManager.completedWorkouts.removeAll()
        sessionManager.FinishTimer()
        sessionManager.EndLiveActivity()
        try? context.save()
    }
    
    private func Dismiss() -> Void {
        dismiss()
    }
    
}
