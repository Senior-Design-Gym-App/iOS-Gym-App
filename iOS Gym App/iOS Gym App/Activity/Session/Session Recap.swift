import SwiftUI
import Charts
import SwiftData

struct SessionRecap: View {
    
    @State var session: WorkoutSession
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(ProgressManager.self) private var hkm
    @State private var selectedSection: DonutData?
    @AppStorage("donutDisplayType") private var displayType: DonutDisplayType = .reps
    
    var body: some View {
        NavigationStack {
            List {
                SessionTitleInfo(deleteSession: DeleteSession, session: $session, startDate: session.started, endDate: session.completed ?? session.started)
                Section {
                    ReusedViews.Charts().DataRecapPieChart(sessions: [session], type: displayType)
                    ReusedViews.Pickers.DisplayTypePicker(type: $displayType, exempt: .weight)
                } header: {
                    Text("Muscle Group Data")
                }
                ForEach(session.exercises ?? [], id: \.self) { sessionEntry in
                    ExerciseSection(entry: sessionEntry)
                }
                if let workout = session.workout {
                    Section {
                        WorkoutSessionSection(workout: workout)
                    } header: {
                        Text("Connections")
                    } footer: {
                        Text("Sessions & Split linked to \(workout.name)")
                    }
                }
            }
            .navigationTitle(formatMonthDayYear(session.started))
        }
    }
    
    private func WorkoutSessionSection(workout: Workout) -> some View {
        Group {
            if let sessions = workout.sessions {
                NavigationLink {
                    SessionsListView(allSessions: sessions)
                } label: {
                    Label {
                        Text("Similar Sessions")
                    } icon: {
                        Image(systemName: "gauge.with.needle")
                            .foregroundStyle(Constants.sessionTheme)
                    }
                }
            }
            if let split = workout.split {
                NavigationLink {
                    SplitSessions(split: split)
                } label: {
                    ReusedViews.SplitViews.ListPreview(split: split)
                }
            }
        }
    }
    
    private func ExerciseSection(entry: WorkoutSessionEntry) -> some View {
        Section {
            NavigationLink {
                SetTable(exercise: entry.exercise!, session: session, entry: entry)
            } label: {
                Chart {
                    ReusedViews.Charts.BarMarks(sets: entry.setEntry, color: ChartGraphType.session.color, offset: 0)
                    if let expected = entry.exercise?.closestUpdate(date: session.started) {
                        ReusedViews.Charts.BarMarks(sets: expected.setData, color: ChartGraphType.expected.color, offset: 0.2)
                    }
                    if let exercise = entry.exercise {
                        ReusedViews.Charts.BarMarks(sets: exercise.findAverageSetData(before: session.started), color: ChartGraphType.average.color, offset: 0.4)
                    }
                    if let recent = session.recentSetData.first(where: { $0.exercise == entry.exercise }) {
                        ReusedViews.Charts.BarMarks(sets: recent.mostRecentSetData.setData, color: ChartGraphType.current.color, offset: 0.6)
                    }
                }
                .chartYAxisLabel("Volume \(hkm.weightUnitString)")
                .chartXAxis(.hidden)
            }.disabled(entry.exercise == nil)
                .navigationLinkIndicatorVisibility(entry.exercise == nil ? .hidden : .visible)
        } header: {
            if let exercise = entry.exercise {
                NavigationLink {
                    ExerciseChanges(exercise: exercise)
                } label: {
                    ReusedViews.Labels.NavigationHeader(text: exercise.name)
                }
            } else {
                Text("Unknown Exercise")
            }
        }
    }
    
    private func formatMonthDayYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMM, yyyy"
        return formatter.string(from: date)
    }
    
    private func DeleteSession() {
        context.delete(session)
        dismiss()
    }
    
}
