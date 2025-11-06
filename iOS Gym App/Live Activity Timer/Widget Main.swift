//
//  Live_Activity_TimerBundle.swift
//  Live Activity Timer
//
//  Created by Matthew Jacobs on 10/23/25.
//

import WidgetKit
import SwiftUI

@main
struct Live_Activity_TimerBundle: WidgetBundle {
    var body: some Widget {
        WorkoutTimerLiveActivity()
        WorkoutWidget()
    }
}
