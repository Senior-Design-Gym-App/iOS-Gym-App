import SwiftUI
import SwiftData

struct StartSessionView: View {
    
    let allWorkouts: [Workout]
    @State private var showAlert: Bool = false
    @Environment(SessionManager.self) private var sm: SessionManager
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(allWorkouts, id: \.self) { workout in
                    Button {
                        QueueWorkout(workout: workout)
                    } label: {
                        HStack {
                            ReusedViews.Labels.SmallIconSize(key: workout.id.hashValue.description)
                                .overlay {
                                    Image(systemName: "play")
                                        .tint(.white)
                                }
                            VStack(alignment: .leading, spacing: 0) {
                                Text(workout.name)
                                Text(ReusedViews.WorkoutViews.MostRecentSession(workout: workout))
                                    .font(.callout)
                                    .fontWeight(.thin)
                            }
                        }
                    }.buttonStyle(.plain)
                }
            }
            .navigationTitle("Start Session")
            .alert("Session Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please end your current session before starting another.")
            }
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
        sm.session = newSession
        context.insert(newSession)
    }
    
}
