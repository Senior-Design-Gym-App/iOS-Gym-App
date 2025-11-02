import SwiftUI
import SwiftData

struct QuickStartSessionView: View {
    
    let allSplits: [Split]
    let allWorkouts: [Workout]
    @Environment(SessionManager.self) private var sm: SessionManager
    @Environment(\.modelContext) private var context
    @State private var showAlert: Bool = false
    
    var pinnedSplits: [Split] {
        allSplits.filter({ $0.active })
    }
    
    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
    
    var body: some View {
        if sm.session == nil {
            GroupBox {
                NavigationLink {
                    StartSessionView(allWorkouts: allWorkouts)
                } label: {
                    VStack(alignment: .leading, spacing: 0) {
                        ReusedViews.Labels.HeaderWithArrow(title: "Start Session")
                        ReusedViews.Labels.Subheader(title: "Active Split")
                    }
                }
                if let activeSplit = pinnedSplits.first {
                    ActiveSplit(split: activeSplit)
                } else {
                    Text("Set a split as active to be quick start a workout. Only one split can be active at a time.")
                        .font(.callout)
                        .padding(.top, 5)
                }
            }
            .alert("Session Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please end your current session before starting another.")
            }
        }
    }
    
    private func ActiveSplit(split: Split) -> some View {
        LazyVGrid(columns: columns) {
            ForEach(split.workouts ?? [], id: \.self) { workout in
                Button {
                    QueueWorkout(workout: workout)
                } label: {
                    ActiveSplitWorkouts(workout: workout)
                }.buttonStyle(.plain)
            }
        }
    }
    
    private func ActiveSplitWorkouts(workout: Workout) -> some View {
        VStack(alignment: .leading) {
            HStack {
                ReusedViews.Labels.TinyIconSize(key: workout.id.hashValue.description)
                    .overlay {
                        Image(systemName: "play.fill")
                            .foregroundStyle(.white)
                    }
                VStack(alignment: .leading) {
                    Text(workout.name)
                        .font(.callout)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Text(ReusedViews.WorkoutViews.MostRecentSession(workout: workout))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Divider()
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
