import SwiftUI

struct SessionConfigurationView: View {
    
    @AppStorage("useRestTimer") private var useRestTimer: Bool = true
    @AppStorage("shareSession") private var shareSession: Bool = true
    @AppStorage("monitorHeartRate") private var monitorHeartRate: Bool = true
    @AppStorage("saveToAppleHealth") private var saveToAppleHealth: Bool = true
    @AppStorage("collapseSessionOptions") private var collapseSessionOptions: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    PreviewSession()
                } header: {
                    Text("Preview")
                }
                Section {
                    HeartRateToggle()
                    TimerToggle()
                    ShareToggle()
                    HealthToggle()
                } header: {
                    Text("Session Options")
                }
                Section {
                    
                } header: {
                    Text("Session Prefrences")
                }
                Section {
                    
                } header: {
                    
                }
                Section {
                    
                } header: {
                    
                }
            }
            .navigationTitle("Session Options")
        }
    }
    
    private func PreviewSession() -> some View {
        VStack {
            TopControls()
            TimerInfo()
            BottomInfo()
        }
    }
    
    private func TopControls() -> some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Workout Name")
                        .font(.headline)
                    Text("Set Counter")
                        .font(.subheadline)
                    Gauge(
                        value: 1,
                        in: 0...3
                    ) {
                    }
                    .gaugeStyle(.accessoryLinearCapacity)
                    .frame(width: 70)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    HStack {
                        PreviousWorkoutButton()
                        NextWorkoutButton()
                    }
                    
                }
            }
        }
    }
    
    private func BottomInfo() -> some View {
        HStack {
            if useRestTimer {
                RestartTimer()
                PreviousSetButton()
                PlayPauseButton()
                NextSetButton()
                EndSessionButton()
            } else {
                PreviousSetButton()
                EndSessionButton()
                NextSetButton()
            }
        }
    }
    
    private func PreviousWorkoutButton() -> some View {
        Button {
        } label: {
            Label("Previous Workout", systemImage: "backward.end.circle.fill")
                .labelStyle(.iconOnly)
                .font(.title2)
        }
    }
    
    private func NextWorkoutButton() -> some View {
        Button {
        } label: {
            Label("Next Workout", systemImage: "forward.end.circle.fill")
                .labelStyle(.iconOnly)
                .font(.title2)
        }
    }
    
    private func TimerInfo() -> some View {
        Gauge(value: 25, in: 0...60) {
        } currentValueLabel: {
            Text("1:05")
                .font(.title2)
                .fontWeight(.medium)
        } minimumValueLabel: {
            Text("0")
        } maximumValueLabel: {
            Text("90")
        }
        .gaugeStyle(.linearCapacity)
    }
    
    private func RestartTimer() -> some View {
        Button {
        } label: {
            Label("Restart Timer", systemImage: "arrow.counterclockwise")
                .labelStyle(.iconOnly)
                .font(.largeTitle)
        }
    }
    
    private func PreviousSetButton() -> some View {
        Button {
        } label: {
            Label("Previous Set", systemImage: "backward")
                .labelStyle(.iconOnly)
                .font(.largeTitle)
        }
    }
    
    private func NextSetButton() -> some View {
        Button {
        } label: {
            Label("Next Set", systemImage: "forward")
                .labelStyle(.iconOnly)
                .font(.largeTitle)
        }
    }
    
    private func EndSessionButton() -> some View {
        Menu {
            Button {
            } label: {
                Label("End Day", systemImage: "arrow.right.square")
            }
            Button {
                //                EndSession()
            } label: {
                Label("End Day at Specific Time", systemImage: "clock")
            }
            Button {
                //                EndSession()
            } label: {
                Label("End Day & Generate Report", systemImage: "list.bullet.clipboard")
            }
            Button {
                //                EndSession()
            } label: {
                Label("Discard Session & Exit", systemImage: "trash")
            }
        } label: {
            Label("End Day", systemImage: "stop")
                .tint(.red)
                .labelStyle(.iconOnly)
                .font(.largeTitle)
        }
    }
    
    private func PlayPauseButton() -> some View {
        Button {
        } label: {
            Label("Play Pause", systemImage: "pause")
                .labelStyle(.iconOnly)
                .font(.largeTitle)
        }
    }
    
    private func HeartRateToggle() -> some View {
        Toggle(isOn: $monitorHeartRate) {
            Label {
                Text("Heart Rate")
            } icon: {
                Image(systemName: "applewatch")
                    .foregroundStyle(.pink)
            }
        }
        .tint(.pink)
    }
    
    private func TimerToggle() -> some View {
        Toggle(isOn: $useRestTimer) {
            Label {
                Text("Rest Timer")
            } icon: {
                Image(systemName: "clock")
                    .foregroundStyle(.purple)
            }
        }
        .tint(.purple)
    }
    
    private func ShareToggle() -> some View {
        Toggle(isOn: $shareSession) {
            Label {
                Text("Share Session")
            } icon: {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(.cyan)
            }
        }
        .tint(.cyan)
    }
    
    private func HealthToggle() -> some View {
        Toggle(isOn: $saveToAppleHealth) {
            Label {
                Text("Save to Health")
            } icon: {
                Image(systemName: "heart.square")
                    .foregroundStyle(.indigo)
            }
        }
        .tint(.indigo)
    }

    
}
