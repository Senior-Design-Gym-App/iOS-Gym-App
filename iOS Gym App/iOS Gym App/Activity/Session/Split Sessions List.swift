import SwiftUI

struct SplitSessions: View {
    
    let split: Split
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(split.workouts ?? [], id: \.self) { workout in
                    if let sessions = workout.sessions {
                        NavigationLink {
                            SessionsListView(allSessions: sessions)
                        } label: {
                            ReusedViews.WorkoutViews.WorkoutListPreview(workout: workout)
                        }
                    }
                }
            }
            .navigationTitle(split.name)
            .navigationSubtitle("Linked Sessions")
        }
    }
    
    
    
}
