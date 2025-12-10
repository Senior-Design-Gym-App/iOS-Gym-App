import SwiftUI
import WidgetKit
import ActivityKit

struct ExerciseTimerBannerView: View {
    
    let context: ActivityViewContext<WorkoutTimer>
    
    var body: some View {
        HStack {
            CircularGauge(context: context)
                .padding(.trailing, 30)
            Text(context.state.currentExercise.exercise.name)
            Spacer()
            TimerGauge(context: context)
                .padding(.leading, 30)
        }
    }
    
}
