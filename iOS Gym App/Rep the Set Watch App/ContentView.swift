//
//  ContentView.swift
//  Rep the Set Watch App
//
//  Main workout view using synced data from iPhone
//

import SwiftUI
internal import Combine
import WatchConnectivity
import HealthKit
import WatchKit
import AppIntents

// MARK: - Workout Session Model

final class WorkoutSessionModel: ObservableObject {
    @Published var workout: WorkoutTransfer
    @Published var currentExerciseIndex: Int = 0
    @Published var currentSet: Int = 1
    @Published var completedSets: [[Int]] = [] // [exercise][set] = reps
    @Published var weights: [[Double]] = [] // [exercise][set] = weight
    @Published var isRunning: Bool = false

    @Published var workoutElapsed: TimeInterval = 0
    @Published var setElapsed: TimeInterval = 0
    @Published var restTime: Int = 90  // Current rest time in seconds
    
    // Sync properties
    @Published var repsInput: Int = 0
    @Published var weightInput: Double = 0
    
    private var workoutTimer: Timer?
    private var setTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var isReceivingUpdate = false
    private var sessionEndedRemotely = false  // Track if iPhone ended the session
    var sessionId: UUID?
    
    // Track if this session was started from iPhone (should sync)
    private let syncEnabled: Bool
    
    // Track if this session originated from iPhone (vs locally on Watch)
    let isPhoneInitiated: Bool
    
    // Workout start time for accurate sync
    private var workoutStartTime: Date?

    init(workout: WorkoutTransfer, sessionId: UUID? = nil, syncEnabled: Bool = true, workoutStartTime: Date? = nil) {
        self.workout = workout
        // If sessionId was provided, this is a phone-initiated session
        self.isPhoneInitiated = (sessionId != nil)
        self.sessionId = sessionId ?? UUID()  // Always have a session ID
        self.syncEnabled = syncEnabled
        self.workoutStartTime = workoutStartTime
        
        print("⌚️ WorkoutSessionModel init: isPhoneInitiated=\(self.isPhoneInitiated), sessionId=\(self.sessionId?.uuidString ?? "nil")")
        
        // Initialize tracking arrays
        self.completedSets = Array(repeating: [], count: workout.exercises.count)
        self.weights = Array(repeating: [], count: workout.exercises.count)
        
        // Initialize inputs from first exercise
        if let firstExercise = workout.exercises.first {
            self.repsInput = firstExercise.targetReps
            self.weightInput = firstExercise.targetWeight ?? 0
            
            // Initialize rest time from first exercise
            if let restTimes = firstExercise.restTimes, !restTimes.isEmpty {
                self.restTime = restTimes[0]  // First set's rest time
            }
        }
        
        if syncEnabled {
            setupSyncListeners()
            
            // If this session was started on Watch (no sessionId provided initially),
            // send start session message to iPhone
            if !isPhoneInitiated {
                sendStartSessionToiPhone()
            }
        }
    }
    
    deinit {
        workoutTimer?.invalidate()
        setTimer?.invalidate()
        cancellables.removeAll()
    }
    
    // MARK: - Sync Setup
    
    private func setupSyncListeners() {
        print("⌚️ WorkoutSessionModel: Setting up sync listeners")
        
        // Listen for live session updates from iPhone
        NotificationCenter.default.publisher(for: .liveSessionUpdated)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let update = notification.userInfo?["update"] as? LiveSessionUpdate else { return }
                self?.handleRemoteUpdate(update)
            }
            .store(in: &cancellables)
        
