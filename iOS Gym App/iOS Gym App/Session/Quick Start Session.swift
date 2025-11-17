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
                if let split = allSplits.first(where: { $0.active }) {
                    Section {
                        ForEach(split.workouts ?? [], id: \.self) { workout in
                            ReusedViews.SessionViews.WorkoutSessionView(workout: workout, start: { workout in QueueWorkout(workout: workout) })
                        }
                    }
                }
//                if let nextWorkout = predictNextWorkout() {
//                    Section {
//                        UpNextCard(workout: nextWorkout)
//                            .listRowBackground(nextWorkout.color)
//                        if let split = nextWorkout.split {
//                            ForEach(split.workouts ?? [], id: \.self) { workout in
//                                if workout != nextWorkout {
//                                    ReusedViews.SessionViews.WorkoutSessionView(workout: workout, start: { workout in QueueWorkout(workout: workout) })
//                                }
//                            }
//                        }
//                    } header: {
//                        ReusedViews.Labels.Header(text: "Next up")
//                    }
//                }
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
        VStack {
            HStack {
                ReusedViews.Labels.Description(topText: workout.name, bottomText: "\(workout.exercises?.count ?? 0) Exercise\(workout.exercises?.count == 1 ? "" : "s")")
                Spacer()
                Image(systemName: Constants.sessionIcon)
            }
        }
    }
        
    private func IncompleteSession(session: WorkoutSession) -> some View {
        HStack {
            ReusedViews.Labels.SmallIconSize(color: session.color)
            ReusedViews.Labels.ListDescription(title: session.name, subtitle: "Started \(DateHandler().RelativeTime(from: session.started))", extend: true)
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
                } header: {
                    Text("Completed")
                }
                if let workout = session.workout {
                    Section {
                        ForEach(workout.exercises?.filter { workoutExercise in
                            session.exercises?.contains(where: { sessionEntry in
                                sessionEntry.exercise?.id == workoutExercise.id
                            }) == false
                        } ?? [], id: \.self) { exercise in
                            Label(exercise.name, systemImage: exercise.workoutEquipment?.imageName ?? Constants.defaultEquipmentIcon)
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
        for exercise in workout.exercises ?? [] {
            sm.QueueExercise(exercise: exercise)
        }
        context.insert(newSession)
        sm.session = newSession
    }
    
    private func StartIncompleteSession(incomplete: WorkoutSession) {
        if let workout = incomplete.workout {
            
            sm.completedExercises = incomplete.exercises ?? []
            
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
