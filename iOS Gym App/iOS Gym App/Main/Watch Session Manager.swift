//
//  Watch Session Manager.swift
//  watchOS Gym App
//
//  Session manager for Apple Watch that syncs with iPhone
//

import Observation
import SwiftUI
import Foundation
import WatchConnectivity
import HealthKit
#if os(watchOS)
import WatchKit
#endif
internal import Combine

@Observable
class WatchSessionManager {
    
    // MARK: - Session State
    var sessionId: UUID?
    var activeWorkout: WorkoutTransfer?  // The workout being performed (for showing regular UI)
    var currentExerciseName: String = ""
    var nextExerciseName: String = ""  // Track the next exercise from iPhone's queue
    var upcomingExerciseNames: [String] = []  // Full queue from iPhone
    var currentSet: Int = 1
    var totalSets: Int = 3
    var currentReps: Int = 10
    var currentWeight: Double = 0
    var restTime: Int = 0
    var elapsedTime: TimeInterval = 0
    var completedReps: [Int] = []
    var completedWeights: [Double] = []
    var showEmptyWorkoutAlert: Bool = false  // Alert state
    
    // MARK: - Heart Rate Auto-Advance
    var isAutoAdvanceEnabled: Bool = true  // Enabled by default
    var currentHeartRate: Double = 0
    
    var isSessionActive: Bool {
        sessionId != nil && activeWorkout != nil
    }
    
    // MARK: - Private
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private let healthStore = HKHealthStore()
    @ObservationIgnored private var heartRateQuery: HKQuery?
    @ObservationIgnored private var workoutSession: HKWorkoutSession?
    @ObservationIgnored private var workoutBuilder: HKLiveWorkoutBuilder?
    
    // Heart rate tracking for auto-advance
    @ObservationIgnored private var heartRateHistory: [Double] = []
    @ObservationIgnored private var peakHeartRate: Double = 0
    @ObservationIgnored private var isInSet: Bool = false
    @ObservationIgnored private let heartRateThreshold: Double = 0.85 // 85% of peak indicates recovery
    
    @ObservationIgnored var isReceivingUpdate = false
    
    init() {
        print("⌚️ WatchSessionManager init called")
        setupWatchConnectivity()
        requestHealthKitAuthorization()
        print("⌚️ WatchSessionManager init complete")
    }
    
    // MARK: - Watch Connectivity Setup
    
