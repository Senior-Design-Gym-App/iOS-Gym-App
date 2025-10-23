import SwiftUI

struct ExerciseOptionsView: View {
    
    @Binding var name: String
    @Binding var showAddSet: Bool
    @Binding var setData: [SetEntry]
    @Binding var selectedMuscle: (any Muscle)?
    @Binding var selectedEquipment: WorkoutEquipment?
    
    @State private var showRename = false
    @State private var repString: String = ""
    @State private var restString: String = ""
    @State private var weightString: String = ""
    @AppStorage("useLBs") private var useLBs = true
    
    var body: some View {
        GlassEffectContainer {
            List {
                Section {
                    WorkoutHeader()
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                }
                SetsView()
            }
            .alert("Edit Workout Name", isPresented: $showRename) {
                TextField("Enter new name", text: $name)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                Button("Ok", role: .confirm) {
                }
            }
            .alert("Set \(setData.count + 1) Data", isPresented: $showAddSet) {
                TextField("Weight (\(useLBs ? "lbs" : "kg"))", text: $weightString)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.decimalPad)
                TextField("Ideal Reps", text: $repString)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.numberPad)
                TextField("Rest (s))", text: $restString)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.numberPad)
                Button("Cancel", role: .cancel) {
                    repString = ""
                    weightString = ""
                    restString = ""
                }
                Button("Ok", role: .confirm) {
                    
                    let newData = SetEntry(rest: Int(restString) ?? 0, reps: Int(repString) ?? 0, weight: Double(weightString) ?? 0.0)
                    
                    setData.append(newData)
                    
                }
            }
        }
    }
    
    private func WorkoutHeader() -> some View {
        VStack {
            Image(systemName: selectedEquipment?.imageName ?? "dumbbell")
                .resizable()
                .scaledToFill()
                .padding(.horizontal, Constants.headerPadding)
            ReusedViews.HeaderTitle(title: name)
            ReusedViews.HeaderSubtitle(subtitle: "\(selectedMuscle?.rawValue ?? "No Muscle Selected") | \(selectedEquipment?.rawValue ?? "No Equipment Selected")")
            DayRename()
        }.frame(maxWidth: .infinity)
    }
    
    private func SetsView() -> some View {
        Section {
            ForEach($setData, id: \.self) { data in
                VStack(alignment: .leading) {
                    Text("Weight: \(data.weight.wrappedValue)kg")
                    Text("Reps: \(data.reps.wrappedValue)")
                    Text("Rest: \(data.rest.wrappedValue)s")
                }
            }
            .onDelete { indicies in
                $setData.wrappedValue.remove(atOffsets: indicies)
            }
            .onMove { indices, newOffset in
                $setData.wrappedValue.move(fromOffsets: indices, toOffset: newOffset)
            }
        } header: {
            SetControlHeader()
        }
    }
    
    private func DayRename() -> some View {
        Button {
            showRename = true
        } label: {
            CustomLabelView(text: "Rename", image: "pencil")
        }.buttonStyle(.glass)
    }
    
    
    private func SetControlHeader() -> some View {
        HStack {
            Text("Sets")
            Spacer()
            Button {
                showAddSet = true
            } label: {
                Label("Add Set", systemImage: "plus")
            }
        }
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
        .buttonStyle(.glass)
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
    
    private func SelectEquipment() -> some View {
        Menu {
            Button {
                selectedEquipment = nil
            } label: {
                Label("No Equipment", systemImage: "xmark.circle")
            }
            ForEach(WorkoutEquipment.allCases, id: \.self) { option in
                Button {
                    selectedEquipment = option
                } label: {
                    Label(option.rawValue, systemImage: option.imageName)
                }
            }
        } label: {
            CustomLabelView(text: "Equipment", image: "gearshape")
        }
        .buttonStyle(.glass)
    }
    
}
