import SwiftUI
import SwiftData

struct CreateWorkoutView: View {
    
    @State private var name: String = "New Workout"
    
    @State private var showAddSet: Bool = false
    @State private var setData: [SetEntry] = []
    @State private var selectedMuscle: (any Muscle)?
    @State private var selectedEquipment: WorkoutEquipment?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            WorkoutOptionsView(name: $name, showAddSet: $showAddSet, setData: $setData, selectedMuscle: $selectedMuscle, selectedEquipment: $selectedEquipment)
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
        
        let reps = setData.map { $0.reps }
        
        let weights = setData.map { $0.weight }
        
        let rest = setData.map { $0.rest }
        
        let newUpdate = WorkoutUpdate(updateDates: [Date.now], reps: [reps], weights: [weights])
        
        context.insert(newUpdate)
        
        let exercise = Workout(name: name, rest: rest, muscleWorked: selectedMuscle?.rawValue ?? "", weights: weights, reps: reps, updateData: newUpdate, equipment: selectedEquipment?.rawValue)
        
        context.insert(exercise)
        try? context.save()
    }
    
}
