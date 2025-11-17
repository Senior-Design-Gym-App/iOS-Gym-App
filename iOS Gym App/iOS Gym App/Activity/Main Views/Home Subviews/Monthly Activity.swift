import SwiftUI
import SwiftData

struct RecentMonthActivity: View {
    
    @Namespace private var namespace
    @Environment(ProgressManager.self) private var hkm
    @Query private var allExercises: [Exercise]
    
    var body: some View {
        GroupBox {
            NavigationLink {
                MonthlyProgressView()
            } label: {
                ReusedViews.Labels.HeaderWithArrow(title: "Monthly Activity")
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(ReusedViews.CalendarViews.GenerateMonthGrid(month: Date()), id: \.self) { day in
                    ProgressDay(daysDate: day, bodyFat: hkm.bodyFatData, bodyWeight: hkm.bodyWeightData, allExercises: allExercises, inMonth: Calendar.current.isDate(day, equalTo: Date(), toGranularity: .month))
                }
            }
        }
        .frame(idealWidth: .infinity, maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func ProgressDay(daysDate: Date, bodyFat: [WeightEntry], bodyWeight: [WeightEntry], allExercises: [Exercise], inMonth: Bool) -> some View {
        NavigationLink {
            DayActivity(dayProgress: daysDate)
                .navigationTransition(.zoom(sourceID: daysDate, in: namespace))
        } label: {
            ReusedViews.CalendarViews.DayLabel(daysDate: daysDate, bodyFat: bodyFat, bodyWeight: bodyWeight, allExercises: allExercises, inMonth: inMonth)
        }
        .navigationLinkIndicatorVisibility(.hidden)
        .disabled(!inMonth)
        .matchedTransitionSource(id: daysDate, in: namespace)
    }
    
}
