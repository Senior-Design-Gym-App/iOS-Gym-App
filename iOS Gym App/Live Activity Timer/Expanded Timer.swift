import ActivityKit
import WidgetKit
import SwiftUI

@DynamicIslandExpandedContentBuilder
func ExerciseTimerExpandedView(context: ActivityViewContext<WorkoutTimer>) -> DynamicIslandExpandedContent<some View> {
    
    DynamicIslandExpandedRegion(.leading) {
        Text(context.state.exerciseName)
            .font(.headline)
        SetGauge(context: context)
    }
    
    DynamicIslandExpandedRegion(.trailing) {
        Spacer()
        TimerGauge(context: context)
        TimerView(context: context)
            .font(.largeTitle)
        Spacer()
    }
    
}

func TimerView(context: ActivityViewContext<WorkoutTimer>) -> some View {
    Text(timerInterval: context.state.timerStart...Date(timeInterval: Double(context.state.setEntry.rest), since: context.state.timerStart))
}

func SetGauge(context: ActivityViewContext<WorkoutTimer>) -> some View {
    VStack {
        Text("Set \(context.state.currentSet) of \(context.state.setCount)")
            .font(.callout)
        Gauge(value: Float(min(context.state.currentSet, context.state.setCount)), in: 0...Float(context.state.setCount)) {
        }.gaugeStyle(.accessoryLinearCapacity)
            .tint(Constants.mainAppTheme)
    }
}

func TimerGauge(context: ActivityViewContext<WorkoutTimer>) -> some View {
    ProgressView(timerInterval: context.state.timerStart...Date(timeInterval: Double(context.state.setEntry.rest), since: context.state.timerStart), countsDown: true)
}
