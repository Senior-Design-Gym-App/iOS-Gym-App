//
//  Workout Provider.swift
//  iOS Gym App
//
//  Created by Troy Madden on 11/6/25.
//

import WidgetKit
import SwiftUI

// MARK: - Entry Model

struct WorkoutEntry: TimelineEntry {
    let date: Date
    let workouts: [Workout]
}

struct Workout: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let duration: Int
}

// MARK: - Sample Data (for Preview)

let sampleWorkouts: [Workout] = [
    Workout(id: "1", name: "Chest Day", duration: 45),
    Workout(id: "2", name: "Leg Day", duration: 60),
    Workout(id: "3", name: "HIIT", duration: 30)
]

// MARK: - Timeline Provider

struct WorkoutProvider: TimelineProvider {
    func placeholder(in context: Context) -> WorkoutEntry {
        WorkoutEntry(date: Date(), workouts: sampleWorkouts)
    }

    func getSnapshot(in context: Context, completion: @escaping (WorkoutEntry) -> ()) {
        completion(WorkoutEntry(date: Date(), workouts: loadPinnedWorkouts()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WorkoutEntry>) -> ()) {
        let workouts = loadPinnedWorkouts()
        let entry = WorkoutEntry(date: Date(), workouts: workouts)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    // MARK: - Data Loading

    private func loadPinnedWorkouts() -> [Workout] {
        // Load from shared App Group
        let defaults = UserDefaults(suiteName: "com.seniordesign.iOSGymApp")
        if let data = defaults?.data(forKey: "pinnedWorkouts"),
           let decoded = try? JSONDecoder().decode([Workout].self, from: data) {
            return decoded
        }
        return []
    }
}
