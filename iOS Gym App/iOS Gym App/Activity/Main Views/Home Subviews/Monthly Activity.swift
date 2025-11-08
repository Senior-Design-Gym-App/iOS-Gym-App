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
            ForEach(ReusedViews.CalendarViews.generateMonthGrid(), id: \.self) { day in
                ProgressDay(daysDate: day, inMonth: calendar.isDate(day, equalTo: Date(), toGranularity: .month))
            }
        }
    }

    private func ProgressDay(daysDate: Date, inMonth: Bool) -> some View {
        NavigationLink {
            DayActivity(dayProgress: daysDate, session: allSessions, allExercises: allExercises)
        } label: {
            VStack(spacing: 5) {
                GenerateImage(for: daysDate)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(allSessions.contains(where: { calendar.isDate($0.completed ?? Date.distantPast, inSameDayAs: daysDate) }) ? .blue : .gray)
//                    .bold(calendar.isDate(daysDate, inSameDayAs: Date()))
                ReusedViews.CalendarViews.IndicatorGrid(day: daysDate, bodyFat: hkm.monthBodyFatData, bodyWeight: hkm.monthBodyWeightData, allExercises: allExercises)
            }
        }.navigationLinkIndicatorVisibility(.hidden)
            .disabled(!inMonth)
            .opacity(inMonth ? 100 : 0)
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
