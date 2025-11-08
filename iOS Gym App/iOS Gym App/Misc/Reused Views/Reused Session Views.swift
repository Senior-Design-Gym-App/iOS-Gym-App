import SwiftUI

extension ReusedViews {
    
    struct SessionViews {
        
        static func SessionLink(session: WorkoutSession) -> some View {
            NavigationLink {
                SessionRecap(session: session)
            } label: {
                HStack {
                    ReusedViews.Labels.SmallIconSize(color: session.color)
                    ReusedViews.Labels.Description(topText: session.name, bottomText: "\(DateHandler().RelativeTime(from: session.completed!)) ago")
                    Spacer()
                }
            }
        }
        
    }
    
}
