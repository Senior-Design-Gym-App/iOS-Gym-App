import SwiftUI
import SwiftData

struct CreateWorkoutSplitView: View {
    
    @Query private var allSplits: [Split]
    let allWorkouts: [Workout]
    let allExercises: [Exercise]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var newSplit = Split(name: "New Split", workouts: [], imageData: nil, active: false)
    @State private var selectedWorkouts: [Workout] = []
    @State private var showAddSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                HStack {
                    Spacer()
                    VStack {
                        ReusedViews.SplitViews.LargeSplitView(split: newSplit)
                            .offset(y: Constants.largeOffset)
                        HStack {
                            ReusedViews.SplitViews.ImagePicker(split: $newSplit)
                            ReusedViews.SplitViews.ActiveSplit(split: $newSplit, allSplits: allSplits)
                            ReusedViews.Buttons.RenameButtonAlert(type: .split, oldName: $newSplit.name)
                        }
                    }
                    Spacer()
                }.padding(.bottom)
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
                ReusedViews.SplitViews.SplitControls(newWorkouts: selectedWorkouts, showAddSheet: $showAddSheet, split: $newSplit)
            }
            .navigationTitle(newSplit.name)
            .navigationSubtitle("Created Now")
            .navigationBarTitleDisplayMode(.inline)
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
        context.insert(newSplit)
        try? context.save()
        dismiss()
    }
    
    private func DismissView() {
        dismiss()
    }
    
}
