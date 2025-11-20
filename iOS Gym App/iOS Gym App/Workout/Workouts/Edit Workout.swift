import SwiftUI
import SwiftData

struct EditWorkoutView: View {
    
    @State var selectedExercises: [Exercise]
    @State var selectedWorkout: Workout
    @State private var showRename: Bool = false
    @State private var showAddSheet: Bool = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            List {
                HStack {
                    ReusedViews.Labels.MediumIconSize(color: selectedWorkout.color)
                    VStack(alignment: .leading) {
                        ReusedViews.Labels.SingleCardTitle(title: selectedWorkout.name, modified: selectedWorkout.modified)
                        HStack {
                            ReusedViews.Buttons.RenameButtonAlert(type: .workout, oldName: $selectedWorkout.name)
                            ReusedViews.Buttons.DeleteButtonConfirmation(type: .workout, deleteAction: Delete)
                        }
                    }
                }.padding(.bottom)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                SelectedExerciseList()
                WorkoutSplitsList()
            }
            .sheet(isPresented: $showAddSheet) {
                ReusedViews.WorkoutViews.WorkoutControls(saveAction: Save, newExercises: selectedExercises, showAddSheet: $showAddSheet, oldExercises: $selectedExercises)
            }
        }
    }
    
    private func SelectedExerciseList() -> some View {
        Section {
            ForEach(selectedExercises, id: \.self) { exercise in
                NavigationLink {
                    EditExerciseView(exercise: exercise, setData: exercise.recentSetData.setData, selectedMuscle: exercise.muscle, selectedEquipment: exercise.workoutEquipment)
                } label: {
                    ReusedViews.ExerciseViews.ExerciseListPreview(exercise: exercise)
                }
            }
        } header: {
            ReusedViews.Buttons.EditHeaderButton(toggleEdit: $showAddSheet, type: .workout, items: selectedExercises)
        }
    }
    
    private func WorkoutSplitsList() -> some View {
        Section {
            if let split = selectedWorkout.split {
                NavigationLink {
                    EditSplitView(selectedSplit: split, selectedWorkouts: split.workouts ?? [])
                } label: {
                    ReusedViews.SplitViews.ListPreview(split: split)
                }
            } else {
                Text("Not in a split.")
            }
        } header: {
            Text("Split")
        }
    }
    
    private func Save() {
        selectedWorkout.exercises = selectedExercises
        selectedWorkout.modified = Date()
        try? context.save()
    }
    
    private func Delete() {
        context.delete(selectedWorkout)
        try? context.save()
        dismiss()
    }
    
}
