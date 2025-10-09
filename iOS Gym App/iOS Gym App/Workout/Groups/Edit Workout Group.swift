import SwiftUI
import SwiftData

struct EditWorkoutGroupView: View {
    
    let allWorkouts: [Workout]
    @State var name: String
    @State var selectedWorkouts: [Workout]
    @State var selectedGroup: WorkoutGroup
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            List {
                RequiredSection()
                GroupWorkouts()
                UpdateSection()
                WorkoutsSection()
            }
            .environment(\.editMode, .constant(.active))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        ForEach(allWorkouts.sorted(by: { $0.name < $1.name })) { workout in
                            Button {
                                selectedWorkouts.append(workout)
                            } label: {
                                Text(workout.name)
                            }
                        }
                    } label: {
                        Label("Add Workout", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Edit Group")
        }
    }
    
    private func RequiredSection() -> some View {
        Section {
            TextField("Group Name", text: $name)
        } header: {
            Label("Required Information", systemImage: "pencil.line")
        }
    }
    
    private func GroupWorkouts() -> some View {
        Section(header: Text("Workouts in Group")) {
            ForEach(selectedWorkouts, id: \.self) { workout in
                Text(workout.name)
            }
            .onDelete { indices in
                selectedWorkouts.remove(atOffsets: indices)
            }
            .onMove { indices, newOffset in
                selectedWorkouts.move(fromOffsets: indices, toOffset: newOffset)
            }
        }
    }
    
    private func WorkoutsSection() -> some View {
        Section {
            ForEach(selectedGroup.workoutRoutine ?? [], id: \.self) { routine in
                Text(routine.name)
            }
        } header: {
            Label("Routines In", systemImage: "folder")
        }
    }
    
    private func UpdateSection() -> some View {
        Section {
            Button {
                selectedGroup.groupName = name
                selectedGroup.workouts = selectedWorkouts
                try? context.save()
                dismiss()
            } label: {
                Label("Update & Exit", systemImage: "square.and.arrow.down.badge.checkmark")
            }
            Button {
                context.delete(selectedGroup)
                dismiss()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .foregroundStyle(.red)
        } header: {
            Label("Save Options", systemImage: "square.and.arrow.down.on.square")
        }
    }
    
}
