//
//  StartWorkoutIntent.swift
//  iOS Gym App
//
//  App Intent for starting workouts from widgets
//

import AppIntents
import SwiftUI
import SwiftData

struct StartWorkoutIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Workout"
    static var description = IntentDescription("Start a workout session")
    static var openAppWhenRun: Bool = true
    
    @Parameter(title: "Workout ID")
    var workoutID: String
    
    init() {
        self.workoutID = ""
    }
    
    init(workoutID: String) {
        self.workoutID = workoutID
    }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        print("🎯 StartWorkoutIntent: Starting workout with ID: \(workoutID)")
        
        // Store the workout ID in UserDefaults for the app to pick up
        let defaults = UserDefaults(suiteName: "group.com.yourcompany.reptheset")
        defaults?.set(workoutID, forKey: "pendingWorkoutStart")
        defaults?.set(Date().timeIntervalSince1970, forKey: "pendingWorkoutStartTime")
        defaults?.synchronize()
        
        print("🎯 StartWorkoutIntent: Saved pending workout ID to app group")
        
        // Also post notification in case app is already running
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .startWorkoutFromWidget,
                object: nil,
                userInfo: ["workoutID": workoutID]
            )
            print("🎯 StartWorkoutIntent: Posted notification with workout ID")
        }
        
        return .result()
    }
}

// MARK: - Notification Name

extension Notification.Name {
    static let startWorkoutFromWidget = Notification.Name("startWorkoutFromWidget")
    static let workoutCompletedValidateWidget = Notification.Name("workoutCompletedValidateWidget")
}

