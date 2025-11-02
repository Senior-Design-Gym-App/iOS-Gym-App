import SwiftUI

struct RecentBodyweight: View {
    
    @Environment(ProgressManager.self) private var hkm
    
    var body: some View {
        GroupBox {
            NavigationLink {
                HealthData(type: .bodyWeight)
            } label: {
                VStack {
                    VStack(alignment: .leading, spacing: 0) {
                        ReusedViews.Labels.HeaderWithArrow(title: "Weight")
                        ReusedViews.Labels.Subheader(title: "test.")
                    }
                    if hkm.bodyWeightData.isEmpty {
                        Text("No body weight data available.")
                    } else {
                        ReusedViews.ProgressChartView(color: .pink, unit: "%", data: hkm.bodyWeightData)
                    }
                }
            }
        }
        .frame(idealWidth: .infinity, maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
    }
    
}
