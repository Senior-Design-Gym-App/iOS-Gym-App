import Observation
import SwiftUI
import Foundation
import ActivityKit
import SwiftData
internal import Combine

@Observable
class SessionManager {
    
    // MARK: Live Activities
    var exerciseTimer: ActivityKit.Activity<WorkoutTimer>? = nil
    var elapsedTime: TimeInterval = 0
    var timer: Timer? = nil
    @ObservationIgnored @AppStorage("timerType") private var timerType: TimerType = .liveActivities
    @ObservationIgnored @AppStorage("autoAdjustWeights") private var autoAdjustWeights: Bool = true
    var sessionStartDate: Date = Date()
    
    // MARK: Session Logic
    var session: WorkoutSession?
    var currentExercise: SessionData?
    var upcomingExercises: [SessionData] = []
    var completedExercises: [WorkoutSessionEntry] = []
    var rest: Int = 0
    var reps: Int = 0
    var weight: Double = 0
    private(set) var workoutStartTime: Date? = nil  // Track when workout started
    
    // MARK: Watch Connectivity
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    private(set) var sessionId: UUID = UUID()
    @ObservationIgnored @AppStorage("syncWithWatch") var syncWithWatch: Bool = true
    private var isReceivingUpdate = false // Prevent feedback loops
    
    // MARK: SwiftData
    private weak var modelContext: ModelContext?
    
    var currentSet: Int {
        (currentExercise?.entry.weight.count ?? 0) + 1
    }
    
