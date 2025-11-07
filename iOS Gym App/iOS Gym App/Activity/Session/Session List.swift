import SwiftUI

struct SessionsListView: View {
    
    let allSessions: [WorkoutSession]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(allSessions, id: \.self) { session in
                    NavigationLink {
                        SessionRecap(session: session)
                    } label: {
                        Text(session.name)
                    }
                }
            }
            .navigationTitle("All Sessions")
        }
    }
    
    
    
}
