import SwiftUI

struct HealthData: View {
    
    @Environment(ProgressManager.self) private var hkm
//    @Environment(AppHandler.self) private var ah: AppHandler
    @State var type: HealthKitType = .bodyWeight
    @AppStorage("sortMethod") private var sortMethod: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Health Type", selection: $type) {
                        Text("Body Fat").tag(HealthKitType.bodyFat)
                        Text("Body Weight").tag(HealthKitType.bodyWeight)
                    }
                    .pickerStyle(.segmented)
                    if type == .bodyFat {
                        ReusedViews.ProgressChartView(color: .pink, unit: "%", data: hkm.bodyFatData)
                    } else {
                        ReusedViews.ProgressChartView(color: .pink, unit: hkm.weightUnitString, data: hkm.bodyWeightData)
                    }
                }
                Section {
                    switch type {
                    case .bodyFat:
                        if sortMethod {
                            ForEach(hkm.bodyFatData.indices.reversed(), id: \.self) { index in
                                WeightEntryViews().DataView(data: hkm.bodyFatData[index], label: "%")
                            }
                        } else {
                            ForEach(hkm.bodyFatData.indices, id: \.self) { index in
                                WeightEntryViews().DataView(data: hkm.bodyFatData[index], label: "%")
                            }
                        }
                    case .bodyWeight:
                        if sortMethod {
                            ForEach(hkm.bodyWeightData.indices.reversed(), id: \.self) { index in
                                WeightEntryViews().DataView(data: hkm.bodyWeightData[index], label: hkm.weightUnitString)
                            }
                        } else {
                            ForEach(hkm.bodyWeightData.indices, id: \.self) { index in
                                WeightEntryViews().DataView(data: hkm.bodyWeightData[index], label: hkm.weightUnitString)
                            }
                        }
                    }
                } header: {
                    WeightEntryViews().DataHeader()
                }
            }
            .navigationTitle("Health Data")
            .toolbar {
                ToolbarItemGroup(placement: .secondaryAction) {
                    if let url = URL(string: "x-apple-health://") {
                        Button {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label("Open Health App", systemImage: "iphone.and.arrow.forward")
                        }
                    }
                    RefreshHealthDataButton()
                }
            }
        }
    }
    
    private func RefreshHealthDataButton() -> some View {
        Button {
            Task {
                do {
                    try await hkm.FetchBodyFatData()
                    try await hkm.FetchBodyWeightData()
                } catch {
//                    ah.HandleError(error: error, errorType: error.localizedDescription)
                }
            }
        } label: {
            Label("Refresh Health Data", systemImage: "arrow.clockwise")
                .tint(.pink)
        }
    }
    
}