        // Listen for session actions from iPhone
        NotificationCenter.default.publisher(for: .sessionActionReceived)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let action = notification.userInfo?["action"] as? SessionAction else { return }
                self?.handleRemoteAction(action)
            }
            .store(in: &cancellables)
        
        print("✅ WorkoutSessionModel: Sync listeners ready")
    }
    
    // MARK: - Handle Remote Updates
    
    private func handleRemoteUpdate(_ update: LiveSessionUpdate) {
        guard !isReceivingUpdate else { return }
        
        isReceivingUpdate = true
        defer { isReceivingUpdate = false }
        
        print("⌚️ WorkoutSessionModel: Received remote update")
        
        // Check if this is a new session (different session ID)
        let isNewSession = sessionId != nil && sessionId != update.sessionId
        
        // Store session ID if we don't have one
        if sessionId == nil {
            sessionId = update.sessionId
        } else if isNewSession {
            // New session detected - reset everything
            print("⌚️ New session detected - resetting timers")
            sessionId = update.sessionId
            workoutElapsed = 0
            setElapsed = 0
            workoutStartTime = nil
            workoutTimer?.invalidate()
            setTimer?.invalidate()
        }
        
        // Sync workout start time if available; align local timer to phone
        if let remoteStartTime = update.workoutStartTime {
            let previousStart = workoutStartTime
            // Adopt remote start time even if we already have a provisional local one
            workoutStartTime = remoteStartTime
            print("⌚️ Synced workout start time: \(remoteStartTime)")
            
            // If the start time changed significantly, restart the workout timer to align elapsed time
            if let previousStart, abs(previousStart.timeIntervalSince1970 - remoteStartTime.timeIntervalSince1970) > 0.5 {
                if isRunning {
                    workoutTimer?.invalidate()
                    startWorkoutTimer()
                } else {
                    // If not running yet, ensure elapsed reflects remote start when started
                    workoutElapsed = Date().timeIntervalSince(remoteStartTime)
                }
            } else if previousStart == nil && isRunning {
                // First time receiving start time while running - restart timer
                workoutTimer?.invalidate()
                startWorkoutTimer()
            }
        }
        
        guard let remoteExercise = update.currentExercise else { return }
        
        // Find the exercise index by name
        if let exerciseIndex = workout.exercises.firstIndex(where: { $0.name == remoteExercise.exerciseName }) {
            if exerciseIndex != currentExerciseIndex {
                currentExerciseIndex = exerciseIndex
                print("⌚️ Synced exercise index to \(exerciseIndex)")
            }
        }
        
        // Update current set
        if remoteExercise.currentSet != currentSet {
            currentSet = remoteExercise.currentSet
            print("⌚️ Synced current set to \(currentSet)")
        }
        
        // Update inputs
        repsInput = remoteExercise.currentReps
        weightInput = remoteExercise.currentWeight
        
        // Update elapsed time (use remote time as source of truth)
        setElapsed = remoteExercise.elapsedTime
        
        // Update completed sets for current exercise
        if currentExerciseIndex < completedSets.count {
            completedSets[currentExerciseIndex] = remoteExercise.completedReps
            weights[currentExerciseIndex] = remoteExercise.completedWeights
        }
        
        print("⌚️ Synced: Set \(currentSet), Reps \(repsInput), Weight \(weightInput), Elapsed \(setElapsed)")
    }
    
    private func handleRemoteAction(_ action: SessionAction) {
        guard !isReceivingUpdate else { 
            print("⌚️ Skipping remote action - already receiving update")
            return 
        }
        
        print("⌚️ WorkoutSessionModel: Received remote action: \(action)")
        
        // Execute the action locally to stay in sync
        // Note: We don't set isReceivingUpdate here because we want to allow
        // the subsequent state sync to come through
        switch action {
        case .nextSet:
            let maxSets = currentExercise.targetSets
            if currentSet < maxSets {
                currentSet += 1
                updateRestTime()  // Update rest time for new set
                print("⌚️ Advanced to set \(currentSet)")
                
                // Play haptic feedback
                WKInterfaceDevice.current().play(.success)
            }
            resetSetTimer()
            
        case .previousSet:
            currentSet = max(1, currentSet - 1)
            updateRestTime()  // Update rest time for previous set
            resetSetTimer()
            
        case .nextExercise:
            if currentExerciseIndex + 1 < workout.exercises.count {
                currentExerciseIndex += 1
                currentSet = 1
                repsInput = currentExercise.targetReps
                weightInput = currentExercise.targetWeight ?? 0
                updateRestTime()  // Update rest time for new exercise
                print("⌚️ Advanced to exercise: \(currentExercise.name)")
            }
            resetSetTimer()
            
        case .previousExercise:
            if currentExerciseIndex > 0 {
                currentExerciseIndex -= 1
                currentSet = 1
                repsInput = currentExercise.targetReps
                weightInput = currentExercise.targetWeight ?? 0
                updateRestTime()  // Update rest time for previous exercise
            }
            resetSetTimer()
            
        case .endSession:
            // Stop and reset timers when session ends
            pause()
            workoutElapsed = 0
            setElapsed = 0
            workoutStartTime = nil
            sessionEndedRemotely = true  // Mark session as ended by iPhone
            print("⌚️ Timers reset after remote session end")
            
            // IMPORTANT: Stop syncing - session is ended on iPhone
            // Don't try to send any more updates
            print("⌚️ Session ended remotely - stopping all sync")
            
            // Post notification to dismiss the view (session completed on iPhone)
            NotificationCenter.default.post(name: .workoutEndedFromPhone, object: nil)
            
        case .cancelSession:
            // Phone canceled/deleted the workout - dismiss without logging
            // Post a notification that the view can listen to for dismissal
            sessionEndedRemotely = true  // Mark session as ended by iPhone
            print("⌚️ Session canceled from phone - preparing to dismiss")
            NotificationCenter.default.post(name: .workoutCanceledFromPhone, object: nil)
            
        default:
            break
        }
    }
    
    // MARK: - Send Updates to iPhone
    
    /// Send start session message to iPhone when Watch initiates workout
    private func sendStartSessionToiPhone() {
        guard let sessionId = sessionId else { return }
        
        print("⌚️ Sending start session to iPhone for workout: \(workout.name)")
        WatchConnectivityManager.shared.sendStartSessionWithWorkout(workout, sessionId: sessionId)
    }
    
    private func sendSyncUpdate() {
        guard syncEnabled, !isReceivingUpdate, !sessionEndedRemotely else {
            if sessionEndedRemotely {
                print("⌚️ Skipping sync update - session ended remotely")
            }
            return
        }
        
        let exerciseState = LiveExerciseState(
            exerciseId: currentExercise.id,
            exerciseName: currentExercise.name,
            currentSet: currentSet,
            totalSets: currentExercise.targetSets,
            currentReps: repsInput,
            currentWeight: weightInput,
            restTime: restTime,  // Use computed rest time from exercise
            elapsedTime: setElapsed,
            completedReps: completedSets[currentExerciseIndex],
            completedWeights: weights[currentExerciseIndex]
        )
        
        let update = LiveSessionUpdate(
            sessionId: sessionId ?? UUID(),
            currentExercise: exerciseState,
            upcomingExerciseIds: [],
            completedExerciseIds: [],
            workoutStartTime: workoutStartTime  // Include start time for sync
        )
        
        WatchConnectivityManager.shared.sendLiveSessionUpdate(update)
        print("⌚️ Sent sync update to iPhone (workout started: \(workoutStartTime?.formatted() ?? "nil"))")
    }
    
    private func sendAction(_ action: SessionAction) {
        guard syncEnabled, !isReceivingUpdate, !sessionEndedRemotely, let sessionId = sessionId else {
            if sessionEndedRemotely {
                print("⌚️ Skipping action send - session ended remotely")
            }
            return
        }
        WatchConnectivityManager.shared.sendSessionAction(action, sessionId: sessionId)
        
        // Send full state update shortly after action
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.sendSyncUpdate()
        }
    }

    var currentExercise: ExerciseTransfer {
        workout.exercises[currentExerciseIndex]
    }
    
    var currentReps: Int {
        let exerciseSets = completedSets[currentExerciseIndex]
        return currentSet <= exerciseSets.count ? exerciseSets[currentSet - 1] : 0
    }
    
    var currentWeight: Double {
        let exerciseWeights = weights[currentExerciseIndex]
        return currentSet <= exerciseWeights.count ? exerciseWeights[currentSet - 1] : currentExercise.targetWeight ?? 0
    }
    
    /// Update rest time from current exercise and set
    private func updateRestTime() {
        guard let restTimes = currentExercise.restTimes,
              currentSet > 0,
              currentSet <= restTimes.count else {
            restTime = 90  // Default 90 seconds if no rest time data
            return
        }
        restTime = restTimes[currentSet - 1]
        print("⌚️ Updated rest time to \(restTime)s for set \(currentSet)")
    }
    
    enum NextAdvanceOutcome {
        case advancedSet
        case advancedExercise
        case reachedEnd
    }

    func nextSet() -> NextAdvanceOutcome {
        guard !isReceivingUpdate else { return .advancedSet }
        let maxSets = currentExercise.targetSets
        if currentSet < maxSets {
            currentSet += 1
            updateRestTime()  // Update rest time for new set
            resetSetTimer()
            sendAction(.nextSet)
            return .advancedSet
        } else {
            // At max set, attempt to advance exercise
            if currentExerciseIndex + 1 < workout.exercises.count {
                currentExerciseIndex += 1
                currentSet = 1
                repsInput = currentExercise.targetReps
                weightInput = currentExercise.targetWeight ?? 0
                updateRestTime()  // Update rest time for new exercise
                resetSetTimer()
                sendAction(.nextExercise)
                return .advancedExercise
            } else {
                // Last set of last exercise
                return .reachedEnd
            }
        }
    }

    func start() {
        isRunning = true
        startWorkoutTimer()
        startSetTimer()
        
        // Send timer started action so iPhone knows to start its timer
        sendAction(.timerStarted)
        
        // Send initial sync when starting to ensure iPhone gets rest time immediately
        sendSyncUpdate()
    }

    func pause() {
        isRunning = false
        workoutTimer?.invalidate()
        setTimer?.invalidate()
    }

    func resetSetTimer() {
        setElapsed = 0
        setTimer?.invalidate()
        if isRunning { 
            startSetTimer()
            // Notify iPhone that timer was reset
            sendAction(.timerStarted)
        }
    }
    
    func logSet(reps: Int, weight: Double) {
        guard !isReceivingUpdate else { return }
        
        // Ensure arrays are large enough
        while completedSets[currentExerciseIndex].count < currentSet {
            completedSets[currentExerciseIndex].append(0)
            weights[currentExerciseIndex].append(currentExercise.targetWeight ?? 0)
        }
        
        // Update or append
        if currentSet <= completedSets[currentExerciseIndex].count {
            completedSets[currentExerciseIndex][currentSet - 1] = reps
            weights[currentExerciseIndex][currentSet - 1] = weight
        } else {
            completedSets[currentExerciseIndex].append(reps)
            weights[currentExerciseIndex].append(weight)
        }
        
        // Send sync update
        sendSyncUpdate()
    }

    func prevSet() {
        guard !isReceivingUpdate else { return }
        currentSet = max(1, currentSet - 1)
        updateRestTime()  // Update rest time for previous set
        resetSetTimer()
        sendAction(.previousSet)
    }

    func nextExercise() {
        guard !isReceivingUpdate else { return }
        guard currentExerciseIndex + 1 < workout.exercises.count else { return }
        currentExerciseIndex += 1
        currentSet = 1
        repsInput = currentExercise.targetReps
        weightInput = currentExercise.targetWeight ?? 0
        updateRestTime()  // Update rest time for new exercise
        resetSetTimer()
        sendAction(.nextExercise)
    }

    func prevExercise() {
        guard !isReceivingUpdate else { return }
        guard currentExerciseIndex > 0 else { return }
        currentExerciseIndex -= 1
        currentSet = 1
        repsInput = currentExercise.targetReps
        weightInput = currentExercise.targetWeight ?? 0
        updateRestTime()  // Update rest time for previous exercise
        resetSetTimer()
        sendAction(.previousExercise)
    }
    
    func updateReps(_ newReps: Int) {
        guard !isReceivingUpdate, newReps != repsInput else { return }
        repsInput = newReps
        sendAction(.updateReps)
    }
    
    func updateWeight(_ newWeight: Double) {
        guard !isReceivingUpdate, newWeight != weightInput else { return }
        weightInput = newWeight
        sendAction(.updateWeight)
    }
    
    func completeWorkout() -> WorkoutSessionTransfer {
        // NOTE: Do NOT send end session action here
        // This is only called for Watch-initiated sessions where we send full data
        // The calling code will send the data via sendCompletedSession
        
        print("⌚️ completeWorkout called")
        print("⌚️ Workout elapsed: \(workoutElapsed)s")
        print("⌚️ Number of exercises: \(workout.exercises.count)")
        
        // Convert to transfer model for sending back to iPhone
        var entries: [SessionEntryTransfer] = []
        
        for (index, exercise) in workout.exercises.enumerated() {
            let reps = completedSets[index]
            let weight = weights[index]
            
            print("⌚️ Exercise \(index): \(exercise.name)")
            print("⌚️   Reps: \(reps)")
            print("⌚️   Weights: \(weight)")
            
            entries.append(SessionEntryTransfer(
                exerciseId: exercise.id,
                reps: reps,
                weight: weight
            ))
        }
        
        let startTime = Date(timeIntervalSinceNow: -workoutElapsed)
        print("⌚️ Session start time: \(startTime)")
        print("⌚️ Session end time: \(Date())")
        
        return WorkoutSessionTransfer(
            name: workout.name,
            started: startTime,
            completed: Date(),
            workoutId: workout.id,
            entries: entries
        )
    }
    
    /// Send end session action to iPhone
    /// This bypasses the normal guards to ensure the action is sent even if session ended remotely
    func sendEndSessionAction() {
        guard let sessionId = sessionId else {
            print("⌚️ Cannot send end session action - no session ID")
            return
        }
        
        WatchConnectivityManager.shared.sendSessionAction(.endSession, sessionId: sessionId)
        print("⌚️ Sent end session action to iPhone")
    }

    private func startWorkoutTimer() {
        workoutTimer?.invalidate()
        
        // Set start time if not already set
        if workoutStartTime == nil {
            workoutStartTime = Date()
        }
        
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.workoutStartTime else { return }
            self.workoutElapsed = Date().timeIntervalSince(startTime)
        }
    }

    private func startSetTimer() {
        setTimer?.invalidate()
        setTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, !self.isReceivingUpdate else { return }
            
            let previousElapsed = Int(self.setElapsed)
            self.setElapsed += 1
            let currentElapsed = Int(self.setElapsed)
            
            // Check if rest timer just completed (crossed from rest time to rest time + 1)
            if self.restTime > 0 && previousElapsed < self.restTime && currentElapsed >= self.restTime {
                // Rest timer completed - play haptic
                #if os(watchOS)
                WKInterfaceDevice.current().play(.notification)
                #endif
                print("⏰ Rest timer completed - playing haptic")
            }
            
            // Send sync every 3 seconds
            if currentElapsed % 3 == 0 {
                self.sendSyncUpdate()
            }
        }
    }
}

