import SwiftUI
import SwiftData

struct SessionHomeView: View {
    
    @Query private var allSplits: [Split]
    @Query private var allSessions: [WorkoutSession]
    @Environment(\.modelContext) private var context
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToSession: Bool = false
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
                        ForEach(split.sortedWorkouts, id: \.self) { workout in
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
                Text(alertMessage.isEmpty ? "Please end your current session before starting another." : alertMessage)
            }
            .onAppear {
                // Validate and sync widget on app launch
                validateAndSyncWidget()
                
                // Check if there's already an active session from Watch
                if sm.session != nil, sm.currentExercise != nil {
                    print("⌚️ Active session detected on app launch - navigating to session")
                    navigateToSession = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .workoutCompletedValidateWidget)) { _ in
                // Validate and sync widget when workout completes
                print("📢 Received workout completion notification - validating widget...")
                validateAndSyncWidget()
            }
            .onReceive(NotificationCenter.default.publisher(for: .remoteSessionStarted)) { _ in
                // When Watch starts a session, navigate to show it
                print("⌚️ Received remote session started notification")
                // Small delay to ensure SessionManager has processed the session
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if sm.session != nil, sm.currentExercise != nil {
                        print("⌚️ Watch started session - navigating to active session")
                        navigateToSession = true
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("remoteSessionStartFailed"))) { notification in
                // When Watch tries to start a session but fails
                print("⚠️ Received remote session start failed notification")
                if let reason = notification.userInfo?["reason"] as? String {
                    alertMessage = reason
                    showAlert = true
                }
            }
            .onChange(of: sm.session) { oldValue, newValue in
                // Also trigger navigation when session changes from nil to non-nil
                if oldValue == nil, newValue != nil, sm.currentExercise != nil {
                    print("⌚️ Session became active - navigating")
                    navigateToSession = true
                }
            }
            .navigationDestination(isPresented: $navigateToSession) {
                // Show the active session view
                if sm.currentExercise != nil {
                    SessionCurrentExerciseView(sessionManager: sm)
                        .navigationTitle(sm.session?.name ?? "Active Session")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("End") {
                                    sm.endSession()
                                    navigateToSession = false
                                }
                                .foregroundStyle(.red)
                            }
                        }
                }
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
            ForEach(workout.sortedExercises, id: \.id) { exercise in
                HStack {
                    Image(systemName: exercise.workoutEquipment?.imageName ?? Constants.defaultEquipmentIcon)
                        .resizable()
                        .frame(width: Constants.tinyIconSIze, height: Constants.tinyIconSIze)
                    Text("\(exercise.name) (\(exercise.recentSetData.setData.count))")
                        .fontWeight(.medium)
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
        
        // Validate workout has exercises
        guard !workout.sortedExercises.isEmpty else {
            print("⚠️ Cannot start workout '\(workout.name)' - has no exercises")
            // TODO: Show a user-friendly alert here
            return
        }
        
        // Use SessionManager's startSession method which handles syncing to other devices
        sm.startSession(workout: workout, context: context)
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
        
        // Get all workouts in the active split (respecting custom order)
        let workouts = activeSplit.sortedWorkouts
        guard !workouts.isEmpty else { return nil }
        
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
    
    /// Validate that widget's "up next" matches the phone's prediction and sync if needed
    private func validateAndSyncWidget() {
        print("🔄 Validating widget 'up next' against phone prediction...")
        
        // Get the active split
        guard let activeSplit = allSplits.first(where: { $0.active }) else {
            print("⚠️ No active split - skipping widget validation")
            return
        }
        
        // Get phone's prediction for next workout
        guard let phoneNextWorkout = predictNextWorkout() else {
            print("⚠️ Phone could not predict next workout - skipping validation")
            return
        }
        
        // Get widget's current prediction
        guard let widgetNextWorkout = WidgetDataManager.shared.getNextWorkoutInSplit() else {
            print("⚠️ Widget has no next workout prediction - syncing now")
            syncWidgetWithPhone(split: activeSplit)
            return
        }
        
        // Convert phone's workout to transfer for ID comparison
        let phoneWorkoutTransfer = phoneNextWorkout.toTransfer()
        
        // Compare IDs
        if phoneWorkoutTransfer.id != widgetNextWorkout.id {
            print("⚠️ MISMATCH DETECTED!")
            print("   Phone predicts: '\(phoneNextWorkout.name)' (ID: \(phoneWorkoutTransfer.id))")
            print("   Widget shows: '\(widgetNextWorkout.name)' (ID: \(widgetNextWorkout.id))")
            print("🔄 Forcing widget to sync with phone...")
            
            syncWidgetWithPhone(split: activeSplit)
        } else {
            print("✅ Widget 'up next' matches phone prediction: '\(phoneNextWorkout.name)'")
        }
    }
    
    /// Force widget to sync with phone's current state
    private func syncWidgetWithPhone(split: Split) {
        // Refresh the split in widget data
        let transferSplit = split.toTransfer()
        WidgetDataManager.shared.refreshActiveSplit(transferSplit)
        
        print("✅ Widget synced with phone - widget will now show correct 'up next'")
    }
    
}
