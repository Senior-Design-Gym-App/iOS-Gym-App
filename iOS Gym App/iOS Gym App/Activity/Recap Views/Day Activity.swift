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
                        ReusedViews.SessionViews.SessionLink(session: session)
                    }
                } header: {
                    Text("Session")
                }
                Section {
                    ForEach(allExercises.filter { $0.updateData.contains { calendar.isDate($0.changeDate, inSameDayAs: dayProgress) } }, id: \.self) { update in
                        ExerciseUpdates(exercise: update)
                    }
                } header: {
                    Text("Progress")
                }
                Section {
                    ForEach(allExercises.filter { $0.allOneRepMaxData.contains { calendar.isDate($0.entry.date, inSameDayAs: dayProgress) } }, id: \.self) { exercise in
                        OneRepMax(exercise: exercise)
                    }
                } header: {
                    Text("One Rep Max")
                }
                Section {
                    ForEach(hkm.bodyWeightData.filter { calendar.isDate($0.date, inSameDayAs: dayProgress) }, id: \.self) { data in
                        BodyWeightData(data: data)
                    }
                    ForEach(hkm.bodyFatData.filter { calendar.isDate($0.date, inSameDayAs: dayProgress) }, id: \.self) { data in
                        BodyFatData(data: data)
                    }
                } header: {
                    Text("Health Data")
                }
                .navigationTitle(HeaderDateFormatter())
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    private func OneRepMax(exercise: Exercise) -> some View {
        ForEach(exercise.allOneRepMaxData.filter { calendar.isDate($0.entry.date, inSameDayAs: dayProgress) } ) { set in
            NavigationLink {
                ExerciseChanges(exercise: exercise)
            } label: {
                Label {
                    Text(exercise.name)
                    Text(ActivityLabels.OneRepMaxLabel(current: set.entry, all: exercise.allOneRepMaxData.map { $0.entry }, label: hkm.weightUnitString))
                } icon: {
                    exercise.icon
                        .foregroundStyle(exercise.color)
                }
            }
        }
    }
//
    private func ExerciseUpdates(exercise: Exercise) -> some View {
        ForEach(exercise.updateData.filter { calendar.isDate($0.changeDate, inSameDayAs: dayProgress) } ) { set in
            NavigationLink {
                ExerciseChanges(exercise: exercise)
            } label: {
                Label {
                    Text(exercise.name)
                    Text(ActivityLabels().UpdateDataLabel(specificUpdate: set, allUpdates: exercise.updateData))
                } icon: {
                    exercise.icon
                        .foregroundStyle(exercise.color)
                }
            }
        }
    }
    
    private func BodyFatData(data: WeightEntry) -> some View {
        NavigationLink {
            HealthData(type: .bodyFat)
        } label: {
            Label {
                Text("\(data.value, specifier: "%.1f")%")
                Text(ActivityLabels.BodyFatLabel(current: data, all: hkm.bodyFatData))
            } icon: {
                Image(systemName: "heart.text.clipboard")
                    .foregroundStyle(Constants.healthColor)
            }
        }
    }
    
    private func BodyWeightData(data: WeightEntry) -> some View {
        NavigationLink {
            HealthData(type: .bodyWeight)
        } label: {
            Label {
                Text("\(data.value, specifier: "%.1f") \(hkm.weightUnitString)")
                Text(ActivityLabels.BodyWeightLabel(current: data, all: hkm.bodyWeightData, weightLabel: hkm.weightUnitString))
            } icon: {
                Image(systemName: "heart.text.clipboard")
                    .foregroundStyle(Constants.healthColor)
            }
        }
    }
    
    private func HeaderDateFormatter() -> String {
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: dayProgress)
    }
    
}
