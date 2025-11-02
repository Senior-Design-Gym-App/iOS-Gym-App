import SwiftUI
import SwiftData

struct CreateExerciseView: View {
    
    @State private var setData: [SetEntry] = []
    @State private var selectedMuscle: Muscle?
    @State private var selectedEquipment: WorkoutEquipment?
    @State private var newExercise = Exercise(name: "", rest: [], muscleWorked: "", weights: [], reps: [], equipment: nil)
    @State private var showChangeNameAlert: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            List {
                ReusedViews.ExerciseViews.SingleExerciseCard(exercise: newExercise)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                ReusedViews.Labels.SingleCardTextField(textFieldName: $newExercise.name, createdDate: newExercise.created, type: .exercise)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                ReusedViews.ExerciseViews.ListHorizontalButtons(selectedEquipment: $selectedEquipment, selectedMuscle: $selectedMuscle)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                ReusedViews.ExerciseViews.SetControls(exercise: newExercise, saveAction: {}, newSetData: setData, oldSetData: $setData)
            }
            .onChange(of: selectedMuscle) {
                newExercise.muscleWorked = selectedMuscle?.rawValue
            }
            .onChange(of: selectedEquipment) {
                newExercise.equipment = selectedEquipment?.rawValue
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    ReusedViews.Buttons.SaveButton(disabled: newExercise.name.isEmpty, save: SaveExercise)
                }
                ToolbarItem(placement: .cancellationAction) {
                    ReusedViews.Buttons.CancelButton(cancel: dismisx)
                }
            }
        }
    }
    
    private func SaveExercise() {
        
        let reps = setData.map { $0.reps }
        
        let weights = setData.map { $0.weight }
        
        let rest = setData.map { $0.rest }
        
        newExercise.reps = [reps]
        newExercise.weights = [weights]
        newExercise.rest = [rest]
        newExercise.muscleWorked = selectedMuscle?.rawValue
        newExercise.equipment = selectedEquipment?.rawValue
        
        context.insert(newExercise)
        try? context.save()
        dismiss()
    }
    
    private func dismisx() {
        dismiss()
    }
    
}
