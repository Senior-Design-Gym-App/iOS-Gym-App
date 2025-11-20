//
//  DebugWatchSyncView.swift
//  iOS Gym App
//
//  Debug view to check watch sync status
//

import SwiftUI
import SwiftData
import WatchConnectivity

struct DebugWatchSyncView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(WatchSyncViewModel.self) private var watchSync
    
    @State private var sessionState = "Unknown"
    @State private var isSupported = false
    @State private var isPaired = false
    @State private var isWatchAppInstalled = false
    @State private var isReachable = false
    
    @Query private var workouts: [Workout]
    @Query(filter: #Predicate<Split> { $0.active == true })
    private var activeSplits: [Split]
    
    var body: some View {
        List {
            Section("WatchConnectivity Status") {
                LabeledContent("Supported", value: isSupported ? "✅" : "❌")
                LabeledContent("Session State", value: sessionState)
                LabeledContent("Watch Paired", value: isPaired ? "✅" : "❌")
                LabeledContent("Watch App Installed", value: isWatchAppInstalled ? "✅" : "❌")
                LabeledContent("Reachable", value: isReachable ? "✅" : "❌")
            }
            
            Section("SwiftData Status") {
                LabeledContent("Workouts", value: "\(workouts.count)")
                LabeledContent("Active Splits", value: "\(activeSplits.count)")
                
                if let split = activeSplits.first {
                    LabeledContent("Active Split", value: split.name)
                    LabeledContent("Split Workouts", value: "\(split.workouts?.count ?? 0)")
                }
            }
            
            Section("Actions") {
                Button("Sync All Data Now") {
                    watchSync.syncToWatch()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Sync Active Split") {
                    watchSync.syncActiveSplit()
                }
                
                Button("Test Send Message") {
                    testSendMessage()
                }
            }
            
            Section("Workouts in SwiftData") {
                if workouts.isEmpty {
                    Text("No workouts in database")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(workouts) { workout in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(workout.name)
                                .font(.headline)
                            Text("\(workout.exercises?.count ?? 0) exercises")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            if let exercises = workout.exercises {
                                ForEach(exercises.prefix(3)) { exercise in
                                    Text("• \(exercise.name)")
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Watch Sync Debug")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            updateStatus()
            
            // Auto-sync when debug view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("🔄 Auto-syncing from debug view...")
                watchSync.syncToWatch()
            }
        }
        .refreshable {
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
        
        isPaired = session.isPaired
        isWatchAppInstalled = session.isWatchAppInstalled
        isReachable = session.isReachable
        
        print("📊 iPhone Debug Status:")
        print("  - Supported: \(isSupported)")
        print("  - State: \(sessionState)")
        print("  - Paired: \(isPaired)")
        print("  - Watch App Installed: \(isWatchAppInstalled)")
        print("  - Reachable: \(isReachable)")
        print("  - Workouts in DB: \(workouts.count)")
    }
    
    private func testSendMessage() {
        guard WCSession.default.isReachable else {
            print("❌ Watch not reachable")
            return
        }
        
        let testMessage: [String: Any] = ["test": "Hello from iPhone", "timestamp": Date()]
        
        WCSession.default.sendMessage(testMessage, replyHandler: { reply in
            print("✅ Got reply from watch: \(reply)")
        }) { error in
            print("❌ Failed to send test message: \(error.localizedDescription)")
        }
    }
}

#Preview {
    NavigationStack {
        DebugWatchSyncView()
    }
    .modelContainer(for: [Exercise.self, Workout.self, Split.self, WorkoutSession.self])
}
