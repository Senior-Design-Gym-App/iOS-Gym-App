import SwiftUI
import SwiftData

struct EditWorkoutView: View {
    
    @State var selectedWorkout: Workout
    @State private var showRename: Bool = false
    @State private var showAddSheet: Bool = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            List {
                HStack {
                    Spacer()
                    VStack {
                        ReusedViews.Labels.LargeIconSize(color: selectedWorkout.color)
                            .offset(y: Constants.largeOffset)
                        HStack {
                            ReusedViews.Buttons.RenameButtonAlert(type: .workout, oldName: $selectedWorkout.name)
                            ReusedViews.Buttons.DeleteButtonConfirmation(type: .workout, deleteAction: Delete)
                        }
                    }
                    Spacer()
                }.padding(.bottom)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                SelectedExerciseList()
                WorkoutSplitsList()
            }
            .sheet(isPresented: $showAddSheet) {
                ReusedViews.WorkoutViews.WorkoutControls(newExercises: selectedWorkout.sortedExercises, showAddSheet: $showAddSheet, workout: $selectedWorkout)
            }
            .navigationTitle(selectedWorkout.name)
            .navigationSubtitle("Edited \(DateHandler().RelativeTime(from: selectedWorkout.modified))")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func SelectedExerciseList() -> some View {
        Section {
            ForEach(selectedWorkout.sortedExercises, id: \.self) { exercise in
                NavigationLink {
                    EditExerciseView(exercise: exercise, setData: exercise.recentSetData.setData, selectedMuscle: exercise.muscle, selectedEquipment: exercise.workoutEquipment)
                } label: {
                    ReusedViews.ExerciseViews.ExerciseListPreview(exercise: exercise)
                }
            }
        } header: {
            ReusedViews.Buttons.EditHeaderButton(toggleEdit: $showAddSheet, type: .workout, items: selectedWorkout.sortedExercises)
        }
    }
    
    private func WorkoutSplitsList() -> some View {
        Section {
            if let split = selectedWorkout.split {
                NavigationLink {
                    EditSplitView(selectedSplit: split)
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
    
    private func Delete() {
        context.delete(selectedWorkout)
        try? context.save()
        dismiss()
    }
    
}
