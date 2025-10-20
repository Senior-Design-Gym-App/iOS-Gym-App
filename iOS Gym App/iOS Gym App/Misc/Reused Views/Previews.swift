import SwiftUI

struct ReusedPreviews {
    
    static func GridSplitView(split: WorkoutSplit) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            SplitViews.CardView(split: split)
                .padding(.bottom, 5)
            ReusedViews.Description(topText: split.name, bottomText: "\(split.days?.count ?? 0) day\(split.days?.count == 1 ? "" : "s")")
        }
        .padding(.bottom)
    }
    
    static func GridDayView(day: WorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .fill(day.color)
                .scaledToFit()
                .padding(.bottom, 5)
                .aspectRatio(1.0, contentMode: .fit)
                    .frame(minWidth: Constants.previewSize ,maxWidth: 300, minHeight: Constants.previewSize ,maxHeight: 300)
            ReusedViews.Description(topText: day.name, bottomText: "\(day.workouts?.count ?? 0) Workout\(day.workouts?.count == 1 ? "" : "s")")
        }
        .padding(.bottom)
    }
    
    static func IncompleteSessionView(session: WorkoutSession) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .fill(session.workoutDay?.color ?? Constants.mainAppTheme)
                .scaledToFit()
                .padding(.bottom, 5)
                .frame(minWidth: Constants.previewSize ,maxWidth: 300, minHeight: Constants.previewSize ,maxHeight: 300)
            ReusedViews.Description(topText: session.name, bottomText: "\(session.exercises?.count ?? 0) completed")
        }
    }
    
}
