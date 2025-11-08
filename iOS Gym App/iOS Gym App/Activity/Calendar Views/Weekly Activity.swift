import SwiftUI
import SwiftData

struct WeeklyActivity: View {
    
    @Query private var workoutSessions: [WorkoutSession]
    @Query private var allExercises: [Exercise]
    @State private var viewingDate: Date = Date()
    @State private var showCalendarPopover: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                DatePicker("", selection: $viewingDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
//                ForEach(WeekDays(week: viewingDate), id: \.self) { day in
//                    DayActivity(dayProgress: day, session: workoutSessions, allExercises: allExercises)
//                }
            }
            .navigationTitle("Weekly Activity")
        }
    }
    
    private func WeekDays(week: Date) -> [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: week) else {
            return []
        }
        
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: weekInterval.start)
        }
    }
    
    private func ChangeWeekButton(increase: Bool) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if let date = Calendar.current.date(byAdding: .weekOfMonth, value: increase ? 1 : -1, to: viewingDate) {
                    viewingDate = date
                }
            }
        } label: {
            Image(systemName: increase ? "chevron.right" : "chevron.left")
        }
    }
    
}
