import SwiftUI
import SwiftData

struct SessionCover: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State var session: WorkoutSession
    @Environment(SessionManager.self) private var sessionManager: SessionManager
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showAlternateExercise = false
    @State private var showPostSheet = false  // ADD THIS
    @State private var postText = ""  // ADD THIS
    
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .frame(width: 65, height: 5)
            
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
        // ADD THIS SHEET
        .sheet(isPresented: $showPostSheet) {
            CreateWorkoutPostView(
                session: session,
                elapsedTime: sessionManager.elapsedTime,
                defaultText: postText,
                sessionManager: sessionManager
            ) {
                // On post created, dismiss the session
                ClearCurrentData()
//                dismiss()
            }
        }
    }
    
    private func EndSession() -> Void {
        sessionManager.NextSet()
        sessionManager.NextWorkout()
        
        session.completed = Date()
        try? context.save()
        
        // Generate default post text
        let duration = formatDuration(session.started, session.completed)
        let exerciseCount = session.exercises?.count ?? 0
        postText = "Completed \(session.name)! 💪\n\(exerciseCount) exercises in \(duration)"
        
        // Show post sheet instead of dismissing immediately
        
        // Use SessionManager's endSession which handles cross-device sync
        sessionManager.endSession()
        //showPostSheet = true

    }
    
    private func formatDuration(_ start: Date, _ end: Date?) -> String {
        guard let end = end else { return "0m" }
        
        let duration = end.timeIntervalSince(start)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func DeleteSession() -> Void {
        // Send cancel action to Watch to dismiss without logging
        let connectivityManager = WatchConnectivityManager.shared
        connectivityManager.sendSessionAction(.cancelSession, sessionId: sessionManager.sessionId)
        
        // Delete session from database
        context.delete(session)
        try? context.save()
        
        // Clear local state
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
    private func CreatePost(poststring: String) async -> Void{
        
    }
}
