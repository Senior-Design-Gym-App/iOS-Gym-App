import SwiftUI

struct SessionEndOptionsView: View {
    
    let sessionManager: SessionManager
    @Binding var showQueue: Bool
    
    @AppStorage("monitorHeartRate") private var monitorHeartRate: Bool = true
    
    var body: some View {
        let currentSet = min(sessionManager.currentWorkout?.exercise.weights.count ?? 0, (sessionManager.currentWorkout?.entry.weight.count ?? 0) + 1)
        let totalSets = (sessionManager.currentWorkout?.exercise.weights.count ?? 1)
        HStack {
            Group {
                Text("\(currentSet)")
                SetGauge(currentSet: currentSet, totalSets: totalSets)
                Text("\(totalSets)")
            }
            .fontWeight(.thin)
            .font(.footnote)
        }.padding(.bottom, 5)
        HStack {
            if monitorHeartRate {
                Spacer()
                HeartRateInfo()
            }
            Spacer()
            QueueToggle()
            Spacer()
        }
    }
    
    private func SetGauge(currentSet: Int, totalSets: Int) -> some View {
        Gauge(value: Float(currentSet), in: 0...(Float(totalSets))) {
        }
        .scaleEffect(x: 1.0, y: 1.5)
        .gaugeStyle(.accessoryLinearCapacity)
    }
    
    private func QueueToggle() -> some View {
        Button {
            withAnimation {
                showQueue.toggle()
            }
        } label: {
            Image(systemName: showQueue ? "list.bullet.circle.fill" : "list.bullet").animation(.easeInOut, value: showQueue)
        }
    }
    
    private func HeartRateInfo() -> some View {
        Label {
            Text("17 bpm")
        } icon: {
            Image(systemName: "waveform.path.ecg")
                .symbolEffect(.breathe, isActive: true)
                .foregroundStyle(.pink)
        }
    }
    
}
