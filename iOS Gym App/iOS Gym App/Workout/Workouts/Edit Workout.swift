import SwiftUI
import SwiftData

struct EditWorkoutView: View {
    
    @State var workout: Workout
    @State private var lastTouchedIndex: Int = 0
    @State private var lastTouchedTextField: String = ""
    @State var sets: Int
    @State var reps: [Int] = Array(repeating: 8, count: 10)
    @State var rest: Double
    @State var weights: [String]
    @State var exerciseName: String
    @State var muscleWorked: String
    @State var sameRepsForAllSets: Bool
    @State var sameWeightForAllSets: Bool
    private let WCF = WorkoutConversionFunctions()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            Form {
                WorkoutOptionsView(lastTouchedIndex: $lastTouchedIndex, lastTouchedTextField: $lastTouchedTextField, sets: $sets, reps: $reps, rest: $rest, weights: $weights, exerciseName: $exerciseName, muscleWorked: $muscleWorked, sameRepsForAllSets: $sameRepsForAllSets, sameWeightForAllSets: $sameWeightForAllSets, lastModified: workout.updateData?.updateDates.last ?? nil)
                SaveOptions()
                GroupsIn()
            }
            .navigationTitle("Edit Workout")
        }
    }
    
    private func SaveOptions() -> some View {
        Section {
            Button {
                SaveExercise()
                dismiss()
            } label: {
                Label("Update & Exit", systemImage: "square.and.arrow.down.badge.checkmark")
            }
            Button {
                context.delete(workout)
                dismiss()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .foregroundStyle(.red)
        } header: {
            Label("Save Options", systemImage: "square.and.arrow.down.on.square")
        }
    }
    
    private func GroupsIn() -> some View {
        Section {
            ForEach(workout.groups ?? [], id: \.self) { group in
                Text(group.groupName)
            }
        } header: {
            Label("Grouped in", systemImage: "tag")
        }
    }
    
    private func SaveExercise() {
        let updatedWeights = WCF.ConvertWeightsArray(weightsArrayString: weights, sets: sets, sameWeightForAllSets: sameWeightForAllSets)

        let repsToSave: [Int] = sameRepsForAllSets ? Array(repeating: reps[0], count: sets) : Array(reps.prefix(sets))
        
        if (repsToSave != workout.reps) || (updatedWeights != workout.weights) || sets != workout.weights.count {
            if let update = workout.updateData {
                update.reps.append(repsToSave)
                update.weights.append(updatedWeights)
                update.updateDates.append(Date())
            } else {
                let newUpdate = WorkoutUpdate(workout: workout, updateDates: [Date()], reps: [workout.reps, repsToSave], weights: [workout.weights, updatedWeights])
                context.insert(newUpdate)
            }
        }
        
        workout.name = exerciseName
        workout.rest = Int(rest)
        workout.muscleWorked = muscleWorked
        workout.weights = updatedWeights
        workout.reps = repsToSave
                
        try? context.save()
    }
    
}