    private func setupWatchConnectivity() {
        print("⌚️ Setting up WatchConnectivity listeners...")
        
        // Listen for session start from iPhone
        NotificationCenter.default.publisher(for: .remoteSessionStarted)
            .sink { [weak self] notification in
                print("⌚️ ========== NOTIFICATION RECEIVED ==========")
                print("⌚️ Notification name: .remoteSessionStarted")
                print("⌚️ UserInfo: \(notification.userInfo ?? [:])")
                
                guard let workoutTransfer = notification.userInfo?["workoutTransfer"] as? WorkoutTransfer else {
                    print("❌ Failed to get workoutTransfer from notification")
                    return
                }
                
                guard let sessionId = notification.userInfo?["sessionId"] as? UUID else {
                    print("❌ Failed to get sessionId from notification")
                    return
                }
                
                print("✅ Got workoutTransfer: \(workoutTransfer.name)")
                print("✅ Got sessionId: \(sessionId)")
                
                self?.handleRemoteStartSession(workoutTransfer: workoutTransfer, sessionId: sessionId)
            }
            .store(in: &cancellables)
        
        print("✅ Set up .remoteSessionStarted listener")
        
        // Listen for updates from iPhone
        NotificationCenter.default.publisher(for: .liveSessionUpdated)
            .sink { [weak self] notification in
                guard let update = notification.userInfo?["update"] as? LiveSessionUpdate else { return }
                self?.handleRemoteSessionUpdate(update)
            }
            .store(in: &cancellables)
        
        // Listen for actions from iPhone
        NotificationCenter.default.publisher(for: .sessionActionReceived)
            .sink { [weak self] notification in
                guard let action = notification.userInfo?["action"] as? SessionAction,
                      let sessionId = notification.userInfo?["sessionId"] as? UUID else { return }
                self?.handleRemoteAction(action, sessionId: sessionId)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Sync Methods
    
    /// Handle session start from iPhone
    private func handleRemoteStartSession(workoutTransfer: WorkoutTransfer, sessionId: UUID) {
        print("⌚️ ========== REMOTE SESSION START CALLED ==========")
        print("⌚️ Workout: '\(workoutTransfer.name)'")
        print("⌚️ SessionId: \(sessionId)")
        print("⌚️ Exercises: \(workoutTransfer.exercises.count)")
        print("⌚️ isReceivingUpdate before: \(isReceivingUpdate)")
        
        guard !isReceivingUpdate else {
            print("⚠️ Already receiving update, ignoring remote session start")
            return
        }
        
        // Validate workout has exercises
        guard !workoutTransfer.exercises.isEmpty else {
            print("❌ Cannot start Watch session - workout '\(workoutTransfer.name)' has no exercises")
            showEmptyWorkoutAlert = true
            return
        }
        
        isReceivingUpdate = true
        defer { isReceivingUpdate = false }
        
        print("⌚️ Setting sessionId and activeWorkout...")
        // Set the session ID to match iPhone
        self.sessionId = sessionId
        // Store the workout so the regular UI can be shown
        self.activeWorkout = workoutTransfer
        
        // Initialize the exercise queue from the workout
        upcomingExerciseNames = workoutTransfer.exercises.dropFirst().map { $0.name }
        if let nextEx = upcomingExerciseNames.first {
            nextExerciseName = nextEx
        }
        
        print("⌚️ sessionId is now: \(String(describing: self.sessionId))")
        print("⌚️ activeWorkout is now: \(String(describing: self.activeWorkout?.name))")
        print("⌚️ upcomingExercises: \(upcomingExerciseNames.joined(separator: ", "))")
        print("⌚️ isSessionActive: \(isSessionActive)")
        
        // Set up first exercise if available
        if let firstExercise = workoutTransfer.exercises.first {
            print("⌚️ Setting up first exercise: \(firstExercise.name)")
            currentExerciseName = firstExercise.name
            currentSet = 1
            totalSets = firstExercise.targetSets
            currentReps = firstExercise.targetReps
            currentWeight = firstExercise.targetWeight ?? 0
            completedReps = []
            completedWeights = []
            print("⌚️ Exercise setup complete")
        } else {
            print("❌ No exercises in workout transfer!")
        }
        
        print("✅ Watch session started with '\(currentExerciseName)'")
        print("⌚️ Final state - isSessionActive: \(isSessionActive)")
        
        // Start heart rate monitoring if auto-advance is enabled
        print("🔍 Checking auto-advance: isAutoAdvanceEnabled = \(isAutoAdvanceEnabled)")
        if isAutoAdvanceEnabled {
            print("🔍 Calling startHeartRateMonitoring()...")
            startHeartRateMonitoring()
        } else {
            print("⚠️ Auto-advance is disabled, NOT starting heart rate monitoring")
        }
        
        print("⌚️ ================================================")
    }
    
    // MARK: - Sync is One-Way (iPhone → Watch only)
    // The Watch no longer syncs state back to iPhone - it only sends action notifications
    // and receives full state updates from iPhone
    
    /*
    func syncCurrentState() {
        guard let sessionId, !isReceivingUpdate else { return }
        
        let currentExerciseState = LiveExerciseState(
            exerciseId: UUID(), // TODO: Proper exercise ID mapping
            exerciseName: currentExerciseName,
            currentSet: currentSet,
            totalSets: totalSets,
            currentReps: currentReps,
            currentWeight: currentWeight,
            restTime: restTime,
            elapsedTime: elapsedTime,
            completedReps: completedReps,
            completedWeights: completedWeights
        )
        
        let update = LiveSessionUpdate(
            sessionId: sessionId,
            currentExercise: currentExerciseState,
            upcomingExerciseIds: [],
            completedExerciseIds: []
        )
        
        // Send update via Watch Connectivity
        sendLiveSessionUpdateToPhone(update)
    }
    */
    
    private func sendLiveSessionUpdateToPhone(_ update: LiveSessionUpdate) {
        guard WCSession.default.isReachable else {
            print("⌚️ Phone not reachable, cannot send update")
            return
        }
        
        do {
            let data = try JSONEncoder().encode(update)
            let message: [String: Any] = ["liveSessionUpdate": data]
            
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("⚠️ Failed to send live update to phone: \(error.localizedDescription)")
            }
        } catch {
            print("❌ Failed to encode live update: \(error)")
        }
    }
    
    private func handleRemoteSessionUpdate(_ update: LiveSessionUpdate) {
        guard !isReceivingUpdate else {
            print("⚠️ Already receiving update, skipping")
            return
        }
        
        // Ensure we're on main thread for UI updates
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.handleRemoteSessionUpdate(update)
            }
            return
        }
        
