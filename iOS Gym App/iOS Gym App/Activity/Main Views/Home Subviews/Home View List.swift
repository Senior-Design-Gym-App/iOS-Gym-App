import SwiftUI

struct HomeViewList: View {
    
    let allWorkouts: [Workout]
    let allExercises: [Exercise]
    let allSessions: [WorkoutSession]
    
    var incompleteSessions: [WorkoutSession] {
        allSessions.filter({ $0.completed == nil })
    }
    
    var completedSessions: [WorkoutSession] {
        allSessions.filter({ $0.completed != nil })
    }
    
    var body: some View {
        NavigationStack {
            List {
                BodyFatLink()
                BodyWeightLink()
                if incompleteSessions.isEmpty == false {
                    IncompleteSessionLink()
                }
                CompletedSessionsLink()
                AllUpdatesLink()
            }.navigationTitle("All Links")
        }
    }
    
    private func BodyWeightLink() -> some View {
        NavigationLink {
            HealthData(type: .bodyWeight)
        } label: {
            Label("Body Weight", systemImage: "figure")
        }
    }
    
    private func BodyFatLink() -> some View {
        NavigationLink {
            HealthData(type: .bodyFat)
        } label: {
            Label("Body Fat", systemImage: "figure")
        }
    }
    
    private func IncompleteSessionLink() -> some View {
        NavigationLink {
            SessionsListView(allSessions: incompleteSessions)
        } label: {
            Label("Incomplete Sessions", systemImage: "timer")
        }
    }
    
    private func CompletedSessionsLink() -> some View {
        NavigationLink {
            SessionsListView(allSessions: completedSessions)
        } label: {
            Label("Completed Sessions", systemImage: "timer")
        }
    }
    
    private func AllUpdatesLink() -> some View {
        NavigationLink {
            UpdatesListView(allExercises: allExercises)
        } label: {
            Label("All Updates", systemImage: "chart.bar")
        }
    }
    
}
