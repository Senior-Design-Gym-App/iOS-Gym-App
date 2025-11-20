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
    func debugInfoPlist() {
        print("===== ALL INFO.PLIST KEYS =====")
        if let infoDictionary = Bundle.main.infoDictionary {
            for (key, value) in infoDictionary.sorted(by: { $0.key < $1.key }) {
                print("\(key): \(value)")
            }
        }
        print("================================")
    }
    
    init() {
        // Initialize WatchConnectivity on app launch
        _ = WatchConnectivityManager.shared
        debugInfoPlist()
    }
    @StateObject private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
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
        .onChange(of: authManager.isAuthenticated) {
            print("auth status \(authManager.isAuthenticated)")
        }
        .modelContainer(for: [Exercise.self, Workout.self, Split.self, WorkoutSession.self, WorkoutSessionEntry.self])
    }
}