        isReceivingUpdate = true
        defer { isReceivingUpdate = false }
        
        print("⌚️ ========== APPLYING REMOTE SESSION UPDATE ==========")
        
        // If this is a new session, adopt it
        if sessionId == nil {
            sessionId = update.sessionId
            print("⌚️ Adopted new session ID: \(update.sessionId)")
        }
        
        guard update.sessionId == sessionId else {
            print("⚠️ Session ID mismatch - ignoring update")
            return
        }
        
        // Update current exercise state with explicit animation to ensure UI refreshes
        if let remoteExercise = update.currentExercise {
            print("⌚️ Updating exercise from '\(currentExerciseName)' to '\(remoteExercise.exerciseName)'")
            
            // Use withAnimation to ensure SwiftUI detects and animates the change
            withAnimation {
                currentExerciseName = remoteExercise.exerciseName
                currentSet = remoteExercise.currentSet
                totalSets = remoteExercise.totalSets
                currentReps = remoteExercise.currentReps
                currentWeight = remoteExercise.currentWeight
                
                // Sync rest timer from iPhone
                restTime = remoteExercise.restTime
                elapsedTime = remoteExercise.elapsedTime
                
                completedReps = remoteExercise.completedReps
                completedWeights = remoteExercise.completedWeights
            }
            
            print("⌚️ Updated to: \(currentExerciseName)")
            print("⌚️ Synced: Rest \(restTime)s, Elapsed \(elapsedTime)s")
        }
        
        // IMPORTANT: Update the exercise queue from iPhone
        withAnimation {
            upcomingExerciseNames = update.upcomingExerciseNames
            
            // Set the next exercise name for UI display
            if let first = upcomingExerciseNames.first {
                nextExerciseName = first
                print("⌚️ Next exercise: \(nextExerciseName)")
            } else {
                nextExerciseName = ""
                print("⌚️ No more exercises in queue")
            }
        }
        
