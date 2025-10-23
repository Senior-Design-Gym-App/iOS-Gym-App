import SwiftUI

struct InspirationalTextView: View {
    
    let title: String
    let subtitle: String
    //    let session: [WorkoutSession]
    //    let allSplits: [WorkoutSplit]
    //    let allSessions: [WorkoutSession]
    //    let allUpdates: [WorkoutUpdate]
    //    let allDays: [WorkoutDay]
    
    var body: some View {
        RoundedRectangle(cornerRadius: Constants.homeRadius)
            .fill(Constants.mainAppTheme)
            .overlay(alignment: .top) {
                Text(title)
                    .fontWeight(.semibold)
                    .font(.largeTitle)
                    .padding(.top)
                    .padding(.horizontal)
                    .foregroundStyle(Constants.iconColor)
            }
            .overlay(alignment: .bottom) {
                VStack {
                    Text(subtitle)
                        .font(.title3)
                        .fontWeight(.medium)
                    Text("Select a session to get started")
                        .font(.body)
                }.padding(.bottom)
                    .foregroundStyle(Constants.iconColor)
            }
            .frame(maxWidth: .infinity, minHeight: 400)
    }
    
}
