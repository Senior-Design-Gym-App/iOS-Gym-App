//
//  DebugConnectivityView.swift
//  Rep the Set Watch App
//
//  Debug view to check WatchConnectivity status
//

import SwiftUI
import WatchConnectivity

struct DebugConnectivityView: View {
    @State private var connectivityManager = WatchConnectivityManager.shared
    @State private var sessionState = "Unknown"
    @State private var isSupported = false
    @State private var isPaired = false
    @State private var isWatchAppInstalled = false
    @State private var isReachable = false
    
    var body: some View {
        List {
            Section("WatchConnectivity Status") {
                LabeledContent("Supported", value: isSupported ? "✅" : "❌")
                LabeledContent("Session State", value: sessionState)
                LabeledContent("Reachable", value: connectivityManager.isReachable ? "✅" : "❌")
            }
            
            Section("Data Status") {
                LabeledContent("Workouts", value: "\(connectivityManager.workouts.count)")
                LabeledContent("Active Split", value: connectivityManager.activeSplit?.name ?? "None")
                
                if let lastSync = connectivityManager.lastSyncDate {
                    LabeledContent("Last Sync") {
                        Text(lastSync.formatted(date: .abbreviated, time: .shortened))
                    }
                } else {
                    LabeledContent("Last Sync", value: "Never")
                }
            }
            
            Section("Actions") {
                Button("Request Workouts") {
                    connectivityManager.requestWorkouts()
                }
                
                Button("Check UserDefaults") {
                    checkUserDefaults()
                }
            }
            
            Section("Workouts") {
                if connectivityManager.workouts.isEmpty {
                    Text("No workouts cached")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(connectivityManager.workouts) { workout in
                        VStack(alignment: .leading) {
                            Text(workout.name)
                                .font(.headline)
                            Text("\(workout.exercises.count) exercises")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Debug")
        .onAppear {
            updateStatus()
        }
    }
    
    private func updateStatus() {
        isSupported = WCSession.isSupported()
        
        let session = WCSession.default
        switch session.activationState {
        case .notActivated:
            sessionState = "Not Activated"
        case .inactive:
            sessionState = "Inactive"
        case .activated:
            sessionState = "✅ Activated"
        @unknown default:
            sessionState = "Unknown"
        }
        
        isReachable = session.isReachable
        
        // On watch, we don't have isPaired/isWatchAppInstalled
        print("📊 Debug Status:")
        print("  - Supported: \(isSupported)")
        print("  - State: \(sessionState)")
        print("  - Reachable: \(isReachable)")
        print("  - Workouts: \(connectivityManager.workouts.count)")
    }
    
    private func checkUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "cachedWorkouts") {
            print("✅ UserDefaults has cachedWorkouts: \(data.count) bytes")
        } else {
            print("❌ No cachedWorkouts in UserDefaults")
        }
        
        if let data = UserDefaults.standard.data(forKey: "cachedActiveSplit") {
            print("✅ UserDefaults has cachedActiveSplit: \(data.count) bytes")
        } else {
            print("❌ No cachedActiveSplit in UserDefaults")
        }
    }
}

#Preview {
    NavigationStack {
        DebugConnectivityView()
    }
}
