//
//  Live_Activity_TimerLiveActivity.swift
//  Live Activity Timer
//
//  Created by Matthew Jacobs on 9/11/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct WorkoutTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutTimer.self) { context in
            
            ExerciseTimerBannerView(context: context)
            
        } dynamicIsland: { context in
            DynamicIsland {
                ExerciseTimerExpandedView(context: context)
            } compactLeading: {
                ExerciseIcon(context: context)
            } compactTrailing: {
                ElapsedTime(context: context)
            } minimal: {
            }
        }
    }
    
}
