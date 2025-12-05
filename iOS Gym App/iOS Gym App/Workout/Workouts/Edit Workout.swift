import SwiftUI
import SwiftData

struct EditWorkoutView: View {
    
    @State var selectedWorkout: Workout
    @State private var showRename: Bool = false
    @State private var showAddSheet: Bool = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            List {
                HStack {
                    Spacer()
                    VStack {
                        ReusedViews.Labels.LargeIconSize(color: selectedWorkout.color)
                            .offset(y: Constants.largeOffset)
                        HStack {
                            ReusedViews.Buttons.RenameButtonAlert(type: .workout, oldName: $selectedWorkout.name)
                            ReusedViews.Buttons.DeleteButtonConfirmation(type: .workout, deleteAction: Delete)
                        }
                    }
                    Spacer()
                }.padding(.bottom)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                SelectedExerciseList()
                WorkoutSplitsList()
                
                // Debug section - remove after testing
                Section {
                    Button("Print JSON") {
                        printWorkoutJSON()
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                ReusedViews.WorkoutViews.WorkoutControls(newExercises: selectedWorkout.sortedExercises, showAddSheet: $showAddSheet, workout: $selectedWorkout)
            }
            .navigationTitle(selectedWorkout.name)
            .navigationSubtitle("Edited \(DateHandler().RelativeTime(from: selectedWorkout.modified))")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func SelectedExerciseList() -> some View {
        Section {
            ForEach(selectedWorkout.sortedExercises, id: \.self) { exercise in
                NavigationLink {
                    EditExerciseView(exercise: exercise, setData: exercise.recentSetData.setData, selectedMuscle: exercise.muscle, selectedEquipment: exercise.workoutEquipment)
                } label: {
                    ReusedViews.ExerciseViews.ExerciseListPreview(exercise: exercise)
                }
            }
        } header: {
            ReusedViews.Buttons.EditHeaderButton(toggleEdit: $showAddSheet, type: .workout, items: selectedWorkout.sortedExercises)
        }
    }
    
    private func WorkoutSplitsList() -> some View {
        Section {
            if let split = selectedWorkout.split {
                NavigationLink {
                    EditSplitView(selectedSplit: split)
                } label: {
                    ReusedViews.SplitViews.ListPreview(split: split)
                }
            } else {
                Text("Not in a split.")
            }
        } header: {
            Text("Split")
        }
    }
    
    private func Delete() {
        context.delete(selectedWorkout)
        try? context.save()
        dismiss()
    }
    
    // MARK: - Debug JSON Output
    
    private func printWorkoutJSON() {
        print("\n🔍 ===== WORKOUT JSON OUTPUT =====\n")
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            
            let jsonData = try encoder.encode(selectedWorkout)
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
                
                // Also print individual exercises
                print("\n📋 ===== INDIVIDUAL EXERCISES =====\n")
                
                if let exercises = selectedWorkout.exercises {
                    for (index, exercise) in exercises.enumerated() {
                        print("\n--- Exercise \(index + 1): \(exercise.name) ---")
                        let exerciseData = try encoder.encode(exercise)
                        if let exerciseString = String(data: exerciseData, encoding: .utf8) {
                            print(exerciseString)
                        }
                    }
                }
                
                // Print a simplified format for LLM
                print("\n🤖 ===== SIMPLIFIED FORMAT FOR LLM =====\n")
                printSimplifiedFormat()
                
            } else {
                print("❌ Failed to convert JSON data to string")
            }
            
        } catch {
            print("❌ Encoding error: \(error)")
            print("Error details: \(error.localizedDescription)")
        }
        
        print("\n🔍 ===== END JSON OUTPUT =====\n")
    }
    
    private func printSimplifiedFormat() {
        guard let exercises = selectedWorkout.exercises else {
            print("No exercises found")
            return
        }
        
        // Create a simplified structure
        let simplifiedWorkout: [String: Any] = [
            "name": selectedWorkout.name,
            "exercises": exercises.map { exercise in
                [
                    "name": exercise.name,
                    "muscleWorked": exercise.muscleWorked ?? "Not specified",
                    "rest": exercise.rest,
                    "weights": exercise.weights,
                    "reps": exercise.reps,
                    "equipment": exercise.equipment ?? "Not specified"
                ] as [String : Any]
            }
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: simplifiedWorkout, options: [.prettyPrinted, .sortedKeys])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
        } catch {
            print("❌ Failed to create simplified format: \(error)")
        }
    }
    
}
