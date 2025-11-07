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
                        ReusedViews.Labels.Subheader(title: "This month")
                    }
                    ReusedViews.Charts.BarChartMonth(data: hkm.monthBodyWeightData, color: Constants.bodyWeightTheme)
                }
            }
        }
        .frame(idealWidth: .infinity, maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
    }
    
}
