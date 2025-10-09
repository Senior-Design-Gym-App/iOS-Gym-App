import SwiftUI
import SwiftData

struct CreateWorkoutGroupView: View {
    
    var workout: [Workout]
    @State private var name: String = ""
    @State private var selectedWorkouts: [Workout] = []
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationView {
            List {
                RequiredSection()
                SaveOptions()
            }
            .navigationTitle("Create Group")
        }
    }
    
    private func RequiredSection() -> some View {
        Section {
            TextField("Group Name", text: $name)
        } header: {
            Label("Required Information", systemImage: "pencil.line")
        }
    }
    
    private func SaveOptions() -> some View {
        Section {
            Button {
                let newGroup = WorkoutGroup(groupName: name, workouts: selectedWorkouts)
                context.insert(newGroup)
                try? context.save()
                name = ""
                selectedWorkouts = []
            } label: {
                Label("Save & Add Another", systemImage: "square.and.arrow.down.on.square")
            }
            Button {
                let newGroup = WorkoutGroup(groupName: name, workouts: selectedWorkouts)
                context.insert(newGroup)
                try? context.save()
                dismiss()
            } label: {
                Label("Save & Exit", systemImage: "square.and.arrow.down.badge.checkmark")
            }
        } header: {
            Label("Save Options", systemImage: "square.and.arrow.down.on.square")
        }
    }
    
}
