import SwiftUI

struct SessionWorkoutQueueView: View {
    
    @Environment(SessionManager.self) private var sessionManager: SessionManager
    
    private var completedExercises: [SessionData] {
        var allItems: [SessionData] = []
        for entry in sessionManager.completedExercises {
            if let workout = entry.exercise {
                allItems.append(SessionData(exercise: workout, entry: entry))
            }
        }
        return allItems
    }
    
    var body: some View {
        List {
            Section {
                PreviousWorkouts(completedExercises: completedExercises)
            } header: {
                Text("Completed")
            }
            Section {
                UpcomingExercises(queuedExercises: sessionManager.upcomingExercises)
            } header: {
                Text("Queue")
            }
        }
        .environment(\.editMode, .constant(.active))
    }
    
    private func PreviousWorkouts(completedExercises: [SessionData]) -> some View {
        ForEach(completedExercises, id: \.self) { exercise in
            ExerciseListPreview(exercise: exercise.exercise, data: exercise).id(exercise.id)
        }
    }
    
    private func UpcomingExercises(queuedExercises: [SessionData]) -> some View {
        ForEach(queuedExercises, id: \.self) { queuedExercise in
            ReusedViews.ExerciseViews.ExerciseListPreview(exercise: queuedExercise.exercise).id(queuedExercise.id)
        }
        .onMove { indices, newOffset in
            sessionManager.upcomingExercises.move(fromOffsets: indices, toOffset: newOffset)
        }.onDelete { indicies in
            sessionManager.upcomingExercises.remove(atOffsets: indicies)
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
