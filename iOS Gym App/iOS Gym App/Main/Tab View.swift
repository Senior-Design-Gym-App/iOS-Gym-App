import SwiftUI
import SwiftData

enum TabSelection: String, CaseIterable {
    case home = "Home"
    case workout = "Workout"
    case explore = "Explore"
    case feed = "Feed"
}

struct TabHome: View {
    @Environment(WatchSyncViewModel.self) private var watchSync
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: TabSelection = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MonthlyProgressView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(TabSelection.home)
            
            WorkoutHome()
                .tabItem {
                    Label("Workout", systemImage: "dumbbell")
                }
                .tag(TabSelection.workout)
            
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "safari")
                }
                .tag(TabSelection.explore)
            
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "text.bubble")
                }
                .tag(TabSelection.feed)
        }
        .tabViewBottomAccessory {
            SessionTabViewWrapper()
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .onAppear {
            // Setup watch sync with modelContext
            watchSync.setup(modelContext: modelContext)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToWorkoutsTab"))) { _ in
            // Switch to Workout tab
            selectedTab = .workout
        }
    }
    
    
    
}
