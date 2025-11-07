import SwiftUI

struct RecentBodyfat: View {
    
    @Environment(ProgressManager.self) private var hkm
    
    var body: some View {
        GroupBox {
            NavigationLink {
                HealthData(type: .bodyFat)
            } label: {
                VStack {
                    VStack(alignment: .leading, spacing: 0) {
                        ReusedViews.Labels.HeaderWithArrow(title: "Body Fat")
                        ReusedViews.Labels.Subheader(title: "This month")
                    }
                    ReusedViews.Charts.BarChartMonth(data: hkm.monthBodyFatData, color: Constants.bodyFatTheme)
                }
            }
        }
        .frame(idealWidth: .infinity, maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
    }
    
}
