import SwiftUI
import Charts

struct DetailedWeightEntry: View {
    
    let exercise: Exercise
    let weightEntries: [WeightEntry]
    let type: DetailedWeightEntryTypes
    @Environment(ProgressManager.self) private var hkm
    
    private var earliestDate: Date {
        let allDates = weightEntries.map { $0.date }
        return allDates.min() ?? Date()
    }
    
    private var latestDate: Date {
        let allDates = weightEntries.map { $0.date }
        return allDates.max() ?? Date()
    }
    
    private var filteredBodyFat: [WeightEntry] {
        hkm.bodyFatData.filter { $0.date >= earliestDate && $0.date <= latestDate }
    }
    
    private var filteredBodyWeight: [WeightEntry] {
        hkm.bodyWeightData.filter { $0.date >= earliestDate && $0.date <= latestDate }
    }
    
    private var maxOneRepMax: Double {
        let max = weightEntries.map { $0.value }.max()
        guard let max else {
            return 1
        }
        return max == 0 ? 1 : max
    }
    
    private var normalizedOneRepMaxes: [WeightEntry] {
        var normalized: [WeightEntry] = []
        
        for data in weightEntries {
            normalized.append(WeightEntry(index: 0, value: data.value / maxOneRepMax, date: data.date))
        }
        return normalized
    }
    
    private var normalizedBodyWeight: [WeightEntry] {
        var normalized: [WeightEntry] = []
        
        for data in filteredBodyWeight {
            normalized.append(WeightEntry(index: 0, value: data.value / maxOneRepMax, date: data.date))
        }
        return normalized
    }
    
    private var normalizedBodyFat: [WeightEntry] {
        var normalized: [WeightEntry] = []
        
        for data in filteredBodyFat {
            normalized.append(WeightEntry(index: 0, value: data.value / maxOneRepMax, date: data.date))
        }
        return normalized
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ReusedViews.Charts.PointMarkDay(data: weightEntries, color: exercise.color, label: hkm.weightUnitString)
                }
                Section {
                    ReusedViews.Charts.PointMarkDay(data: filteredBodyFat, color: Constants.healthColor, label: "%")
                }
                Section {
                    ReusedViews.Charts.PointMarkDay(data: filteredBodyWeight, color: Constants.healthColor, label: hkm.weightUnitString)
                }
                Section {
                    Chart {
                        ReusedViews.Charts.PointMarks(data: normalizedOneRepMaxes, color: exercise.color)
                        ReusedViews.Charts.PointMarks(data: normalizedBodyWeight, color: Constants.healthColor)
                        ReusedViews.Charts.PointMarks(data: normalizedBodyFat, color: Constants.healthColor)
                    }
                } header: {
                    Text("Normalized Data")
                }
            }
            .navigationTitle(exercise.name)
            .navigationSubtitle(type.rawValue)
        }
    }
    
    
    
}
