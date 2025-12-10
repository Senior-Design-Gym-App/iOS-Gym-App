//
//  Debug Test View.swift
//  Watch App
//
//  Temporary view to test if session UI works independently of connectivity
//

import SwiftUI

struct DebugTestView: View {
    @Environment(WatchSessionManager.self) private var sessionManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Debug Testing")
                .font(.headline)
            
            VStack(spacing: 8) {
                Text("Session ID: \(sessionManager.sessionId?.uuidString ?? "nil")")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Text("Is Active: \(sessionManager.isSessionActive ? "YES" : "NO")")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(sessionManager.isSessionActive ? .green : .red)
            }
            
            Divider()
            
            VStack(spacing: 12) {
                Button("Manually Start Session") {
                    print("⌚️ 🧪 TEST: Manually starting session")
                    sessionManager.sessionId = UUID()
                    sessionManager.currentExerciseName = "Test Exercise"
                    sessionManager.currentSet = 1
                    sessionManager.totalSets = 5
                    sessionManager.currentReps = 10
                    sessionManager.currentWeight = 135
                    print("⌚️ 🧪 TEST: sessionId set to \(sessionManager.sessionId!)")
                    print("⌚️ 🧪 TEST: isSessionActive: \(sessionManager.isSessionActive)")
                }
                .buttonStyle(.borderedProminent)
                
                Button("End Session") {
                    print("⌚️ 🧪 TEST: Manually ending session")
                    sessionManager.endSession()
                    print("⌚️ 🧪 TEST: isSessionActive: \(sessionManager.isSessionActive)")
                }
                .buttonStyle(.bordered)
                .disabled(!sessionManager.isSessionActive)
            }
            
            Divider()
            
            VStack(spacing: 4) {
                Text("Instructions:")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text("1. Tap 'Manually Start Session'")
                    .font(.caption2)
                Text("2. Session view should appear")
                    .font(.caption2)
                Text("3. If it does, connectivity is the issue")
                    .font(.caption2)
                Text("4. If it doesn't, UI observation is the issue")
                    .font(.caption2)
            }
            .foregroundStyle(.secondary)
        }
        .padding()
    }
}

// Add this to your ContentView workout list toolbar for easy access:
/*
.toolbar {
    ToolbarItem(placement: .topBarLeading) {
        NavigationLink {
            DebugTestView()
        } label: {
            Image(systemName: "ladybug.fill")
                .foregroundStyle(.orange)
        }
    }
}
*/
