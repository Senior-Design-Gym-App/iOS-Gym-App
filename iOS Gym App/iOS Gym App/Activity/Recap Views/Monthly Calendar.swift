import SwiftUI
import SwiftData

struct MonthlyCalendarView: View {
    
    let viewingMonth: Date
    @Binding var selectedDate: Date?
    @Environment(ProgressManager.self) private var hkm
    @Namespace private var namespace
    @Query private var allExercises: [Exercise]
    @Query private var allSessions: [WorkoutSession]
    
    var body: some View {
        Section {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(GenerateMonthGrid(month: viewingMonth), id: \.self) { day in
                    ProgressDay(daysDate: day, bodyFat: hkm.bodyFatData, bodyWeight: hkm.bodyWeightData, allExercises: allExercises, inMonth: Calendar.current.isDate(day, equalTo: viewingMonth, toGranularity: .month))
                }
            }
            ActivityLabel()
        }
    }
    
    private func ProgressDay(daysDate: Date, bodyFat: [WeightEntry], bodyWeight: [WeightEntry], allExercises: [Exercise], inMonth: Bool) -> some View {
        Button {
            selectedDate = daysDate
        } label: {
            DayLabel(daysDate: daysDate, bodyFat: bodyFat, bodyWeight: bodyWeight, allExercises: allExercises, inMonth: inMonth)
        }
        .buttonStyle(.plain)
        .matchedTransitionSource(id: daysDate, in: namespace)
    }
    
    private func ActivityLabel() -> some View {
        HStack(spacing: 5) {
            Spacer()
            Image(systemName: "square.fill")
                .foregroundStyle(ColorSwitch(eventCount: 1))
            Image(systemName: "square.fill")
                .foregroundStyle(ColorSwitch(eventCount: 2))
            Image(systemName: "square.fill")
                .foregroundStyle(ColorSwitch(eventCount: 3))
            Image(systemName: "square.fill")
                .foregroundStyle(ColorSwitch(eventCount: 4))
            Image(systemName: "square.fill")
                .foregroundStyle(ColorSwitch(eventCount: 5))
        }
    }

    
    private func GenerateMonthGrid(month: Date) -> [Date] {
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
    
    private func DetermineEventsCount(day: Date, bodyFat: [WeightEntry], bodyWeight: [WeightEntry], allExercises: [Exercise]) -> Color {
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
        let completedDates = allSessions.compactMap { $0.completed }
        if completedDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: day) }) {
            eventCount += 1
        }
        // dont forget to include PRs
        //            if allExercises.contains(where: { $0. })
        return ColorSwitch(eventCount: eventCount)
    }
    
    private func ColorSwitch(eventCount: Int) -> Color {
        switch eventCount {
        case 5:     // 4 should be the max ????
            return Constants.calendarTheme.opacity(1.0)
        case 4:
            return Constants.calendarTheme.opacity(0.8)
        case 3:
            return Constants.calendarTheme.opacity(0.6)
        case 2:
            return Constants.calendarTheme.opacity(0.4)
        case 1:
            return Constants.calendarTheme.opacity(0.30)
        default:
            return Color.gray
        }
    }
    
    private func DayLabel(daysDate: Date, bodyFat: [WeightEntry], bodyWeight: [WeightEntry], allExercises: [Exercise], inMonth: Bool) -> some View {
        GenerateImage(for: daysDate)
            .resizable()
            .scaledToFit()
            .foregroundStyle(DetermineEventsCount(day: daysDate, bodyFat: bodyFat, bodyWeight: bodyWeight, allExercises: allExercises))
            .opacity(inMonth ? 1.0 : 0.0)
    }
    
    private func GenerateImage(for date: Date) -> Image {
        let dayNumber = Calendar.current.component(.day, from: date)
        let imageName = "\(dayNumber).square.fill"
        
        return Image(systemName: imageName)
    }

    
}
