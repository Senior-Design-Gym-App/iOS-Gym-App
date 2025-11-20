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
    
    // Handle messages from iPhone
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("⌚️ Received message from iPhone")
        
        DispatchQueue.main.async {
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

