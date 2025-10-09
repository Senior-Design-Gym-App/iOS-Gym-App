import SwiftUI
import SwiftData

struct WorkoutListView: View {
    
    @Query private var workout: [Workout]
    @Environment(\.modelContext) private var context
    
    private var groupedWorkouts: [String: [Workout]] {
        Dictionary(grouping: workout) { workout in
            let firstChar = workout.name.prefix(1).uppercased()
            let char = firstChar.first ?? Character(" ")
            
            if char.isLetter {
                return String(char)
            } else {
                return "#" // Group all non-letters together
            }
        }
    }
    
    private var sortedLetters: [String] {
        let keys = groupedWorkouts.keys
        let letters = keys.filter { $0 != "#" }.sorted()
        let hasNonLetters = keys.contains("#")
        
        return hasNonLetters ? letters + ["#"] : letters
    }
    
    var body: some View {
        NavigationStack {
            List(sortedLetters, id: \.self) { letter in
                Section {
                    ForEach((groupedWorkouts[letter] ?? []).sorted(by: { $0.name < $1.name })) { workout in
                        NavigationLink {
                            EditWorkoutView(
                                workout: workout,
                                sets: workout.weights.count,
                                reps: workout.reps.count >= 10 ? workout.reps : workout.reps + Array(repeating: 8, count: 10 - workout.reps.count),
                                rest: Double(workout.rest),
                                weights: Array((workout.weights.map { String($0) } + Array(repeating: "0.0", count: max(0, 10 - workout.weights.count))).prefix(10)),
                                exerciseName: workout.name,
                                muscleWorked: workout.muscleWorked,
                                sameRepsForAllSets: Set(workout.reps).count <= 1,
                                sameWeightForAllSets: Set(workout.weights).count <= 1
                            )
                        } label: {
                            Text(workout.name)
                        }
                    }
                } header: {
                    Text(letter)
                }
                .sectionIndexLabel(letter)
            }
            .navigationTitle("My Workouts")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    NavigationLink {
                        CreateWorkoutView()
                    } label: {
                        Label("Add Workout", systemImage: "plus")
                    }
                }
            }
        }
    }
    
}
