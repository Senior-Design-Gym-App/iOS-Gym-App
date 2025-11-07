import SwiftUI
import SwiftData

struct SessionHomeView: View {
    
    @Query private var allSplits: [Split]
    @Query private var allWorkouts: [Workout]
    @Query private var allSessions: [WorkoutSession]
    @Environment(\.modelContext) private var context
    
    @State private var showAlert: Bool = false
    @Environment(SessionManager.self) private var sm: SessionManager
    
    var incompleteSessions: [WorkoutSession] {
        allSessions.filter({ $0.completed == nil })
    }
    
    var sortedSplits: [Split] {
        allSplits.sorted { lhs, rhs in
            if lhs.active != rhs.active {
                return lhs.active && !rhs.active
            }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if !incompleteSessions.isEmpty {
                    Section {
                        ForEach(incompleteSessions, id: \.self) { session in
                            IncompleteSession(session: session)
                        }
                    } header: {
                        Text("Incomplete Sessions")
                    }
                }
                ForEach(sortedSplits, id: \.self) { split in
                    SplitSection(split: split)
                }
            }
            .navigationTitle("Start Session")
            .toolbarTitleDisplayMode(.inlineLarge)
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
                WorkoutView(workout: workout)
            }
        } header: {
            Text(split.name)
        }
    }
    
    private func WorkoutView(workout: Workout) -> some View {
        HStack {
            ReusedViews.Labels.SmallIconSize(color: workout.color)
            ReusedViews.Labels.ListDescription(title: workout.name, subtitle: ReusedViews.WorkoutViews.MostRecentSession(workout: workout))
            Spacer()
            Menu {
                Section {
                    ForEach(workout.exercises ?? [], id: \.self) { exercise in
                        Label(exercise.name, systemImage: exercise.workoutEquipment?.imageName ?? Constants.defaultEquipmentIcon)
                    }
                } header: {
                    Text(workout.name)
                }
                if workout.exercises?.count == 0 {
                    Text("You must add exercises to start.")
                } else {
                    Button {
                        QueueWorkout(workout: workout)
                    } label: {
                        Label("Start Session", systemImage: "play")
                    }.disabled(workout.exercises?.count == 0)
                }
            } label: {
                Image(systemName: "play.circle.fill")
            }
        }
    }
    
    private func IncompleteSession(session: WorkoutSession) -> some View {
        HStack {
            ReusedViews.Labels.SmallIconSize(color: session.color)
            ReusedViews.Labels.ListDescription(title: session.name, subtitle: "Started \(DateHandler().RelativeTime(from: session.started))")
            Spacer()
            Menu {
                Section {
                    ForEach(session.exercises ?? [], id: \.self) { sessionData in
                        if let exercise = sessionData.exercise {
                            Label(exercise.name, systemImage: exercise.workoutEquipment?.imageName ?? Constants.defaultEquipmentIcon)
                        } else {
                            Label("Unknown Exercise", systemImage: "exclamationmark.shield")
                        }
                    }
                    Button {
                        StartIncompleteSession(incomplete: session)
                    } label: {
                        Label("Continue \(session.name)", systemImage: "play")
                    }
                    Button {
                        context.delete(session)
                    } label: {
                        Label("Delete \(session.name)", systemImage: "trash")
                    }
                } header: {
                    Text(session.name)
                }
            } label: {
                Image(systemName: "memories")
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
        context.insert(newSession)
        sm.session = newSession
    }
    
    private func StartIncompleteSession(incomplete: WorkoutSession) {
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
    }
    
}
