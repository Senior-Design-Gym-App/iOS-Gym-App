import SwiftUI
import SwiftData

struct AllExerciseView: View {
    
    @Query private var allExercises: [Exercise]
    @Environment(\.modelContext) private var context
    @State private var showCreateWorkout: Bool = false
    @State private var searchText: String = ""
    
    @Namespace private var namespace
    @AppStorage("workoutSortMethod") private var sortType: WorkoutSortTypes = .alphabetical
    @AppStorage("exerciseViewType") private var viewType: WorkoutViewTypes = .grid
    
    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 10)
    ]
    
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
    
    private var sortedExercises: [Exercise] {
        switch sortType {
        case .alphabetical:
            allExercises.sorted { $0.name < $1.name }
        case .created:
            allExercises.sorted { $0.created > $1.created }
        case .modified:
            allExercises.sorted { $0.modified < $1.modified }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewType {
                case .grid:
                    GridView()
                case .verticalList:
                    if sortType == .alphabetical {
                        AlphabeticalVerticalListView()
                    } else {
                        SortedVerticalListView()
                    }
                }
            }
            .navigationTitle("Exercises")
//            .searchable(text: $searchText, prompt: "Search")
            .toolbar {
                ToolbarItem {
                    ReusedViews.Buttons.CreateButton(toggleCreateSheet: $showCreateWorkout)
                }
                ToolbarItem {
                    ReusedViews.Pickers.WorkoutMenu(sortType: $sortType, viewType: $viewType)
                }
            }
            .sheet(isPresented: $showCreateWorkout) {
                CreateExerciseView()
            }
        }
    }
    
    private func AlphabeticalVerticalListView() -> some View {
        List {
            ForEach(sortedLetters, id: \.self) { letter in
                Section {
                    ForEach((groupedWorkouts[letter] ?? []).sorted(by: { $0.name < $1.name })) { exercise in
                        ExerciseListRow(exercise: exercise)
                    }
                } header: {
                    Text(letter)
                }
                .sectionIndexLabel(letter)
            }
        }
    }
    
    private func SortedVerticalListView() -> some View {
        List {
            ForEach(sortedExercises, id: \.self) { exercise in
                ExerciseListRow(exercise: exercise)
            }
        }
    }
    
    private func ExerciseListRow(exercise: Exercise) -> some View {
        NavigationLink {
            EditExerciseView(exercise: exercise, setData: exercise.setData.last ?? [])
        } label: {
            ReusedViews.ExerciseViews.ExerciseListPreview(exercise: exercise)
        }
    }
    
    private func GridView() -> some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(sortedExercises, id: \.self) { exercise in
                    NavigationLink {
                        EditExerciseView(exercise: exercise, setData: exercise.setData.last ?? [])
                            .navigationTransition(.zoom(sourceID: exercise.id, in: namespace))
                    } label: {
                        ReusedViews.ExerciseViews.HorizontalListPreview(exercise: exercise)
                    }.buttonStyle(.plain)
                    .matchedTransitionSource(id: exercise.id, in: namespace)
                }
            }
        }
        .padding(.horizontal)
    }
    
}
