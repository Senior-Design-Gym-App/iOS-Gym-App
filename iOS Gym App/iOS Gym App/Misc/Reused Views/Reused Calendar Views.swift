import SwiftUI
import SwiftData

extension ReusedViews {
    
    struct CalendarViews {
        
        static func GenerateMonthGrid(month: Date) -> [Date] {
            var days: [Date] = []
            let calendar = Calendar.current
            
            guard let monthInterval = calendar.dateInterval(of: .month, for: month) else {
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
        
        static func DetermineEventsCount(day: Date, bodyFat: [WeightEntry], bodyWeight: [WeightEntry], allExercises: [Exercise]) -> Color {
            var eventCount: Int = 0
            if bodyFat.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: day) }) {
                eventCount += 1
            }
            if bodyWeight.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: day) }) {
                eventCount += 1
            }
            if allExercises.contains(where: { exercise in
                exercise.updateDates.contains { updateDate in
                    Calendar.current.isDate(updateDate, inSameDayAs: day)
                }
            }) {
                eventCount += 1
            }
            // dont forget to include PRs
            //            if allExercises.contains(where: { $0. })
            return ColorSwitch(eventCount: eventCount)
        }
        
        static func ColorSwitch(eventCount: Int) -> Color {
            switch eventCount {
            case 1:
                return Constants.calendarTheme.opacity(1.0)
            case 2:
                return Constants.calendarTheme.opacity(0.75)
            case 3:
                return Constants.calendarTheme.opacity(0.5)
            case 4:
                return Constants.calendarTheme.opacity(0.3)
            default:
                return Constants.calendarTheme.opacity(0.22)
            }
        }
        
        static func DayLabel(daysDate: Date, bodyFat: [WeightEntry], bodyWeight: [WeightEntry], allExercises: [Exercise], inMonth: Bool) -> some View {
            GenerateImage(for: daysDate)
                .resizable()
                .scaledToFit()
                .foregroundStyle(DetermineEventsCount(day: daysDate, bodyFat: bodyFat, bodyWeight: bodyWeight, allExercises: allExercises))
                .opacity(inMonth ? 1.0 : 0.0)
        }
        
        private static func GenerateImage(for date: Date) -> Image {
            let dayNumber = Calendar.current.component(.day, from: date)
            let imageName = "\(dayNumber).square.fill"
            
            return Image(systemName: imageName)
        }
                        
    }
    
}
