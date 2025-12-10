import SwiftUI
import SwiftData

struct EditExerciseView: View {
    
    @State var exercise: Exercise
    @State var setData: [SetData]
    @State var selectedMuscle: Muscle?
    @State var selectedEquipment: WorkoutEquipment?
    @State var manualOneRepMax: [WeightEntry]
    
    @State private var showRename: Bool = false
    @State private var showMaxSheet: Bool = false
    @State private var showAddSheet: Bool = false
    @State private var showDeleteConfirmation: Bool = false
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
                        ReusedViews.ExerciseViews.LargeExerciseLabel(exercise: exercise)
                            .offset(y: Constants.largeOffset)
                        HStack {
                            ReusedViews.ExerciseViews.ExerciseCustomization(selectedMuscle: $selectedMuscle, selectedEquipment: $selectedEquipment)
                            ReusedViews.Buttons.RenameButtonAlert(type: .exercise, oldName: $exercise.name)
                            ReusedViews.Buttons.DeleteButtonConfirmation(type: .exercise, deleteAction: Delete)
                        }
                    }
                    Spacer()
                }.padding(.bottom)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                ReusedViews.ExerciseViews.SetDataInfo(setData: setData, exericse: exercise, showAddSheet: $showAddSheet)
                ReusedViews.ExerciseViews.OneRepMaxInfo(data: manualOneRepMax, exercise: exercise, showMaxSheet: $showMaxSheet, label: hkm.weightUnitString)
                ExerciseWorkouts()
            }
            .onChange(of: selectedMuscle) {
                exercise.muscleWorked = selectedMuscle?.rawValue
            }
            .onChange(of: selectedEquipment) {
                exercise.equipment = selectedEquipment?.rawValue
            }
            .sheet(isPresented: $showAddSheet) {
                ReusedViews.ExerciseViews.SetControls(exercise: exercise, saveAction: SaveExercise, newSetData: setData, oldSetData: $setData, showAddSheet: $showAddSheet, restTime: defaultRestTime, reps: defaultRepCount)
            }
            .sheet(isPresented: $showMaxSheet) {
                ReusedViews.ExerciseViews.ManualOneRepMaxControls(saveAction: SaveExercise, oldOneRepMaxData: $manualOneRepMax, newOneRepMaxData: manualOneRepMax, showMaxSheet: $showMaxSheet)
            }
            .navigationTitle(exercise.name)
            .navigationSubtitle("Edited \(DateHandler().RelativeTime(from: exercise.modified))")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func ExerciseWorkouts() -> some View {
        Section {
            ForEach(exercise.workouts ?? [], id: \.self) { workout in
                NavigationLink {
                    EditWorkoutView(selectedWorkout: workout)
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
        
        exercise.manualOneRepMaxDates = manualOneRepMax.map { $0.date }
        exercise.manualOneRepMaxWeights = manualOneRepMax.map { $0.value }
        
        if (setData) != (exercise.recentSetData.setData) {
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
    
}
