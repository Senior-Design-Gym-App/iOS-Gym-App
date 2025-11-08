import SwiftUI

struct RecentSessionsView: View {
    
    let allSessions: [WorkoutSession]
    
    var recentSessions: [WorkoutSession] {
        allSessions
            .filter { $0.completed != nil }
            .sorted { lhs, rhs in
                guard let lhsDate = lhs.completed, let rhsDate = rhs.completed else { return false }
                return lhsDate > rhsDate
            }
            .prefix(3)
            .map { $0 }
    }
    
    var body: some View {
        GroupBox {
            NavigationLink {
                SessionsListView(allSessions: allSessions)
            } label: {
                ReusedViews.Labels.HeaderWithArrow(title: "Recent Sessions")
            }
            RecentSessionsView()
        }
        .frame(idealWidth: .infinity, maxWidth: .infinity)
    }
    
    private func RecentSessionsView() -> some View {
        ForEach(recentSessions, id: \.self) { session in
            ReusedViews.SessionViews.SessionLink(session: session)
        }
    }
    
}
