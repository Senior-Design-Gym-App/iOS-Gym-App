import SwiftUI

struct MonthlyUpdates: View {
    
    @Namespace private var namespace
    let viewingMonth: Date
    let allExercises: [Exercise]
    private let calendar = Calendar.current
    
    var recentUpdates: [Exercise] {
        allExercises
            .sorted { $0.recentUpdateDate > $1.recentUpdateDate }
            .prefix(5)
            .map { $0 }
    }
    
    var body: some View {
        if recentUpdates.isEmpty == false {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(recentUpdates, id: \.self) { exercise in
                        HorizontalListPreview(exercise: exercise)
                    }
                }
            }.scrollIndicators(.hidden)
        }
        NavigationLink {
            UpdatesListView(allExercises: allExercises.filter { calendar.isDate($0.recentUpdateDate, equalTo: viewingMonth, toGranularity: .month) })
        } label: {
            Label {
                Text("This months updates")
            } icon: {
                Image(systemName: Constants.exerciseIcon)
                    .foregroundStyle(Constants.mainAppTheme)
            }
        }
    }
    
    private func HorizontalListPreview(exercise: Exercise) -> some View {
        NavigationLink {
            ExerciseChanges(exercise: exercise)
                .navigationTransition(.zoom(sourceID: exercise.id, in: namespace))
        } label: {
            ReusedViews.ExerciseViews.HorizontalListPreview(exercise: exercise)
        }.buttonStyle(.plain)
            .matchedTransitionSource(id: exercise.id, in: namespace)
    }
    
}
