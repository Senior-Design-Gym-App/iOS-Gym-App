import SwiftUI
import SwiftData

struct EditExerciseView: View {
    
    @State var exercise: Exercise
    
    @State private var showRename: Bool = false
    @State private var showAddSheet: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State var setData: [SetData]
    @State var selectedMuscle: Muscle?
    @State var selectedEquipment: WorkoutEquipment?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            List {
                ReusedViews.ExerciseViews.SingleExerciseCard(exercise: exercise)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                ReusedViews.Labels.SingleCardTitle(title: exercise.name, modified: exercise.modified)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                ReusedViews.ExerciseViews.SetDataInfo(setData: setData, exericse: exercise, showAddSheet: $showAddSheet)
                ExerciseWorkouts()
            }
            .onChange(of: selectedMuscle) {
                exercise.muscleWorked = selectedMuscle?.rawValue
            }
            .onChange(of: selectedEquipment) {
                exercise.equipment = selectedEquipment?.rawValue
            }
            .toolbar {
                ToolbarItemGroup(placement: .secondaryAction) {
                    ReusedViews.Buttons.RenameButtonAlert(type: .exercise, oldName: $exercise.name)
                    ReusedViews.Buttons.DeleteButtonConfirmation(type: .exercise, deleteAction: Delete)
                    MuscleSelector(selectedMuscle: $selectedMuscle)
                    EquipmentSelector(selectedEquipment: $selectedEquipment)
                }
            }
            .sheet(isPresented: $showAddSheet) {
                ReusedViews.ExerciseViews.SetControls(exercise: exercise, saveAction: SaveExercise, newSetData: setData, oldSetData: $setData, showAddSheet: $showAddSheet)
            }
        }
    }
    
    private func ExerciseWorkouts() -> some View {
        Section {
            ForEach(exercise.workouts ?? [], id: \.self) { workout in
                NavigationLink {
                    EditWorkoutView(selectedExercises: workout.exercises ?? [], selectedWorkout: workout)
                } label: {
                    ReusedViews.WorkoutViews.WorkoutListPreview(workout: workout)
                }
            }
        } header: {
            Text("Workouts")
        }
    }
    
    private func SaveExercise() {
        
        let newReps = setData.map { $0.reps }
        
        let newWeights = setData.map { $0.weight }
        
        let rest = setData.map { $0.rest }
        
        if setData != exercise.recentSetData.setData {
            exercise.reps.append(newReps)
            exercise.weights.append(newWeights)
            exercise.rest.append(rest)
            exercise.updateDates.append(Date())
        }
        
        exercise.modified = Date()
        
        try? context.save()
    }
    
    private func Delete() {
        context.delete(exercise)
        try? context.save()
        dismiss()
    }
    
    private func EquipmentSelector(selectedEquipment: Binding<WorkoutEquipment?>) -> some View {
        Picker("Equipment", selection: $selectedEquipment) {
            Label("No Equipment", systemImage: "circle.badge.xmark").tag(nil as WorkoutEquipment?)
            ForEach(EquipmentCategory.allCases, id: \.self) { category in
                Section(header: Text(category.rawValue)) {
                    ForEach(WorkoutEquipment.allCases.filter { $0.category == category }) { equipment in
                        Label(equipment.rawValue, systemImage: equipment.imageName).tag(equipment)
                    }
                }
            }
        }
    }
    
    private func MuscleSelector(selectedMuscle: Binding<Muscle?>) -> some View {
        Menu {
            Section {
                MuscleSelect(muscle: nil, selectedMuscle: selectedMuscle)
                MuscleMenu(
                    muscles: Muscle.allCases.filter { $0.general == .general },
                    title: "Groups",
                    selectedMuscle: selectedMuscle
                )
            } header: {
                Text("General Options")
            }
            
            Section {
                MuscleMenu(muscles: Muscle.allCases.filter { $0.general == .chest }, title: "Chest", selectedMuscle: selectedMuscle)
                MuscleMenu(muscles: Muscle.allCases.filter { $0.general == .back }, title: "Back", selectedMuscle: selectedMuscle)
                MuscleMenu(muscles: Muscle.allCases.filter { $0.general == .legs }, title: "Legs", selectedMuscle: selectedMuscle)
                MuscleMenu(muscles: Muscle.allCases.filter { $0.general == .shoulders }, title: "Shoulders", selectedMuscle: selectedMuscle)
                MuscleMenu(muscles: Muscle.allCases.filter { $0.general == .biceps }, title: "Biceps", selectedMuscle: selectedMuscle)
                MuscleMenu(muscles: Muscle.allCases.filter { $0.general == .triceps }, title: "Triceps", selectedMuscle: selectedMuscle)
                MuscleMenu(muscles: Muscle.allCases.filter { $0.general == .core }, title: "Core", selectedMuscle: selectedMuscle)
            } header: {
                Text("Specific Options")
            }
        } label: {
            Label(
                selectedMuscle.wrappedValue?.rawValue.capitalized ?? "Muscle",
                systemImage: "scope"
            )
            .padding()
        }
    }
    
    private func MuscleMenu(muscles: [Muscle], title: String, selectedMuscle: Binding<Muscle?>) -> some View {
        Menu {
            ForEach(muscles, id: \.self) { muscle in
                MuscleSelect(muscle: muscle, selectedMuscle: selectedMuscle)
            }
        } label: {
            Text(title)
        }
    }
    
    private func MuscleSelect(muscle: Muscle?, selectedMuscle: Binding<Muscle?>) -> some View {
        Button {
            selectedMuscle.wrappedValue = muscle
        } label: {
            if let muscle {
                Text(muscle.rawValue.capitalized)
            } else {
                Text("None")
            }
        }
    }

    
}
