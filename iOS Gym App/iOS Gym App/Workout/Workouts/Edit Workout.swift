import SwiftUI
import SwiftData

struct EditWorkoutView: View {
    
    let allExercises: [Exercise]
    @State var name: String
    @State var selectedExercises: [Exercise]
    @State var selectedWorkout: Workout
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            WorkoutOptionsView(allExercises: allExercises, name: $name, selectedExercises: $selectedExercises)
            .environment(\.editMode, .constant(.active))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        selectedWorkout.name = name
                        selectedWorkout.exercises = selectedExercises
                        try? context.save()
                        dismiss()
                    } label: {
                        Label("Save", systemImage: "checkmark")
                    }
                }
            }
        }
    }
    
}