        print("⌚️ Updated queue with \(upcomingExerciseNames.count) upcoming exercises: \(upcomingExerciseNames.joined(separator: ", "))")
        print("⌚️ ================================================")
    }
    
    private func handleRemoteAction(_ action: SessionAction, sessionId: UUID) {
        guard sessionId == self.sessionId, !isReceivingUpdate else { return }
        
        isReceivingUpdate = true
        defer { isReceivingUpdate = false }
        
        print("⌚️ Executing remote action: \(action)")
        
        switch action {
        case .startSession:
            self.sessionId = sessionId
        case .endSession:
            // Use internal clear method to avoid isReceivingUpdate guard
            clearSessionState()
        case .cancelSession:
            // Phone deleted the workout - clear state without notification
            print("⌚️ Session canceled from phone - dismissing without save")
            clearSessionState()
        case .nextSet, .previousSet, .nextExercise, .previousExercise:
            // Don't execute locally - wait for the state sync that follows
            // The iPhone/Watch that initiated the action will send a full state update
            print("⌚️ Button action received - waiting for state sync")
        case .updateReps, .updateWeight, .updateRest:
            // These are handled by the LiveSessionUpdate that follows
            print("⌚️ Value update action received - waiting for state sync")
        case .timerTick:
            // Timer updates are handled by LiveSessionUpdate
            break
        case .timerStarted:
            // Timer was reset/started on remote device - handled by LiveSessionUpdate
            print("⌚️ Timer started on remote device - waiting for state sync")
        }
    }
    
    func sendAction(_ action: SessionAction) {
        guard let sessionId, !isReceivingUpdate else { return }
        
        guard WCSession.default.isReachable else {
            print("⚠️ Phone not reachable, action not sent")
            return
        }
        
        let message: [String: Any] = [
            "sessionAction": action.rawValue,
            "sessionId": sessionId.uuidString
        ]
        
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("❌ Failed to send action: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Public Actions
    
    /// Get the next exercise name for display
    var nextExerciseForDisplay: String {
        nextExerciseName.isEmpty ? "End Workout" : nextExerciseName
    }
    
    /// Get count of remaining exercises
    var remainingExercisesCount: Int {
        upcomingExerciseNames.count
    }
    
    func nextSet() {
        guard !isReceivingUpdate else {
            print("⌚️ Skipping nextSet - receiving remote update")
            return
        }
        
        completedReps.append(currentReps)
        completedWeights.append(currentWeight)
        currentSet += 1
        
        // Send action to iPhone - it will update and sync back to us
        sendAction(.nextSet)
    }
    
    func previousSet() {
        guard !isReceivingUpdate, currentSet > 1 else {
            if isReceivingUpdate {
                print("⌚️ Skipping previousSet - receiving remote update")
            }
            return
        }
        
        currentSet -= 1
        if !completedReps.isEmpty {
            currentReps = completedReps.removeLast()
        }
        if !completedWeights.isEmpty {
            currentWeight = completedWeights.removeLast()
        }
        
        // Send action to iPhone - it will update and sync back to us
        sendAction(.previousSet)
    }
    
    func updateReps(_ newReps: Int) {
        guard newReps != currentReps, !isReceivingUpdate else { return }
        currentReps = newReps
        // Send action to iPhone - it will update and sync back to us
        sendAction(.updateReps)
    }
    
    func updateWeight(_ newWeight: Double) {
        guard newWeight != currentWeight, !isReceivingUpdate else { return }
        currentWeight = newWeight
        // Send action to iPhone - it will update and sync back to us
        sendAction(.updateWeight)
    }
    
    func endSession() {
        guard !isReceivingUpdate else {
            print("⌚️ Skipping endSession - receiving remote update")
            return
        }
        
        stopHeartRateMonitoring()
        sendAction(.endSession)
        clearSessionState()
    }
    
    // MARK: - Heart Rate Monitoring
    
    private func requestHealthKitAuthorization() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let workoutType = HKObjectType.workoutType()
        
        healthStore.requestAuthorization(toShare: [workoutType], read: [heartRateType]) { success, error in
            if let error = error {
                print("❌ HealthKit authorization failed: \(error.localizedDescription)")
            } else if success {
                print("✅ HealthKit authorization granted")
            }
        }
    }
    
    func startHeartRateMonitoring() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("❌ Health data not available on this device")
            return
        }
        
        print("🔄 Starting heart rate monitoring...")
        
        // Start a workout session to get live heart rate data
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor
        
        do {
            let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            let builder = session.associatedWorkoutBuilder()
            
            builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
            
            // Store references BEFORE starting
            self.workoutSession = session
            self.workoutBuilder = builder
            
            print("✅ Created workout session and builder")
            
            // Start the session
            session.startActivity(with: Date())
            print("✅ Started workout activity")
            
            // Begin collection and start query
            builder.beginCollection(withStart: Date()) { [weak self] success, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Failed to begin workout collection: \(error.localizedDescription)")
                    return
                }
                
                if success {
                    print("✅ Workout collection started successfully")
                    // Start heart rate query on main thread
                    DispatchQueue.main.async {
                        self.startHeartRateQuery()
                    }
                } else {
                    print("⚠️ Workout collection did not start successfully")
                }
            }
        } catch {
            print("❌ Failed to start workout session: \(error.localizedDescription)")
        }
    }
    
    private func startHeartRateQuery() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            print("❌ Heart rate type not available")
            return
        }
        
        print("🔄 Starting heart rate query...")
        
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: .strictStartDate)
        
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: predicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            if let error = error {
                print("❌ Heart rate query error: \(error.localizedDescription)")
                return
            }
            
            print("📊 Initial heart rate query returned \(samples?.count ?? 0) samples")
            self?.processHeartRateSamples(samples)
        }
        
        query.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
            if let error = error {
                print("❌ Heart rate update error: \(error.localizedDescription)")
                return
            }
            
            print("📊 Heart rate update received \(samples?.count ?? 0) samples")
            self?.processHeartRateSamples(samples)
        }
        
        heartRateQuery = query
        healthStore.execute(query)
        
        print("✅ Heart rate query started and executed")
    }
    
    private func processHeartRateSamples(_ samples: [HKSample]?) {
        print("🔍 processHeartRateSamples called with \(samples?.count ?? 0) samples")
        
        guard let samples = samples as? [HKQuantitySample],
              let sample = samples.last else {
            print("⚠️ No heart rate samples to process (failed cast or empty)")
            return
        }
        
        print("🔍 isAutoAdvanceEnabled: \(isAutoAdvanceEnabled)")
        
        guard isAutoAdvanceEnabled else {
            // Still update heart rate for display, just don't auto-advance
            let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            print("⚠️ Auto-advance disabled, only updating display: \(Int(heartRate)) BPM")
            DispatchQueue.main.async { [weak self] in
                self?.currentHeartRate = heartRate
            }
            return
        }
        
        let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
        
        print("❤️ Received heart rate: \(Int(heartRate)) BPM")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.currentHeartRate = heartRate
            self.analyzeHeartRateForAutoAdvance(heartRate)
        }
    }
    
    private func analyzeHeartRateForAutoAdvance(_ heartRate: Double) {
        // Add to history (keep last 10 readings, roughly 10 seconds of data)
        heartRateHistory.append(heartRate)
        if heartRateHistory.count > 10 {
            heartRateHistory.removeFirst()
        }
        
        print("💓 HR History: \(heartRateHistory.map { Int($0) }) (count: \(heartRateHistory.count))")
        
        // Need at least 5 readings to detect patterns
        guard heartRateHistory.count >= 5 else {
            print("⏳ Waiting for more readings (\(heartRateHistory.count)/5)")
            return
        }
        
        // Detect if heart rate is increasing (person is performing a set)
        if !isInSet {
            let recentAverage = heartRateHistory.suffix(3).reduce(0, +) / 3.0
            let olderAverage = heartRateHistory.prefix(3).reduce(0, +) / 3.0
            let difference = recentAverage - olderAverage
            
            print("📊 Not in set - Recent avg: \(Int(recentAverage)), Older avg: \(Int(olderAverage)), Diff: \(Int(difference))")
            
            // Heart rate increased by at least 5 BPM - likely starting a set
            if difference > 5 {
                isInSet = true
                peakHeartRate = heartRate
                print("💓 🔥 SET DETECTED - HR increased to \(Int(heartRate)) BPM")
            }
        }
        // Detect if heart rate is decreasing (person finished set and is resting)
        else {
            // Track peak heart rate during set
            if heartRate > peakHeartRate {
                peakHeartRate = heartRate
                print("📈 New peak HR: \(Int(peakHeartRate)) BPM")
            }
            
            // Check if heart rate has dropped significantly from peak
            let recoveryThreshold = peakHeartRate * heartRateThreshold
            let percentOfPeak = (heartRate / peakHeartRate) * 100
            
            print("📊 In set - Current: \(Int(heartRate)) BPM, Peak: \(Int(peakHeartRate)) BPM, Threshold: \(Int(recoveryThreshold)) BPM (\(Int(percentOfPeak))% of peak)")
            
            if heartRate < recoveryThreshold {
                print("💓 ✅ RECOVERY DETECTED - HR dropped from \(Int(peakHeartRate)) to \(Int(heartRate)) BPM")
                print("✅ Auto-advancing to next set (current: \(currentSet)/\(totalSets))")
                
                // Play haptic feedback to notify user
                #if os(watchOS)
                WKInterfaceDevice.current().play(.success)
                #endif
                
                // Reset state
                isInSet = false
                peakHeartRate = 0
                heartRateHistory.removeAll()
                
                // Auto-advance to next set if not at the end
                if currentSet < totalSets {
                    nextSet()
                } else {
                    print("⚠️ Already at last set, not advancing")
                }
            }
        }
    }
    
    func stopHeartRateMonitoring() {
        if let query = heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
        }
        
        workoutSession?.end()
        workoutBuilder?.endCollection(withEnd: Date()) { success, error in
            if let error = error {
                print("❌ Failed to end workout collection: \(error.localizedDescription)")
            }
        }
        
        workoutSession = nil
        workoutBuilder = nil
        heartRateHistory.removeAll()
        isInSet = false
        peakHeartRate = 0
        
        print("⌚️ Heart rate monitoring stopped")
    }
    
    /// Internal method to clear session state without sending action (used for remote end)
    private func clearSessionState() {
        sessionId = nil
        activeWorkout = nil
        currentExerciseName = ""
        nextExerciseName = ""
        upcomingExerciseNames = []
        currentSet = 1
        totalSets = 3
        currentReps = 10
        currentWeight = 0
        restTime = 0
        elapsedTime = 0
        completedReps = []
        completedWeights = []
    }
}