// MARK: - Main Content View

struct ContentView: View {
    @State private var connectivityManager = WatchConnectivityManager.shared
    @Environment(WatchSessionManager.self) private var sessionManager
    
    // Create a proper binding for the fullScreenCover
    private var isSessionActiveBinding: Binding<Bool> {
        Binding(
            get: { sessionManager.isSessionActive },
            set: { newValue in
                if !newValue {
                    sessionManager.endSession()
                }
            }
        )
    }
    
    var body: some View {
        let _ = print("⌚️ ContentView.body - isSessionActive: \(sessionManager.isSessionActive)")
        
        NavigationStack {
            mainContent
        }
        // Full screen cover that automatically presents when session starts from iPhone
        .fullScreenCover(isPresented: isSessionActiveBinding) {
            if let workout = sessionManager.activeWorkout {
                WorkoutSessionView(model: WorkoutSessionModel(
                    workout: workout,
                    sessionId: sessionManager.sessionId,
                    syncEnabled: true
                ))
            } else if let workout = connectivityManager.workouts.first {
                // Fallback to first synced workout if activeWorkout hasn't arrived yet
                WorkoutSessionView(model: WorkoutSessionModel(workout: workout))
            } else if let split = connectivityManager.activeSplit, let workout = split.workouts.first {
                WorkoutSessionView(model: WorkoutSessionModel(workout: workout))
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundStyle(.orange)
                    Text("Waiting for workout from iPhone…")
                        .font(.headline)
                    Button("Dismiss") {
                        sessionManager.endSession()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
        }
        .onAppear {
            print("⌚️ ContentView appeared")
            print("⌚️ isSessionActive: \(sessionManager.isSessionActive)")
        }
        .onChange(of: sessionManager.isSessionActive) { oldValue, newValue in
            print("⌚️ ========== isSessionActive CHANGED ==========")
            print("⌚️ Old value: \(oldValue)")
            print("⌚️ New value: \(newValue)")
            print("⌚️ sessionId: \(sessionManager.sessionId?.uuidString ?? "nil")")
            print("⌚️ ===========================================")
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        if connectivityManager.workouts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "iphone.and.arrow.forward")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    
                    Text("No Workouts")
                        .font(.headline)
                    
                    Text("Open the iPhone app to sync your workouts")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    if let lastSync = connectivityManager.lastSyncDate {
                        Text("Last sync: \(lastSync.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .padding(.top, 8)
                    }
                    
                    VStack(spacing: 8) {
                        Button {
                            checkApplicationContext()
                        } label: {
                            Label("Check App Context", systemImage: "tray.and.arrow.down")
                        }
                        .buttonStyle(.bordered)
                        
                        Button {
                            connectivityManager.requestWorkouts()
                        } label: {
                            Label("Request from iPhone", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top)
                }
                .padding()
            } else {
                List {
                    if let split = connectivityManager.activeSplit {
                        Section("Active Split: \(split.name)") {
                            ForEach(split.workouts) { workout in
                                WorkoutRow(workout: workout)
                            }
                        }
                    }
                    
                    Section("All Workouts") {
                        ForEach(connectivityManager.workouts) { workout in
                            WorkoutRow(workout: workout)
                        }
                    }
                }
                .navigationTitle("Workouts")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink {
                            DebugConnectivityView()
                        } label: {
                            Image(systemName: "ant.fill")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            connectivityManager.requestWorkouts()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
    }
    
    private func checkApplicationContext() {
        let session = WCSession.default
        let context = session.receivedApplicationContext
        
        print("⌚️ Checking received application context...")
        print("⌚️ Context keys: \(context.keys)")
        
        if let workoutsData = context["workouts"] as? Data {
            print("✅ Found workouts data: \(workoutsData.count) bytes")
            do {
                let workouts = try JSONDecoder().decode([WorkoutTransfer].self, from: workoutsData)
                print("✅ Successfully decoded \(workouts.count) workouts from context")
                
                // Manually update if not already loaded
                if connectivityManager.workouts.isEmpty {
                    connectivityManager.workouts = workouts
                    print("✅ Manually loaded workouts into app")
                }
            } catch {
                print("❌ Failed to decode: \(error)")
            }
        } else {
            print("⚠️ No workouts data in received context")
            print("⚠️ iPhone may not have sent data yet. Open iPhone app and wait 30 seconds.")
        }
    }
}

// MARK: - Workout Row

struct WorkoutRow: View {
    let workout: WorkoutTransfer
    
    var body: some View {
        NavigationLink {
            WorkoutDetailView(workout: workout)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.headline)
                
                Text("\(workout.exercises.count) exercises")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Workout Detail View

struct WorkoutDetailView: View {
    let workout: WorkoutTransfer
    @State private var start = false
    @State private var showInfo = false
    @State private var showEmptyWorkoutAlert = false

    var body: some View {
        VStack(spacing: 8) {
            Text(workout.name)
                .font(.headline)

            Text("Exercises: \(workout.exercises.count)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button("Start Workout") {
                // Validate workout has exercises
                if workout.exercises.isEmpty {
                    showEmptyWorkoutAlert = true
                } else {
                    start = true
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
            .handGestureShortcut(.primaryAction)
            .fullScreenCover(isPresented: $start) {
                WorkoutSessionView(model: WorkoutSessionModel(workout: workout))
            }
            .alert("Cannot Start Workout", isPresented: $showEmptyWorkoutAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("This workout has no exercises. Add exercises on your iPhone before starting.")
            }
            
            Button("About This Plan") {
                showInfo = true
            }
            .buttonStyle(.bordered)

            .sheet(isPresented: $showInfo) {
                VStack(spacing: 8) {
                    Text(workout.name)
                        .font(.headline)
                    Text("Exercises: \(workout.exercises.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Divider()
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(workout.exercises) { ex in
                            HStack {
                                Text(ex.name)
                                    .lineLimit(2)
                                Spacer()
                                Text("\(ex.targetSets)x\(ex.targetReps)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .navigationTitle("About Plan")
            }
        }
    }
}

// MARK: - Workout Session View

struct WorkoutSessionView: View {
    @StateObject var model: WorkoutSessionModel
    @State private var heartRateManager = HeartRateManager()
    @Environment(\.dismiss) private var dismiss
    @State private var showEndConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Heart rate
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(heartRateManager.currentHeartRate > 0 ? .red : .gray)
                        Text("\(heartRateManager.currentHeartRate) BPM")
                            .monospacedDigit()
                            .font(.caption)
                        
                        if !heartRateManager.isAuthorized {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }
                    }
                    
//                     Debug info
                    if !heartRateManager.isAuthorized {
                        VStack(spacing: 2) {
                            Text("HealthKit not authorized")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                            Button("Request Access") {
                                Task {
                                    await heartRateManager.requestAuthorization()
                                }
                            }
                            .font(.caption2)
                            .buttonStyle(.bordered)
                        }
                    } else if heartRateManager.currentHeartRate == 0 {
                        Text("Waiting for heart rate...")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                VStack(spacing: 8) {
                    
                    
                    // Exercise info
                    VStack(spacing: 2) {
                        Text(model.currentExercise.name)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        Text("Set \(model.currentSet) of \(model.currentExercise.targetSets)\nTarget: \(model.currentExercise.targetReps) reps")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    // Timers
                    LabeledContent(model.workout.name) {
                        Text(timeString(model.workoutElapsed))
                            .monospacedDigit()
                    }
                    
                    // Rest timer - counts down from rest time
                    LabeledContent("Rest") {
                        let remaining = max(0, model.restTime - Int(model.setElapsed))
                        Text(timeString(TimeInterval(remaining)))
                            .monospacedDigit()
                            .foregroundStyle(remaining > 0 ? .blue : .green)
                    }
                    
                    // Reps & Weight input - now using model properties
                    
                    // Log set button - automatically advances to next set
                    Button("Next Set") {
                        model.logSet(reps: model.repsInput, weight: model.weightInput)
                        let outcome = model.nextSet()
                        if case .reachedEnd = outcome {
                            showEndConfirmation = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(model.repsInput == 0)
                    .handGestureShortcut(.primaryAction)
                    
                    Button("Next Ex.") {
                        // If at last exercise and last set, prompt to complete
                        if model.currentExerciseIndex == model.workout.exercises.count - 1 && model.currentSet >= model.currentExercise.targetSets {
                            showEndConfirmation = true
                        } else {
                            model.nextExercise()
                        }
                    }
                    .font(.caption)
                    
                    // Navigation
                    HStack(spacing: 10) {
                        Button("Prev Set") {
                            model.prevSet()
                        }
                        .font(.caption)
                        
                        Button("Prev Ex.") {
                            model.prevExercise()
                        }
                        .font(.caption)
                        
                        
                    }
                    VStack(spacing: 6) {
                        HStack {
                            Text("Reps:")
                            Spacer()
                            Button("-") { model.updateReps(max(0, model.repsInput - 1)) }
                            Text("\(model.repsInput)")
                                .frame(width: 40)
                                .monospacedDigit()
                            Button("+") { model.updateReps(model.repsInput + 1) }
                        }
                        .font(.caption)
                        
                        HStack {
                            Text("Lbs:")
                            Spacer()
                            Button("-") { model.updateWeight(max(0, model.weightInput - 5)) }
                            Text(String(format: "%.0f", model.weightInput))
                                .frame(width: 40)
                                .monospacedDigit()
                            Button("+") { model.updateWeight(model.weightInput + 5) }
                        }
                        .font(.caption)
                    }
                    .padding(.vertical, 4)
                    
                    
//                    // Timer Controls
//                    HStack(spacing: 10) {
//                        Button(model.isRunning ? "Pause" : "Start") {
//                            model.isRunning ? model.pause() : model.start()
//                        }
//                        Button("Reset Set") { model.resetSetTimer() }
//                    }
//                    .buttonStyle(.bordered)
//                    .font(.caption)
//                    .padding(.top, 4)
                    
                    // End Workout - at the bottom
                    Button("End Workout") {
                        showEndConfirmation = true
                    }
                    .buttonStyle(.bordered)
                    .foregroundStyle(.red)
                    .padding(.top, 8)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Session")
        .fullScreenCover(isPresented: $showEndConfirmation) {
            ZStack {
                // Dimmed background
                Color.black.opacity(0.6).ignoresSafeArea()
                VStack(spacing: 12) {
                    Text("End Workout?")
                        .font(.headline)
                    Text("This will save your workout to your iPhone")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)   // center-align when wrapped
                        .lineLimit(nil)                    // allow unlimited lines
                        .fixedSize(horizontal: false, vertical: true) // expand vertically to wrap
                        .padding(.horizontal)              // give it some width to wrap nicely
                    HStack(spacing: 12) {
                        Button(role: .destructive) {
                            // For phone-initiated sessions, just send end action - iPhone will save
                            // For local Watch sessions, send the completed data
                            if model.isPhoneInitiated {
                                // Phone-initiated session - just notify iPhone to end
                                print("⌚️ Ending phone-initiated session - sending end action only")
                                model.sendEndSessionAction()
                            } else {
                                // Local Watch session - send full data to iPhone for saving
                                print("⌚️ Ending Watch-initiated session - sending full workout data + end action")
                                let session = model.completeWorkout()
                                print("⌚️ Session data - workout: \(session.name), started: \(session.started), entries: \(session.entries.count)")
                                
                                // Check if we have data to send
                                for (index, entry) in session.entries.enumerated() {
                                    print("⌚️   Entry \(index): exercise=\(entry.exerciseId), reps=\(entry.reps), weights=\(entry.weight)")
                                }
                                
                                // COMMENTED OUT: Watch saving workout
                                // print("⌚️ Calling sendCompletedSession...")
                                // WatchConnectivityManager.shared.sendCompletedSession(session)
                                // print("⌚️ sendCompletedSession called")
                                
                                // Also send end session action to clean up iPhone's session state
                                model.sendEndSessionAction()
                            }
                            dismiss()
                        } label: {
                            Text("Complete Workout")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .handGestureShortcut(.primaryAction)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            model.start()
            
            // Start HealthKit workout session
            Task {
                do {
                    try await heartRateManager.startWorkoutSession()
                } catch {
                    print("❌ Failed to start workout session: \(error.localizedDescription)")
                }
            }
        }
        .onDisappear {
            model.pause()
            
            // End HealthKit workout session
            Task {
                do {
                    try await heartRateManager.endWorkoutSession()
                } catch {
                    print("❌ Failed to end workout session: \(error.localizedDescription)")
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .workoutCanceledFromPhone)) { _ in
            print("⌚️ Received workout canceled notification - dismissing")
            // Dismiss without saving
            dismiss()
        }
        .onReceive(NotificationCenter.default.publisher(for: .workoutEndedFromPhone)) { _ in
            print("⌚️ Received workout ended notification from iPhone - dismissing")
            // Dismiss (workout was completed on iPhone)
            dismiss()
        }
        .onReceive(NotificationCenter.default.publisher(for: .heartRateAutoAdvance)) { _ in
            print("💓 Heart rate auto-advance triggered - advancing to next set")
            // Log current set first
            model.logSet(reps: model.repsInput, weight: model.weightInput)
            // Advance to next set (same as button press)
            let outcome = model.nextSet()
            if case .reachedEnd = outcome {
                showEndConfirmation = true
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func timeString(_ interval: TimeInterval) -> String {
        let seconds = Int(interval) % 60
        let minutes = (Int(interval) / 60) % 60
        let hours = Int(interval) / 3600
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

// MARK: - Active Session View (Synced from iPhone)

struct ActiveSessionView: View {
    @Environment(WatchSessionManager.self) private var sessionManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Exercise Name
                Text(sessionManager.currentExerciseName)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                // Set Progress
                Text("Set \(sessionManager.currentSet) of \(sessionManager.totalSets)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                // Current Stats
                VStack(spacing: 12) {
                    HStack {
                        VStack {
                            Text("Reps")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(sessionManager.currentReps)")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack {
                            Text("Weight")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(sessionManager.currentWeight, specifier: "%.1f")")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    if sessionManager.restTime > 0 {
                        VStack {
                            Text("Rest")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(timeString(TimeInterval(sessionManager.restTime - Int(sessionManager.elapsedTime))))
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(sessionManager.elapsedTime < Double(sessionManager.restTime) ? .blue : .green)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Completed Sets
                if !sessionManager.completedReps.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Completed")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        ForEach(Array(sessionManager.completedReps.enumerated()), id: \.offset) { index, reps in
                            HStack {
                                Text("Set \(index + 1):")
                                    .font(.caption2)
                                Text("\(reps) × \(sessionManager.completedWeights[index], specifier: "%.1f") lbs")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Action Buttons
                VStack(spacing: 8) {
                    Button {
                        sessionManager.nextSet()
                    } label: {
                        Label("Next Set", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(sessionManager.currentSet > sessionManager.totalSets)
                    .handGestureShortcut(.primaryAction)
                    
                    Button(role: .destructive) {
                        sessionManager.endSession()
                    } label: {
                        Label("End Workout", systemImage: "stop.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 8)
                }
            }
            .padding()
        }
        .navigationTitle("Active Workout")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func timeString(_ interval: TimeInterval) -> String {
        let seconds = Int(interval) % 60
        let minutes = (Int(interval) / 60) % 60
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "%02ds", seconds)
        }
    }
}

#Preview {
    ContentView()
}

