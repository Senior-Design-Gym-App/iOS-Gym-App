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
        
        if Set(setData) != Set(exercise.recentSetData.setData) {
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
