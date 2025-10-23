//
//  Live_Activity_TimerBundle.swift
//  Live Activity Timer
//
//  Created by Troy Madden on 10/23/25.
//

import WidgetKit
import SwiftUI

@main
struct Live_Activity_TimerBundle: WidgetBundle {
    var body: some Widget {
        Live_Activity_Timer()
        Live_Activity_TimerControl()
        Live_Activity_TimerLiveActivity()
    }
}
