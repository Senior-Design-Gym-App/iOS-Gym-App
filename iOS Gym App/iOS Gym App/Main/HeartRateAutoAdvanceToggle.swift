//
//  HeartRateAutoAdvanceToggle.swift
//  watchOS Gym App
//
//  Toggle control for heart rate-based auto-advance feature
//

import SwiftUI

struct HeartRateAutoAdvanceToggle: View {
    @Bindable var sessionManager: WatchSessionManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $sessionManager.isAutoAdvanceEnabled) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                        Text("Auto-Advance")
                            .font(.headline)
                    }
                    
                    Text("Automatically advance to next set when heart rate recovers")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .onChange(of: sessionManager.isAutoAdvanceEnabled) { oldValue, newValue in
                if newValue && sessionManager.isSessionActive {
                    sessionManager.startHeartRateMonitoring()
                } else if !newValue {
                    sessionManager.stopHeartRateMonitoring()
                }
            }
            
            // Show current heart rate when monitoring
            if sessionManager.isAutoAdvanceEnabled && sessionManager.currentHeartRate > 0 {
                HStack {
                    Image(systemName: "waveform.path.ecg")
                        .foregroundStyle(.red)
                    Text("\(Int(sessionManager.currentHeartRate)) BPM")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding(.leading, 4)
            }
        }
        .padding()
    }
}

#Preview {
    HeartRateAutoAdvanceToggle(sessionManager: WatchSessionManager())
}
