import SwiftUI
import SwiftData

struct EditSplitView: View {
    
    @State var selectedImage: UIImage?
    @State var selectedSplit: Split
    @State var selectedWorkouts: [Workout]
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var showRename: Bool = false
    @State private var showAddSheet: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ReusedViews.SplitViews.LargeIconView(split: selectedSplit)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                ReusedViews.Labels.SingleCardTitle(title: selectedSplit.name, modified: selectedSplit.modified)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                SelectedWorkoutsList()
            }
            .toolbar {
                ToolbarItemGroup(placement: .secondaryAction) {
                    ToggleFavorite()
                    ReusedViews.Buttons.RenameButtonAlert(type: .split, oldName: $selectedSplit.name)
                    ReusedViews.Buttons.DeleteButtonConfirmation(type: .split, deleteAction: Delete)
                    ReusedViews.SplitViews.ImagePicker(split: $selectedSplit)
                }
            }
            .sheet(isPresented: $showAddSheet) {
                ReusedViews.SplitViews.SplitControls(saveAction: SaveSplit, newWorkouts: selectedWorkouts, showAddSheet: $showAddSheet, oldWorkouts: $selectedWorkouts)
            }
        }
    }
    
    private func SelectedWorkoutsList() -> some View {
        Section {
            ForEach(selectedWorkouts, id: \.self) { workout in
                NavigationLink {
                    EditWorkoutView(selectedExercises: workout.exercises ?? [], selectedWorkout: workout)
                } label: {
                    ReusedViews.WorkoutViews.WorkoutListPreview(workout: workout)
                }
            }
        } header: {
            ReusedViews.Buttons.EditHeaderButton(toggleEdit: $showAddSheet, type: .split, items: selectedWorkouts)
        }
    }
    
    private func ToggleFavorite() -> some View {
        Toggle(isOn: $selectedSplit.active) {
            Label("Pin", systemImage: "pin")
        }
    }
    
    private func SaveSplit() {
        selectedSplit.modified = Date()
        selectedSplit.workouts = selectedWorkouts
        try? context.save()
    }
    
    private func Delete() {
        context.delete(selectedSplit)
        try? context.save()
        dismiss()
    }
    
}
