import SwiftUI
import SwiftData

struct CreateWorkoutView: View {
    
    @State private var showAddSheet: Bool = false
    @State private var newWorkout = Workout(name: "New Workout", exercises: [])
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            List {
                HStack {
                    Spacer()
                    VStack {
                        ReusedViews.Labels.LargeIconSize(color: newWorkout.color)
                            .offset(y: Constants.largeOffset)
                        HStack {
                            ReusedViews.Buttons.RenameButtonAlert(type: .workout, oldName: $newWorkout.name)
                        }
                    }
                    Spacer()
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
                ReusedViews.WorkoutViews.WorkoutControls(newExercises: newWorkout.sortedExercises, showAddSheet: $showAddSheet, workout: $newWorkout)
            }
            .navigationTitle(newWorkout.name)
            .navigationSubtitle("Created Now")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func SelectedExerciseList() -> some View {
        Section {
            ForEach(newWorkout.sortedExercises, id: \.self) { exercise in
                ReusedViews.ExerciseViews.ExerciseListPreview(exercise: exercise)
            }
        } header: {
            ReusedViews.Buttons.EditHeaderButton(toggleEdit: $showAddSheet, type: .workout, items: newWorkout.sortedExercises)
        }
    }
    
    private func Save() {
        context.insert(newWorkout)
        try? context.save()
        dismiss()
    }
    
    private func Dismiss() {
        dismiss()
    }
    
}
