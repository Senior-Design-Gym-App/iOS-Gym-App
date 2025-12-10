import SwiftUI
import SwiftData

struct SessionHomeView: View {
    
    @Query private var allSplits: [Split]
    @Query private var allSessions: [WorkoutSession]
    @Environment(\.modelContext) private var context
    
    @State private var showAlert: Bool = false
    @Environment(SessionManager.self) private var sm: SessionManager
    
    var incompleteSessions: [WorkoutSession] {
        allSessions.filter({ $0.completed == nil })
    }
    
    var body: some View {
        NavigationStack {
            List {
                if !incompleteSessions.isEmpty {
                    Section {
                        ForEach(incompleteSessions.filter { $0 != sm.session }, id: \.self) { session in
                            IncompleteSession(session: session)
                        }
                    } header: {
                        ReusedViews.Labels.Header(text: "Incomplete Sessions")
                    } footer: {
                        Text("You must complete your current session before starting another.")
                    }
                }
                if let split = allSplits.first(where: { $0.active }), incompleteSessions.isEmpty {
                    Section {
                        ForEach(split.workouts ?? [], id: \.self) { workout in
                            if workout == predictNextWorkout() {
                                UpNextCard(workout: workout)
                                    .listRowSeparator(.hidden)
                            } else {
                                ReusedViews.SessionViews.WorkoutSessionView(workout: workout, start: { workout in QueueWorkout(workout: workout) })
                            }
                        }
                    } header: {
                        Label(split.name, systemImage: "star")
                    }
                }
                if incompleteSessions.isEmpty {
                    Section {
                        NavigationLink {
                            StartAllSessionsView()
                        } label: {
                            Label {
                                Text("All Splits")
                            } icon: {
                                Image(systemName: Constants.sessionIcon)
                                    .foregroundStyle(Constants.sessionTheme)
                            }
                        }
                    } header: {
                        ReusedViews.Labels.Header(text: "All")
                    }
                }
            }
            .navigationTitle("Quick Start")
            .toolbarTitleDisplayMode(.inlineLarge)
            .alert("Session Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please end your current session before starting another.")
            }
        }
    }
    
    private func UpNextCard(workout: Workout) -> some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(workout.name)
                        .font(.title)
                        .fontWeight(.semibold)
                    Spacer()
                    Button {
                        QueueWorkout(workout: workout)
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.title)
                    }
                }
                Text("Up Next")
                    .font(.caption)
                    .fontWeight(.light)
            }.padding(.bottom)
            ForEach(workout.sortedExercises, id: \.self) { exercise in
                Label {
                    Text("\(exercise.name) (\(exercise.recentSetData.setData.count))")
                        .fontWeight(.medium)
                } icon: {
                    exercise.icon
                }.padding(.bottom, 5)
            }
        }.listRowBackground(workout.color)
            .foregroundStyle(.white)
    }
    
    private func IncompleteSession(session: WorkoutSession) -> some View {
        HStack {
            Label {
                Text(session.name)
                Text("Started \(DateHandler().RelativeTime(from: session.started))")
            } icon: {
                Image(systemName: "square.fill")
                    .foregroundStyle(session.color)
            }
            Spacer()
            Menu {
                Section {
                    ForEach(session.exercises ?? [], id: \.self) { sessionData in
                        if let exercise = sessionData.exercise {
                            Label(exercise.name, systemImage: exercise.workoutEquipment?.imageName ?? Constants.exerciseIcon)
                        } else {
                            Label("Unknown Exercise", systemImage: "exclamationmark.shield")
                        }
                    }
                } header: {
                    Text("Completed")
                }
                if let workout = session.workout {
                    Section {
                        ForEach(workout.sortedExercises.filter { workoutExercise in
                            session.exercises?.contains(where: { sessionEntry in
                                sessionEntry.exercise?.id == workoutExercise.id
                            }) == false
                        }, id: \.self) { exercise in
                            Label(exercise.name, systemImage: exercise.workoutEquipment?.imageName ?? Constants.exerciseIcon)
                        }
                    } header: {
                        Text("Incomplete")
                    }
                }
                Section {
                    Button {
                        StartIncompleteSession(incomplete: session)
                    } label: {
                        Label("Continue", systemImage: "play")
                    }
                    Button {
                        context.delete(session)
                    } label: {
                        Label("Delete", systemImage: "trash")
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
        for exercise in workout.sortedExercises {
            sm.QueueExercise(exercise: exercise)
        }
        context.insert(newSession)
        sm.session = newSession
        sm.sessionStartDate = Date()
    }
    
    private func StartIncompleteSession(incomplete: WorkoutSession) {
        if let workout = incomplete.workout {
            
            sm.completedExercises = incomplete.exercises ?? []
            
            for exercise in workout.sortedExercises {
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
    
    func predictNextWorkout() -> Workout? {
        // Find the active split
        guard let activeSplit = allSplits.first(where: { $0.active }) else { return nil }
        
        // Get all workouts in the active split
        guard let workouts = activeSplit.workouts, !workouts.isEmpty else { return nil }
        
        // Find the most recently completed session across all workouts
        let mostRecentSession = findMostRecentCompletedSession(in: workouts)
        
        // If no completed sessions exist, return the first workout
        guard let recentSession = mostRecentSession,
              let lastWorkout = recentSession.workout else {
            return workouts.first
        }
        
        // Find the index of the last completed workout
        guard let lastWorkoutIndex = workouts.firstIndex(where: { $0 === lastWorkout }) else {
            return workouts.first
        }
        
        // Get the next workout (or wrap around to the first one)
        let nextIndex = lastWorkoutIndex + 1
        if nextIndex < workouts.count {
            return workouts[nextIndex]
        } else {
            return workouts.first
        }
    }
    
    /// Finds the most recently completed session from a list of workouts
    private func findMostRecentCompletedSession(in workouts: [Workout]) -> WorkoutSession? {
        var mostRecentSession: WorkoutSession?
        var mostRecentDate: Date?
        
        for workout in workouts {
            guard let sessions = workout.sessions else { continue }
            
            for session in sessions {
                // Only consider completed sessions
                guard let completedDate = session.completed else { continue }
                
                // Check if this is the most recent completed session
                if mostRecentDate == nil || completedDate > mostRecentDate! {
                    mostRecentDate = completedDate
                    mostRecentSession = session
                }
            }
        }
        
        return mostRecentSession
    }
    
}
