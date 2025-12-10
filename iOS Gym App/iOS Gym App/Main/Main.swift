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
    
    @State private var sessionManager: SessionManager
    @State private var pm = ProgressManager()
    @State private var watchSync = WatchSyncViewModel()
    @StateObject private var authManager = AuthManager()
    
    // Profile checking states
    @State private var needsProfile = false
    @State private var isCheckingProfile = true
    
    // Create shared model container first so we can pass it to SessionManager
    static var sharedModelContainerInstance: ModelContainer = {
        let schema = Schema([
            Exercise.self,
            Workout.self,
            Split.self,
            WorkoutSession.self,
            WorkoutSessionEntry.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
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
        
        // Initialize SessionManager with ModelContext immediately so it can handle remote notifications
        let manager = SessionManager(modelContext: Self.sharedModelContainerInstance.mainContext)
        _sessionManager = State(initialValue: manager)
        print("✅ SessionManager initialized with ModelContext in App.init()")
        
        debugInfoPlist()
    }
    
    var sharedModelContainer: ModelContainer {
        Self.sharedModelContainerInstance
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    if isCheckingProfile {
                        // Show loading while checking profile
                        VStack(spacing: 20) {
                            ProgressView()
                            Text("Loading your profile...")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        TabHome()
                            .tint(Constants.mainAppTheme)
                            .environment(pm)
                            .environment(sessionManager)
                            .environment(watchSync)
                            .environmentObject(authManager)
                            .onAppear {
                                // Give SessionManager access to ModelContext for cross-device sync
                                sessionManager.setModelContext(sharedModelContainer.mainContext)
                                print("✅ SessionManager configured with ModelContext")
                            }
                    }
                } else {
                    SignInView()
                        .environmentObject(authManager)
                }
            }
            .sheet(isPresented: $needsProfile) {
                CreateProfileView {
                    // Profile created successfully
                    isCheckingProfile = false
                }
            }
            .task {
                // Initialize AuthManager
                do {
                    try await authManager.initialize()
                    // Set CloudManager's auth reference
                    CloudManager.shared.setAuthManager(authManager)
                    print("✅ CloudManager initialized with AuthManager")
                    
                    // Check if user has a profile
                    if authManager.isAuthenticated {
                        await checkUserProfile()
                    } else {
                        isCheckingProfile = false
                    }
                } catch {
                    print("❌ Failed to initialize auth: \(error)")
                    isCheckingProfile = false
                }
            }
            .onChange(of: authManager.isAuthenticated) { oldValue, newValue in
                print("auth status \(newValue)")
                
                // Check profile when user signs in
                if newValue && !oldValue {
                    Task {
                        await checkUserProfile()
                    }
                }
                
                // Reset profile check when user signs out
                if !newValue && oldValue {
                    isCheckingProfile = true
                    needsProfile = false
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
    
    // ADD THIS FUNCTION
    private func checkUserProfile() async {
        isCheckingProfile = true
        
        do {
            // Try to get current user's profile
            let userId = try await CloudManager.shared.getCurrentUserId()
            _ = try await CloudManager.shared.getUserProfile(userId: userId)
            
            print("✅ User profile exists")
            isCheckingProfile = false
        } catch {
            print("⚠️ No profile found, showing profile creation")
            isCheckingProfile = false
            
            // Small delay to ensure sheet appears smoothly
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            needsProfile = true
        }
    }
}
