import SwiftUI

struct TabHome: View {
    
    
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
            }
            Tab("Workout", systemImage: "dumbbell") {
                WorkoutHome()
            }
            Tab("Explore", systemImage: "safari") {
                Text("Walka w kuchni")
            }
        }
    }
    
    
    
}
