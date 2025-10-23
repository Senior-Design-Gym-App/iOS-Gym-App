import SwiftUI
import WidgetKit
import ActivityKit

struct ExerciseTimerBannerView: View {
    
    let context: ActivityViewContext<WorkoutTimer>
    
    var body: some View {
        HStack {
            VStack {
                Text(context.state.exerciseName)
                    .font(.headline)
                SetGauge(context: context)
            }
            Spacer()
            TimerView(context: context)
                .font(.largeTitle)
        }
    }
    
}
