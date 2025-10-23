import SwiftUI
import SwiftData

struct CreateWorkoutView: View {
    
    let allExercises: [Exercise]
    @State private var name: String = "New Day"
    @State private var selectedExercises: [Exercise] = []
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            WorkoutOptionsView(allExercises: allExercises, name: $name, selectedExercises: $selectedExercises)
            .environment(\.editMode, .constant(.active))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        let newWorkout = Workout(groupName: name, exercises: selectedExercises)
                        context.insert(newWorkout)
                        try? context.save()
                        dismiss()
                    } label: {
                        Label("Save", systemImage: "checkmark")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    } label: {
                        Label("Exit", systemImage: "xmark")
                    }
                }
            }
        }
    }
    
}
