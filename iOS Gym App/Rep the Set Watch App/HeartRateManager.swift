//
//  HeartRateManager.swift
//  Rep the Set Watch App
//
//  Manages live heart rate monitoring during workouts
//

import Foundation
import HealthKit
internal import Combine
#if os(watchOS)
import WatchKit
#endif

// Lightweight async semaphore to await a completion handler inside async context
fileprivate actor AsyncSemaphore {
    private var continuation: CheckedContinuation<Void, Never>?
    func wait() async {
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            continuation = c
        }
    }
    func signal() {
        continuation?.resume()
        continuation = nil
    }
}

@MainActor
@Observable
final class HeartRateManager {
    
    // MARK: - Published Properties
    
    var currentHeartRate: Int = 0
    var isAuthorized: Bool = false
    
    // MARK: - Auto-Advance Properties
    
    var isAutoAdvanceEnabled: Bool = true
    var onAutoAdvance: (() -> Void)?  // Callback when auto-advance should trigger
    
    // MARK: - Private Properties
    
    private let healthStore = HKHealthStore()
    private var heartRateQuery: HKQuery?
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?
    
    // Heart rate tracking for auto-advance
    private var heartRateHistory: [Double] = []
    private var peakHeartRate: Double = 0
    private var isInSet: Bool = false
    private let heartRateThreshold: Double = 0.85 // 85% of peak indicates recovery
    
    // MARK: - Initialization
    
    init() {
        Task {
            await requestAuthorization()
        }
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("❌ HealthKit is not available on this device")
            isAuthorized = false
            return
        }
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let workoutType = HKObjectType.workoutType()
        let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        let typesToShare: Set<HKSampleType> = [workoutType, energyType]
        let typesToRead: Set<HKObjectType> = [heartRateType, workoutType, energyType]
        
        do {
            // Optional: check if a prompt will appear (use completion-handler API)
            let semaphore = AsyncSemaphore()
            healthStore.getRequestStatusForAuthorization(toShare: typesToShare, read: typesToRead) { requestStatus, error in
                if let error = error {
                    print("⚠️ Failed to check authorization request status: \(error.localizedDescription)")
                } else {
                    switch requestStatus {
                    case .shouldRequest:
                        print("🔔 HealthKit will prompt for authorization")
                    case .unnecessary:
                        print("ℹ️ HealthKit authorization already determined (no prompt expected)")
                    case .unknown:
                        fallthrough
                    @unknown default:
                        print("❓ HealthKit authorization request status unknown")
                    }
                }
                semaphore.signal()
            }
            await semaphore.wait()
            
            try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
            
            // Check share status only for shareable types
            let workoutShareStatus = healthStore.authorizationStatus(for: workoutType)
            let energyShareStatus = healthStore.authorizationStatus(for: energyType)
            
            // There is no reliable API to confirm read auth for heart rate. After requesting,
            // assume read access and verify at query-time by observing samples/updates.
            isAuthorized = true
            
            print("✅ HealthKit authorization request completed")
            print("   Workout share status: \(statusString(workoutShareStatus))")
            print("   Active Energy share status: \(statusString(energyShareStatus))")
            print("   Heart Rate read access: assumed (verify via queries)")
            print("   Is Authorized: \(isAuthorized)")
        } catch {
            print("❌ HealthKit authorization failed: \(error.localizedDescription)")
            isAuthorized = false
        }
    }
    
    private func statusString(_ status: HKAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .sharingDenied: return "Denied"
        case .sharingAuthorized: return "Authorized"
        @unknown default: return "Unknown"
        }
    }
    
    // MARK: - Workout Session Management
    
    func startWorkoutSession() async throws {
        // Request authorization if not already done
        if !isAuthorized {
            await requestAuthorization()
        }
        
        guard isAuthorized else {
            print("❌ HealthKit not authorized")
            throw NSError(domain: "HeartRateManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit authorization failed"])
        }
        
        // Create workout configuration for strength training
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor
        
        // Create workout session
        let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        let builder = session.associatedWorkoutBuilder()
        
        // Set data source
        builder.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: configuration
        )
        
        // Store references
        self.workoutSession = session
        self.workoutBuilder = builder
        
        // Start the session and builder
        session.startActivity(with: Date())
        try await builder.beginCollection(at: Date())
        
        // Start heart rate monitoring
        startHeartRateQuery()
        
        print("✅ Workout session started")
    }
    
    func endWorkoutSession() async throws {
        guard let session = workoutSession, let builder = workoutBuilder else {
            print("⚠️ No active workout session to end")
            return
        }
        
        // Stop heart rate monitoring
        stopHeartRateQuery()
        
        // End the session
        session.end()
        try await builder.endCollection(at: Date())
        
        // Finish and save the workout
        let workout = try await builder.finishWorkout()
        
        print("✅ Workout session ended and saved: \(String(describing: workout))")
        
        // Clean up
        self.workoutSession = nil
        self.workoutBuilder = nil
        self.currentHeartRate = 0
        
        // Reset auto-advance state
        resetAutoAdvanceState()
    }
    
    // MARK: - Heart Rate Monitoring
    
    private func startHeartRateQuery() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            print("❌ Heart rate type not available")
            return
        }
        
        print("🔄 Starting heart rate query...")
        
        // Create a query for live heart rate updates
        let predicate = HKQuery.predicateForSamples(
            withStart: Date(),
            end: nil,
            options: .strictStartDate
        )
        
        let heartRateQuery = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: predicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Heart rate query error: \(error.localizedDescription)")
                return
            }
            
            print("📊 Initial heart rate query returned \(samples?.count ?? 0) samples")
            
            Task { @MainActor in
                self.processSamples(samples)
            }
        }
        
        // Set update handler for continuous updates
        heartRateQuery.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
            
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Heart rate update error: \(error.localizedDescription)")
                return
            }
            
            print("📊 Heart rate update received \(samples?.count ?? 0) samples")
            
            Task { @MainActor in
                self.processSamples(samples)
            }
        }
        
        self.heartRateQuery = heartRateQuery
        healthStore.execute(heartRateQuery)
        
        print("✅ Heart rate monitoring started")
    }
    
    private func stopHeartRateQuery() {
        if let query = heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
            print("✅ Heart rate monitoring stopped")
        }
    }
    
    private func processSamples(_ samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample],
              let mostRecent = samples.last else {
            return
        }
        
        let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
        let value = mostRecent.quantity.doubleValue(for: heartRateUnit)
        
        currentHeartRate = Int(round(value))
        
        print("❤️ Heart rate updated: \(currentHeartRate) BPM")
        
        // Analyze for auto-advance if enabled
        if isAutoAdvanceEnabled {
            analyzeHeartRateForAutoAdvance(value)
        }
    }
    
    // MARK: - Auto-Advance Logic
    
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
                print("✅ Triggering auto-advance")
                
                // Play haptic feedback to notify user
                #if os(watchOS)
                WKInterfaceDevice.current().play(.success)
                #endif
                
                // Reset state
                resetAutoAdvanceState()
                
                // Trigger callback to advance set
                onAutoAdvance?()
            }
        }
    }
    
    private func resetAutoAdvanceState() {
        isInSet = false
        peakHeartRate = 0
        heartRateHistory.removeAll()
    }
}
