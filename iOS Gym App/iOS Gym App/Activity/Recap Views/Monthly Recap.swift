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
    @AppStorage("greetingString") private var greetingString = "Initial"
    
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
    
    var recentSessions: [WorkoutSession] {
        allSessions
            .filter {
                if let completedDate = $0.completed {
                    return calendar.isDate(completedDate, equalTo: viewingMonth, toGranularity: .month)
                }
                return false
            }
            .sorted { lhs, rhs in
                guard let lhsDate = lhs.completed, let rhsDate = rhs.completed else { return false }
                return lhsDate > rhsDate
            }
            .prefix(5)
            .map { $0 }
    }
    
    var recentUpdates: [Exercise] {
        allExercises.filter { calendar.isDate($0.recentUpdateDate, equalTo: viewingMonth, toGranularity: .month) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if calendar.isDate(viewingMonth, equalTo: Date(), toGranularity: .month) {
                    Section {
                        HStack {
                            Spacer()
                            Text(greetingString)
                                .font(.largeTitle)
                            Spacer()
                        }
                    }
                }
                Section {
                    MonthlyCalendarView(viewingMonth: viewingMonth, selectedDate: $selectedDate, allExercises: recentUpdates, allSessions: recentSessions)
                } header: {
                    Text("Daily Activity")
                }
                Section {
                    ReusedViews.Charts().DataRecapPieChart(sessions: allSessions.filter { calendar.isDate($0.started, equalTo: viewingMonth, toGranularity: .month) }, type: displayType).id(viewingMonth)
                    ReusedViews.Pickers.DisplayTypePicker(type: $displayType, exempt: .weight)
                    MonthlySessions(viewingMonth: viewingMonth, allSessions: recentSessions)
                } header: {
                    Text("Session Summary")
                } footer: {
                    Text("\(ActivityCount.sessions) Session\(ActivityCount.sessions == 1 ? "" : "s")")
                }
                Section {
                    MonthlyUpdates(viewingMonth: viewingMonth, allExercises: recentUpdates)
                } header: {
                    Text("Updates")
                } footer: {
                    Text("\(ActivityCount.exercise) Update\(ActivityCount.exercise == 1 ? "" : "s")")
                }
                Section {
                    VStack {
                        ReusedViews.Charts.BarChartMonth(data: hkm.bodyFatData.filter { calendar.isDate($0.date, equalTo: viewingMonth, toGranularity: .month)  }, color: Constants.healthColor)
                            .listRowSeparator(.hidden)
                        ReusedViews.Charts.BarChartMonth(data: hkm.bodyWeightData.filter { calendar.isDate($0.date, equalTo: viewingMonth, toGranularity: .month)  }, color: Constants.healthColor)
                    }
                } header: {
                    Text("Health Updates")
                } footer: {
                    Text("\(ActivityCount.health) Updates\(ActivityCount.health == 1 ? "" : "s")")
                }
                Section {
                    NavigationLink {
                        SessionsListView(allSessions: allSessions)
                    } label: {
                        Label {
                            Text("All Sessions")
                        } icon: {
                            Image(systemName: Constants.sessionIcon)
                                .foregroundStyle(Constants.sessionTheme)
                        }
                    }
                    NavigationLink {
                        UpdatesListView(allExercises: allExercises)
                    } label: {
                        Label {
                            Text("All Updates")
                        } icon: {
                            Image(systemName: Constants.exerciseIcon)
                                .foregroundStyle(Constants.mainAppTheme)
                        }
                    }
                    NavigationLink {
                        HealthData(type: .bodyFat)
                    } label: {
                        Label {
                            Text("Health Data")
                        } icon: {
                            Image(systemName: Constants.healthIcon)
                                .foregroundStyle(Constants.healthColor)
                        }
                    }
                } header: {
                    Text("More")
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
                    if calendar.compare(Date.now, to: earliestDataMonth, toGranularity: .month) != .orderedAscending &&
                       calendar.compare(Date.now, to: latestDataMonth, toGranularity: .month) != .orderedDescending {
                        Button {
                            viewingMonth = Date.now
                        } label: {
                            Label("This Month", systemImage: "calendar")
                        }.disabled(Calendar.current.isDate(viewingMonth, equalTo: Date(), toGranularity: .month))
                    }
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
