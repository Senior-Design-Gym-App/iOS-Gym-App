import SwiftUI
import Charts

struct ExerciseChanges: View {
    
    let exercise: Exercise
    @Environment(\.modelContext) private var context
    @Environment(ProgressManager.self) private var hkm
    @AppStorage("showTips") private var showTips: Bool = true
    
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
                    ExerciseSessions()
                } header: {
                    Text("Session Data")
                }
                Section {
                    WeightInfo()
                } header: {
                    Text("Working Set History")
                }
                Section {
                    GraphType(data: exercise.avgSetsWeight, type: .workingSet)
                } header: {
                    Text("Volume Change History")
                }
                Section {
                    OneRepMaxInfo()
                } header: {
                    Text("One Rep Max History")
                } footer: {
                    if showTips {
                        Text("You can manually enter a one rep max when editing an exercise. This will also be recorded when you do a one rep set in a session.")
                    }
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
            LabeledContent("Total Volume") {
                Text("\(exercise.totalVolume, specifier: "%.1f")")
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
        NavigationLink {
            SessionsListView(allSessions: relatedSessions)
        } label: {
            Label {
                Text("View related sessions")
            } icon: {
                Image(systemName: Constants.sessionIcon)
                    .foregroundStyle(Constants.sessionTheme)
            }
        }.disabled(relatedSessions.isEmpty)
    }
    
    private func OneRepMaxInfo() -> some View {
        Group {
            GraphType(data: exercise.allOneRepMaxData.map { $0.entry }, type: .oneRepMax)
            ForEach(exercise.allOneRepMaxData, id: \.self) { entry in
                if let session = entry.session {
                    NavigationLink {
                        SessionRecap(session: session)
                    } label: {
                        Label {
                            ReusedViews.WeightEntryView.OneRepMaxLabel(data: entry.entry, weightLabel: hkm.weightUnitString)
                        } icon: {
                            Image(systemName: "square.fill")
                                .foregroundStyle(session.color)
                        }
                    }
                } else {
                    Label {
                        ReusedViews.WeightEntryView.OneRepMaxLabel(data: entry.entry, weightLabel: hkm.weightUnitString)
                    } icon: {
                        Image(systemName: "pencil.circle")
                            .foregroundStyle(exercise.color)
                    }
                }
            }
        }
    }
    
    private func ChangeChartView(data: SetChangeData) -> some View {
        Group {
            Chart {
                ForEach(data.setData) { set in
                    BarMark(
                        x: .value("Set", "\(set.set + 1)"),
                        y: .value("Weight", set.setVolume)
                    )
                }.foregroundStyle(exercise.color)
                    .cornerRadius(Constants.smallRadius)
            }
            .chartYAxisLabel("Volume")
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
            .chartYAxisLabel("\(hkm.weightUnitString)")
            VStack(alignment: .leading) {
                LabeledContent("Max") {
                    Text("\(exercise.maxWeight, specifier: "%.1f")")
                }
                LabeledContent("Min") {
                    Text("\(exercise.minWeight, specifier: "%.1f")")
                }
                LabeledContent("Avg") {
                    Text("\(exercise.averageWeight, specifier: "%.1f")")
                }
            }
        }
    }
    
    @ViewBuilder
    func GraphType(data: [WeightEntry], type: DetailedWeightEntryTypes) -> some View {
        switch data.count {
        case 0:
            Text("No data available.")
        case 1:
            ReusedViews.Charts.WeightEntryBarChart(data: data, exercise: exercise, yaxisTitle: hkm.weightUnitString)
        default:
            NavigationLink {
                DetailedWeightEntry(exercise: exercise, weightEntries: data, type: type)
            } label: {
                ReusedViews.Charts.WeightEntryBarChart(data: data, exercise: exercise, yaxisTitle: hkm.weightUnitString)
            }
        }
    }
    
}
