//
//  iOS_Gym_AppApp.swift
//  iOS Gym App
//
//  Created by Troy Madden on 9/30/25.
//

import SwiftUI
import SwiftData

@main
struct iOS_Gym_AppApp: App {
    
    @State private var sessionManager = SessionManager()
    @State private var pm = ProgressManager()
    @State private var watchSync = WatchSyncViewModel()
    @StateObject private var authManager = AuthManager()
    
    init() {
        // Initialize WatchConnectivity on app launch
        _ = WatchConnectivityManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    TabHome()
                        .tint(Constants.mainAppTheme)
                        .environment(pm)
                        .environment(sessionManager)
                        .environment(watchSync)
                        .environmentObject(authManager)
                } else {
                    SignInView()
                        .environmentObject(authManager)
                }
            }
            .task {
                // Initialize AuthManager
                do {
                    try await authManager.initialize()
                    // Set CloudManager's auth reference
                    CloudManager.shared.setAuthManager(authManager)
                    print("✅ CloudManager initialized with AuthManager")
                } catch {
                    print("❌ Failed to initialize auth: \(error)")
                }
            }
            .onChange(of: authManager.isAuthenticated) {
                print("auth status \(authManager.isAuthenticated)")
            }
        }
        .modelContainer(for: [Exercise.self, Workout.self, Split.self, WorkoutSession.self, WorkoutSessionEntry.self])
    }
}
