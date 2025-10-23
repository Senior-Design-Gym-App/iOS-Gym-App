import SwiftUI
import Charts

struct ExerciseChanges: View {
    
    let exercise: Exercise
    @Environment(\.modelContext) private var context
    
//    var recentSessions: [WorkoutSession] {
//        guard let originalWorkout = workout.workout else {
//            return []
//        }
//        guard let sessionEntries = originalWorkout.sessionEntries else {
//            return []
//        }
//        
//        // Get non-nil sessions
//        let allSessions = sessionEntries.compactMap { $0.session }
//        
//        // Sort by started descending (most recent first)
//        let sortedByDate = allSessions.sorted { lhs, rhs in
//            lhs.started > rhs.started
//        }
//        
//        // Return up to the 5 most recent
//        return Array(sortedByDate.prefix(5))
//    }

    
    var body: some View {
        NavigationStack {
            List {
//                Section {
//                    if workout.prData.isEmpty == false {
//                        ProgressChartView(color: Constants.mainAppTheme, unit: "lbs", data: workout.prData)
//                    }
//                } header: {
//                    Label("PR History", systemImage: "trophy")
//                }
//                Section {
//                    AverageGraph(data: workout.updateData)
//                } header: {
//                    Label("Average Weight", systemImage: "divide")
//                }
//                Section {
//                    ForEach(workout.updateData, id: \.self) { data in
//                        UpdateDataHistory(data: data)
//                    }
//                } header: {
//                    Label("Change History", systemImage: "calendar")
//                }
//                Section {
//                    ForEach(recentSessions, id: \.self) { session in
//                        NavigationLink {
//                            SessionRecap(session: session, sessionName: session.name)
//                        } label: {
//                            Label {
//                                Text(session.name)
//                            } icon: {
//                                Image(systemName: "timer")
//                                    .foregroundStyle(.purple)
//                            }
//                        }
//                    }
//                } header: {
//                    Label("Recent Sessions", systemImage: "timer")
//                }
                EmptyView()
                .navigationTitle("History")
                .navigationSubtitle(exercise.name)
//                .toolbar {
//                    ToolbarItem(placement: .secondaryAction) {
//                        Section {
//                            DeletePRData()
//                        } header: {
//                            Text("Delete Options")
//                        }
//                    }
//                }
            }
        }
    }
    
    private func BarGraphLabel(data: UpdateData) -> some View {
        Chart {
            BarMark(x: .value("Avg", "bird"),
                    y: .value("Date?", 1))
        }
    }
    
    private func AverageGraph(data: [UpdateData]) -> some View {
        Chart {
            ForEach(data, id: \.self) { point in
                BarMark(x: .value("Order", point.updateDate, unit: .day),
                        y: .value("Avg", point.averageVolumePerSet))
            }
        }
    }
    
    private func UpdateDataHistory(data: UpdateData) -> some View {
        VStack(alignment: .leading) {
            Text("\(UpdateDate(date: data.updateDate))")
                .font(.headline)
            Group {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Reps")
                        Text("Weight")
                    }
                    ForEach(0..<data.sets, id: \.self) { set in
                        VStack(alignment: .leading) {
                            Text("\(data.reps[set])")
                            Text("\(data.weights[set], specifier: "%.1f")")
                        }
                    }
                }
            }.font(.subheadline)
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
