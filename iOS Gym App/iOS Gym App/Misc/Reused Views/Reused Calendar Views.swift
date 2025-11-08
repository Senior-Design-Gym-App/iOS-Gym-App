import SwiftUI

extension ReusedViews {
    
    struct CalendarViews {
                
        static func IndicatorGrid(day: Date, bodyFat: [WeightEntry], bodyWeight: [WeightEntry], allExercises: [Exercise]) -> some View {
            HStack(spacing: 5) {
                if bodyFat.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: day) }) {
                    CircleView(color: .pink)
                } else {
                    CircleView(color: .gray)
                }
                if bodyWeight.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: day) }) {
                    CircleView(color: .purple)
                } else {
                    CircleView(color: .gray)
                }
                if allExercises.contains(where: { exercise in
                    exercise.updateDates.contains { updateDate in
                        Calendar.current.isDate(updateDate, inSameDayAs: day)
                    }
                }) {
                    CircleView(color: .orange)
                } else {
                    CircleView(color: .gray)
                }
    //            if allExercises.contains(where: { $0. })
                CircleView(color: .gray)
            }
        }
        
        static func generateMonthGrid() -> [Date] {
            let date = Date()
            var days: [Date] = []
            let calendar = Calendar.current
            
            guard let monthInterval = calendar.dateInterval(of: .month, for: date) else {
                return days
            }
            
            var startOfGrid = monthInterval.start
            while calendar.component(.weekday, from: startOfGrid) != calendar.firstWeekday {
                startOfGrid = calendar.date(byAdding: .day, value: -1, to: startOfGrid)!
            }
            
            var endOfGrid = monthInterval.end
            while calendar.component(.weekday, from: endOfGrid) != ((calendar.firstWeekday + 6 - 1) % 7) + 1 {
                endOfGrid = calendar.date(byAdding: .day, value: 1, to: endOfGrid)!
            }
            
            var current = startOfGrid
            while current < endOfGrid {
                days.append(current)
                current = calendar.date(byAdding: .day, value: 1, to: current)!
            }
            
            return days
        }
        
        private static func CircleView(color: Color) -> some View {
            Circle()
                .frame(height: 5)
                .foregroundColor(color)
        }
        
    }
    
}
