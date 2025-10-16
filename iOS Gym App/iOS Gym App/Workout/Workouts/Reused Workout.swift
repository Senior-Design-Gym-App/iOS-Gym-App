import SwiftUI

struct WorkoutOptionsView: View {
    
    @Binding var name: String
    @Binding var showAddSet: Bool
    @Binding var setData: [SetEntry]
    @Binding var selectedMuscle: (any Muscle)?

    @State private var showRename = false
    @State private var testFloat: Float = 0
    @State private var repString: String = ""
    @State private var weightString: String = ""
    
    var body: some View {
        List {
            GlassEffectContainer {
                Section {
                    WorkoutHeader()
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                }
                SetsView()
            }
        }
        .alert("Edit Workout Name", isPresented: $showRename) {
            TextField("Enter new name", text: $name)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            Button("Ok", role: .confirm) {
            }
        }
        .alert("Add Set", isPresented: $showAddSet) {
            TextField("Weight for set \(setData.count + 1)", text: $weightString)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .keyboardType(.decimalPad)
            TextField("Reps for set \(setData.count + 1)", text: $repString)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .keyboardType(.numberPad)
            Button("Cancel", role: .cancel) {
                repString = ""
                weightString = ""
            }
            Button("Ok", role: .confirm) {
                
                let newData = SetEntry(reps: Int(repString) ?? 0, weight: Double(weightString) ?? 0.0)
                
                setData.append(newData)
                
            }
        }
    }
    
    private func DayRename() -> some View {
        Button {
            showRename = true
        } label: {
            CustomLabelView(text: "Rename Day", image: "pencil")
        }.buttonStyle(.glass)
    }
    
    private func TagSelector() -> some View {
        Menu {
            Button {
                selectedMuscle = nil
            } label: {
                Text("Remove Tag")
            }
//            ForEach(Muscle, id: \.self) { muscle in
//                
//            }
//            ForEach(WorkoutSplitTag.allCases, id: \.self) { tag in
//                Button {
//                    selectedMuscle = tag
//                } label: {
//                    Text(tag.rawValue).tag(tag)
//                }
//            }
        } label: {
            CustomLabelView(text: "Muscle Tag", image: "tag")
        }
        .buttonStyle(.glass)
    }
    
    private func SetsView() -> some View {
        Section {
            ForEach($setData, id: \.self) { data in
                VStack(alignment: .leading) {
                    Text("Weight: \(data.weight.wrappedValue)kg")
                    Text("Reps: \(data.reps.wrappedValue)")
//                    Text("Set \(index + 1)")
//                    Stepper(value: reps, in: 1...100) {
//                        //                        Text("\(reps.wrappedValue
//                    }
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
    
    private func WorkoutHeader() -> some View {
        VStack {
            Image(systemName: "dumbbell")
                .resizable()
                .scaledToFill()
                .padding(.horizontal, 70)
            Text(name)
                .font(.title)
                .bold()
            Text(selectedMuscle?.rawValue ?? "No Muscle Selected")
                .font(.subheadline)
            HStack {
                TagSelector()
                DayRename()
            }
        }.frame(maxWidth: .infinity)
    }
    
}
