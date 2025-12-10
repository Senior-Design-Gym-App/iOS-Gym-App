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
            ForEach(split.sortedWorkouts, id: \.self) { workout in
                ReusedViews.SessionViews.WorkoutSessionView(workout: workout, start: { workout in QueueWorkout(workout: workout, split: split) })
            }
        } header: {
            Text(split.name)
        }
    }
    
    private func QueueWorkout(workout: Workout, split: Split) {
        NotificationManager.instance.ScheduleNotificationsForSplit(split: split)
        if sm.session != nil {
            showAlert = true
            return
        }
        
        // Validate workout has exercises
        guard !workout.sortedExercises.isEmpty else {
            print("⚠️ Cannot start workout '\(workout.name)' - has no exercises")
            // TODO: Show a user-friendly alert here
            return
        }
        
        // Use SessionManager's startSession method which handles syncing to Watch
        sm.startSession(workout: workout, context: context)
    }
    
}
