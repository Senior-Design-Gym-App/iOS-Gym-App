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
    
    private var CountDatesInCurrentMonth: (sessions: Int, exercise: Int, healthData: Int, total: Int) {
        let allSessionDates = allSessions.map { $0.started }
        let allUpdateDates = allExercises.flatMap { $0.updateDates }
        let bodyFatDates = hkm.bodyFatData.map { $0.date }
        let bodyweightDates = hkm.bodyWeightData.map { $0.date }
        
        let sessionCount = allSessionDates.filter { calendar.isDate($0, equalTo: viewingMonth, toGranularity: .month) }.count
        let updateCount = allUpdateDates.filter { calendar.isDate($0, equalTo: viewingMonth, toGranularity: .month) }.count
        let bodyFatCount = bodyFatDates.filter { calendar.isDate($0, equalTo: viewingMonth, toGranularity: .month) }.count
        let bodyWeightCount = bodyweightDates.filter { calendar.isDate($0, equalTo: viewingMonth, toGranularity: .month) }.count
        
        return (sessionCount, updateCount, (bodyFatCount + bodyWeightCount), (sessionCount + updateCount + (bodyFatCount + bodyWeightCount)))
    }
    
    var body: some View {
        List {
            Section {
                MonthSection()
                    .listRowSeparator(.hidden)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(ReusedViews.CalendarViews.GenerateMonthGrid(month: viewingMonth), id: \.self) { day in
                        ProgressDay(daysDate: day, bodyFat: hkm.bodyFatData, bodyWeight: hkm.bodyWeightData, allExercises: allExercises, inMonth: Calendar.current.isDate(day, equalTo: viewingMonth, toGranularity: .month))
                    }
                }.id(viewingMonth)
                ActivityLabel()
            }
            Section {
                UpdateRecap()
                RecapLinks()
            } header: {
                ReusedViews.Labels.Header(text: "Events")
            }
            Section {
                MonthSetRecap()
            } header: {
                ReusedViews.Labels.Header(text: "Muscle Recap")
            }
            Section {
                ReusedViews.Charts.BarChartMonth(data: hkm.bodyFatData.filter { calendar.isDate($0.date, equalTo: viewingMonth, toGranularity: .month)  }, color: Constants.bodyFatTheme)
                    .listRowSeparator(.hidden)
                ReusedViews.Charts.BarChartMonth(data: hkm.bodyWeightData.filter { calendar.isDate($0.date, equalTo: viewingMonth, toGranularity: .month)  }, color: Constants.bodyWeightTheme)
            } header: {
                ReusedViews.Labels.Header(text: "Health Data")
            }
        }
        .navigationTitle("Monthly Recap")
        .navigationDestination(item: $selectedDate) { date in
            DayActivity(dayProgress: date)
                .navigationTransition(.zoom(sourceID: date, in: namespace))
        }
    }
    
    private func MonthSection() -> some View {
        HStack {
            Button {
                if let previousMonth = calendar.date(byAdding: .month, value: -1, to: viewingMonth) {
                    withAnimation {
                        viewingMonth = previousMonth // Remove withAnimation here
                    }
                }
            } label: {
                Label("Previous Month", systemImage: "chevron.left")
                    .font(.title)
                    .labelStyle(.iconOnly)
            }.disabled(calendar.isDate(viewingMonth, equalTo: earliestDataMonth, toGranularity: .month) || viewingMonth < earliestDataMonth)
                .buttonStyle(.borderless)
            Spacer()
            Text(DateHandler.MonthYearString(date: viewingMonth))
            Spacer()
            Button {
                if let nextMonth = calendar.date(byAdding: .month, value: 1, to: viewingMonth) {
                    if calendar.isDate(nextMonth, equalTo: Date(), toGranularity: .month) {
                        viewingMonth = nextMonth
                    } else {
                        withAnimation {
                            viewingMonth = nextMonth // Remove withAnimation here
                        }
                    }
                }
            } label: {
                Label("Next Month", systemImage: "chevron.right")
                    .font(.title)
                    .labelStyle(.iconOnly)
            }.disabled(calendar.isDate(viewingMonth, equalTo: latestDataMonth, toGranularity: .month) || viewingMonth > latestDataMonth)
                .buttonStyle(.borderless)
        }
    }
    
    private func RecapLinks() -> some View {
        Group {
            NavigationLink {
                SessionsListView(allSessions: allSessions.filter { calendar.isDate($0.started, equalTo: viewingMonth, toGranularity: .month) } )
            } label: {
                Label {
                    Text("This months sessions")
                } icon: {
                    Image(systemName: Constants.sessionIcon)
                        .foregroundStyle(Constants.sessionTheme)
                }
            }
            NavigationLink {
                UpdatesListView(allExercises: allExercises.filter { $0.updateDates.contains { calendar.isDate($0, equalTo: viewingMonth, toGranularity: .month) } } )
            } label: {
                Label {
                    Text("This months updates")
                } icon: {
                    Image(systemName: Constants.exerciseIcon)
                        .foregroundStyle(Constants.updateTheme)
                }
            }
        }
    }
    
    private func UpdateRecap() -> some View {
        HStack {
            GaugeLabel(value: CountDatesInCurrentMonth.sessions, type: .session)
            Spacer()
            GaugeLabel(value: CountDatesInCurrentMonth.exercise, type: .update)
            Spacer()
            GaugeLabel(value: CountDatesInCurrentMonth.healthData, type: .healthData)
        }
    }
    
    private func GaugeLabel(value: Int, type: GaugeTypes) -> some View {
        Gauge(value: Float(value), in: 0...Float(CountDatesInCurrentMonth.total)) {
            Image(systemName: type.label)
        } currentValueLabel: {
            Text("\(value)")
        }.gaugeStyle(.accessoryCircular)
            .tint(type.color)
    }
    
    private func MonthSetRecap() -> some View {
        ReusedViews.Charts.SetRecapChart(sessions: allSessions.filter { calendar.isDate($0.started, equalTo: viewingMonth, toGranularity: .month) })
    }
    
    enum GaugeTypes: String {
        
        case session = "Sessions"
        case update = "Updates"
        case healthData = "Health Data"
        
        var label: String {
            switch self {
            case .session:
                Constants.sessionIcon
            case .update:
                Constants.exerciseIcon
            case .healthData:
                Constants.healthIcon
            }
        }
        
        var color: Color {
            switch self {
            case .session:
                Constants.sessionTheme
            case .update:
                Constants.updateTheme
            case .healthData:
                Constants.bodyFatTheme
            }
        }
        
    }
    
    private func ProgressDay(daysDate: Date, bodyFat: [WeightEntry], bodyWeight: [WeightEntry], allExercises: [Exercise], inMonth: Bool) -> some View {
        Group {
            if inMonth {
                Button {
                    selectedDate = daysDate
                } label: {
                    ReusedViews.CalendarViews.DayLabel(daysDate: daysDate, bodyFat: bodyFat, bodyWeight: bodyWeight, allExercises: allExercises, inMonth: inMonth)
                }
                .buttonStyle(.plain)
                .matchedTransitionSource(id: daysDate, in: namespace)
            } else {
                ReusedViews.CalendarViews.DayLabel(daysDate: daysDate, bodyFat: bodyFat, bodyWeight: bodyWeight, allExercises: allExercises, inMonth: inMonth)
            }
        }
    }
    
    private func ActivityLabel() -> some View {
        HStack(spacing: 5) {
            Spacer()
            Image(systemName: "square.fill")
                .foregroundStyle(ReusedViews.CalendarViews.ColorSwitch(eventCount: 5))
            Image(systemName: "square.fill")
                .foregroundStyle(ReusedViews.CalendarViews.ColorSwitch(eventCount: 4))
            Image(systemName: "square.fill")
                .foregroundStyle(ReusedViews.CalendarViews.ColorSwitch(eventCount: 3))
            Image(systemName: "square.fill")
                .foregroundStyle(ReusedViews.CalendarViews.ColorSwitch(eventCount: 2))
            Image(systemName: "square.fill")
                .foregroundStyle(ReusedViews.CalendarViews.ColorSwitch(eventCount: 1))
        }.padding(.top, 10)
    }
    
}