    var totalSets: Int {
        max(currentExercise?.exercise.recentSetData.setData.count ?? 1, currentSet)
    }
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        setupWatchConnectivity()
        setupWidgetIntentHandler()
    }
    
    /// Set or update the ModelContext (useful for dependency injection)
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
        
    func StartTimer(exercise: Exercise, entry: WorkoutSessionEntry) {
        FinishTimer()
        elapsedTime = 0
        if rest > 0 {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [self] _ in
                withAnimation {
                    elapsedTime += 1
                }
                
                if Int(self.elapsedTime) >= rest {
                    // Play haptic feedback when timer completes
                    #if os(iOS)
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    #endif
                    print("⏰ Rest timer completed - playing haptic")
                    self.FinishTimer()
                }
            })
            
            // Handle timer type-specific behaviors
            switch timerType {
            case .liveActivities:
                UpdateLiveActivity(exercise: exercise)
            case .notifications:
                NotificationManager.instance.ScheduleNotification(seconds: rest)
            case .timer:
                // Just use the basic timer (already created above)
                break
            case .none:
                // User doesn't want a timer - stop it
                FinishTimer()
            }
        }
        
        // Send timer started action to notify Watch (do this even if rest is 0 or timer is disabled)
        sendAction(.timerStarted)
        
        // Initial sync when timer starts
        syncCurrentState()
    }
    
    // MARK: - Watch Connectivity Setup
    
    private func setupWatchConnectivity() {
        // Listen for updates from other device
        NotificationCenter.default.publisher(for: .liveSessionUpdated)
            .sink { [weak self] notification in
                guard let update = notification.userInfo?["update"] as? LiveSessionUpdate else { return }
                self?.handleRemoteSessionUpdate(update)
            }
            .store(in: &cancellables)
        
        // Listen for actions from other device
        NotificationCenter.default.publisher(for: .sessionActionReceived)
            .sink { [weak self] notification in
                guard let action = notification.userInfo?["action"] as? SessionAction,
                      let sessionId = notification.userInfo?["sessionId"] as? UUID else { return }
                self?.handleRemoteAction(action, sessionId: sessionId)
            }
            .store(in: &cancellables)
        
        // Listen for session start from other device
        NotificationCenter.default.publisher(for: .remoteSessionStarted)
            .sink { [weak self] notification in
                guard let workoutTransfer = notification.userInfo?["workoutTransfer"] as? WorkoutTransfer,
                      let sessionId = notification.userInfo?["sessionId"] as? UUID else { return }
                self?.handleRemoteStartSession(workoutTransfer: workoutTransfer, sessionId: sessionId)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Widget Intent Handler
    
    private func setupWidgetIntentHandler() {
        // Listen for workout start requests from widget
        NotificationCenter.default.publisher(for: .startWorkoutFromWidget)
            .sink { [weak self] notification in
                guard let workoutID = notification.userInfo?["workoutID"] as? String else {
                    print("❌ Widget Intent: No workout ID provided")
                    return
                }
                self?.handleWidgetWorkoutStart(workoutID: workoutID)
            }
            .store(in: &cancellables)
    }
    
    /// Handle workout start request from widget
    private func handleWidgetWorkoutStart(workoutID: String) {
        guard let modelContext = modelContext else {
            print("❌ Widget Intent: No ModelContext available")
            return
        }
        
        print("🎯 Widget Intent: Starting workout with ID: \(workoutID)")
        
        // Load the active split to find the workout
        guard let activeSplit = WidgetDataManager.shared.getActiveSplit() else {
            print("❌ Widget Intent: No active split found")
            return
        }
        
        // Find the workout in the split by ID
        guard let workoutTransfer = activeSplit.workouts.first(where: { $0.id.uuidString == workoutID }) else {
            print("❌ Widget Intent: Workout not found in active split")
            return
        }
        
        print("✅ Widget Intent: Found workout '\(workoutTransfer.name)'")
        
        // Find the matching workout in the database by name
        let workoutDescriptor = FetchDescriptor<Workout>(
            predicate: #Predicate<Workout> { workout in
                workout.name == workoutTransfer.name
            }
        )
        
        do {
            let workouts = try modelContext.fetch(workoutDescriptor)
            
            if let workout = workouts.first {
                print("✅ Widget Intent: Found workout in database, starting session...")
                
                // Check if there's already an active session
                if session != nil {
                    print("⚠️ Widget Intent: Session already active, not starting new one")
                    return
                }
                
                // Start the session using the existing method
                // This will queue all exercises and sync with watch
                startSession(workout: workout, context: modelContext)
                
                print("✅ Widget Intent: Session started successfully")
                print("✅ Widget Intent: Current exercise: \(currentExercise?.exercise.name ?? "none")")
                print("✅ Widget Intent: Upcoming exercises: \(upcomingExercises.count)")
            } else {
                print("❌ Widget Intent: Workout '\(workoutTransfer.name)' not found in database")
            }
        } catch {
            print("❌ Widget Intent: Failed to fetch workout: \(error)")
        }
    }
    
    // MARK: - Sync Methods
    
    /// Sync current session state to other device
    private func syncCurrentState() {
        guard syncWithWatch, !isReceivingUpdate else { return }
        
        let currentExerciseState: LiveExerciseState?
        if let current = currentExercise {
            currentExerciseState = LiveExerciseState(
                exerciseId: UUID(), // TODO: Need proper exercise ID mapping
                exerciseName: current.exercise.name,
                currentSet: currentSet,
                totalSets: totalSets,
                currentReps: reps,
                currentWeight: weight,
                restTime: rest,
                elapsedTime: elapsedTime,
                completedReps: current.entry.reps,
                completedWeights: current.entry.weight
            )
        } else {
            currentExerciseState = nil
        }
        
        // Extract upcoming exercise names from the queue
        let upcomingNames = upcomingExercises.map { $0.exercise.name }
        
        let update = LiveSessionUpdate(
            sessionId: sessionId,
            currentExercise: currentExerciseState,
            upcomingExerciseIds: [], // TODO: Map exercises to IDs
            completedExerciseIds: [],  // TODO: Map completed exercises
            workoutStartTime: workoutStartTime,  // Include workout start time
            upcomingExerciseNames: upcomingNames  // Send exercise names for Watch display
        )
        
        let connectivityManager = WatchConnectivityManager.shared
        connectivityManager.sendLiveSessionUpdate(update)
        
        print("📤 Synced state to Watch - Current: \(currentExerciseState?.exerciseName ?? "none"), Upcoming: \(upcomingNames.joined(separator: ", "))")
    }
    
    /// Handle session update from other device
    /// NOTE: iPhone is the source of truth - Watch doesn't send state updates back
    /// This handler is kept for potential future multi-device support
    private func handleRemoteSessionUpdate(_ update: LiveSessionUpdate) {
        // Check if this is a new session (different session ID)
        let isNewSession = update.sessionId != sessionId
        
        // If new session and we have an active session, ignore it (let remote start handle it)
        guard update.sessionId == sessionId || isNewSession, !isReceivingUpdate else { return }
        
        // Ensure we're on the main thread for SwiftData operations
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.handleRemoteSessionUpdate(update)
            }
            return
        }
        
        isReceivingUpdate = true
        defer { isReceivingUpdate = false }
        
        if isNewSession {
            print("🔄 New session detected (ID mismatch) - resetting state")
            // Reset everything for the new session
            sessionId = update.sessionId
            FinishTimer()
            elapsedTime = 0
            rest = 0
            workoutStartTime = update.workoutStartTime
            print("🔄 Reset to new session with ID: \(sessionId)")
        } else {
            print("🔄 Applying remote session update")
        }
        
        // Sync workout start time if we don't have one or if it's a new session
        if workoutStartTime == nil, let remoteStartTime = update.workoutStartTime {
            workoutStartTime = remoteStartTime
            print("🔄 Synced workout start time: \(remoteStartTime)")
        }
        
        // Update current exercise state
        if let remoteExercise = update.currentExercise {
            reps = remoteExercise.currentReps
            weight = remoteExercise.currentWeight
            
            // Sync rest time (but run our own timer independently)
            let previousRest = rest
            rest = remoteExercise.restTime
            
            // Only start timer if this is the first time we're getting rest time
            if previousRest == 0 && rest > 0, let current = currentExercise {
                print("🔄 First rest time received (\(rest)s) - starting timer")
                StartTimer(exercise: current.exercise, entry: current.entry)
            }
            
            print("🔄 Synced rest: \(rest)s (running independent timer)")
            
            // Update completed sets
            if let current = currentExercise {
                current.entry.reps = remoteExercise.completedReps
                current.entry.weight = remoteExercise.completedWeights
            }
        }
    }
    
    /// Handle action from other device
    private func handleRemoteAction(_ action: SessionAction, sessionId: UUID) {
        guard sessionId == self.sessionId, !isReceivingUpdate else { return }
        
        // Ensure we're on the main thread for SwiftData operations
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.handleRemoteAction(action, sessionId: sessionId)
            }
            return
        }
        
        isReceivingUpdate = true
        defer { isReceivingUpdate = false }
        
        print("🔄 Executing remote action: \(action)")
        
        switch action {
        case .timerStarted:
            // Watch timer was reset/started - just reset elapsed time (don't call StartTimer as that would send action back)
            print("🔄 Timer started signal received - resetting elapsed time")
            elapsedTime = 0
            
        case .nextSet:
            // Execute the action locally (iPhone is source of truth)
            print("🔄 Next set requested from Watch - executing locally")
            performNextSet()
            // Send updated state back to Watch
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.syncCurrentState()
            }
            
        case .previousSet:
            // Execute the action locally (iPhone is source of truth)
            print("🔄 Previous set requested from Watch - executing locally")
            performPreviousSet()
            // Send updated state back to Watch
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.syncCurrentState()
            }
            
        case .nextExercise:
            // Execute the action locally (iPhone is source of truth)
            print("🔄 Next exercise requested from Watch - executing locally")
            performNextWorkout()
            // Send updated state back to Watch
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.syncCurrentState()
            }
            
        case .previousExercise:
            // Execute the action locally (iPhone is source of truth)
            print("🔄 Previous exercise requested from Watch - executing locally")
            performPreviousWorkout()
            // Send updated state back to Watch
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.syncCurrentState()
            }
            
        case .updateReps, .updateWeight, .updateRest:
            // These will be handled by the LiveSessionUpdate that follows
            print("🔄 Value update action received - will apply via state sync")
        case .endSession:
            handleRemoteEndSession()
        case .cancelSession:
            handleRemoteCancelSession()
        case .timerTick:
            // Timer updates are handled by LiveSessionUpdate
            break
        case .startSession:
            // Session start is handled separately
            break
        }
    }
    
    /// Handle session end from remote device
    private func handleRemoteEndSession() {
        print("🔄 Ending session from remote device")
        
        // Small delay to ensure any in-flight sync updates are processed first
        // This prevents race conditions where endSession arrives before final state sync
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            
            // Wrap in main actor to ensure thread safety with @Observable
            Task { @MainActor in
                self.performRemoteEndSession()
            }
        }
    }
    
    /// Actually perform the remote session end (called after delay to avoid race conditions)
    @MainActor
    private func performRemoteEndSession() {
        print("🔄 Performing remote session end")
        
        // End live activity
        EndLiveActivity()
        
        // Store references before clearing to avoid accessing cleared state
        let sessionToSave = self.session
        let currentExerciseToLink = self.currentExercise
        let completedExercisesToLink = self.completedExercises
        let context = self.modelContext
        
        // Complete and SAVE the session
        if let session = sessionToSave {
            session.completed = Date.now
            print("✅ Completed session '\(session.name)' from remote")
            print("📊 Session has \(completedExercisesToLink.count) completed exercises")
            print("📊 Current exercise has \(currentExerciseToLink?.entry.reps.count ?? 0) sets")
            
            // Link all completed exercises to the session before saving
            for entry in completedExercisesToLink {
                entry.session = session
                print("  - Linked entry for exercise: \(entry.exercise?.name ?? "unknown") with \(entry.reps.count) sets")
            }
            
            // Link current exercise if it has any completed sets
            var totalEntries = completedExercisesToLink.count
            if let current = currentExerciseToLink, !current.entry.reps.isEmpty {
                current.entry.session = session
                current.entry.exercise = current.exercise
                totalEntries += 1
                print("  - Linked current exercise: \(current.exercise.name) with \(current.entry.reps.count) sets")
            }
            
            // Check if we have any data
            var hasData = completedExercisesToLink.contains { !$0.reps.isEmpty }
            if let current = currentExerciseToLink, !current.entry.reps.isEmpty {
                hasData = true
            }
            
            if !hasData {
                print("⚠️ No exercise data to save - session appears empty")
                print("⚠️ This might indicate a sync issue with the remote device")
            }
            
            // Update widget with completed workout info
            if let workout = session.workout {
                let workoutTransfer = workout.toTransfer()
                WidgetDataManager.shared.markWorkoutCompleted(
                    workoutId: workoutTransfer.id,
                    completedDate: session.completed ?? Date.now
                )
                print("✅ Updated widget for next workout")
                
                // Post notification to trigger widget validation
                NotificationCenter.default.post(name: .workoutCompletedValidateWidget, object: nil)
            }
            
            // IMPORTANT: Save the session to the database
            if let context = context {
                do {
                    try context.save()
                    print("✅ Session saved to database with \(totalEntries) entries")
                } catch {
                    print("❌ Failed to save session: \(error)")
                }
            } else {
                print("⚠️ No ModelContext available - session not saved!")
            }
        } else {
            print("⚠️ No session to save")
        }
        
        // NOW clean up - after everything is saved
        FinishTimer()
        elapsedTime = 0
        rest = 0
        reps = 0
        weight = 0
        currentExercise = nil
        upcomingExercises = []
        completedExercises = []
        self.session = nil
        workoutStartTime = nil
        
        // Generate new session ID for next workout
        sessionId = UUID()
        
        print("✅ Session state fully cleared and ready for next workout")
    }
    
    /// Handle session cancellation from remote device (delete without saving)
    private func handleRemoteCancelSession() {
        print("🔄 Canceling session from remote device (no save)")
        
        // End live activity
        EndLiveActivity()
        
        // Delete the session if it exists (don't mark as completed)
        if let session = session, let modelContext = modelContext {
            print("🗑️ Deleting session '\(session.name)' without saving")
            modelContext.delete(session)
            try? modelContext.save()
        }
        
        // Clean up - including timer state
        FinishTimer()
        elapsedTime = 0
        rest = 0
        currentExercise = nil
        upcomingExercises = []
        completedExercises = []
        self.session = nil
        workoutStartTime = nil
        
        print("✅ Session canceled and cleaned up")
    }
    
    /// Handle remote session start with workout data
    private func handleRemoteStartSession(workoutTransfer: WorkoutTransfer, sessionId: UUID) {
        guard !isReceivingUpdate else { 
            print("⚠️ Already receiving update, ignoring remote session start")
            return 
        }
        
        // Check if there's already an active session
        if session != nil {
            print("⚠️ Cannot start remote session - active session already exists on this device")
            print("⚠️ Current session: '\(session?.name ?? "unknown")' must be completed first")
            
            // Post notification to show alert on UI
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: Notification.Name("remoteSessionStartFailed"),
                    object: nil,
                    userInfo: [
                        "reason": "An active session is already in progress. Complete it before starting a new workout.",
                        "workoutName": workoutTransfer.name
                    ]
                )
            }
            return
        }
        
        guard let modelContext = modelContext else {
            print("❌ No ModelContext available - cannot start remote session")
            return
        }
        
        // Ensure we're on the main thread for SwiftData operations
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.handleRemoteStartSession(workoutTransfer: workoutTransfer, sessionId: sessionId)
            }
            return
        }
        
        isReceivingUpdate = true
        defer { isReceivingUpdate = false }
        
        print("🔄 Starting session from remote device: '\(workoutTransfer.name)'")
        
        // Set the session ID to match the remote device
        self.sessionId = sessionId
        
        // Clear any existing session data
        FinishTimer()
        currentExercise = nil
        upcomingExercises = []
        completedExercises = []
        
        // Try to find the matching workout in the database
        // Since IDs are hash-based, we can recreate the workout transfer and match by name
        let workoutDescriptor = FetchDescriptor<Workout>(
            predicate: #Predicate<Workout> { workout in
                workout.name == workoutTransfer.name
            }
        )
        
        let matchingWorkout: Workout
        do {
            let workouts = try modelContext.fetch(workoutDescriptor)
            if let found = workouts.first {
                matchingWorkout = found
                print("✅ Found matching workout: '\(found.name)'")
            } else {
                // Create a temporary workout if not found
                print("⚠️ No matching workout found for '\(workoutTransfer.name)', creating temporary workout")
                matchingWorkout = Workout(name: workoutTransfer.name, exercises: [])
                modelContext.insert(matchingWorkout)
            }
        } catch {
            print("❌ Failed to fetch workout: \(error), creating temporary workout")
            matchingWorkout = Workout(name: workoutTransfer.name, exercises: [])
            modelContext.insert(matchingWorkout)
        }
        
        // Create a new workout session with the shared sessionId
        let newSession = WorkoutSession(name: workoutTransfer.name, started: Date.now, workout: matchingWorkout, sessionId: sessionId)
        modelContext.insert(newSession)
        self.session = newSession
        
        // IMPORTANT: Save the session immediately so it's persisted
        do {
            try modelContext.save()
            print("✅ Remote session saved to database")
        } catch {
            print("❌ Failed to save remote session: \(error)")
        }
        
        // Fetch all exercises from database by name (since IDs are hash-based)
        let exerciseNames = workoutTransfer.exercises.map { $0.name }
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate<Exercise> { exercise in
                exerciseNames.contains(exercise.name)
            }
        )
        
        do {
            let fetchedExercises = try modelContext.fetch(descriptor)
            print("📦 Fetched \(fetchedExercises.count) exercises from database")
            
            // Create a lookup dictionary for fast access
            let exerciseLookup = Dictionary(uniqueKeysWithValues: fetchedExercises.map { ($0.name, $0) })
            
            // Queue exercises in the same order as the workout transfer
            // Only queue exercises that exist in the local database
            var queuedCount = 0
            var skippedCount = 0
            
            for exerciseTransfer in workoutTransfer.exercises {
                if let exercise = exerciseLookup[exerciseTransfer.name] {
                    QueueExercise(exercise: exercise)
                    queuedCount += 1
                } else {
                    print("⚠️ Skipping exercise '\(exerciseTransfer.name)' - not found in local database")
                    skippedCount += 1
                }
            }
            
            let totalQueued = (currentExercise != nil ? 1 : 0) + upcomingExercises.count
            
            if queuedCount > 0 {
                print("✅ Successfully started remote session with \(queuedCount) exercises (Current: \(currentExercise != nil ? 1 : 0), Upcoming: \(upcomingExercises.count))")
                if skippedCount > 0 {
                    print("⚠️ Skipped \(skippedCount) exercises that weren't found locally")
                }
                sendSessionAcknowledgment(success: true)
            } else {
                print("❌ No exercises could be queued - session cannot start")
                sendSessionAcknowledgment(success: false)
            }
            
        } catch {
            print("❌ Failed to fetch exercises: \(error)")
            sendSessionAcknowledgment(success: false)
        }
    }
    
    /// Send acknowledgment that session was started successfully
    private func sendSessionAcknowledgment(success: Bool) {
        guard syncWithWatch else { return }
        
        // Temporarily allow sending during receive
        let wasReceiving = isReceivingUpdate
        isReceivingUpdate = false
        
        if success {
            syncCurrentState()
        }
        
        isReceivingUpdate = wasReceiving
        print(success ? "✅ Sent session start acknowledgment" : "❌ Sent session start failure")
    }
    
    /// Send action to other device
    private func sendAction(_ action: SessionAction) {
        guard syncWithWatch, !isReceivingUpdate else { return }
        let connectivityManager = WatchConnectivityManager.shared
        connectivityManager.sendSessionAction(action, sessionId: sessionId)
    }
    
    /// Send workout data to start session on other device
    private func sendStartSession(workout: Workout) {
        guard syncWithWatch, !isReceivingUpdate else { return }
        let connectivityManager = WatchConnectivityManager.shared
        connectivityManager.sendStartSessionWithWorkout(workout, sessionId: sessionId)
    }
    
    func FinishTimer() {
        timer?.invalidate()
        timer = nil
        elapsedTime = TimeInterval(rest)
    }
    
    func QueueExercise(exercise: Exercise) {
        // Ensure we're on main thread when working with SwiftData
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.QueueExercise(exercise: exercise)
            }
            return
        }
        
        let newEntry = WorkoutSessionEntry(reps: [], weight: [], session: nil, exercise: nil)
        
        // Insert into context if we have one
        if let modelContext = modelContext {
            modelContext.insert(newEntry)
        }
        
        let newQueueItem = SessionData(exercise: exercise, entry: newEntry)
        if currentExercise == nil {
            currentExercise = newQueueItem
            if let first = exercise.recentSetData.setData.first {
                reps = first.reps
                weight = first.weight
                rest = first.rest
                StartTimer(exercise: exercise, entry: newEntry)
            }
        } else {
            upcomingExercises.append(newQueueItem)
        }
    }
    
    func NextWorkout() {
        guard !isReceivingUpdate else {
            print("⚠️ Skipping NextWorkout - receiving remote update")
            return
        }
        
        // Perform the actual next exercise logic
        performNextWorkout()
        
        // Sync with watch - send action as notification, then full state
        sendAction(.nextExercise)
        // Small delay to ensure action is sent first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.syncCurrentState()
        }
    }
    
    /// Internal method to perform next exercise logic (used for both local and remote actions)
    private func performNextWorkout() {
        FinishTimer()
        if let current = currentExercise {
            current.entry.exercise = current.exercise
            current.entry.session = session
            completedExercises.append(current.entry)
            self.currentExercise = nil
        }
        
        if let next = upcomingExercises.first {
            
            QueueExercise(exercise: next.exercise)
            upcomingExercises.removeFirst()
            
        }
    }
    
    func PreviousWorkout() {
        guard !isReceivingUpdate else {
            print("⚠️ Skipping PreviousWorkout - receiving remote update")
            return
        }
        
        // Perform the actual previous exercise logic
        performPreviousWorkout()
        
        // Sync with watch - send action as notification, then full state
        sendAction(.previousExercise)
        // Small delay to ensure action is sent first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.syncCurrentState()
        }
    }
    
    /// Internal method to perform previous exercise logic (used for both local and remote actions)
    private func performPreviousWorkout() {
        FinishTimer()
        UnselectWorkout()
        if let prevEntry = completedExercises.last {
            
            if let exercise = prevEntry.exercise {
                QueueExercise(exercise: exercise)
                prevEntry.exercise = nil
            }
            
            prevEntry.session = nil
            completedExercises.removeLast()
        }
    }
    
    func NextSet() {
        guard !isReceivingUpdate else {
            print("⚠️ Skipping NextSet - receiving remote update")
            return
        }
        
        // Perform the actual set completion logic
        performNextSet()
        
        // Sync with watch - send action as notification, then full state
        sendAction(.nextSet)
        // Small delay to ensure action is sent first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.syncCurrentState()
        }
    }
    
    /// Internal method to perform next set logic (used for both local and remote actions)
    private func performNextSet() {
        FinishTimer()
        self.currentExercise?.entry.reps.append(reps)
        self.currentExercise?.entry.weight.append(weight)
        
        // Save after modifying data to prevent data loss
        if let modelContext = modelContext {
            do {
                try modelContext.save()
                print("💾 Saved set data to database")
            } catch {
                print("❌ Failed to save after completing set: \(error)")
            }
        }
        
        if let currentExercise {
            
            let nextSetIndex = currentExercise.entry.weight.count // This is now the index for the NEXT set (0-indexed)
            
            if nextSetIndex < currentExercise.exercise.recentSetData.setData.count {
                reps = currentExercise.exercise.recentSetData.setData[nextSetIndex].reps
            }
            
            if nextSetIndex < currentExercise.exercise.recentSetData.setData.count {
                let newWeight = currentExercise.exercise.recentSetData.setData[nextSetIndex].weight
                if nextSetIndex > 0, weight != newWeight, autoAdjustWeights {
                    weight = newWeight
                }
            }
            
            if nextSetIndex < currentExercise.exercise.recentSetData.setData.count {
                rest = currentExercise.exercise.recentSetData.setData[nextSetIndex].rest
            }
            
            StartTimer(exercise: currentExercise.exercise, entry: currentExercise.entry)
        }
    }
    
    func UnselectWorkout() {
        FinishTimer()
        if let currentExercise {
            upcomingExercises.insert(currentExercise, at: 0)
            self.currentExercise = nil
        }
        
        // Sync the updated queue to Watch
        syncCurrentState()
    }
    
    /// Call this method after manually reordering the exercise queue
    /// This ensures the Watch gets updated with the new order
    func syncExerciseQueueChanged() {
        syncCurrentState()
    }
    
    func PreviousSet() {
        guard !isReceivingUpdate else {
            print("⚠️ Skipping PreviousSet - receiving remote update")
            return
        }
        
        // Perform the actual previous set logic
        performPreviousSet()
        
        // Sync with watch - send action as notification, then full state
        sendAction(.previousSet)
        // Small delay to ensure action is sent first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.syncCurrentState()
        }
    }
    
    /// Internal method to perform previous set logic (used for both local and remote actions)
    private func performPreviousSet() {
        FinishTimer()
        if let weight = currentExercise?.entry.weight.last, let reps = currentExercise?.entry.reps.last {
            self.weight = weight
            self.reps = reps
        }
        
        currentExercise?.entry.weight.removeLast()
        currentExercise?.entry.reps.removeLast()
        
        if let currentExercise {
            
            let nextSetIndex = currentExercise.entry.weight.count // This is now the index for the NEXT set (0-indexed)
            if nextSetIndex < currentExercise.exercise.recentSetData.setData.count {
                rest = currentExercise.exercise.recentSetData.setData[nextSetIndex].rest
            }
            StartTimer(exercise: currentExercise.exercise, entry: currentExercise.entry)
        }
    }
    
    // MARK: - Public Methods for Value Updates
    
    /// Update reps and sync with watch
    func updateReps(_ newReps: Int) {
        guard newReps != reps, !isReceivingUpdate else { return }
        reps = newReps
        sendAction(.updateReps)
        // Small delay to ensure action is sent first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.syncCurrentState()
        }
    }
    
    /// Update weight and sync with watch
    func updateWeight(_ newWeight: Double) {
        guard newWeight != weight, !isReceivingUpdate else { return }
        weight = newWeight
        sendAction(.updateWeight)
        // Small delay to ensure action is sent first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.syncCurrentState()
        }
    }
    
    /// Update rest time and sync with watch
    func updateRest(_ newRest: Int) {
        guard newRest != rest, !isReceivingUpdate else { return }
        rest = newRest
        sendAction(.updateRest)
        // Small delay to ensure action is sent first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.syncCurrentState()
        }
    }
    
    /// Start a new session and sync with watch
    func startSession(workout: Workout, context: ModelContext? = nil) {
        let effectiveContext = context ?? modelContext
        
        guard let effectiveContext = effectiveContext else {
            print("❌ No ModelContext available - cannot start session")
            return
        }
        
        // Generate a new session ID
        sessionId = UUID()
        
        // Clear any existing session data - including timers
        FinishTimer()
        elapsedTime = 0  // Reset elapsed time for new session
        rest = 0         // Reset rest timer
        currentExercise = nil
        upcomingExercises = []
        completedExercises = []
        workoutStartTime = Date.now  // Record when workout starts
        
        // Create the workout session locally with the new sessionId
        let newSession = WorkoutSession(name: workout.name, started: Date.now, workout: workout, sessionId: sessionId)
        effectiveContext.insert(newSession)
        self.session = newSession
        
        // Queue exercises locally
        for exercise in workout.sortedExercises {
            QueueExercise(exercise: exercise)
        }
        
        print("✅ Started local session '\(workout.name)' with \(workout.sortedExercises.count) exercises")
        
        // Send to other device
        sendStartSession(workout: workout)
    }
    
    /// End session and sync with watch
    func endSession() {
        // End live activity
        EndLiveActivity()
        
        // Complete the session
        if let session = session {
            session.completed = Date.now
            print("✅ Completed session '\(session.name)'")
            
            // Update widget with completed workout info
            if let workout = session.workout {
                let workoutTransfer = workout.toTransfer()
                WidgetDataManager.shared.markWorkoutCompleted(
                    workoutId: workoutTransfer.id,
                    completedDate: session.completed ?? Date.now
                )
                print("✅ Updated widget for next workout")
                
                // Post notification to trigger widget validation
                NotificationCenter.default.post(name: .workoutCompletedValidateWidget, object: nil)
            }
        }
        
        // Send end action to other device
        sendAction(.endSession)
        
        // Final sync before clearing
        syncCurrentState()
        
        // Clean up - reset all state for fresh start
        FinishTimer()
        elapsedTime = 0
        rest = 0
        currentExercise = nil
        upcomingExercises = []
        completedExercises = []
        self.session = nil
        workoutStartTime = nil
        
        // Generate new session ID for next workout
        sessionId = UUID()
        
        print("✅ Session fully reset - ready for new workout")
    }
    
}
