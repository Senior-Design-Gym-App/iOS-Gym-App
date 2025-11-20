//
//  HeartRateManager.swift
//  Rep the Set Watch App
//
//  Manages live heart rate monitoring during workouts
//

import Foundation
import HealthKit
internal import Combine

@MainActor
@Observable
final class HeartRateManager {
    
    // MARK: - Published Properties
    
    var currentHeartRate: Int = 0
    var isAuthorized: Bool = false
    
    // MARK: - Private Properties
    
    private let healthStore = HKHealthStore()
    private var heartRateQuery: HKQuery?
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?
    
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
            try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
            
            // Check if we actually got authorization for heart rate reading
            let status = healthStore.authorizationStatus(for: heartRateType)
            
            // Important: For privacy, HealthKit may return .notDetermined even after authorization
            // We'll assume authorized unless explicitly denied
            isAuthorized = (status != .sharingDenied)
            
            print("✅ HealthKit authorization requested")
            print("   Heart Rate status: \(status.rawValue) (\(statusString(status)))")
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
    }
}
