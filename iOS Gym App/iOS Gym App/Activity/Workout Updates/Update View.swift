import SwiftUI
import Charts

struct ExerciseChanges: View {
    
    let exercise: Exercise
    @Environment(\.modelContext) private var context
    
    var recentSessions: [WorkoutSession] {
        guard let allSessionEntries = exercise.sessionEntries else { return [] }
        
        let sessions = allSessionEntries
            .compactMap { $0.session }
            .filter { $0.started < Date() }
            .prefix(5)
        return Array(sessions)
    }
    
    var relatedSessions: [WorkoutSession] {
        guard let allSessionEntries = exercise.sessionEntries else { return [] }
        
        let sessions = allSessionEntries
            .compactMap { $0.session }
            .sorted { $0.started > $1.started }
        return Array(sessions)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    LifetimeStats()
                } header: {
                    Text("Lifetime Stats")
                }
                Section {
                    WeightInfo()
                } header: {
                    Text("Weight Info")
                }
                Section {
                    if relatedSessions.isEmpty {
                        Text("No sessions containing \(exercise.name)")
                    } else {
                        ExerciseSessions()
                    }
                } header: {
                    Text("Sessions containing \(exercise.name)")
                }
                ForEach(exercise.updateData, id: \.self) { data in
                    Section {
                        ChangeChartView(data: data)
                    } header: {
                        if data == exercise.recentSetData {
                            Text("Current")
                        }
                    } footer: {
                        Text(data.changeDate.formatted())
                    }
                }
            }
            .navigationTitle(exercise.name)
            .navigationSubtitle(exercise.workoutEquipment?.rawValue ?? "No Equipment")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func LifetimeStats() -> some View {
        Group {
            Chart {
                ForEach(exercise.avgSetsWeight, id: \.self) { point in
                    BarMark(x: .value("Update Date", point.date, unit: .month), y: .value("Avg Weight", point.value)).cornerRadius(Constants.smallRadius)
                }
            }.foregroundStyle(exercise.color)
            LabeledContent("Total Sets") {
                Text("\(exercise.totalSets)")
            }
            LabeledContent("Total Reps") {
                Text("\(exercise.totalReps)")
            }
            LabeledContent("Total Weight") {
                Text("\(exercise.totalWeight, specifier: "%.1f")")
            }
            LabeledContent("Max Reps in one set") {
                Text("\(exercise.maxReps)")
            }
            LabeledContent("Average Reps") {
                Text("\(exercise.averageReps)")
            }
        }
    }
    
    private func ExerciseSessions() -> some View {
        Group {
            ForEach(recentSessions, id: \.self) { session in
                ReusedViews.SessionViews.SessionLink(session: session)
            }
            if relatedSessions.count > 5 {
                NavigationLink {
                    SessionsListView(allSessions: relatedSessions)
                } label: {
                    Label("View all \(relatedSessions.count) session\(relatedSessions.count == 1 ? "" : "s")", systemImage: "list.bullet")
                }.disabled(relatedSessions.isEmpty)
            }
        }
    }
    
    private func ChangeChartView(data: SetChangeData) -> some View {
        Group {
            Chart {
                ReusedViews.Charts.BarMarks(sets: data.setData, color: exercise.color, offset: 0)
            }
            ForEach(data.setData, id: \.self) { point in
                ReusedViews.ExerciseViews.IndiidualSetInfo(setData: point, color: exercise.color, index: point.set)
            }
        }
    }
    
    private func WeightInfo() -> some View {
        HStack {
            Chart {
                BarMark(
                    x: .value("Set", "Max"),
                    y: .value("Weight", exercise.maxWeight),
                    width: .ratio(0.3)
                ).cornerRadius(Constants.smallRadius)
                BarMark(
                    x: .value("Set", "Min"),
                    y: .value("Weight", exercise.minWeight),
                    width: .ratio(0.3)
                ).cornerRadius(Constants.smallRadius)
                BarMark(
                    x: .value("Set", "Avg"),
                    y: .value("Weight", exercise.averageWeight),
                    width: .ratio(0.3)
                ).cornerRadius(Constants.smallRadius)
            }
            .foregroundStyle(exercise.color)
            .chartXAxis(.hidden)
            .chartYAxisLabel("(lbs)")
            VStack(alignment: .leading) {
                LabeledContent("Max") {
                    Text("\(exercise.maxWeight, specifier: "%.1f")")
                }
                LabeledContent("Min") {
                    Text("\(exercise.minWeight, specifier: "%.1f")")
                }
                LabeledContent("Average") {
                    Text("\(exercise.averageWeight, specifier: "%.1f")")
                }
            }
        }
    }
    
    private func UpdateDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
}
