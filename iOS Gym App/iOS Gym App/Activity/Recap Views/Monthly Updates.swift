import SwiftUI

struct MonthlyUpdates: View {
    
    @Namespace private var namespace
    let viewingMonth: Date
    let allExercises: [Exercise]
    private let calendar = Calendar.current
    
    var recentUpdates: [Exercise] {
        allExercises
            .filter { exercise in
                exercise.updateDates.contains { date in
                    calendar.isDate(date, equalTo: viewingMonth, toGranularity: .month)
                }
            }
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
            UpdatesListView(allExercises: allExercises.filter { $0.updateDates.contains { calendar.isDate($0, equalTo: viewingMonth, toGranularity: .month) } } )
        } label: {
            Label {
                Text("This months updates")
            } icon: {
                Image(systemName: Constants.exerciseIcon)
                    .foregroundStyle(Constants.updateTheme)
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
