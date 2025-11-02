import SwiftUI

struct InspirationalTextView: View {
    
    let title: String
    let allWorkouts: [Workout]
    
    var body: some View {
        GroupBox {
            Text(title)
                .fontWeight(.semibold)
                .font(.largeTitle)
                .frame(maxWidth: .infinity)
            if allWorkouts.isEmpty {
                Text("Create a few exercises and add them to a workout to start a session.")
                    .font(.body)
            } else {
                Text("Select a session to get started")
                    .font(.body)
            }
        }.frame(idealWidth: .infinity, maxWidth: .infinity)
    }
    
}
