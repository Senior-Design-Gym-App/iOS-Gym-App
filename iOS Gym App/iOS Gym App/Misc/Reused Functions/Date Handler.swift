import SwiftUI

final class DateHandler {
    
    func RelativeTime(from lastTouchTime: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.minute, .hour, .day], from: lastTouchTime, to: now)
        
        if let day = components.day, day > 0 {
            return day == 1 ? "1 day ago" : "\(day) days ago"
        } else if let hour = components.hour, hour > 0 {
            return hour == 1 ? "1 hour ago" : "\(hour) hours ago"
        } else if let minute = components.minute, minute > 0 {
            return minute == 1 ? "1 minute ago" : "\(minute) minutes ago"
        } else {
            return "now"
        }
    }
    
    static func MonthYearString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    private struct TimeAPIResponse: Decodable {
        let dateTime: String
    }
    
    func DayNumber(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    func IsInCurrentMonth(date: Date?) -> Bool {
        guard let date = date else {
            return false
        }
        let calendar = Calendar.current
        let now = Date()

        let dateComponents = calendar.dateComponents([.year, .month], from: date)
        let currentComponents = calendar.dateComponents([.year, .month], from: now)

        return dateComponents.year == currentComponents.year &&
               dateComponents.month == currentComponents.month
    }
    
    func countDatesInCurrentMonth(dates: [Date]) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let currentComponents = calendar.dateComponents([.year, .month], from: now)

        return dates.filter { date in
            let dateComponents = calendar.dateComponents([.year, .month], from: date)
            return dateComponents.year == currentComponents.year &&
                   dateComponents.month == currentComponents.month
        }.count
    }
    
}

extension Date {
    func startOfMonth() -> Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
    }

    func endOfMonth() -> Date {
        let start = startOfMonth()
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: 0), to: start)!
    }
}
