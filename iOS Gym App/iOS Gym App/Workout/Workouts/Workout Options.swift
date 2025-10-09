import SwiftUI

struct WorkoutOptionsView: View {
    
    @Binding var lastTouchedIndex: Int
    @Binding var lastTouchedTextField: String
    @Binding var sets: Int
    @Binding var reps: [Int]
    @Binding var rest: Double
    @Binding var weights: [String]
    @Binding var exerciseName: String
    @Binding var muscleWorked: String
    @Binding var sameRepsForAllSets: Bool
    @Binding var sameWeightForAllSets: Bool
    let lastModified: Date?
    
    private let bicepMuscles: [String] = ["Long Head", "Short Head"]
    private let legMuscles: [String] = ["Quads", "Hamstrings", "Calves", "Glutes"]
    private let tricepMuscles: [String] = ["Long Head", "Lateral Head", "Medial Head"]
    private let shoulderMuscles: [String] = ["Front Delts", "Rear Delts", "Side Delts"]
    private let backMuscles: [String] = ["Lats", "Traps", "Rhomboids", "Serratus", "Levator"]
    private let muscleGroups: [String] = ["Chest", "Back", "Biiceps", "Triceps","Shoulders", "Legs", "Forearms" ,"Core"]
    
    var body: some View {
        Section {
            WorkoutNameTextfield(type: "Exercise Name")
            SetsStepper()
            RepInput()
            SameWeightToggle()
            WeightInput(lbs: false)
        } header: {
            Label("Required Information", systemImage: "pencil.line")
        } footer: {
            if let lastModified {
                Text("Last modified \(lastModified)")
            }
        }
        Section {
            MusclesWorked()
            RestSlider(type: "Rest")
        } header: {
            Text("Optional Information")
        }
    }
    
    private func MusclesWorked() -> some View {
        HStack {
            TextField("Muscle Worked", text: $muscleWorked)
            Menu {
                Section {
                    ForEach(muscleGroups, id: \.self) { muscleGroup in
                        Button {
                            muscleWorked = muscleGroup
                        } label: {
                            Text(muscleGroup)
                        }
                    }
                } header: {
                    Text("Groups")
                }
                Section {
                    MenuLabel(group: backMuscles, groupName: "Back Muscles")
                    MenuLabel(group: bicepMuscles, groupName: "Bicep Muscles")
                    MenuLabel(group: tricepMuscles, groupName: "Tricep Muscles")
                    MenuLabel(group: shoulderMuscles, groupName: "Shoulder Muscles")
                    MenuLabel(group: legMuscles, groupName: "Legs Muscles")
                } header: {
                    Text("Muscles")
                }
            } label: {
                Image(systemName: "list.dash")
            }
        }
    }
    
    private func MenuLabel(group: [String], groupName: String) -> some View {
        Menu {
            ForEach(group, id: \.self) { muscle in
                Button {
                    muscleWorked = muscle
                } label: {
                    Text(muscle)
                }
            }
        } label: {
            Text(groupName)
        }
    }
    
    private func SetsStepper() -> some View {
        Stepper(value: $sets, in: 1...10) {
            Text("Number of Sets: \(sets)")
                .animation(.easeInOut, value: sets)
        }
    }
    
    private func RepInput() -> some View {
        VStack(alignment: .leading) {
            Toggle("Same Reps for All Sets", isOn: $sameRepsForAllSets)
            if sameRepsForAllSets {
                RepStepper(text: "Reps:", repsForSet: $reps[0])
            } else {
                ForEach(0..<sets, id: \.self) { index in
                    RepStepper(text: "Set \(index + 1) Reps:", repsForSet: $reps[index])
                }
            }
        }
    }
    
    private func RepStepper(text: String, repsForSet: Binding<Int>) -> some View {
        Stepper(value: repsForSet, in: 1...40) {
            Text("\(text): \(repsForSet.wrappedValue)")
                .animation(.easeInOut, value: repsForSet.wrappedValue)
        }
    }

    private func SameWeightToggle() -> some View {
        Toggle("Same Weight for All Sets", isOn: $sameWeightForAllSets)
    }

    private func WeightInput(lbs: Bool) -> some View {
        Group {
            if sameWeightForAllSets {
                TextField("Weight \(lbs ? "lbs" : "kg")", text: $weights[0])
                    .keyboardType(.decimalPad)
                    .simultaneousGesture(TapGesture().onEnded {
                        if weights[lastTouchedIndex].isEmpty {
                            weights[lastTouchedIndex] = lastTouchedTextField
                        }
                        lastTouchedIndex = 0
                        lastTouchedTextField = weights[0]
                        weights[0] = ""
                    })
            } else {
                ForEach(0..<sets, id: \.self) { index in
                    TextField("Weight for Set \(index + 1) \(lbs ? "lbs" : "kg")", text: $weights[index])
                        .keyboardType(.decimalPad)
                        .simultaneousGesture(TapGesture().onEnded {
                            if weights[lastTouchedIndex].isEmpty {
                                weights[lastTouchedIndex] = lastTouchedTextField
                            }
                            lastTouchedIndex = index
                            lastTouchedTextField = weights[index]
                            weights[index] = ""
                        })
                }
            }
        }
    }
    
    private func RestSlider(type: String) -> some View {
        HStack {
            Text("\(type): \(String(format: "%.0f", rest))")
            Slider(value: $rest, in: 0...180, step: 5)
        }
    }
    
    private func WorkoutNameTextfield(type: String) -> some View {
        TextField(type, text: $exerciseName)
    }

}
