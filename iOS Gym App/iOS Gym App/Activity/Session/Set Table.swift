import SwiftUI
import Charts

struct SetTable: View {
    
    let exercise: Exercise
    let session: WorkoutSession
    let entry: WorkoutSessionEntry
    
    private var recent: RecentExerciseData? {
        session.recentSetData.first(where: { $0.exercise == exercise })
    }
    
    private var avgSetData: [SetData] {
        exercise.findAverageSetData(before: session.started)
    }
    
    private var entrySetCount: Int {
        entry.setEntry.count
    }
    
    private var recentSetDataCount: Int {
        recent?.mostRecentSetData.setData.count ?? 0
    }
    
    private var exerciseSetCount: Int {
        avgSetData.count
    }
    
    private var maxSetCount: Int {
        max(entrySetCount, recentSetDataCount, exerciseSetCount, expectedSets)
    }
    
    private var expectedSets: Int {
        exercise.closestUpdate(date: session.started)?.setData.count ?? 0
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                        ForEach(ChartGraphType.allCases, id: \.self) { type in
                            LabelType(type: type)
                        }
                } header: {
                    Text("Label")
                }
                ForEach(0..<maxSetCount, id: \.self) { index in
                    SetSection(index: index, setNumber: index + 1)
                }
            }
            .navigationTitle(exercise.name)
            .navigationSubtitle(exercise.workoutEquipment?.rawValue ?? "No Equipment")
        }
    }
    
    private func SetSection(index: Int, setNumber: Int) -> some View {
        Section {
            Chart {
                if setNumber <= entrySetCount {
                    BarMark(
                        x: .value("Type", ChartGraphType.session.rawValue),
                        y: .value("Weight", entry.setEntry[index].weight)
                    )
                    .cornerRadius(Constants.smallRadius)
                    .foregroundStyle(ChartGraphType.session.color)
                }
                if setNumber <= expectedSets {
                    BarMark(
                        x: .value("Type", ChartGraphType.expected.rawValue),
                        y: .value("Weight",  exercise.closestUpdate(date: session.started)!.setData[index].weight)
                    )
                    .cornerRadius(Constants.smallRadius)
                    .foregroundStyle(ChartGraphType.expected.color)
                }
                if setNumber <= exerciseSetCount {
                    BarMark(
                        x: .value("Type", ChartGraphType.average.rawValue),
                        y: .value("Weight", avgSetData[index].weight)
                    )
                    .cornerRadius(Constants.smallRadius)
                    .foregroundStyle(ChartGraphType.average.color)
                }
                if setNumber <= recentSetDataCount {
                    BarMark(
                        x: .value("Type", ChartGraphType.current.rawValue),
                        y: .value("Weight", recent!.mostRecentSetData.setData[index].weight)
                    )
                    .cornerRadius(Constants.smallRadius)
                    .foregroundStyle(ChartGraphType.current.color)
                }
            }
            .chartXAxis {
                AxisMarks(values: [ChartGraphType.session.rawValue, ChartGraphType.expected.rawValue, ChartGraphType.average.rawValue, ChartGraphType.current.rawValue]) { value in
                    AxisValueLabel {
                        if let type = ChartGraphType(rawValue: value.as(String.self) ?? "") {
                            TypeHelper(type: type, index: index, setNumber: setNumber)
                        }
                    }
                }
            }
            .chartYAxisLabel("Weight (lbs)")
        } header: {
            Text("Set \(setNumber)")
        }
    }
    
    @ViewBuilder
    private func TypeHelper(type: ChartGraphType, index: Int, setNumber: Int) -> some View {
        switch type {
        case .session:
            if setNumber <= entrySetCount {
                SetLabel(data: entry.setEntry[index])
            }
        case .current:
            if setNumber <= recentSetDataCount {
                SetLabel(data: recent!.mostRecentSetData.setData[index])
            }
        case .average:
            if setNumber <= exerciseSetCount {
                SetLabel(data: avgSetData[index])
            }
        case .expected:
            if setNumber <= expectedSets {
                SetLabel(data: exercise.closestUpdate(date: session.started)!.setData[index])
            }
        }
    }
    
    private func SetLabel(data: SetData) -> some View {
        VStack(alignment: .leading) {
            Text("\(data.weight, specifier: "%.1f") kg")
            Text("\(data.reps) reps")
        }
    }
    
    private func LabelType(type: ChartGraphType) -> some View {
        Label {
            Text(type.description)
        } icon: {
            Image(systemName: "circle.fill")
                .foregroundStyle(type.color)
        }
    }
    
}
