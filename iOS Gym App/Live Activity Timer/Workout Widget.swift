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
        .configurationDisplayName("Split Workouts")
        .description("Track progress through your active workout split.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct WorkoutWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: WorkoutProvider.Entry

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget (Next Workout Only)

struct SmallWidgetView: View {
    var entry: WorkoutProvider.Entry
    
    var nextWorkout: WorkoutWidgetData? {
        guard let nextIndex = entry.nextWorkoutIndex,
              nextIndex < entry.workouts.count else {
            return nil
        }
        return entry.workouts[nextIndex]
    }
    
    var body: some View {
        if let workout = nextWorkout {
            Button(intent: StartWorkoutIntent(workoutID: workout.id)) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                        Text("Up Next")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(workout.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text("~\(workout.duration) min")
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.tint)
                        Spacer()
                        if let splitName = entry.splitName {
                            Text(splitName)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding()
            }
            .buttonStyle(.plain)
        } else {
            EmptyWidgetView(size: .small)
        }
    }
}

// MARK: - Medium Widget (Next 2 Workouts)

struct MediumWidgetView: View {
    var entry: WorkoutProvider.Entry
    
    var displayWorkouts: [(index: Int, workout: WorkoutWidgetData, isNext: Bool)] {
        guard !entry.workouts.isEmpty else { return [] }
        
        if let nextIndex = entry.nextWorkoutIndex {
            let firstIndex = nextIndex
            let secondIndex = (nextIndex + 1) % entry.workouts.count
            
            return [
                (firstIndex, entry.workouts[firstIndex], true),
                (secondIndex, entry.workouts[secondIndex], false)
            ]
        }
        
        return []
    }
    
    var body: some View {
        if !displayWorkouts.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                // Header
                HStack {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.subheadline)
                        .foregroundStyle(.tint)
                    if let splitName = entry.splitName {
                        Text(splitName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                    }
                    Spacer()
                }
                
                // Two workouts side by side
                HStack(spacing: 12) {
                    ForEach(displayWorkouts, id: \.index) { item in
                        WorkoutCard(
                            workout: item.workout,
                            isNext: item.isNext,
                            compact: false
                        )
                    }
                }
            }
            .padding()
        } else {
            EmptyWidgetView(size: .medium)
        }
    }
}

// MARK: - Large Widget (All Workouts)

struct LargeWidgetView: View {
    var entry: WorkoutProvider.Entry
    
    var body: some View {
        if !entry.workouts.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                // Header
                HStack {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.body)
                        .foregroundStyle(.tint)
                    if let splitName = entry.splitName {
                        Text(splitName)
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    Text("\(entry.workouts.count) workouts")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                
                // List of all workouts
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(entry.workouts.enumerated()), id: \.element.id) { index, workout in
                        let isNext = index == entry.nextWorkoutIndex
                        
                        Button(intent: StartWorkoutIntent(workoutID: workout.id)) {
                            HStack(spacing: 12) {
                                // Number badge
                                ZStack {
                                    Circle()
                                        .fill(isNext ? Color.accentColor : Color.secondary.opacity(0.2))
                                        .frame(width: 32, height: 32)
                                    Text("\(index + 1)")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(isNext ? .white : .secondary)
                                }
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack(spacing: 6) {
                                        if isNext {
                                            Image(systemName: "star.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.yellow)
                                        }
                                        Text(workout.name)
                                            .font(isNext ? .body : .subheadline)
                                            .fontWeight(isNext ? .semibold : .regular)
                                            .lineLimit(1)
                                    }
                                    
                                    HStack(spacing: 4) {
                                        if isNext {
                                            Text("Up Next")
                                                .font(.caption2)
                                                .foregroundStyle(.tint)
                                                .fontWeight(.medium)
                                            Text("•")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                        Image(systemName: "clock")
                                            .font(.caption2)
                                        Text("~\(workout.duration) min")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "play.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(isNext ? Color.accentColor : Color.secondary)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(isNext ? Color.accentColor.opacity(0.1) : Color.clear)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding()
        } else {
            EmptyWidgetView(size: .large)
        }
    }
}

// MARK: - Reusable Components

struct WorkoutCard: View {
    let workout: WorkoutWidgetData
    let isNext: Bool
    let compact: Bool
    
    var body: some View {
        Button(intent: StartWorkoutIntent(workoutID: workout.id)) {
            VStack(alignment: .leading, spacing: 6) {
                if isNext {
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                        Text("Up Next")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.tint)
                } else {
                    Text("After")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(workout.name)
                    .font(compact ? .subheadline : .body)
                    .fontWeight(isNext ? .bold : .semibold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                HStack {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text("~\(workout.duration) min")
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
                
                Spacer()
                
                Image(systemName: "play.circle.fill")
                    .font(isNext ? .title3 : .body)
                    .foregroundStyle(isNext ? Color.accentColor : Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isNext ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }
}

struct EmptyWidgetView: View {
    enum WidgetSize {
        case small, medium, large
    }
    
    let size: WidgetSize
    
    var body: some View {
        VStack(spacing: size == .small ? 6 : 10) {
            Image(systemName: "list.clipboard")
                .font(size == .small ? .title2 : .largeTitle)
                .foregroundStyle(.secondary)
            
            Text("No Active Split")
                .font(size == .small ? .caption : .headline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            if size != .small {
                Text("Create or activate a split in the app")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview("Small Widget", as: .systemSmall) {
    WorkoutWidget()
} timeline: {
    WorkoutEntry(
        date: .now, 
        workouts: sampleWorkouts,
        nextWorkoutIndex: 0,
        splitName: "Push/Pull/Legs"
    )
}

#Preview("Medium Widget", as: .systemMedium) {
    WorkoutWidget()
} timeline: {
    WorkoutEntry(
        date: .now, 
        workouts: sampleWorkouts,
        nextWorkoutIndex: 0,
        splitName: "Push/Pull/Legs"
    )
    WorkoutEntry(
        date: .now,
        workouts: sampleWorkouts,
        nextWorkoutIndex: 1,
        splitName: "Upper/Lower"
    )
}

#Preview("Large Widget", as: .systemLarge) {
    WorkoutWidget()
} timeline: {
    WorkoutEntry(
        date: .now, 
        workouts: sampleWorkouts,
        nextWorkoutIndex: 0,
        splitName: "Push/Pull/Legs"
    )
}

#Preview("Empty Widget", as: .systemMedium) {
    WorkoutWidget()
} timeline: {
    WorkoutEntry(
        date: .now,
        workouts: [],
        nextWorkoutIndex: nil,
        splitName: nil
    )
}
