import SwiftUI
import SwiftData

struct WorkoutHome: View {
    
    @Query private var workouts: [Workout]
    @Query private var groups: [WorkoutGroup]
    @Query private var routines: [WorkoutRoutine]
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                MyWorkoutSection()
            }
            .navigationTitle("Workouts")
            .searchable(text: $searchText, prompt: "Search Workouts, Groups and Routines")
        }
    }
    
    private func MyWorkoutSection() -> some View {
        Section {
            NavigationLink {
                WorkoutListView()
            } label: {
                Label("Workouts", systemImage: "dumbbell")
            }
            NavigationLink {
                WorkoutGroupListView()
            } label: {
                Label("Workout Groups", systemImage: "tag")
            }
            NavigationLink {
                WorkoutRoutineListView()
            } label: {
                Label("Workout Routines", systemImage: "folder")
            }
        } header: {
            Label("My Workouts", systemImage: "checklist")
        }
    }
    
}
