import SwiftUI
import SwiftData

struct CreateWorkoutView: View {
    
    let allExercises: [Exercise]
    @State private var showAddSheet: Bool = false
    @State private var selectedExercises: [Exercise] = []
    @State private var newWorkout = Workout(name: "New Workout", exercises: [])
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            List {
                HStack {
                    ReusedViews.Labels.MediumIconSize(color: newWorkout.color)
                    VStack(alignment: .leading) {
                        ReusedViews.Labels.SingleCardTitle(title: newWorkout.name, modified: newWorkout.modified)
                        HStack {
                            ReusedViews.Buttons.RenameButtonAlert(type: .workout, oldName: $newWorkout.name)
                        }
                    }
                }.padding(.bottom)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                SelectedExerciseList()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    ReusedViews.Buttons.CancelButton(cancel: Dismiss)
                }
                ToolbarItem(placement: .confirmationAction) {
                    ReusedViews.Buttons.SaveButton(disabled: newWorkout.name.isEmpty, save: Save)
                }
            }
            .sheet(isPresented: $showAddSheet) {
                ReusedViews.WorkoutViews.WorkoutControls(saveAction: {}, newExercises: selectedExercises, showAddSheet: $showAddSheet, oldExercises: $selectedExercises)
            }
        }
    }
    
    private func SelectedExerciseList() -> some View {
        Section {
            ForEach(selectedExercises, id: \.self) { exercise in
                ReusedViews.ExerciseViews.ExerciseListPreview(exercise: exercise)
            }
        } header: {
            ReusedViews.Buttons.EditHeaderButton(toggleEdit: $showAddSheet, type: .workout, items: selectedExercises)
        }
    }
    
    private func Save() {
        newWorkout.exercises = selectedExercises
        context.insert(newWorkout)
        try? context.save()
        dismiss()
    }
    
    private func Dismiss() {
        dismiss()
    }
    
}
