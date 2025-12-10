import SwiftUI

struct SessionInfo:  View {
    
    let session: WorkoutSession
    
    var body: some View {
        Text(session.started, style: .timer)
            .font(.largeTitle)
    }
    
}
	
