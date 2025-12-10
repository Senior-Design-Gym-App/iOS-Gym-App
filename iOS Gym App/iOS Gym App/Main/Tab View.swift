import SwiftUI
import SwiftData

struct TabHome: View {
    @Environment(WatchSyncViewModel.self) private var watchSync
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                MonthlyProgressView()
            }
            Tab("Workout", systemImage: "dumbbell") {
                WorkoutHome()
            }
            Tab("Explore", systemImage: "safari") {
                ExploreView()
            }
            Tab("Feed", systemImage: "text.bubble") {
                FeedView()
            }
            Tab("Add Friends", systemImage: "person.badge.plus") {
                AddFriendsView()
            }
            Tab("Friends", systemImage: "person.2") {
                NavigationStack {
                    FriendsListView()
                }
            }
        }
        .tabViewBottomAccessory {
            SessionTabViewWrapper()
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .onAppear {
            // Setup watch sync with modelContext
            watchSync.setup(modelContext: modelContext)
        }
    }
    
    
    
}
