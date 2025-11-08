import SwiftUI

struct SessionWorkoutQueueView: View {
    
    @Environment(SessionManager.self) private var sessionManager: SessionManager
    
    private var completedWorkouts: [SessionData] {
        var allItems: [SessionData] = []
        for entry in sessionManager.completedWorkouts {
            if let workout = entry.exercise {
                allItems.append(SessionData(exercise: workout, entry: entry))
            }
        }
        if let currentWorkout = sessionManager.currentWorkout {
            allItems.append(currentWorkout)
        }
        return allItems
    }
    
    var body: some View {
        List {
            Section {
                PreviousWorkouts(completedExercises: completedWorkouts)
            } header: {
                Text("Completed")
            }
            Section {
                UpcomingExercises(queuedExercises: sessionManager.upcomingWorkouts)
            } header: {
                Text("Queue")
            }
        }
        .environment(\.editMode, .constant(.active))
    }
    
    private func PreviousWorkouts(completedExercises: [SessionData]) -> some View {
        ForEach(completedExercises, id: \.self) { exercise in
            ExerciseListPreview(exercise: exercise.exercise, data: exercise)
        }
    }
    
    private func UpcomingExercises(queuedExercises: [SessionData]) -> some View {
        ForEach(queuedExercises, id: \.self) { workout in
            ReusedViews.ExerciseViews.ExerciseListPreview(exercise: workout.exercise)
        }
        .onMove { indices, newOffset in
            sessionManager.upcomingWorkouts.move(fromOffsets: indices, toOffset: newOffset)
        }.onDelete { indicies in
            sessionManager.upcomingWorkouts.remove(atOffsets: indicies)
        }
    }
    
    private func ExerciseListPreview(exercise: Exercise, data: SessionData) -> some View {
        HStack {
            ReusedViews.Labels.SmallIconSize(color: exercise.color)
                .overlay(alignment: .center) {
                    Image(systemName: exercise.workoutEquipment?.imageName ?? "dumbbell")
                        .foregroundStyle(Constants.iconColor)
                }
            ReusedViews.Labels.TypeListDescription(name: exercise.name, items: data.entry.weight, type: .exercise, extend: true)
        }
    }
    
}
