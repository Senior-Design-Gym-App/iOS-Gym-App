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
