//
//  Workout Widget.swift
//  iOS Gym App
//
//  Created by Troy Madden on 11/6/25.
//

import WidgetKit
import SwiftUI
import AppIntents

struct WorkoutWidget: Widget {
    let kind: String = "WorkoutWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WorkoutProvider()) { entry in
            WorkoutWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color.clear
                }
        }
        .configurationDisplayName("Pinned Workouts")
        .description("Quickly start your favorite workouts.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct WorkoutWidgetEntryView: View {
    var entry: WorkoutProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Pinned Workouts")
                .font(.headline)
                .padding(.bottom, 4)

            if entry.workouts.isEmpty {
                Text("No pinned workouts")
                    .foregroundColor(.secondary)
                    .font(.footnote)
            } else {
                ForEach(entry.workouts.prefix(3)) { workout in
                    Button(intent: StartWorkoutIntent(workoutID: .init(title: .init(stringLiteral: workout.id)))) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(workout.name)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                Text("\(workout.duration) min")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "play.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

            Spacer()
        }
        .padding()
    }
}

#Preview(as: .systemMedium) {
    WorkoutWidget()
} timeline: {
    WorkoutEntry(date: .now, workouts: sampleWorkouts)
}

