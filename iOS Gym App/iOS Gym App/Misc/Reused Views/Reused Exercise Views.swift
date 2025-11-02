import SwiftUI

extension ReusedViews {
    
    struct ExerciseViews {
        
        static func ExerciseListPreview(exercise: Exercise) -> some View {
            HStack {
                Labels.SmallIconSize(key: exercise.id.hashValue.description)
                    .overlay(alignment: .center) {
                        Image(systemName: exercise.workoutEquipment?.imageName ?? "dumbbell")
                            .foregroundStyle(Constants.iconColor)
                    }
                Labels.ListDescription(name: exercise.name, items: exercise.setData.last ?? [], type: .exercise)
            }
        }
        
        static func SingleExerciseCard(exercise: Exercise) -> some View {
            HStack {
                Spacer()
                ZStack {
                    Labels.LargeIconSize(key: exercise.id.hashValue.description)
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
                    ReusedViews.Labels.MediumIconSize(key: exercise.id.hashValue.description)
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
        
        static func IndiidualSetInfo(setData: SetEntry, colorKey: String) -> some View {
            HStack {
                if setData.index < 50 {
                    Image(systemName: "\(setData.index + 1).circle")
                        .foregroundStyle(ColorManager.shared.GetColor(key: colorKey))
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(ColorManager.shared.GetColor(key: colorKey))
                }
                Text("\(setData.weight, specifier: "%.1f") lbs, \(setData.reps) reps, \(setData.rest)s")
                Spacer()
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
            @State var newSetData: [SetEntry]
            @Binding var oldSetData: [SetEntry]
            
            @State private var repString: String = ""
            @State private var restString: String = ""
            @State private var weightString: String = ""
            @State private var showAddSheet: Bool = false
            @AppStorage("useLBs") private var useLBs = true
                        
            var body: some View {
                Section {
                    ForEach(oldSetData, id: \.self) { data in
                        IndiidualSetInfo(setData: data, colorKey: exercise.id.hashValue.description)
                    }
                } header: {
                    Buttons.EditHeaderButton(toggleEdit: $showAddSheet, type: .exercise, items: oldSetData)
                }
                .sheet(isPresented: $showAddSheet) {
                    AddSheet()
                }
            }
            
            private func AddSheet() -> some View {
                NavigationStack {
                    List {
                        Section {
                            ForEach(newSetData, id: \.self) { set in
                                IndiidualSetInfo(setData: set, colorKey: exercise.id.hashValue.description)
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
                    TextField("Ideal Reps", text: $repString)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.numberPad)
                    TextField("Rest (s)", text: $restString)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.numberPad)
                        Button("Cancel", role: .cancel) {
                            repString = ""
                            weightString = ""
                            restString = ""
                        }
                        Button("Ok", role: .confirm) {
                            let newData = SetEntry(index: newSetData.count, rest: Int(restString) ?? 0, reps: Int(repString) ?? 0, weight: Double(weightString) ?? 0.0)
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
            
        }
        
    }
    
}
