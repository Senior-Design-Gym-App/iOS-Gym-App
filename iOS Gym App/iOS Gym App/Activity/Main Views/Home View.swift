import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Query private var session: [WorkoutSession]
    @Environment(SessionManager.self) private var sm: SessionManager
    @Query private var allSplits: [Split]
    @Query private var allSessions: [WorkoutSession]
    @Query private var allWorkouts: [Workout]
    @Query private var allExercises: [Exercise]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    InspirationalTextView(title: ActivityLabels.RandomGymGreeting(), subtitle: ActivityLabels.getRandomGymPun())
                    StartSessionsView(allSplits: allSplits)
                    IncompleteSessionsView(allSessions: allSessions)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                    RecentUpdatesView(allExercises: allExercises)
                    RecentSessionsView(allSessions: allSessions)
                }
            }
            .padding(.horizontal, 20)

            .navigationTitle("Home")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        
                    } label: {
                        Image(systemName: "clipboard")
                    }
                }
            }
        }
    }
    
}
