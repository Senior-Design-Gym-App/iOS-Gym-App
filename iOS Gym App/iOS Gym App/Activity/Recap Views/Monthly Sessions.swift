import SwiftUI

struct MonthlySessions: View {
    
    @Namespace private var namespace
    let viewingMonth: Date
    let allSessions: [WorkoutSession]
    private let calendar = Calendar.current
    
    var recentSessions: [WorkoutSession] {
        allSessions
            .sorted { lhs, rhs in
                guard let lhsDate = lhs.completed, let rhsDate = rhs.completed else { return false }
                return lhsDate > rhsDate
            }
            .prefix(5)
            .map { $0 }
    }
    
    var body: some View {
        if recentSessions.isEmpty == false {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(recentSessions, id: \.self) { session in
                        HorizontalListPreview(session: session)
                    }
                }
            }.scrollIndicators(.hidden)
        }
        NavigationLink {
            SessionsListView(allSessions: allSessions.filter { calendar.isDate($0.started, equalTo: viewingMonth, toGranularity: .month) } )
        } label: {
            Label {
                Text("This months sessions")
            } icon: {
                Image(systemName: Constants.sessionIcon)
                    .foregroundStyle(Constants.sessionTheme)
            }
        }
    }
    
    private func HorizontalListPreview(session: WorkoutSession) -> some View {
        NavigationLink {
            SessionRecap(session: session)
                .navigationTransition(.zoom(sourceID: session.id, in: namespace))
        } label: {
            VStack(alignment: .leading, spacing: 5) {
                ReusedViews.Labels.MediumIconSize(color: session.color)
                    .matchedTransitionSource(id: session.id, in: namespace)
                ReusedViews.Labels.ListDescription(title: session.name, subtitle: DateHandler().RelativeTime(from: session.completed!))
            }
        }.buttonStyle(.plain)
            .navigationLinkIndicatorVisibility(.hidden)
    }
    
}
