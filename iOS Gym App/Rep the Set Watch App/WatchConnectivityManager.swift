//
//  WatchConnectivityManager.swift
//  Rep the Set Watch App
//
//  Manages data received from iOS app
//

import Foundation
import WatchConnectivity
import SwiftUI

@Observable
final class WatchConnectivityManager: NSObject {
    static let shared = WatchConnectivityManager()
    
    private(set) var isReachable = false
    var workouts: [WorkoutTransfer] = []
    private(set) var activeSplit: SplitTransfer?
    private(set) var lastSyncDate: Date?
    
    private override init() {
        super.init()
        
        print("⌚️ Initializing WatchConnectivityManager...")
        
        if WCSession.isSupported() {
            print("⌚️ WCSession is supported")
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("⌚️ WCSession activation requested")
        } else {
            print("❌ WCSession NOT supported on this device!")
        }
        
        // Load cached data
        loadCachedData()
    }
    
    // MARK: - Send Data to iPhone
    
    /// Send start session with workout data to iPhone
    func sendStartSessionWithWorkout(_ workout: WorkoutTransfer, sessionId: UUID) {
        guard WCSession.default.isReachable else {
            print("📱 iPhone not reachable, cannot start session")
            return
        }
        
        do {
            let workoutData = try JSONEncoder().encode(workout)
            
            let message: [String: Any] = [
                "startSession": workoutData,
                "sessionId": sessionId.uuidString
            ]
            
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("❌ Failed to send start session: \(error.localizedDescription)")
            }
            
            print("✅ Sent start session with workout '\(workout.name)' to iPhone")
        } catch {
            print("❌ Failed to encode workout: \(error)")
        }
    }
    
    /// Send session action to iPhone
    func sendSessionAction(_ action: SessionAction, sessionId: UUID) {
        guard WCSession.default.isReachable else {
            print("⚠️ iPhone not reachable, action not sent")
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
    
    /// Send live session update to iPhone
    func sendLiveSessionUpdate(_ update: LiveSessionUpdate) {
        // Try real-time message first
        if WCSession.default.isReachable {
            do {
                let data = try JSONEncoder().encode(update)
                let message: [String: Any] = ["liveSessionUpdate": data]
                
                WCSession.default.sendMessage(message, replyHandler: nil) { error in
                    print("⚠️ Failed to send live update: \(error.localizedDescription)")
                }
            } catch {
                print("❌ Failed to encode live update: \(error)")
            }
        }
    }
    
    /// Send completed session back to iPhone
    func sendCompletedSession(_ session: WorkoutSessionTransfer) {
        guard WCSession.default.isReachable else {
            print("📱 iPhone not reachable")
            return
        }
        
        do {
            let data = try JSONEncoder().encode(session)
            let message: [String: Any] = ["completedSession": data]
            
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("❌ Failed to send session: \(error.localizedDescription)")
            }
            print("✅ Sent completed session to iPhone")
        } catch {
            print("❌ Failed to encode session: \(error)")
        }
    }
    
    /// Request workouts from iPhone
    func requestWorkouts() {
        guard WCSession.default.isReachable else {
            print("📱 iPhone not reachable")
            return
        }
        
        WCSession.default.sendMessage(["requestWorkouts": true], replyHandler: nil)
        print("📱 Requested workouts from iPhone")
    }
    
    // MARK: - Data Persistence
    
    private func loadCachedData() {
        if let workoutsData = UserDefaults.standard.data(forKey: "cachedWorkouts") {
            do {
                workouts = try JSONDecoder().decode([WorkoutTransfer].self, from: workoutsData)
                print("✅ Loaded \(workouts.count) cached workouts")
            } catch {
                print("❌ Failed to decode cached workouts: \(error)")
            }
        }
        
        if let splitData = UserDefaults.standard.data(forKey: "cachedActiveSplit") {
            do {
                activeSplit = try JSONDecoder().decode(SplitTransfer.self, from: splitData)
                print("✅ Loaded cached active split")
            } catch {
                print("❌ Failed to decode cached split: \(error)")
            }
        }
        
        lastSyncDate = UserDefaults.standard.object(forKey: "lastSyncDate") as? Date
    }
    
    private func saveCachedData() {
        do {
            let workoutsData = try JSONEncoder().encode(workouts)
            UserDefaults.standard.set(workoutsData, forKey: "cachedWorkouts")
            
            if let split = activeSplit {
                let splitData = try JSONEncoder().encode(split)
                UserDefaults.standard.set(splitData, forKey: "cachedActiveSplit")
            }
            
            UserDefaults.standard.set(Date(), forKey: "lastSyncDate")
            lastSyncDate = Date()
            
            print("✅ Cached workout data")
        } catch {
            print("❌ Failed to cache data: \(error)")
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
            
            if let error = error {
                print("❌ WCSession activation failed: \(error.localizedDescription)")
            } else {
                print("✅ WCSession activated - State: \(activationState.rawValue)")
                print("✅ Reachable: \(session.isReachable)")
                print("✅ Has pending messages: \(session.hasContentPending)")
                
                // Wait a moment then request initial data
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    print("⌚️ Requesting initial workouts from iPhone...")
                    self.requestWorkouts()
                }
            }
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
            print("📱 iPhone reachability: \(session.isReachable)")
        }
    }
    
    // Handle messages from iPhone (without reply handler)
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("⌚️ Received message from iPhone: \(message.keys)")
        handleIncomingMessage(message)
    }
    
    // Handle messages from iPhone (with reply handler)
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("⌚️ Received message with reply handler from iPhone: \(message.keys)")
        handleIncomingMessage(message)
        replyHandler(["status": "received"])
    }
    
    // Common message handling logic
    private func handleIncomingMessage(_ message: [String: Any]) {
        DispatchQueue.main.async {
            // Handle start session from iPhone
            if let workoutData = message["startSession"] as? Data,
               let sessionIdString = message["sessionId"] as? String,
               let sessionId = UUID(uuidString: sessionIdString) {
                self.handleStartSession(workoutData, sessionId: sessionId)
            }
            
            // Handle live session update from iPhone
            if let updateData = message["liveSessionUpdate"] as? Data {
                self.handleLiveSessionUpdate(updateData)
            }
            
            // Handle session action from iPhone
            if let actionString = message["sessionAction"] as? String,
               let action = SessionAction(rawValue: actionString),
               let sessionIdString = message["sessionId"] as? String,
               let sessionId = UUID(uuidString: sessionIdString) {
                self.handleSessionAction(action, sessionId: sessionId)
            }
            
            // Handle workouts update
            if let workoutsData = message["workouts"] as? Data {
                do {
                    let newWorkouts = try JSONDecoder().decode([WorkoutTransfer].self, from: workoutsData)
                    self.workouts = newWorkouts
                    self.saveCachedData()
                    print("✅ Updated \(newWorkouts.count) workouts")
                } catch {
                    print("❌ Failed to decode workouts: \(error)")
                }
            }
            
            // Handle active split update
            if let splitData = message["activeSplit"] as? Data {
                do {
                    let split = try JSONDecoder().decode(SplitTransfer.self, from: splitData)
                    self.activeSplit = split
                    self.saveCachedData()
                    print("✅ Updated active split")
                } catch {
                    print("❌ Failed to decode split: \(error)")
                }
            }
        }
    }
    
    // MARK: - Session Handling
    
    private func handleStartSession(_ data: Data, sessionId: UUID) {
        do {
            let workoutTransfer = try JSONDecoder().decode(WorkoutTransfer.self, from: data)
            print("⌚️ Received start session for workout '\(workoutTransfer.name)'")
            
            // Post notification for WatchSessionManager to handle
            NotificationCenter.default.post(
                name: .remoteSessionStarted,
                object: nil,
                userInfo: ["workoutTransfer": workoutTransfer, "sessionId": sessionId]
            )
            print("✅ Posted remoteSessionStarted notification")
        } catch {
            print("❌ Failed to decode workout: \(error)")
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
    
    private func handleSessionAction(_ action: SessionAction, sessionId: UUID) {
        NotificationCenter.default.post(
            name: .sessionActionReceived,
            object: nil,
            userInfo: ["action": action, "sessionId": sessionId]
        )
        print("✅ Received session action: \(action)")
    }
    
    // Handle user info transfer (for when devices aren't directly reachable)
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("⌚️ Received user info from iPhone: \(userInfo.keys)")
        
        DispatchQueue.main.async {
            if let updateData = userInfo["liveSessionUpdate"] as? Data {
                self.handleLiveSessionUpdate(updateData)
            }
            
            // Also handle start session via userInfo (fallback)
            if let workoutData = userInfo["startSession"] as? Data,
               let sessionIdString = userInfo["sessionId"] as? String,
               let sessionId = UUID(uuidString: sessionIdString) {
                self.handleStartSession(workoutData, sessionId: sessionId)
            }
        }
    }
    
    // Handle application context updates (background)
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("⌚️ Received application context update")
        print("⌚️ Context keys: \(applicationContext.keys)")
        
        DispatchQueue.main.async {
            var updated = false
            
            if let workoutsData = applicationContext["workouts"] as? Data {
                do {
                    let newWorkouts = try JSONDecoder().decode([WorkoutTransfer].self, from: workoutsData)
                    self.workouts = newWorkouts
                    updated = true
                    print("✅ Context: Updated \(newWorkouts.count) workouts")
                    
                    // Log first workout
                    if let first = newWorkouts.first {
                        print("⌚️ First workout: '\(first.name)' with \(first.exercises.count) exercises")
                    }
                } catch {
                    print("❌ Failed to decode workouts from context: \(error)")
                }
            } else {
                print("⚠️ No workout data in context")
            }
            
            if let splitData = applicationContext["activeSplit"] as? Data {
                do {
                    self.activeSplit = try JSONDecoder().decode(SplitTransfer.self, from: splitData)
                    updated = true
                    print("✅ Context: Updated active split")
                } catch {
                    print("❌ Failed to decode split from context: \(error)")
                }
            }
            
            if updated {
                self.saveCachedData()
                print("✅ Saved context data to cache")
            }
        }
    }
}

