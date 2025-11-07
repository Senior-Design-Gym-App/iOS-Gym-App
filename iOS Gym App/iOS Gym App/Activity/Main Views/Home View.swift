import SwiftUI
import SwiftData

struct HomeView: View {
    
    let title: String
    @Query private var session: [WorkoutSession]
    @Environment(SessionManager.self) private var sm: SessionManager
    @Query private var allSplits: [Split]
    @Query private var allSessions: [WorkoutSession]
    @Query private var allWorkouts: [Workout]
    @Query private var allExercises: [Exercise]
    
    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                InspirationalTextView(title: title, allWorkouts: allWorkouts)
                RecentSessionsView(allSessions: allSessions)
                LazyVGrid(columns: columns) {
                    RecentUpdatesView(allExercises: allExercises)
                    RecentPRView(allExercises: allExercises)
                    RecentBodyweight()
                    RecentBodyfat()
                }
                RecentMonthActivity(allExercises: allExercises, allSessions: allSessions)
                Divider().padding(.vertical)
                GroupBox {
                    NavigationLink {
                        HomeViewList(allWorkouts: allWorkouts, allExercises: allExercises, allSessions: allSessions)
                    } label: {
                        Text("See All")
                            .frame(idealWidth: .infinity, maxWidth: .infinity)
                    }.navigationLinkIndicatorVisibility(.hidden)
                }.clipShape(.capsule)
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
            .navigationTitle("Home")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        Text("Generic Settings")
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
    
}
