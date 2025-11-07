import SwiftUI

extension ReusedViews {
    
    struct ExerciseViews {
        
        static func ExerciseListPreview(exercise: Exercise) -> some View {
            HStack {
                Labels.SmallIconSize(color: exercise.color)
                    .overlay(alignment: .center) {
                        Image(systemName: exercise.workoutEquipment?.imageName ?? "dumbbell")
                            .foregroundStyle(Constants.iconColor)
                    }
                Labels.TypeListDescription(name: exercise.name, items: exercise.recentSetData.setData, type: .exercise)
            }
        }
        
        static func SingleExerciseCard(exercise: Exercise) -> some View {
            HStack {
                Spacer()
                ZStack {
                    Labels.LargeIconSize(color: exercise.color)
                    Image(systemName: exercise.workoutEquipment?.imageName ?? Constants.defaultEquipmentIcon)
                        .resizable()
                        .scaledToFit()
                        .padding(Constants.bigImagePadding)
                        .clipShape(.rect(cornerRadius: 10))
                        .foregroundStyle(Constants.iconColor)
                }
                .aspectRatio(1.0, contentMode: .fit)
                .frame(width: Constants.largeIconSize, height: Constants.largeIconSize)
                Spacer()
            }
        }
        
        static func HorizontalListPreview(exercise: Exercise) -> some View {
            VStack(alignment: .leading, spacing: 5) {
                ZStack {
//                    ReusedViews.Labels.MediumIconSize(color: exercise.id.hashValue.description)
                    ReusedViews.Labels.MediumIconSize(color: exercise.color)
                    Image(systemName: exercise.workoutEquipment?.imageName ?? Constants.defaultEquipmentIcon)
                        .resizable()
                        .scaledToFit()
                        .padding(Constants.bigImagePadding)
                        .clipShape(.rect(cornerRadius: 10))
                        .foregroundStyle(Constants.iconColor)
                }
                .aspectRatio(1.0, contentMode: .fit)
                .frame(width: Constants.mediumIconSize, height: Constants.mediumIconSize)
                ReusedViews.Labels.MediumTextLabel(title: exercise.name)
            }
        }
        
        static func IndiidualSetInfo(setData: SetData, colorKey: String, index: Int) -> some View {
            HStack {
                if index < 50 {
                    Image(systemName: "\(index + 1).circle")
                        .foregroundStyle(ColorManager.shared.GetColor(key: colorKey))
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(ColorManager.shared.GetColor(key: colorKey))
                }
                Text("\(setData.weight, specifier: "%.1f") lbs, \(setData.reps) reps, \(setData.rest)s")
                Spacer()
            }
        }
        
        static func SetDataInfo(setData: [SetData], exericse: Exercise, showAddSheet: Binding<Bool>) -> some View {
            Section {
                ForEach(setData, id: \.self) { entry in
                    IndiidualSetInfo(setData: entry, colorKey: exericse.id.hashValue.description, index: setData.firstIndex(of: entry)!)
                }
            } header: {
                Buttons.EditHeaderButton(toggleEdit: showAddSheet, type: .exercise, items: setData)
            }
        }
        
        struct EquipmentPickerView: UIViewRepresentable {
            @Binding var selectedEquipment: WorkoutEquipment?
            
            func makeUIView(context: Context) -> EquipmentPicker {
                let picker = EquipmentPicker(selectedEquipment: selectedEquipment)
                picker.onSelectionChanged = { equipment in
                    selectedEquipment = equipment
                }
                return picker
            }
            
            func updateUIView(_ uiView: EquipmentPicker, context: Context) {
                uiView.selectedEquipment = selectedEquipment
            }
        }
        
        static func ListHorizontalButtons(selectedEquipment: Binding<WorkoutEquipment?>, selectedMuscle: Binding<Muscle?>) -> some View {
            HStack {
                Spacer()
                EquipmentPickerView(selectedEquipment: selectedEquipment)
                    .padding(.trailing)
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.borderless)
                //                    .background(.regularMaterial, in: Capsule())
                    .frame(maxWidth: .infinity)
                MuscleMenuButton(selectedMuscle: selectedMuscle)
                    .padding(.leading)
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.borderedProminent)
                //                    .background(.regularMaterial, in: Capsule())
                    .frame(maxWidth: .infinity)
                Spacer()
            }
        }
        
        struct SetControls: View {
            
            let exercise: Exercise
            let saveAction: () -> Void
            @State var newSetData: [SetData]
            @Binding var oldSetData: [SetData]
            @Binding var showAddSheet: Bool
            
            @State private var restTime: Int = 60
            @State private var reps: Int = 8
            
            @State private var weightString: String = ""
            @AppStorage("useLBs") private var useLBs = true
            
            var body: some View {
                NavigationStack {
                    List {
                        Section {
                            ForEach(newSetData, id: \.self) { set in
                                IndiidualSetInfo(setData: set, colorKey: exercise.id.hashValue.description, index: newSetData.firstIndex(of: set)!)
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
                    TextField("Weight (\(useLBs ? "lbs" : "kg"))", text: $weightString)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.decimalPad)
                    Stepper("Ideal Reps \(reps)", value: $reps, in: 0...40, step: 1)
                    Stepper("Rest \(formatSeconds(totalSeconds: restTime))", value: $restTime, in: 0...600, step: 5)
                    Button("Add Set", role: .confirm) {
                        let newData = SetData(rest: restTime, reps: reps, weight: Double(weightString) ?? 0)
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
