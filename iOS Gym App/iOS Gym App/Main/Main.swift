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
    
    var body: some Scene {
        WindowGroup {
            TabHome()
                .tint(Constants.mainAppTheme)
                .environment(sessionManager)
        }.modelContainer(for: [Exercise.self, Workout.self, Split.self, WorkoutSession.self, WorkoutSessionEntry.self])
    }
}
