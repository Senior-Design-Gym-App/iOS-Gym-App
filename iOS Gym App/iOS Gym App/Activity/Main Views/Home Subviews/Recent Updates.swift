import SwiftUI
import Charts

struct RecentUpdatesView: View {
    
    let allExercises: [Exercise]
    
    var recentUpdates: [Exercise] {
//        let now = Date()
//        return allExercises
//            .compactMap { update -> (WorkoutUpdate, Date)? in
//                guard let latestDate = update.updateData.last?.updateDate else { return nil }
//                return (update, latestDate)
//            }
//            .sorted { abs($0.1.timeIntervalSince(now)) < abs($1.1.timeIntervalSince(now)) }
//            .filter { $0.0.updateData.count > 1 }
//            .prefix(10)
//            .map { $0.0 }
        []
    }
    
    var body: some View {
        VStack(spacing: 10) {
            if recentUpdates.isEmpty == false {
                NavigationLink {
                    UpdatesListView(allExercises: allExercises)
                } label: {
                    ReusedViews.HorizontalHeader(text: "Recent Updates", showNavigation: true)
                }
                RecentUpdates()
            }
        }
    }
    
    private func RecentUpdates() -> some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(recentUpdates, id: \.self) { update in
                    SingleUpdateView(update: update)
                }
            }
        }.scrollIndicators(.hidden)
    }
    
    private func SingleUpdateView(update: Exercise) -> some View {
        NavigationLink {
//            WorkoutUpdateView(workout: update)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                ProgressChart(update: update)
                ReusedViews.Description(topText: update.name, bottomText: DateHandler().RelativeTime(from: update.created))
            }
        }
    }
    
    private func ProgressChart(update: Exercise) -> some View {
        Chart {
//            ForEach(update.updateData, id: \.self) { progress in
//                BarMark(
//                    x: .value("Date", progress.updateDate, unit: .day),
//                    y: .value("Weight", progress.averageVolumePerSet),
//                )
//            }
        }
        .frame(minWidth: Constants.previewSize ,maxWidth: 300, minHeight: Constants.previewSize ,maxHeight: 300)
    }
    
//    let allUpdates: [WorkoutUpdate]
//    
//    var recentPRs: [WorkoutUpdate] {
//        let now = Date()
//        return allUpdates
//            .compactMap { update -> (WorkoutUpdate, Date)? in
//                guard let latestDate = update.prData.last?.date else { return nil }
//                return (update, latestDate)
//            }
//            .sorted { abs($0.1.timeIntervalSince(now)) < abs($1.1.timeIntervalSince(now)) }
//            .prefix(5)
//            .map { $0.0 }
//    }
//    
//    var body: some View {
//        if recentPRs.isEmpty == false {
//            Section {
//                PRSection()
//            } header: {
//                Text("Recent PRs")
//            }
//        }
//    }
//    
//    private func PRSection() -> some View {
//        ScrollView(.horizontal) {
//            HStack {
//                ForEach(recentPRs, id: \.self) { update in
//                    NavigationLink {
//                        WorkoutUpdateView(workout: update)
//                    } label: {
//                        Text("\(update.workout?.name ?? "Unknown Workout")")
//                            .foregroundStyle(.primary)
//                    }
//                    .tint(Constants.updateTheme)
//                    .buttonStyle(.glass)
//                }
//            }.padding(.horizontal)
//        }.scrollIndicators(.hidden)
//    }

    
}
