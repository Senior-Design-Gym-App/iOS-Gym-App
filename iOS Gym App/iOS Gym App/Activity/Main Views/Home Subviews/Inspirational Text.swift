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
        }.frame(idealWidth: .infinity, maxWidth: .infinity)
    }
    
}
