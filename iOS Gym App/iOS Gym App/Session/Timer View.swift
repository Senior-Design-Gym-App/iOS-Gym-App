import SwiftUI
import ActivityKit

struct SessionTimerView: View {
    
    let sessionManager: SessionManager
    
    @AppStorage("showTimer") private var showTimer: Bool = true
    
    var body: some View {
        if showTimer {
            VStack(spacing: 15) {
                TimerInfo()
                HStack {
                    Group {
                        Text(TimeElapsedText(sessionManager.elapsedTime))
                        Spacer()
                        Text(TimeRemainingText())
                    }
                    .fontWeight(.ultraLight)
                    .font(.caption2)
                }
            }
        }
    }
    
    private func TimerInfo() -> some View {
        Gauge(value: sessionManager.progress, in: 0...1.0) {
        } currentValueLabel: {
        }
        .scaleEffect(x: 1.0, y: 1.75)
        .gaugeStyle(.accessoryLinearCapacity)
    }
    
    private func TimeElapsedText(_ interval: TimeInterval) -> String {
        let totalSeconds = max(0, Int(interval.rounded(.down)))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func TimeRemainingText() -> String {
        if let activityState = sessionManager.exerciseTimer?.content.state {
            let endTime = activityState.timerStart.addingTimeInterval(Double(activityState.setEntry.rest))
            let remaining = endTime.timeIntervalSince(Date.now)
            let seconds = max(0, Int(remaining))
            
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return String(format: "%d:%02d", minutes, remainingSeconds)
        }
        
        return "0:00"
    }

    
}
