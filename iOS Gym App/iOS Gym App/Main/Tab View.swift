import SwiftUI

struct TabHome: View {
    
    
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView(title: ActivityLabels.RandomGymGreeting())
            }
            Tab("Workout", systemImage: "dumbbell") {
                WorkoutHome()
            }
            Tab("Explore", systemImage: "safari") {
                ExploreView()
            }
        }
        .tabViewBottomAccessory {
            SessionTabViewWrapper()
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
    
    
    
}
