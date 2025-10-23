import SwiftUI

struct RecentSessionsView: View {
    
    let allSessions: [WorkoutSession]
    
    var recentSessions: [WorkoutSession] {
        let now = Date()
        return allSessions
            .filter { $0.completed != nil }
            .sorted { abs($0.completed!.timeIntervalSince(now)) < abs($1.completed!.timeIntervalSince(now)) }
            .prefix(5)
            .map { $0 }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            if recentSessions.isEmpty == false {
                NavigationLink {
                    SessionsListView(allSessions: allSessions)
                } label: {
                    ReusedViews.HorizontalHeader(text: "Recent Sessions", showNavigation: true)
                }
                RecentSessionsSection()
            }
        }
    }
    
    private func RecentSessionsSection() -> some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(recentSessions) { session in
                    NavigationLink {
                        SessionRecap(session: session, sessionName: session.name)
                    } label: {
                        VStack(alignment: .leading, spacing: 0) {
                            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                .fill(ColorManager.shared.GetColor(key: session.id.hashValue.description))
                                .aspectRatio(1.0, contentMode: .fit)
                                .padding(.bottom, 5)
                                .frame(minWidth: Constants.previewSize ,maxWidth: 300, minHeight: Constants.previewSize ,maxHeight: 300)
                            ReusedViews.Description(topText: session.workout?.name ?? "Unknown Day", bottomText: "\(session.exercises?.count ?? 0) Exercises")
                        }
                    }
                }
            }
        }.scrollIndicators(.hidden)
    }
    
}
