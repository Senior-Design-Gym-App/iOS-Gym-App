import SwiftUI
import SwiftData

struct DayActivity: View {
    
    let dayProgress: Date
    @Query private var allSessions: [WorkoutSession]
    @Query private var allExercises: [Exercise]
    @Environment(ProgressManager.self) private var hkm
    private let calendar = Calendar.current
    private let formatter = DateFormatter()
    private let AL = ActivityLabels()
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(
                        allSessions.filter {
                            $0.completed.map { calendar.isDate($0, inSameDayAs: dayProgress) } ?? false
                        },
                        id: \.self
                    ) { session in
                        SessionLink(session: session)
                    }
                } header: {
                    Text("Session")
                }
                Section {
                    ForEach(allExercises.filter { $0.updateData.contains { calendar.isDate($0.changeDate, inSameDayAs: dayProgress) } }, id: \.self) { update in
                        
                    }
                } header: {
                    Text("Progress")
                }
                Section {
                    ForEach(hkm.bodyWeightData.filter { calendar.isDate($0.date, inSameDayAs: dayProgress) }, id: \.self) { data in
                        BodyWeightData(data: data)
                    }
                } header: {
                    Text("Body Weight")
                }
                Section {
                    ForEach(hkm.bodyFatData.filter { calendar.isDate($0.date, inSameDayAs: dayProgress) }, id: \.self) { data in
                        BodyFatData(data: data)
                    }
                } header: {
                    Text("Body Fat")
                }
                .navigationTitle(HeaderDateFormatter())
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
//    private func PRList(update: Exercise) -> some View {
//        ForEach(update.prData.filter { calendar.isDate($0.date, inSameDayAs: dayProgress) } ) { set in
//            NavigationLink {
//                WorkoutUpdateView(workout: update)
//            } label: {
//                Label {
//                    //Text(AL.UpdateLabel(specificUpdate: set, allUpdates: update.updateData, workoutName: update.workout?.name ?? "Unknown Workout"))
//                } icon: {
//                    Image(systemName: "trophy")
//                        .foregroundStyle(Constants.updateTheme)
//                }
//            }
//        }
//    }
//
//    private func UpdateList(update: WorkoutUpdate) -> some View {
//        ForEach(update.updateData.filter { calendar.isDate($0.updateDate, inSameDayAs: dayProgress) } ) { set in
//            NavigationLink {
//                WorkoutUpdateView(workout: update)
//            } label: {
//                Label {
//                    Text(AL.UpdateDataLabel(specificUpdate: set, allUpdates: update.updateData, workoutName: update.workout?.name ?? "Unknown Workout"))
//                } icon: {
//                    Image(systemName: "chart.dots.scatter")
//                        .foregroundStyle(Constants.updateTheme)
//                }
//            }
//        }
//    }
    
    private func SessionLink(session: WorkoutSession) -> some View {
        NavigationLink {
            SessionRecap(session: session)
        } label: {
            Label {
                Text(session.name)
            } icon: {
                Image(systemName: "timer")
                    .foregroundStyle(Constants.sessionTheme)
            }
        }
    }
    
    private func BodyFatData(data: WeightEntry) -> some View {
        NavigationLink {
            HealthData(type: .bodyFat)
        } label: {
            Label {
                if data.index != 0 {
                    Text(ActivityLabels().BodyFatLabel(currentValue: data.value, previousValue: hkm.bodyFatData[data.index - 1].value))
                } else {
                    Text(ActivityLabels().BodyFatLabel(currentValue: data.value, previousValue: nil))
                }
            } icon: {
                Image(systemName: "heart.text.clipboard")
                    .foregroundStyle(Constants.bodyFatTheme)
            }
        }
    }
    
    private func BodyWeightData(data: WeightEntry) -> some View {
        NavigationLink {
            HealthData(type: .bodyWeight)
        } label: {
            Label {
                if data.index != 0 {
                    Text(ActivityLabels().BodyWeightLabel(currentValue: data.value, previousValue: hkm.bodyWeightData[data.index - 1].value, unit: hkm.weightUnitString))
                } else {
                    Text(ActivityLabels().BodyWeightLabel(currentValue: data.value, previousValue: nil, unit: hkm.weightUnitString))
                }
            } icon: {
                Image(systemName: "heart.text.clipboard")
                    .foregroundStyle(Constants.bodyWeightTheme)
            }
        }
    }
    
    private func HeaderDateFormatter() -> String {
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: dayProgress)
    }
    
}
