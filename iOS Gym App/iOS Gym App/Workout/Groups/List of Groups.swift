import SwiftUI
import SwiftData

struct WorkoutGroupListView: View {
    
    @Query private var group: [WorkoutGroup]
    @Query private var workout: [Workout]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(group, id: \.self) { group in
                    NavigationLink {
                        EditWorkoutGroupView(allWorkouts: workout ,name: group.groupName, selectedWorkouts: group.workouts ?? [], selectedGroup: group)
                    } label: {
                        Text(group.groupName)
                    }
                }
            }
            .navigationTitle("Workout Groups")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    NavigationLink {
                        CreateWorkoutGroupView(workout: workout)
                    } label: {
                        Label("Create Group", systemImage: "plus")
                    }
                }
            }
        }
    }
    
}
