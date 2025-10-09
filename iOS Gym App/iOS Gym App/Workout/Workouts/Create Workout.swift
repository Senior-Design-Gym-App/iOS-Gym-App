import SwiftUI
import SwiftData

struct CreateWorkoutView: View {
    
    @State private var lastTouchedIndex: Int = 0
    @State private var lastTouchedTextField: String = ""
    @State private var sets: Int = 3
    @State private var reps: [Int] = Array(repeating: 8, count: 10)
    @State private var rest: Double = 0.0
    @State private var weights: [String] = Array(repeating: "0.0", count: 10)
    @State private var exerciseName: String = ""
    @State private var muscleWorked: String = ""
    @State private var sameRepsForAllSets: Bool = true
    @State private var sameWeightForAllSets: Bool = true
    private let WCF = WorkoutConversionFunctions()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            Form {
                WorkoutOptionsView(lastTouchedIndex: $lastTouchedIndex, lastTouchedTextField: $lastTouchedTextField, sets: $sets, reps: $reps, rest: $rest, weights: $weights, exerciseName: $exerciseName, muscleWorked: $muscleWorked, sameRepsForAllSets: $sameRepsForAllSets, sameWeightForAllSets: $sameWeightForAllSets, lastModified: nil)
                SaveOptions()
            }
            .navigationTitle("Create Workout")
        }
    }
    
    private func SaveOptions() -> some View {
        Section {
            Button {
                SaveExercise()
                ClearFields()
            } label: {
                Label("Save & Add Another", systemImage: "square.and.arrow.down.on.square")
            }
            Button {
                SaveExercise()
                dismiss()
            } label: {
                Label("Save & Exit", systemImage: "square.and.arrow.down.badge.checkmark")
            }
        } header: {
            Label("Save Options", systemImage: "square.and.arrow.down.on.square")
        }
    }
    
    private func SaveExercise() {
        let updatedWeights = WCF.ConvertWeightsArray(weightsArrayString: weights, sets: sets, sameWeightForAllSets: sameWeightForAllSets)

        let repsToSave: [Int] = sameRepsForAllSets
            ? Array(repeating: reps[0], count: sets)
            : Array(reps.prefix(sets)) + Array(repeating: reps.last ?? 0, count: max(0, sets - reps.count))
        
        let newUpdate = WorkoutUpdate(updateDates: [Date.now], reps: [repsToSave], weights: [updatedWeights])
        
        context.insert(newUpdate)

        let exercise = Workout(name: exerciseName, rest: Int(rest), order: 0, muscleWorked: muscleWorked, weights: updatedWeights, reps: repsToSave, updateData: newUpdate)

        context.insert(exercise)
        try? context.save()
    }
    
    private func ClearFields() {
        lastTouchedIndex = 0
        lastTouchedTextField = ""
        reps = Array(repeating: 8, count: 10)
        weights = Array(repeating: "0.0", count: 10)
        exerciseName = ""
        muscleWorked = ""
    }
    
}
