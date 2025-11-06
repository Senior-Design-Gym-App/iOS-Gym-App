//
//  Start Workout Intent.swift
//  iOS Gym App
//
//  Created by Troy Madden on 11/6/25.
//
import AppIntents

struct StartWorkoutIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Workout"
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Workout ID")
    var workoutID: String

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        return .result(value: workoutID)
    }
}
