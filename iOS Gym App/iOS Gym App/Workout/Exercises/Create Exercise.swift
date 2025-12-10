import SwiftUI
import SwiftData

struct CreateExerciseView: View {
    
    @State private var setData: [SetData] = []
    @State private var manualOneRepMax: [WeightEntry] = []
    @State private var selectedMuscle: Muscle?
    @State private var selectedEquipment: WorkoutEquipment?
    @State private var newExercise = Exercise(name: "New Exercise", rest: [], muscleWorked: "", weights: [], reps: [], equipment: nil)
    
    @State private var showAddSheet: Bool = false
    @State private var showMaxSheet: Bool = false
    @State private var showChangeNameAlert: Bool = false
    @Environment(ProgressManager.self) private var hkm
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @AppStorage("defaultRepCount") private var defaultRepCount: Int = 8
    @AppStorage("defaultRestTime") private var defaultRestTime: Int = 60
    
    var body: some View {
        NavigationStack {
            List {
                HStack {
                    Spacer()
                    VStack {
                        ReusedViews.ExerciseViews.LargeExerciseLabel(exercise: newExercise)
                            .offset(y: Constants.largeOffset)
                        HStack {
                            ReusedViews.ExerciseViews.ExerciseCustomization(selectedMuscle: $selectedMuscle, selectedEquipment: $selectedEquipment)
                            ReusedViews.Buttons.RenameButtonAlert(type: .exercise, oldName: $newExercise.name)
                        }
                    }
                    Spacer()
                }.padding(.bottom)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                ReusedViews.ExerciseViews.SetDataInfo(setData: setData, exericse: newExercise, showAddSheet: $showAddSheet)
                ReusedViews.ExerciseViews.OneRepMaxInfo(data: manualOneRepMax, exercise: newExercise, showMaxSheet: $showMaxSheet, label: hkm.weightUnitString)
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
            .sheet(isPresented: $showAddSheet) {
                ReusedViews.ExerciseViews.SetControls(exercise: newExercise, saveAction: {}, newSetData: setData, oldSetData: $setData, showAddSheet: $showAddSheet, restTime: defaultRestTime, reps: defaultRepCount)
            }
            .sheet(isPresented: $showMaxSheet) {
                ReusedViews.ExerciseViews.ManualOneRepMaxControls(saveAction: {}, oldOneRepMaxData: $manualOneRepMax, newOneRepMaxData: manualOneRepMax, showMaxSheet: $showMaxSheet)
            }
            .navigationTitle(newExercise.name)
            .navigationSubtitle("Created Now")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func SaveExercise() {
        
        let reps = setData.map { $0.reps }
        
        let weights = setData.map { $0.weight }
        
        let rest = setData.map { $0.rest }
        
        newExercise.manualOneRepMaxDates = manualOneRepMax.map { $0.date }
        newExercise.manualOneRepMaxWeights = manualOneRepMax.map { $0.value }
        
        newExercise.reps = [reps]
        newExercise.weights = [weights]
        newExercise.rest = [rest]
        newExercise.updateDates = [Date()]
        
        context.insert(newExercise)
        try? context.save()
        dismiss()
    }
    
    private func dismisx() {
        dismiss()
    }
    
}
