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
                    ForEach(exercise.updateData, id: \.self) { data in
                        ChangeChartView(data: data)
                    }
                } header: {
                    Text("All Updates")
                }
                WeightInfo()
                ExerciseSessions()
                TotalExerciseInfo()
                Text("Found stuff \(exercise.sessionEntries?.count ?? 0)")
            }
            .navigationTitle("History")
            .navigationSubtitle(exercise.name)
        }
    }
    
    private func ChangeChartView(data: SetChangeData) -> some View {
        Chart {
            ForEach(data.setData, id: \.self) { point in
                BarMark(
                    x: .value("Set", point.set),
                    y: .value("Weight", point.weight),
                    //                            width: .fixed(20)
                )
            }
        }
    }
    
    private func IndividualUpdate() -> some View {
        HStack {
            Chart {
                ForEach(exercise.updateData, id: \.self) { data in
                    
                }
            }
        }
    }
    
    private func WeightInfo() -> some View {
        Section {
            HStack {
                Chart {
                    BarMark(
                        x: .value("Set", 0),
                        y: .value("Weight", exercise.maxWeight),
                    )
                    BarMark(
                        x: .value("Set", 0.2),
                        y: .value("Weight", exercise.minWeight),
                    )
                    BarMark(
                        x: .value("Set", 0.4),
                        y: .value("Weight", exercise.averageWeight),
                    )
                }
                .chartXAxis(.hidden)
                .chartYAxisLabel("(lbs)")
                VStack(alignment: .leading) {
                    LabeledContent("Min") {
                        Text("\(exercise.minWeight, specifier: "%.1f")")
                    }
                    LabeledContent("Max") {
                        Text("\(exercise.maxWeight, specifier: "%.1f")")
                    }
                    LabeledContent("Average") {
                        Text("\(exercise.averageWeight, specifier: "%.1f")")
                    }
                }
            }
        } header: {
            Text("Weight")
        }
    }
    
    private func TotalExerciseInfo() -> some View {
        Section {
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
        } header: {
            Text("Exercise Stats")
        }
    }
    
    private func ExerciseSessions() -> some View {
        Section {
            ForEach(recentSessions, id: \.self) { session in
                ReusedViews.SessionViews.SessionLink(session: session)
            }
            NavigationLink {
                SessionsListView(allSessions: relatedSessions)
            } label: {
                Label("Found in \(relatedSessions.count) session\(relatedSessions.count == 1 ? "" : "s")", systemImage: "square")
            }.disabled(relatedSessions.isEmpty)
        } header: {
            Text("Sessions containing \(exercise.name)")
        }
    }
    
    private func UpdateDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func DeletePRData() -> some View {
        Button(role: .destructive) {
            
        } label: {
            Text("Delete PR Data")
        }
    }
    
}
