import SwiftUI
import SwiftData

struct IncompleteSessionsView: View {
    
    let allSessions: [WorkoutSession]
    @Environment(SessionManager.self) private var sm: SessionManager
    @Environment(\.modelContext) private var context
    @State private var showAlert: Bool = false
    
    var incompleteSessions: [WorkoutSession] {
        allSessions.filter({ $0.completed == nil })
    }
    
    var body: some View {
        if let incomplete = incompleteSessions.first, incomplete != sm.session {
            GroupBox {
                NavigationLink {
                    SessionsListView(allSessions: incompleteSessions)
                } label: {
                    VStack(alignment: .leading, spacing: 0) {
                        ReusedViews.Labels.HeaderWithArrow(title: "Incomplete Session")
                        ReusedViews.Labels.Subheader(title: "Continue working....")
                    }
                }
                Button {
                    if let workout = incomplete.workout {
                        
                        for exercise in workout.exercises ?? [] {
                            let hasEntry = incomplete.exercises?.contains(where: { entry in
                                entry.exercise == exercise
                            }) ?? false
                            
                            if !hasEntry {
                                sm.QueueExercise(exercise: exercise)
                            }
                        }
                    }
                    sm.session = incomplete
                    
                } label: {
                    IncompleteSession(session: incomplete)
                }
            }
            .alert("Session Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please end your current session before starting another.")
            }
        }
    }
    
    private func IncompleteSession(session: WorkoutSession) -> some View {
        HStack {
            VStack(alignment: .leading) {
                ReusedViews.Labels.MediumIconSize(key: session.workout?.id.hashValue.description ?? session.id.hashValue.description)
                ReusedViews.Labels.MediumTextLabel(title: session.name)
            }
            VStack(alignment: .leading) {
                if let exercises = session.exercises, exercises.isEmpty == false {
                    ForEach(session.exercises ?? [], id: \.self) { sessionData in
                        HStack {
                            if let exercise = sessionData.exercise {
                                ReusedViews.Labels.SmallIconSize(key: exercise.id.hashValue.description)
                                VStack {
                                    Text(exercise.name)
                                    Text("\(sessionData.weight.count) sets")
                                }
                            }
                        }
                    }
                } else {
                    Text("No exercises completed.")
                }
            }
        }
    }
    
}
