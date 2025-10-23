import SwiftUI
import SwiftData

struct EditExerciseView: View {
    
    @State var exercise: Exercise
    
    @State var name: String
    
    @State private var showAddSet: Bool = false
    @State var setData: [SetEntry]
    @State var selectedMuscle: (any Muscle)?
    @State var selectedEquipment: WorkoutEquipment?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            ExerciseOptionsView(name: $name, showAddSet: $showAddSet, setData: $setData, selectedMuscle: $selectedMuscle, selectedEquipment: $selectedEquipment)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        SaveExercise()
                        dismiss()
                    } label: {
                        Label("Save", systemImage: "checkmark")
                    }
                }
                ToolbarItem(placement: .secondaryAction) {
                    Section {
                        Button {
                            
                        } label: {
                            Label("Rename", systemImage: "pencil")
                        }
                        Button {
                            
                        } label: {
                            Label("Add Set", systemImage: "plus")
                        }
                    }
                    Section {
                        EquipmentPicker()
                        TagSelector()
                    }
                    Button(role: .destructive) {
                        
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
        }
    }
    
    private func SaveExercise() {
        
        let newReps = setData.map { $0.reps }
        
        let newWeights = setData.map { $0.weight }
        
        let rest = setData.map { $0.rest }
        
        if setData != exercise.setData.last {
            exercise.reps.append(newReps)
            exercise.weights.append(newWeights)
            exercise.rest.append(rest)
            exercise.updateDates.append(Date())
        }
        
        exercise.name = name
        exercise.muscleWorked = selectedMuscle?.rawValue ?? ""
        exercise.equipment = selectedEquipment?.rawValue
        
        try? context.save()
    }
    
    private func EquipmentPicker() -> some View {
        Picker("Equipment", selection: $selectedEquipment) {
            ForEach(WorkoutEquipment.allCases, id: \.self) { equipment in
                Label(equipment.rawValue, systemImage: equipment.imageName).tag(equipment)
            }
        }.pickerStyle(.menu)
    }
    
    private func TagSelector() -> some View {
        Menu {
            Section {
                Button {
                    selectedMuscle = nil
                } label: {
                    Text("No Tag")
                }
            }
            Section {
                
            } header: {
                Text("General")
            }
            Section {
                MusclePicker(for: BackMuscle.self, headerText: MuscleGroup.back.rawValue)
                MusclePicker(for: BicepMuscle.self, headerText: MuscleGroup.biceps.rawValue)
                MusclePicker(for: ChestMuscle.self, headerText: MuscleGroup.chest.rawValue)
                MusclePicker(for: CoreMuscle.self, headerText: MuscleGroup.core.rawValue)
                MusclePicker(for: LegMuscle.self, headerText: MuscleGroup.legs.rawValue)
                MusclePicker(for: ShoulderMuscle.self, headerText: MuscleGroup.shoulders.rawValue)
                MusclePicker(for: TricepMuscle.self, headerText: MuscleGroup.triceps.rawValue)
            } header: {
                Text("Specific Muscles")
            }
        } label: {
            CustomLabelView(text: "Muscle Tag", image: "tag")
        }
    }
    
    private func MusclePicker<T: Muscle>(for groupType: T.Type, headerText: String) -> some View {
        Menu {
            ForEach(Array(T.allCases), id: \.self) { (muscle: T) in
                SelectButton(muscle: muscle)
            }
        } label: {
            Text(headerText)
        }
    }
    
    private func SelectButton(muscle: any Muscle) -> some View {
        Button {
            selectedMuscle = muscle
        } label: {
            Text(muscle.rawValue)
        }
    }

    
}
