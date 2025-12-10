import ActivityKit
import WidgetKit
import SwiftUI

@DynamicIslandExpandedContentBuilder
func ExerciseTimerExpandedView(context: ActivityViewContext<WorkoutTimer>) -> DynamicIslandExpandedContent<some View> {
    
    DynamicIslandExpandedRegion(.leading) {
        CircularGauge(context: context)
            .padding(.trailing, 30)
    }
    
    DynamicIslandExpandedRegion(.center) {
        Text(context.state.currentExercise.exercise.name)
            .font(.title3)
    }
    
    DynamicIslandExpandedRegion(.trailing) {
        TimerGauge(context: context)
            .padding(.leading, 30)
    }
    
    DynamicIslandExpandedRegion(.bottom) {
        HStack {
            Text(context.state.sessionName)
                .font(.caption)
            Spacer()
            SessionTimeLength(context: context)
                .font(.caption)
        }.padding(.horizontal)
    }
    
}

func ElapsedTime(context: ActivityViewContext<WorkoutTimer>) -> some View {
    Text(context.state.timerStart, style: .timer)
}

func CircularGauge(context: ActivityViewContext<WorkoutTimer>) -> some View {
    ProgressView(value: Float(context.state.currentExercise.currentSet), total: Float(context.state.currentExercise.totalSets)) {
        ExerciseIcon(context: context)
    }
    .progressViewStyle(.circular)
    .tint(context.state.currentExercise.exercise.color)
}

func ExerciseIcon(context: ActivityViewContext<WorkoutTimer>) -> some View {
    Label("Equipment", systemImage: context.state.currentExercise.exercise.workoutEquipment?.imageName ?? "questionmark")
        .labelStyle(.iconOnly)
        .foregroundStyle(context.state.currentExercise.exercise.color)
}

func TimerGauge(context: ActivityViewContext<WorkoutTimer>) -> some View {
    ProgressView(timerInterval: context.state.timerStart...Date(timeInterval: Double(context.state.currentExercise.exercise.recentSetData.rest[context.state.currentExercise.currentSet]), since: context.state.timerStart))
        .progressViewStyle(.circular)
        .foregroundStyle(context.state.currentExercise.exercise.color)
        .tint(context.state.currentExercise.exercise.color)
}

func SessionTimeLength(context: ActivityViewContext<WorkoutTimer>) -> some View {
    Text(context.state.sessionStartDate, style: .timer)
}
