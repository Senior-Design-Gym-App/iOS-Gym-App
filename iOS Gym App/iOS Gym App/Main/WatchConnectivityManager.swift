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
    
    // MARK: - Real-Time Session Sync
    
    /// Send live session update (during active workout)
    func sendLiveSessionUpdate(_ update: LiveSessionUpdate) {
        // Try real-time message first (if watch is reachable)
        if WCSession.default.isReachable {
            do {
                let data = try JSONEncoder().encode(update)
                let message: [String: Any] = ["liveSessionUpdate": data]
                
                // Send without reply handler to avoid Watch app delegate errors
                WCSession.default.sendMessage(message, replyHandler: nil) { error in
                    print("⚠️ Failed to send live update: \(error.localizedDescription)")
                    // Fallback to user info transfer
                    self.sendLiveUpdateViaUserInfo(data)
                }
            } catch {
                print("❌ Failed to encode live update: \(error)")
            }
        } else {
            // Watch not reachable - use user info transfer as fallback
            do {
                let data = try JSONEncoder().encode(update)
                sendLiveUpdateViaUserInfo(data)
            } catch {
                print("❌ Failed to encode live update: \(error)")
            }
        }
    }
    
    /// Fallback method using transferUserInfo for when watch isn't reachable
    private func sendLiveUpdateViaUserInfo(_ data: Data) {
        let userInfo: [String: Any] = [
            "liveSessionUpdate": data,
            "timestamp": Date()
        ]
        WCSession.default.transferUserInfo(userInfo)
        print("📤 Sent live update via transferUserInfo")
    }
    
    /// Send session action to other device
    func sendSessionAction(_ action: SessionAction, sessionId: UUID) {
        guard WCSession.default.isReachable else {
            print("⚠️ Watch not reachable, action not sent")
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
    
    /// Send start session with workout data to other device
    func sendStartSessionWithWorkout(_ workout: Workout, sessionId: UUID) {
        guard WCSession.default.isReachable else {
            print("⚠️ Watch not reachable, cannot start session")
            return
        }
        
        do {
            let workoutTransfer = workout.toTransfer()
            let workoutData = try JSONEncoder().encode(workoutTransfer)
            
            let message: [String: Any] = [
                "startSession": workoutData,
                "sessionId": sessionId.uuidString
            ]
            
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("❌ Failed to send start session: \(error.localizedDescription)")
            }
            
            print("✅ Sent start session with workout '\(workout.name)'")
        } catch {
            print("❌ Failed to encode workout: \(error)")
        }
    }
    
    /// Send start session with workout transfer (from Watch)
    func sendStartSessionWithWorkout(_ workoutTransfer: WorkoutTransfer, sessionId: UUID) {
        guard WCSession.default.isReachable else {
            print("⚠️ iPhone not reachable, cannot start session")
            return
        }
        
        do {
            let workoutData = try JSONEncoder().encode(workoutTransfer)
            
            let message: [String: Any] = [
                "startSession": workoutData,
                "sessionId": sessionId.uuidString
            ]
            
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("❌ Failed to send start session: \(error.localizedDescription)")
            }
            
            print("✅ Sent start session to iPhone with workout '\(workoutTransfer.name)'")
        } catch {
            print("❌ Failed to encode workout: \(error)")
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
    
    // Handle messages from watch (without reply handler)
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("📱 Received message from watch: \(message.keys)")
        
        // Handle start session with workout data
        if let workoutData = message["startSession"] as? Data,
           let sessionIdString = message["sessionId"] as? String,
           let sessionId = UUID(uuidString: sessionIdString) {
            handleStartSession(workoutData, sessionId: sessionId)
        }
        
        // Handle live session update
        if let updateData = message["liveSessionUpdate"] as? Data {
            handleLiveSessionUpdate(updateData)
        }
        
        // Handle session action
        if let actionString = message["sessionAction"] as? String,
           let action = SessionAction(rawValue: actionString),
           let sessionIdString = message["sessionId"] as? String,
           let sessionId = UUID(uuidString: sessionIdString) {
            handleSessionAction(action, sessionId: sessionId)
        }
        
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
    
    // Handle messages from watch (with reply handler) - REQUIRED!
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("📱 Received message with reply handler from watch: \(message.keys)")
        
        // Handle start session with workout data
        if let workoutData = message["startSession"] as? Data,
           let sessionIdString = message["sessionId"] as? String,
           let sessionId = UUID(uuidString: sessionIdString) {
            handleStartSession(workoutData, sessionId: sessionId)
            replyHandler(["status": "started"])
            return
        }
        
        // Handle live session update
        if let updateData = message["liveSessionUpdate"] as? Data {
            handleLiveSessionUpdate(updateData)
            replyHandler(["status": "updated"])
            return
        }
        
        // Handle session action
        if let actionString = message["sessionAction"] as? String,
           let action = SessionAction(rawValue: actionString),
           let sessionIdString = message["sessionId"] as? String,
           let sessionId = UUID(uuidString: sessionIdString) {
            handleSessionAction(action, sessionId: sessionId)
            replyHandler(["status": "action_executed", "action": actionString])
            return
        }
        
        // Handle session completion from watch
        if let sessionData = message["completedSession"] as? Data {
            handleCompletedSession(sessionData)
            replyHandler(["status": "completed"])
            return
        }
        
        // Handle workout request from watch
        if message["requestWorkouts"] != nil {
            print("📱 Watch requested workouts - triggering sync")
            NotificationCenter.default.post(name: .watchRequestedWorkouts, object: nil)
            replyHandler(["status": "workouts_requested"])
            return
        }
        
        // Default reply for unknown messages
        replyHandler(["status": "unknown_message"])
    }
    
    // Handle user info transfer (for when devices aren't reachable)
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("📱 Received user info from watch: \(userInfo.keys)")
        
        if let updateData = userInfo["liveSessionUpdate"] as? Data {
            handleLiveSessionUpdate(updateData)
        }
    }
    
    private func handleLiveSessionUpdate(_ data: Data) {
        do {
            let update = try JSONDecoder().decode(LiveSessionUpdate.self, from: data)
            NotificationCenter.default.post(
                name: .liveSessionUpdated,
                object: nil,
                userInfo: ["update": update]
            )
            print("✅ Received live session update")
        } catch {
            print("❌ Failed to decode live update: \(error)")
        }
    }
    
    private func handleStartSession(_ data: Data, sessionId: UUID) {
        do {
            let workoutTransfer = try JSONDecoder().decode(WorkoutTransfer.self, from: data)
            // Convert WorkoutTransfer to Workout - will need to be implemented in the receiving app
            NotificationCenter.default.post(
                name: .remoteSessionStarted,
                object: nil,
                userInfo: ["workoutTransfer": workoutTransfer, "sessionId": sessionId]
            )
            print("✅ Received start session for workout '\(workoutTransfer.name)'")
        } catch {
            print("❌ Failed to decode workout: \(error)")
        }
    }
    
    private func handleSessionAction(_ action: SessionAction, sessionId: UUID) {
        NotificationCenter.default.post(
            name: .sessionActionReceived,
            object: nil,
            userInfo: ["action": action, "sessionId": sessionId]
        )
        print("✅ Received session action: \(action)")
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


