import SwiftUI
import Charts

struct RecentPRView: View {
    
    let allExercises: [Exercise]
    
    var recentExercise: Exercise? {
        allExercises.max(by: { $0.modified < $1.modified })
    }
    
    var body: some View {
        GroupBox {
            NavigationLink {
                UpdatesListView(allExercises: allExercises)
            } label: {
                VStack(alignment: .leading, spacing: 0) {
                    ReusedViews.Labels.HeaderWithArrow(title: "Recent PR")
                    ReusedViews.Labels.Subheader(title: recentExercise?.name ?? "No recent exercise.")
                }
            }
            if let recentExercise {
//                NavigationLink {
//                    ExerciseChanges(exercise: recentExercise)
//                } label: {
//                    ReusedViews.Charts.BarChartMonth(data: recentExercise.recentSetData.setData, color: recentExercise.color)
//                }
            } else {
//                Text("Here will be your most recent exercise update.")
            }
        }
        .frame(idealWidth: .infinity, maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
    }
    
}
