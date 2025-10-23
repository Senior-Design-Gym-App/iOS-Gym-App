import SwiftUI
import SwiftData

struct AllExerciseView: View {
    
    @Query private var allExercises: [Exercise]
    @Environment(\.modelContext) private var context
    @State private var showCreateWorkout: Bool = false
    @State private var selectedExercise: Exercise?
    @State private var searchText: String = ""
    
    @AppStorage("workoutSortMethod") private var sortMethod: WorkoutSortTypes = .alphabetical
    
    private var groupedWorkouts: [String: [Exercise]] {
        Dictionary(grouping: allExercises) { exercise in
            let firstChar = exercise.name.prefix(1).uppercased()
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
        List {
            VerticalListView()
        }
        .listStyle(.plain)
        .navigationTitle("My Workouts")
        .searchable(text: $searchText, prompt: "Search")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                CreateWorkoutButton()
            }
//            ToolbarItem(placement: .secondaryAction) {
//                Menu {
//                    SortPicker()
//                } label: {
//                    Image(systemName: "ellipsis")
//                }
//            }
        }
        .sheet(item: $selectedExercise, content: { exercise in
            EditExerciseView(exercise: exercise, name: exercise.name, setData: exercise.setData.last ?? [])
        })
        .sheet(isPresented: $showCreateWorkout) {
            CreateExerciseView()
        }
    }
    
    private func VerticalListView() -> some View {
        ForEach(sortedLetters, id: \.self) { letter in
            Section {
                ForEach((groupedWorkouts[letter] ?? []).sorted(by: { $0.name < $1.name })) { exercise in
                    HStack {
                        ReusedViews.ExerciseViews.WorkoutInfo(exercise: exercise)
                        Spacer()
                        Menu {
                            WorkoutChangeOptions(exercise: exercise)
                            WorkoutAddOptions(exercise: exercise)
                        } label: {
                            Image(systemName: "ellipsis")
                                .tint(Constants.labelColor)
                        }
                    }
                }
            } header: {
                Text(letter)
            }
            .sectionIndexLabel(letter)
        }
    }
    
    private func WorkoutChangeOptions(exercise: Exercise) -> some View {
        Section {
            Button {
                selectedExercise = exercise
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                
            } label: {
                Label("Delete", systemImage: "trash")
                    .tint(.red)
            }
        }
    }
    
    private func WorkoutAddOptions(exercise: Exercise) -> some View {
        Section {
            Button {
                
            } label: {
                Label("Add to Queue", systemImage: "text.badge.plus")
            }
            Button {
                
            } label: {
                Label("Add to Day", systemImage: "document.badge.plus")
            }
        }
    }
    
    private func CreateWorkoutButton() -> some View {
        Button {
            showCreateWorkout = true
        } label: {
            Label("Add Workout", systemImage: "plus")
        }
    }
    
    private func SortPicker() -> some View {
        Picker("Sort Method", selection: $sortMethod) {
            Text("A-Z")
            Text("Created")
        }
    }
    
}
