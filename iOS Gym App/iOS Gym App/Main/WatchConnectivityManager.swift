//
//  WatchConnectivityManager.swift
//  iOS Gym App
//
//  Manages data sync between iOS and watchOS
//

import Foundation
import WatchConnectivity
import SwiftData

@Observable
final class WatchConnectivityManager: NSObject {
    static let shared = WatchConnectivityManager()
    
    private(set) var isWatchPaired = false
    private(set) var isWatchAppInstalled = false
    private(set) var isReachable = false
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: - Send Data to Watch
    
    /// Send all workouts to watch - Uses application context for reliability
    func syncWorkouts(_ workouts: [Workout]) {
        print("📱 syncWorkouts called with \(workouts.count) workouts")
        
        guard WCSession.default.activationState == .activated else {
            print("❌ WCSession not activated yet")
            return
        }
        
        let transfers = workouts.map { $0.toTransfer() }
        print("📱 Converted \(transfers.count) workouts to transfer models")
        
        if let first = transfers.first {
            print("📱 First workout transfer: '\(first.name)' with \(first.exercises.count) exercises")
        }
        
        // ALWAYS update application context (reliable background sync)
        updateApplicationContext(workouts: workouts, activeSplit: nil)
        print("✅ Synced \(workouts.count) workouts to watch")
    }
    
    /// Send active split to watch
    func syncActiveSplit(_ split: Split) {
        guard WCSession.default.activationState == .activated else {
            print("❌ WCSession not activated yet")
            return
        }
        
        let transfer = split.toTransfer()
        
        do {
            let splitData = try JSONEncoder().encode(transfer)
            var context = WCSession.default.applicationContext
            context["activeSplit"] = splitData
            context["lastSync"] = Date()
            
            try WCSession.default.updateApplicationContext(context)
            print("✅ Sent active split to watch")
        } catch {
            print("❌ Failed to encode/send split: \(error)")
        }
    }
    
    /// Send workout session update to watch
    func syncSessionUpdate(_ session: WorkoutSessionTransfer) {
        guard WCSession.default.isReachable else { return }
        
        do {
            let data = try JSONEncoder().encode(session)
            let message: [String: Any] = ["sessionUpdate": data]
            
            WCSession.default.sendMessage(message, replyHandler: nil)
        } catch {
            print("❌ Failed to encode session: \(error)")
        }
    }
    
    /// Transfer application context (for background sync)
    func updateApplicationContext(workouts: [Workout], activeSplit: Split?) {
        guard WCSession.default.activationState == .activated else { 
            print("❌ Cannot update context - session not activated")
            return 
        }
        
        var context: [String: Any] = [:]
        
        do {
            let workoutTransfers = workouts.map { $0.toTransfer() }
            let workoutsData = try JSONEncoder().encode(workoutTransfers)
            context["workouts"] = workoutsData
            print("📱 Encoded \(workoutTransfers.count) workouts into context (\(workoutsData.count) bytes)")
            
            if let activeSplit = activeSplit {
                let splitData = try JSONEncoder().encode(activeSplit.toTransfer())
                context["activeSplit"] = splitData
                print("📱 Added active split to context")
            }
            
            context["lastSync"] = Date()
            
            try WCSession.default.updateApplicationContext(context)
            print("✅ Updated application context successfully")
        } catch {
            print("❌ Failed to update context: \(error)")
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isWatchPaired = session.isPaired
            self.isWatchAppInstalled = session.isWatchAppInstalled
            
            if let error = error {
                print("❌ WCSession activation failed: \(error.localizedDescription)")
            } else {
                print("✅ WCSession activated: \(activationState.rawValue)")
                print("  - Paired: \(session.isPaired)")
                print("  - Watch App Installed: \(session.isWatchAppInstalled)")
                print("  - Reachable: \(session.isReachable)")
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("⚠️ WCSession became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("⚠️ WCSession deactivated")
        session.activate()
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
            print("⌚️ Watch reachability: \(session.isReachable)")
        }
    }
    
    // Handle messages from watch
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("📱 Received message from watch: \(message.keys)")
        
        // Handle session completion from watch
        if let sessionData = message["completedSession"] as? Data {
            handleCompletedSession(sessionData)
        }
        
        // Handle workout request from watch
        if message["requestWorkouts"] != nil {
            print("📱 Watch requested workouts - triggering sync")
            NotificationCenter.default.post(name: .watchRequestedWorkouts, object: nil)
        }
    }
    
    private func handleCompletedSession(_ data: Data) {
        do {
            let session = try JSONDecoder().decode(WorkoutSessionTransfer.self, from: data)
            NotificationCenter.default.post(
                name: .watchCompletedSession,
                object: nil,
                userInfo: ["session": session]
            )
            print("✅ Received completed session from watch")
        } catch {
            print("❌ Failed to decode session: \(error)")
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let watchRequestedWorkouts = Notification.Name("watchRequestedWorkouts")
    static let watchCompletedSession = Notification.Name("watchCompletedSession")
}
