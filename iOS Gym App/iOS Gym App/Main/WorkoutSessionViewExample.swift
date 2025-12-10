//
//  WorkoutSessionView+HeartRate.swift
//  watchOS Gym App
//
//  Example integration of heart rate auto-advance in a workout view
//

import SwiftUI

struct WorkoutSessionViewExample: View {
    @State private var sessionManager = WatchSessionManager()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Current Exercise Info
                VStack(spacing: 8) {
                    Text(sessionManager.currentExerciseName)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Set \(sessionManager.currentSet) of \(sessionManager.totalSets)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                
                // Reps and Weight
                HStack(spacing: 20) {
                    VStack {
                        Text("\(sessionManager.currentReps)")
                            .font(.system(.title, design: .rounded))
                        Text("Reps")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack {
                        Text("\(Int(sessionManager.currentWeight))")
                            .font(.system(.title, design: .rounded))
                        Text("lbs")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Divider()
                
                // Heart Rate Auto-Advance Toggle
                HeartRateAutoAdvanceToggle(sessionManager: sessionManager)
                
                Divider()
                
                // Manual Controls
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Button {
                            sessionManager.previousSet()
                        } label: {
                            Image(systemName: "chevron.left")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(sessionManager.currentSet <= 1)
                        
                        Button {
                            sessionManager.nextSet()
                        } label: {
                            Image(systemName: "chevron.right")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(sessionManager.currentSet >= sessionManager.totalSets)
                    }
                    
                    Button("End Workout", role: .destructive) {
                        sessionManager.endSession()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .navigationTitle("Workout")
    }
}

#Preview {
    NavigationStack {
        WorkoutSessionViewExample()
    }
}
