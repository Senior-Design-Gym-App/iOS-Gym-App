import SwiftUI
import SwiftData

struct StartAllSessionsView: View {
    
    @Query private var allSplits: [Split]
    @Query private var allSessions: [WorkoutSession]
    @Environment(\.modelContext) private var context
    @Environment(SessionManager.self) private var sm: SessionManager
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(allSplits, id: \.self) { split in
                    SplitSection(split: split)
                }
            }
            .navigationBarTitle("Start Any Session")
            .alert("Session Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please end your current session before starting another.")
            }
        }
    }
    
    private func SplitSection(split: Split) -> some View {
        Section {
            ForEach(split.workouts ?? [], id: \.self) { workout in
                ReusedViews.SessionViews.WorkoutSessionView(workout: workout, start: { workout in QueueWorkout(workout: workout) })
            }
        } header: {
            Text(split.name)
        }
    }
    
    private func QueueWorkout(workout: Workout) {
        if sm.session != nil {
            showAlert = true
            return
        }
        let newSession = WorkoutSession(name: workout.name, started: Date(), workout: workout)
        for exercise in workout.exercises ?? [] {
            sm.QueueExercise(exercise: exercise)
        }
        context.insert(newSession)
        sm.session = newSession
    }
    
}
