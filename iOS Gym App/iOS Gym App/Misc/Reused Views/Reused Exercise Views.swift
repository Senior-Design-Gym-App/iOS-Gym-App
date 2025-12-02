import SwiftUI

extension ReusedViews {
    
    struct ExerciseViews {
        
        static func ExerciseListPreview(exercise: Exercise) -> some View {
            HStack {
                Labels.SmallIconSize(color: exercise.color)
                    .overlay(alignment: .center) {
                        Image(systemName: exercise.workoutEquipment?.imageName ?? Constants.defaultEquipmentIcon)
                            .foregroundStyle(Constants.iconColor)
                    }
                Labels.TypeListDescription(name: exercise.name, items: exercise.recentSetData.setData, type: .exercise, extend: true)
            }
        }
        
        static func HorizontalListPreview(exercise: Exercise) -> some View {
            VStack(alignment: .leading, spacing: 5) {
                ExerciseLabel(exercise: exercise)
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(width: Constants.mediumIconSize, height: Constants.mediumIconSize)
                Labels.TypeListDescription(name: exercise.name, items: exercise.recentSetData.setData, type: .exercise, extend: false)
            }
        }
        
        static func IndiidualSetInfo(setData: SetData, color: Color, index: Int) -> some View {
            HStack {
                if index < 50 {
                    Image(systemName: "\(index + 1).circle")
                        .foregroundStyle(color)
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(color)
                }
                Text("\(setData.weight, specifier: "%.1f") lbs, \(setData.reps) reps, \(setData.rest)s")
                Spacer()
            }
        }
        
        static func SetDataInfo(setData: [SetData], exericse: Exercise, showAddSheet: Binding<Bool>) -> some View {
            Section {
                ForEach(setData, id: \.self) { entry in
                    IndiidualSetInfo(setData: entry, color: exericse.color, index: setData.firstIndex(of: entry)!)
                        .id(entry.id)
                }
            } header: {
                Buttons.EditHeaderButton(toggleEdit: showAddSheet, type: .exercise, items: setData)
            }
        }
        
        static func ExerciseLabel(exercise: Exercise) -> some View {
            ZStack {
                Labels.MediumIconSize(color: exercise.color)
                Image(systemName: exercise.workoutEquipment?.imageName ?? Constants.defaultEquipmentIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.mediumIconSize - Constants.bigImagePadding, height: Constants.mediumIconSize - Constants.bigImagePadding)
                    .clipShape(.rect(cornerRadius: 10))
                    .foregroundStyle(Constants.iconColor)
            }
        }
        
        static func LargeExerciseLabel(exercise: Exercise) -> some View {
            ZStack {
                Labels.LargeIconSize(color: exercise.color)
                Image(systemName: exercise.workoutEquipment?.imageName ?? Constants.defaultEquipmentIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.largeIconSize - Constants.bigImagePadding, height: Constants.largeIconSize - Constants.bigImagePadding)
                    .clipShape(.rect(cornerRadius: 10))
                    .foregroundStyle(Constants.iconColor)
            }
        }
        
        struct ExerciseCustomization: View {
            
            @Binding var selectedMuscle: Muscle?
            @Binding var selectedEquipment: WorkoutEquipment?
            
            var body: some View {
                HStack {
                    MuscleSelector(selectedMuscle: $selectedMuscle)
                    EquipmentSelector(selectedEquipment: $selectedEquipment)
                        .buttonBorderShape(.circle)
                        .buttonStyle(.glass)
                }
            }
            
            private func EquipmentSelector(selectedEquipment: Binding<WorkoutEquipment?>) -> some View {
                Menu {
                    Picker("", selection: selectedEquipment) {
                        Text("None").tag(nil as WorkoutEquipment?)
                    }
                    EquipmentMenu(equipment: WorkoutEquipment.allCases.filter { $0.category == .bodyweight }, selectedEquipment: selectedEquipment, title: "Body Weight")
                    EquipmentMenu(equipment: WorkoutEquipment.allCases.filter { $0.category == .freeWeight }, selectedEquipment: selectedEquipment, title: "Free Weight")
                    EquipmentMenu(equipment: WorkoutEquipment.allCases.filter { $0.category == .machine }, selectedEquipment: selectedEquipment, title: "Machine")
                    EquipmentMenu(equipment: WorkoutEquipment.allCases.filter { $0.category == .cableAttachment }, selectedEquipment: selectedEquipment, title: "Cable")
                } label: {
                    Label("Equipment", systemImage: "scale.3d")
                        .labelStyle(.iconOnly)
                        .frame(width: Constants.tinyIconSIze, height: Constants.tinyIconSIze)
                }
            }
            
            private func EquipmentMenu(equipment: [WorkoutEquipment], selectedEquipment: Binding<WorkoutEquipment?>, title: String) -> some View {
                Menu {
                    Picker("", selection: selectedEquipment) {
                        ForEach(equipment, id: \.self) { equipment in
                            Label(equipment.rawValue, systemImage: equipment.imageName).tag(equipment)
                        }
                    }
                } label: {
                    Text(title)
                }
            }
            
