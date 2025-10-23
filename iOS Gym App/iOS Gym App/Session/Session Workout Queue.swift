import SwiftUI

struct SessionWorkoutQueueView: View {
    
    @Environment(SessionManager.self) private var sessionManager: SessionManager
    
    private var allWorkouts: [SessionData] {
        var allItems: [SessionData] = sessionManager.upcomingWorkouts
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
            PreviousWorkouts(workouts: sessionManager.completedWorkouts)
            if let current = sessionManager.currentWorkout {
                CurrentWorkoutView(currentExercise: current)
            }
            UpcomingExercises(queuedExercises: sessionManager.upcomingWorkouts)
        }
    }
    
    private func CurrentWorkoutView(currentExercise: SessionData) -> some View {
        HStack {
            Image(systemName: currentExercise.exercise.workoutEquipment?.imageName ?? "dumbbell")
            Text(currentExercise.exercise.name)
            Text("\(currentExercise.entry.weight.count + 1) Sets")
        }
    }
    
    private func PreviousWorkouts(workouts: [WorkoutSessionEntry]) -> some View {
        ForEach(workouts, id: \.self) { workout in
            NotCurrentWorkoutView(imageName: workout.exercise?.workoutEquipment?.imageName, workoutName: workout.exercise?.name ?? "Unknown Workout", setCount: workout.weight.count + 1)
        }
    }
    
    private func UpcomingExercises(queuedExercises: [SessionData]) -> some View {
        ForEach(queuedExercises, id: \.self) { workout in
            NotCurrentWorkoutView(imageName: workout.exercise.workoutEquipment?.imageName, workoutName: workout.exercise.name, setCount: workout.entry.weight.count + 1)
        }
        .onMove { indices, newOffset in
        }
    }
    
    private func NotCurrentWorkoutView(imageName: String?, workoutName: String, setCount: Int) -> some View {
        HStack {
            Image(systemName: imageName ?? Constants.defaultEquipmentIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            VStack(alignment: .leading) {
                Text(workoutName)
                Text("\(setCount) set\(setCount == 1 ? "" : "s")")
            }
        }
    }
    
}
