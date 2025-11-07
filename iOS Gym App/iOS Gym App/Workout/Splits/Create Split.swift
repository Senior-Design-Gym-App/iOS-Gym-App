import SwiftUI
import SwiftData

struct CreateWorkoutSplitView: View {
    
    let allWorkouts: [Workout]
    let allExercises: [Exercise]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var newSplit = Split(name: "", workouts: [], imageData: nil, active: false)
    @State private var selectedWorkouts: [Workout] = []
    @State private var showAddSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ReusedViews.SplitViews.LargeIconView(split: newSplit)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .overlay {
                        ReusedViews.SplitViews.ImagePicker(split: $newSplit)
                            .labelStyle(.iconOnly)
                            .font(.largeTitle)
                            .tint(.white)
                    }
                ReusedViews.Labels.SingleCardTextField(textFieldName: $newSplit.name, createdDate: newSplit.created, type: .workout)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                SelectedWorkoutsList()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    ReusedViews.Buttons.SaveButton(disabled: newSplit.name.isEmpty, save: SaveSplit)
                }
                ToolbarItem(placement: .cancellationAction) {
                    ReusedViews.Buttons.CancelButton(cancel: DismissView)
                }
            }
            .sheet(isPresented: $showAddSheet) {
                ReusedViews.SplitViews.SplitControls(saveAction: {}, newWorkouts: selectedWorkouts, showAddSheet: $showAddSheet, oldWorkouts: $selectedWorkouts)
            }
        }
    }
    
    private func SelectedWorkoutsList() -> some View {
        Section {
            ForEach(selectedWorkouts, id: \.self) { workout in
                ReusedViews.WorkoutViews.WorkoutListPreview(workout: workout)
            }
        } header: {
            ReusedViews.Buttons.EditHeaderButton(toggleEdit: $showAddSheet, type: .split, items: selectedWorkouts)
        }
    }
    
    private func SaveSplit() {
        newSplit.workouts = selectedWorkouts
        context.insert(newSplit)
        try? context.save()
        dismiss()
    }
    
    private func DismissView() {
        dismiss()
    }
    
}