            private func MuscleSelector(selectedMuscle: Binding<Muscle?>) -> some View {
                Menu {
                    Section {
                        Picker("", selection: selectedMuscle) {
                            Text("None").tag(nil as Muscle?)
                            Menu {
                                Picker("", selection: selectedMuscle) {
                                    ForEach(Muscle.allCases.filter { $0.general == .general }) { muscle in
                                        Text(muscle.rawValue).tag(muscle)
                                    }
                                }
                            } label: {
                                Text("Muscle Groups")
                            }
                        }
                    }
                    Section {
                        MuscleMenu(muscles: Muscle.allCases.filter { $0.general == .back }, title: "Back", selectedMuscle: selectedMuscle, color: MuscleGroup.back.colorPalette)
                        MuscleMenu(muscles: Muscle.allCases.filter { $0.general == .biceps }, title: "Biceps", selectedMuscle: selectedMuscle, color: MuscleGroup.biceps.colorPalette)
                        MuscleMenu(muscles: Muscle.allCases.filter { $0.general == .chest }, title: "Chest", selectedMuscle: selectedMuscle, color: MuscleGroup.chest.colorPalette)
                        MuscleMenu(muscles: Muscle.allCases.filter { $0.general == .core }, title: "Core", selectedMuscle: selectedMuscle, color: MuscleGroup.core.colorPalette)
                        MuscleMenu(muscles: Muscle.allCases.filter { $0.general == .forearm }, title: "Forearms", selectedMuscle: selectedMuscle, color: MuscleGroup.forearm.colorPalette)
                        MuscleMenu(muscles: Muscle.allCases.filter { $0.general == .legs }, title: "Legs", selectedMuscle: selectedMuscle, color: MuscleGroup.legs.colorPalette)
                        MuscleMenu(muscles: Muscle.allCases.filter { $0.general == .shoulders }, title: "Shoulders", selectedMuscle: selectedMuscle, color: MuscleGroup.shoulders.colorPalette)
                        MuscleMenu(muscles: Muscle.allCases.filter { $0.general == .triceps }, title: "Triceps", selectedMuscle: selectedMuscle, color: MuscleGroup.triceps.colorPalette)
                    } header: {
                        Text("Specific Options")
                    }
                } label: {
                    Label(selectedMuscle.wrappedValue?.rawValue.capitalized ?? "Muscle", systemImage: "scope")
                        .labelStyle(.iconOnly)
                        .frame(width: Constants.tinyIconSIze, height: Constants.tinyIconSIze)
                }
                .buttonBorderShape(.circle)
                .buttonStyle(.glass)
            }
            
            private func MuscleMenu(muscles: [Muscle], title: String, selectedMuscle: Binding<Muscle?>, color: Color) -> some View {
                Menu {
                    Picker("", selection: selectedMuscle) {
                        ForEach(muscles, id: \.self) { muscle in
                            Text(muscle.rawValue).tag(muscle)
                        }
                    }
                } label: {
                    Label(title, systemImage: "square.fill")
                        .tint(color)
                }
            }

        }
        
        struct SetControls: View {
            
            let exercise: Exercise
            let saveAction: () -> Void
            @State var newSetData: [SetData]
            @Binding var oldSetData: [SetData]
            @Binding var showAddSheet: Bool
            
            @State var restTime: Int
            @State var reps: Int
            @Environment(ProgressManager.self) private var hkm
            
            @State private var weightString: String = ""
            
            var body: some View {
                NavigationStack {
                    List {
                        Section {
                            ForEach(newSetData, id: \.self) { set in
                                IndiidualSetInfo(setData: set, color: exercise.color, index: newSetData.firstIndex(of: set)!)
                            }
                            .onMove { indices, newOffset in
                                newSetData.move(fromOffsets: indices, toOffset: newOffset)
                            }
                            .onDelete { indices in
                                newSetData.remove(atOffsets: indices)
                            }
                        }
                        Section {
                            SetOptions()
                        }
                    }
                    .environment(\.editMode, .constant(.active))
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            ReusedViews.Buttons.CancelButton(cancel: CancelOptions)
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            ReusedViews.Buttons.SaveButton(disabled: newSetData.isEmpty, save: SaveOptions)
                        }
                    }
                }
            }
            
            private func SetOptions() -> some View {
                Group {
                    TextField("Weight \(hkm.weightUnitString)", text: $weightString)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.decimalPad)
                    Stepper("Ideal Reps \(reps)", value: $reps, in: 0...40, step: 1)
                    Stepper("Rest \(formatSeconds(totalSeconds: restTime))", value: $restTime, in: 0...600, step: 5)
                    Button("Add Set", role: .confirm) {
                        let newData = SetData(set: 0, rest: restTime, reps: reps, weight: Double(weightString) ?? 0)
                        newSetData.append(newData)
                    }
                }
            }
            
            private func CancelOptions() {
                showAddSheet = false
            }
            
            private func SaveOptions() {
                oldSetData = newSetData
                saveAction()
                showAddSheet = false
            }
            
            private func formatSeconds(totalSeconds: Int) -> String {
                let minutes = totalSeconds / 60
                let seconds = totalSeconds % 60
                return String(format: "%d:%02d", minutes, seconds)
            }
            
        }
        
    }
    
}
