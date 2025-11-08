import SwiftUI
import Charts
import SwiftData

struct SessionRecap: View {
    
    @State var session: WorkoutSession
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var selectedSection: DonutData?
    
    var body: some View {
        NavigationStack {
            List {
                SessionInfo()
                Section {
                    MuscleInfo()
                } header: {
                    Text("Sets by Muscle")
                }
                ForEach(session.exercises ?? [], id: \.self) { sessionEntry in
                    ExerciseSection(entry: sessionEntry)
                }
                Text("Exercise Data \(session.exercises?.count ?? -1)")
            }
            .toolbar {
                Button {
                    context.delete(session)
                    dismiss()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            .onAppear {
                for i in session.recentSetData {
                    print(i)
                }
            }
        }
    }
    
    private func SessionInfo() -> some View {
        HStack {
            ReusedViews.Labels.SmallIconSize(color: session.color)
            ReusedViews.Labels.Description(topText: session.name, bottomText: formatDateRange(start: session.started, end: session.completed))
            Spacer()
        }.listRowBackground(Color.clear)
    }
    
    private func ExerciseSection(entry: WorkoutSessionEntry) -> some View {
        Section {
            Chart {
                ForEach(entry.setEntry) { set in
                    BarMark(
                        x: .value("Set", set.rest + 1),
                        y: .value("Weight", set.weight),
//                        width: .fixed(20)
                    )
                    .foregroundStyle(.red)
//                    .foregroundStyle(by: .value("Set", set.rest + 1))
                }
                if let recent = session.recentSetData.first(where: { $0.exercise == entry.exercise }) {
                    ForEach(recent.mostRecentSetData.setData) { set in
                        BarMark(
                            x: .value("Set", Double(set.rest) + 1 - 0.3),
                            y: .value("Weight", set.weight),
//                            width: .fixed(20)
                        )
                        .foregroundStyle(.blue)
//                        .foregroundStyle(by: .value("Set", set.rest + 1))
                    }
//                    .onAppear {
//                        print("testing 1")
//                    }
                }
                if let exercise = entry.exercise {
                    ForEach(exercise.findAverageSetDataForExercises(in: session), id: \.self) { set in
                        BarMark(
                            x: .value("Set", Double(set.rest) + 1 + 0.3),
                            y: .value("Weight", set.weight),
    //                        width: .fixed(20)
                        )
                        .foregroundStyle(.yellow)
                    }
//                    .onAppear {
//                        print("testing 2")
//                    }
                }
            }
            .frame(minHeight: 200)
            .chartXScale(domain: (0.7)...(Double(entry.weight.count) + 0.3))
//            .chartYScale(domain: (0)...(200)) // Add a small range buffer
            .chartXAxisLabel("Reps")
            .chartYAxisLabel("Weight (lbs)")
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
    
    private func MuscleInfo() -> some View {
        HStack {
            Chart(session.allmuscleSetData) { item in
                SectorMark(
                    angle: .value("Sets", item.sets),
                    innerRadius: .ratio(0.6),
                    angularInset: 1.5
                )
                .foregroundStyle(item.muscle.colorPalette)
            }
            VStack(alignment: .leading) {
                ForEach(session.allmuscleSetData) { item in
                    HStack {
                        Circle()
                            .fill(item.muscle.colorPalette)
                            .frame(width: 25, height: 25)
                        VStack(alignment: .leading) {
                            Text(item.muscle.rawValue)
                            Text("\(item.sets) Set\(item.sets == 1 ? "" : "s")")
                                .font(.caption2)
                                .fontWeight(.thin)
                        }
                    }
                }
            }
        }
    }
    
    private func CheckInDateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, h:mm a, yyyy"
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
    
    private func formatDateRange(start: Date, end: Date?) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        
        // Handle missing end date
        guard let end = end else {
            return "Incomplete"
        }
        
        let calendar = Calendar.current
        
        // Check if same day
        if calendar.isDate(start, inSameDayAs: end) {
            formatter.dateFormat = "h:mm a"
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        } else {
            formatter.dateFormat = "MMM d h:mm a"
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        }
    }

    
}
