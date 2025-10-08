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
                if searchText.isEmpty {
                    MyWorkoutSection()
                    OthersRoutinesSection()
                } else {
                    
                }
            }
            .navigationTitle("Workouts")
            .searchable(text: $searchText, prompt: "Search Workouts, Groups and Routines")
        }
    }
    
    private func MyWorkoutSection() -> some View {
        Section {
            NavigationLink {
                
            } label: {
                Label("Workouts", systemImage: "dumbbell")
            }
            NavigationLink {
                
            } label: {
                Label("Workout Groups", systemImage: "tag")
            }
            NavigationLink {
                
            } label: {
                Label("Workout Routines", systemImage: "folder")
            }
        } header: {
            Label("My Workouts", systemImage: "checklist")
        }
    }
    
    private func OthersRoutinesSection() -> some View {
        Section {
            NavigationLink {
                
            } label: {
                Label("Shared with me", systemImage: "sharedwithyou")
            }
            NavigationLink {
                
            } label: {
                Label("Share Routines", systemImage: "square.and.arrow.up")
            }
            NavigationLink {
                
            } label: {
                Label("AI Routines & Groups", systemImage: "apple.intelligence")
            }
        } header: {
            Text("Friend Routines")
        }
    }
    
}
