import SwiftUI
import SwiftData

struct EditSplitView: View {
    
    @Query private var allSplits: [Split]
    @State var selectedImage: UIImage?
    @State var selectedSplit: Split
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var showRename: Bool = false
    @State private var showAddSheet: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                HStack {
                    Spacer()
                    VStack {
                        ReusedViews.SplitViews.LargeSplitView(split: selectedSplit)
                            .offset(y: Constants.largeOffset)
                        HStack {
                            ReusedViews.SplitViews.ImagePicker(split: $selectedSplit)
                            ReusedViews.SplitViews.ActiveSplit(split: $selectedSplit, allSplits: allSplits)
                            ReusedViews.Buttons.RenameButtonAlert(type: .split, oldName: $selectedSplit.name)
                            ReusedViews.Buttons.DeleteButtonConfirmation(type: .split, deleteAction: Delete)
                        }
                    }
                    Spacer()
                }.padding(.bottom)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                SelectedWorkoutsList()
            }
            .sheet(isPresented: $showAddSheet) {
                ReusedViews.SplitViews.SplitControls(newWorkouts: selectedSplit.sortedWorkouts, showAddSheet: $showAddSheet, split: $selectedSplit)
            }
            .navigationTitle(selectedSplit.name)
            .navigationSubtitle("Edited \(DateHandler().RelativeTime(from: selectedSplit.modified))")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func SelectedWorkoutsList() -> some View {
        Section {
            ForEach(selectedSplit.sortedWorkouts, id: \.self) { workout in
                NavigationLink {
                    EditWorkoutView(selectedWorkout: workout)
                } label: {
                    ReusedViews.WorkoutViews.WorkoutListPreview(workout: workout)
                }
            }
        } header: {
            ReusedViews.Buttons.EditHeaderButton(toggleEdit: $showAddSheet, type: .split, items: selectedSplit.sortedWorkouts)
        }
    }
    
    private func ToggleFavorite() -> some View {
        Toggle(isOn: $selectedSplit.active) {
            Label("Pin", systemImage: "pin")
        }
    }
    
    private func Delete() {
        // Clear widget data if deleting the active split
        if selectedSplit.active {
            WidgetDataManager.shared.setActiveSplit(nil)
        }
        
        context.delete(selectedSplit)
        try? context.save()
        dismiss()
    }
    
}
