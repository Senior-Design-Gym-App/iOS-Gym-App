import SwiftUI
import SwiftData

struct MonthlyProgressView: View {
    
    @Query private var allExercises: [Exercise]
    @Query private var allSessions: [WorkoutSession]
    
    @Namespace private var namespace
    @State private var viewingMonth: Date = Date()
    @State private var selectedDate: Date?
    private let calendar = Calendar.current
    @Environment(ProgressManager.self) private var hkm
    @AppStorage("donutDisplayType") private var displayType: DonutDisplayType = .reps
    
    private var earliestDataMonth: Date {
        let allSessionDates = allSessions.map { $0.started }
        let allUpdateDates = allExercises.flatMap { $0.updateDates }
        let bodyFatDates = hkm.bodyFatData.map { $0.date }
        let bodyweightDates = hkm.bodyWeightData.map { $0.date }
        
        let allDates = allSessionDates + allUpdateDates + bodyFatDates + bodyweightDates
        
        return allDates.min() ?? Date()
    }
    
    private var latestDataMonth: Date {
        let allSessionDates = allSessions.map { $0.started }
        let allUpdateDates = allExercises.flatMap { $0.updateDates }
        let bodyFatDates = hkm.bodyFatData.map { $0.date }
        let bodyweightDates = hkm.bodyWeightData.map { $0.date }
        
        let allDates = allSessionDates + allUpdateDates + bodyFatDates + bodyweightDates
        
        return allDates.max() ?? Date()
    }
    
    private var ActivityCount: (sessions: Int, exercise: Int, health: Int) {
        let allSessionDates = allSessions.map { $0.started }
        let allUpdateDates = allExercises.flatMap { $0.updateDates }
        let bodyFatDates = hkm.bodyFatData.map { $0.date }
        let bodyweightDates = hkm.bodyWeightData.map { $0.date }
        
        let sessionCount = allSessionDates.filter { calendar.isDate($0, equalTo: viewingMonth, toGranularity: .month) }.count
        let updateCount = allUpdateDates.filter { calendar.isDate($0, equalTo: viewingMonth, toGranularity: .month) }.count
        let bodyFatCount = bodyFatDates.filter { calendar.isDate($0, equalTo: viewingMonth, toGranularity: .month) }.count
        let bodyWeightCount = bodyweightDates.filter { calendar.isDate($0, equalTo: viewingMonth, toGranularity: .month) }.count

        
        return (sessionCount, updateCount, bodyFatCount + bodyWeightCount)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    MonthlyCalendarView(viewingMonth: viewingMonth, selectedDate: $selectedDate)
                } header: {
                    ReusedViews.Labels.Header(text: "Daily Activity")
                }
                Section {
                    ReusedViews.Charts().DataRecapPieChart(sessions: allSessions.filter { calendar.isDate($0.started, equalTo: viewingMonth, toGranularity: .month) }, type: displayType).id(viewingMonth)
                    ReusedViews.Pickers.DisplayTypePicker(type: $displayType, exempt: .weight)
                    MonthlySessions(viewingMonth: viewingMonth, allSessions: allSessions)
                } header: {
                    ReusedViews.Labels.Header(text: "Session Data")
                } footer: {
                    Text("\(ActivityCount.sessions) Session\(ActivityCount.sessions == 1 ? "" : "s")")
                }
                Section {
                    MonthlyUpdates(viewingMonth: viewingMonth, allExercises: allExercises)
                } header: {
                    ReusedViews.Labels.Header(text: "Updates")
                } footer: {
                    Text("\(ActivityCount.exercise) Update\(ActivityCount.exercise == 1 ? "" : "s")")
                }
                Section {
                    VStack {
                        ReusedViews.Charts.BarChartMonth(data: hkm.bodyFatData.filter { calendar.isDate($0.date, equalTo: viewingMonth, toGranularity: .month)  }, color: Constants.bodyFatTheme)
                            .listRowSeparator(.hidden)
                        ReusedViews.Charts.BarChartMonth(data: hkm.bodyWeightData.filter { calendar.isDate($0.date, equalTo: viewingMonth, toGranularity: .month)  }, color: Constants.bodyWeightTheme)
                    }

                } header: {
                    ReusedViews.Labels.Header(text: "Health Data")
                } footer: {
                    Text("\(ActivityCount.health) Updates\(ActivityCount.health == 1 ? "" : "s")")
                }
                Section {
                    NavigationLink {
                        SessionsListView(allSessions: allSessions)
                    } label: {
                        Text("All Sessions")
                    }
                    NavigationLink {
                        UpdatesListView(allExercises: allExercises)
                    } label: {
                        Text("All Updates")
                    }
                    NavigationLink {
                        HealthData(type: .bodyFat)
                    } label: {
                        Text("Health Data")
                    }
                    NavigationLink {
                        Text("Settings")
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                } header: {
                    ReusedViews.Labels.Header(text: "More")
                }
            }
            .navigationTitle(DateHandler.MonthYearString(date: viewingMonth))
            .toolbarTitleDisplayMode(.inlineLarge)
            .navigationDestination(item: $selectedDate) { date in
                DayActivity(dayProgress: date)
                    .navigationTransition(.zoom(sourceID: date, in: namespace))
            }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    MonthControl(increase: false)
                    MonthControl(increase: true)
                }
            }
        }
    }
    
    private func MonthControl(increase: Bool) -> some View {
        Button {
            if let newMonth = calendar.date(byAdding: .month, value: increase ? 1 : -1, to: viewingMonth) {
                withAnimation {
                    viewingMonth = newMonth
                }
            }
        } label: {
            Label(increase ? "Next Month" : "Previous Month", systemImage: increase ? "chevron.right" : "chevron.left")
        }.disabled(
            (!increase && calendar.isDate(viewingMonth, equalTo: earliestDataMonth, toGranularity: .month)) ||
            (increase && calendar.isDate(viewingMonth, equalTo: latestDataMonth, toGranularity: .month))
        )
    }
    
}
