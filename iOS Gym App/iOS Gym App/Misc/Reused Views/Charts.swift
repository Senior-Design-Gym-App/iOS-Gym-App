import Charts
import SwiftUI

extension ReusedViews {
    
    struct Charts {
                
        static func BarChart(data: [WeightEntry], color: Color) -> some View {
            Chart {
                ForEach(data, id: \.self) { progress in
                    PointMark(
                        x: .value("Date", progress.date),
                        y: .value("Weight", progress.value),
                    )
                }
            }.foregroundStyle(color)
        }
        
        static func BarChartMonth(data: [WeightEntry], color: Color) -> some View {
            Chart {
                ForEach(data, id: \.self) { progress in
                    PointMark(
                        x: .value("Date", progress.date, unit: .day),
                        y: .value("Weight", progress.value),
                    )
                }
            }.foregroundStyle(color)
        }
        
        static func BarChartMonth(data: [SetData], color: Color) -> some View {
            Chart {
                ForEach(data, id: \.self) { progress in
                    PointMark(
                        x: .value("Date", progress.reps),
                        y: .value("Weight", progress.weight),
                    )
                }
            }.foregroundStyle(color)
        }
        
        static func BarMarks(sets: [SetData], color: Color, offset: Double) -> some ChartContent {
            ForEach(sets) { set in
                BarMark(
                    x: .value("Set", set.setDouble - 1 + offset),
                    y: .value("Weight", set.weight)
                )
            }.foregroundStyle(color)
                .cornerRadius(Constants.smallRadius)
        }
        
        func DataRecapPieChart(sessions: [WorkoutSession], type: DonutDisplayType) -> some View {
            VStack {
                HStack {
                    Chart(CalculateSessionSets(sessions: sessions, displayType: type)) { group in
                        SectorMark(
                            angle: .value("Sets", group.sets),
                            innerRadius: .ratio(0.6),
                            angularInset: 1.5
                        )
                        .foregroundStyle(group.muscle.colorPalette)
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(CalculateSessionSets(sessions: sessions, displayType: type)) { group in
                            HStack {
                                Circle()
                                    .fill(group.muscle.colorPalette)
                                    .frame(width: 25, height: 25)
                                VStack(alignment: .leading) {
                                    Text(group.muscle.rawValue)
                                    Group {
                                        if type == .reps || type == .sets {
                                            Text("\(group.sets) \(type.unit)\(group.sets == 1 ? "" : "s")")
                                        } else {
                                            Text("\(group.sets) \(type.unit)")
                                        }
                                    }                                        .font(.caption2)
                                        .fontWeight(.thin)
                                }
                            }
                        }
                    }
                }
            }.listRowSeparator(.hidden)
        }
        
        private func CalculateSessionSets(sessions: [WorkoutSession], displayType: DonutDisplayType) -> [DonutData] {
            var muscleSetDict: [MuscleGroup: Int] = [:]
            for session in sessions {
                
                guard let exercises = session.exercises else { continue }
                
                for entry in exercises {
                    
                    let group: MuscleGroup
                    
                    if let exercise = entry.exercise, let muscleGroup = exercise.muscleGroup {
                        group = muscleGroup
                    } else {
                        group = .unknown
                    }
                    
                    let value: Int
                    
                    switch displayType {
                    case .sets:
                        value = entry.setEntry.count
                    case .reps:
                        value = entry.reps.reduce(0, +)
                    case .weight:
                        value = entry.weight.reduce(0) { $0 + Int($1) }
                    case .volume:
                        value = entry.setEntry.reduce(into: 0) { $0 += Int($1.setVolume) }
                    }
                    
                    muscleSetDict[group, default: 0] += value
                }
            }
            
            return muscleSetDict.map { DonutData(muscle: $0.key, sets: $0.value) }
                .sorted { $0.muscle.rawValue < $1.muscle.rawValue }
        }
                
    }
    
    struct ProgressChartView: View {
        
        let color: Color
        let unit: String
        let data: [WeightEntry]
        @State private var rawSelectedDate: Date?
        
        var body: some View {
            Chart {
                if let viewPoint = nearestProgress(selectedDate: rawSelectedDate) {
                    RuleMark(x: .value("Progress", viewPoint.date))
                        .annotation(position: .trailing, overflowResolution: .automatic) {
                            GroupBox {
                                Text(formattedDate(from: viewPoint.date))
                                Text("\(viewPoint.value, specifier: "%.1f") \(unit)")
                            }
                        }
                }
                
                ForEach(data, id: \.self) { progress in
                    LineMark(
                        x: .value("Date", progress.date),
                        y: .value("Weight", progress.value),
                    )
                    .foregroundStyle(color.tertiary)

                    PointMark(
                        x: .value("Date", progress.date),
                        y: .value("Weight", progress.value)
                    )
                    .foregroundStyle(color.secondary)
                }
            }
            .foregroundStyle(color)
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
        }
        
        private func formattedDate(from date: Date) -> String {
            let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: Date())
            let dateYear = calendar.component(.year, from: date)
            
            let formatter = DateFormatter()
            formatter.dateFormat = (dateYear == currentYear) ? "MMM d" : "MMM d, yyyy"
            
            return formatter.string(from: date)
        }
        
        private func nearestProgress(selectedDate: Date?) -> WeightEntry? {
            guard let selectedDate, !data.isEmpty else { return nil }
            
            return data.min { abs($0.date.timeIntervalSince(selectedDate)) <
                              abs($1.date.timeIntervalSince(selectedDate)) }
        }
    }
    
}
