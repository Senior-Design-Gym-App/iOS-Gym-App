import SwiftUI

struct RecentMonthActivity: View {
    
    let allExercises: [Exercise]
    let allSessions: [WorkoutSession]
    private let calendar = Calendar.current
    
    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
    
    @Environment(ProgressManager.self) private var hkm
    
    var body: some View {
        GroupBox {
            NavigationLink {
                WeeklyActivity()
            } label: {
                VStack(alignment: .leading, spacing: 0) {
                    ReusedViews.Labels.HeaderWithArrow(title: "Monthly Activity")
                    ReusedViews.Labels.Subheader(title: monthYearString)
                }
            }
            MonthGridView()
        }
        .frame(idealWidth: .infinity, maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func MonthGridView() -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
            ForEach(generateMonthGrid(), id: \.self) { day in
                if calendar.isDate(day, equalTo: Date(), toGranularity: .month) {
                    ProgressDay(daysDate: day)
                }
            }
        }
    }

    private func ProgressDay(daysDate: Date) -> some View {
        NavigationLink {
            DayActivity(dayProgress: daysDate, session: allSessions, allExercises: allExercises)
        } label: {
            VStack(spacing: 5) {
                GenerateImage(for: daysDate)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(allSessions.contains(where: { calendar.isDate($0.completed ?? Date.distantPast, inSameDayAs: daysDate) }) ? .blue : .gray)
                IndicatorGrid(day: daysDate)
            }
        }.navigationLinkIndicatorVisibility(.hidden)
    }
    
    private func IndicatorGrid(day: Date) -> some View {
        HStack {
            if hkm.bodyFatData.contains(where: { calendar.isDate($0.date, inSameDayAs: day) }) {
                CircleView(color: .pink)
            } else {
                CircleView(color: .gray)
            }
            if hkm.bodyWeightData.contains(where: { calendar.isDate($0.date, inSameDayAs: day) }) {
                CircleView(color: .purple)
            } else {
                CircleView(color: .gray)
            }
            if allExercises.contains(where: { exercise in
                exercise.updateDates.contains { updateDate in
                    calendar.isDate(updateDate, inSameDayAs: day)
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
    
    private func CircleView(color: Color) -> some View {
        Circle()
            .frame(height: 5)
            .foregroundColor(color)
    }
    
    private func generateMonthGrid() -> [Date] {
        let date = Date()
        var days: [Date] = []

        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else {
            return days
        }

        var current = firstWeek.start

        while current <= lastWeek.end {
            days.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }

        return days
    }
    
    private func GenerateImage(for date: Date) -> Image {
        let dayNumber = Calendar.current.component(.day, from: date)
        let imageName = "\(dayNumber).circle.fill"

        return Image(systemName: imageName)
    }

    private var monthYearString: String {
          let formatter = DateFormatter()
          formatter.dateFormat = "MMMM yyyy"
          return formatter.string(from: Date())
      }
    
}
