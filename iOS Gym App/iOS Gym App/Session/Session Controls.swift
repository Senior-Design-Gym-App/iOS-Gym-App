import SwiftUI
import SwiftData

struct SessionSetControlView: View {
    
    let sessionName: String
    let endAction: () -> Void
    let deleteAction: () -> Void
    let renameAction: (String) -> Void
    let sessionManager: SessionManager
    
    @AppStorage("timerType") private var timerType: TimerType = .liveActivities
    @AppStorage("weightChangeType") private var weightChangeType: WeightChangeType = .ten
    @AppStorage("autoAdjustWeights") private var autoAdjustWeights: Bool = true
    @AppStorage("show25Option") private var show25Option: Bool = false
    
    @State private var newName: String = ""
    @Query private var allExercises: [Exercise]
    @State private var showDelete: Bool = false
    @State private var showRenameAlert: Bool = false
    
    var suggestedExercises: [Exercise] {
        
        let completedMuscles = sessionManager.completedExercises.compactMap { $0.exercise?.muscleGroup }
        let upcomingMuscles  = sessionManager.upcomingExercises.compactMap { $0.exercise.muscleGroup }
        
        let allMuscles = Set(completedMuscles + upcomingMuscles)

        return allExercises.filter { exercise in
            guard let group = exercise.muscleGroup else { return false }
            return !invalidExercises.contains(exercise) && allMuscles.contains(group)
        }
    }
    
    var invalidExercises: Set<Exercise> {
        let completed = sessionManager.completedExercises.compactMap(\.exercise)
        let upcoming = sessionManager.upcomingExercises.compactMap(\.exercise)
        if let exercise = sessionManager.currentExercise?.exercise {
            return Set(completed + upcoming + [exercise])
        } else {
            return Set(completed + upcoming)
        }
    }
    
    var body: some View {
        @Bindable var sessionManager = sessionManager
        VStack {
            Divider()
                .padding(.top)
            StepControl(reps: $sessionManager.reps, weight: $sessionManager.weight)
            BottomControls()
                .padding(.bottom)
        }
        .alert("Rename Session", isPresented: $showRenameAlert) {
            TextField("New Name", text: $newName)
            Button(role: .confirm) {
                renameAction(newName)
                newName = ""
            }
            Button(role: .cancel) {
                newName = ""
            }
        }
        .alert("Are you sure you want to delete this session?", isPresented: $showDelete) {
            Button("Delete", role: .destructive) {
                deleteAction()
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private func BottomControls() -> some View {
        HStack {
            WeightChangeSelector()
            Menu {
                Section {
                    Button(role: .destructive) {
                        showDelete = true
                    } label: {
                        Label {
                            Text("Delete")
                        } icon: {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                                .tint(.red)
                        }
                    }
                    Button(role: .confirm) {
                        endAction()
                    } label: {
                        Label("End", systemImage: "checkmark.square")
                        Text("Ends current set and workout.")
                    }
                    Button {
                        showRenameAlert = true
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                } header: {
                    Label("\(sessionName) Options", systemImage: Constants.sessionIcon)
                }
                Menu {
                    TimerMenu()
                    Toggle(isOn: $autoAdjustWeights) {
                        Label("Auto-Adjust Weights", systemImage: "lightbulb")
                    }
                    Toggle(isOn: $show25Option) {
                        Label("Show 25 Weight Step", systemImage: "stairs")
                    }
                } label: {
                    Label("Prefrences", systemImage: "paintpalette")
                }
                Section {
                    QueueExercise(exercises: allExercises, label: "All (A-Z)")
                    QueueExercise(exercises: suggestedExercises, label: "Suggested")
                } header: {
                    Label("Add Exercise to Queue", systemImage: "text.badge.plus")
                }
            } label: {
                Label("Options", systemImage: "gearshape")
                    .labelStyle(.iconOnly)
                    .font(.title)
            }
        }.frame(idealWidth: .infinity ,maxWidth: .infinity)
    }
    
    private func StepControl(reps: Binding<Int>, weight: Binding<Double>) -> some View {
        VStack {
            Stepper("\(reps.wrappedValue) Rep\(reps.wrappedValue == 1 ? "" : "s")", value: reps)
            Stepper(value: weight, step: weightChangeType.weightChange) {
                Text("\(weight.wrappedValue, specifier: "%.1f") lbs")
            }
        }
    }
    
    private func WeightChangeSelector() -> some View {
        Picker("Weight Step Size", selection: $weightChangeType) {
            ForEach(WeightChangeType.allCases, id: \.self) { type in
                if !(type == .twentyFive && !show25Option) {
                    Text(type.rawValue).tag(type)
                }
            }
        }.pickerStyle(.segmented)
    }
    
    private func TimerMenu() -> some View {
        Menu {
            ReusedViews.Pickers.TimerTypePicker(type: $timerType)
        } label: {
            Label("Rest Timer Type", systemImage: "bell")
        }.onChange(of: timerType) {
            if timerType == .none {
                sessionManager.FinishTimer()
            }
        }
    }
    
    private func QueueExercise(exercises: [Exercise], label: String) -> some View {
        Menu {
            ForEach(exercises.sorted { $0.name > $1.name }, id: \.self) { exercise in
                Button {
                    sessionManager.QueueExercise(exercise: exercise)
                } label: {
                    Label(exercise.name, systemImage: exercise.workoutEquipment?.imageName ?? Constants.exerciseIcon)
                    Text("\(exercise.recentSetData.setData.count) Set\(exercise.recentSetData.setData.count == 1 ? "" : "s")")
                }.disabled(invalidExercises.contains(exercise))
            }
        } label: {
            Text(label)
        }
    }
    
}
