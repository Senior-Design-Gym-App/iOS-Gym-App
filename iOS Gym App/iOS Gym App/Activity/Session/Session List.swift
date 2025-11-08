import SwiftUI

struct SessionsListView: View {
    
    let allSessions: [WorkoutSession]
    
    // Group sessions by month
    private var sessionsByMonth: [(monthYear: String, sessions: [WorkoutSession])] {
        // Filter out incomplete sessions
        let completedSessions = allSessions.filter { $0.completed != nil }
        
        // Group by month
        let grouped = Dictionary(grouping: completedSessions) { session -> String in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: session.completed!)
        }
        
        // Sort by date (most recent first)
        return grouped.map { (monthYear: $0.key, sessions: $0.value) }
            .sorted { first, second in
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                guard let date1 = formatter.date(from: first.monthYear),
                      let date2 = formatter.date(from: second.monthYear) else {
                    return false
                }
                return date1 > date2
            }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(sessionsByMonth, id: \.monthYear) { monthGroup in
                    Section(header: Text(monthGroup.monthYear)) {
                        ForEach(monthGroup.sessions, id: \.id) { session in
                            ReusedViews.SessionViews.SessionLink(session: session)
                        }
                    }
                }
            }
            .listRowSpacing(10)
            .navigationTitle("All Sessions")
        }
    }
}
