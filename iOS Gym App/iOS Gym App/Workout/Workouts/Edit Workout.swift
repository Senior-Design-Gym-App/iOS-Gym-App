import SwiftUI
import SwiftData

struct EditWorkoutView: View {
    
    @State var workout: Workout
    
    @State var rest: Double
    @State var name: String
    
    @State private var showAddSet: Bool = false
    @State var setData: [SetEntry]
    @State var selectedMuscle: (any Muscle)?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            WorkoutOptionsView(name: $name, showAddSet: $showAddSet, setData: $setData, selectedMuscle: $selectedMuscle)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        SaveExercise()
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
            .environment(\.editMode, .constant(.active))
        }
    }
    
    private func SaveExercise() {
        let newReps = setData.map { $0.reps }
        
        let newWeights = setData.map { $0.weight }
        
        if setData != workout.setData {
            if let update = workout.updateData {
                update.reps.append(newReps)
                update.weights.append(newWeights)
                update.updateDates.append(Date())
            } else {
                let newUpdate = WorkoutUpdate(workout: workout, updateDates: [Date()], reps: [workout.reps, newReps], weights: [workout.weights, newWeights])
                context.insert(newUpdate)
            }
        }
        
        workout.name = name
        workout.rest = Int(rest)
        workout.muscleWorked = selectedMuscle?.rawValue ?? ""
        workout.weights = newWeights
        workout.reps = newReps
        
        try? context.save()
    }
    
}
