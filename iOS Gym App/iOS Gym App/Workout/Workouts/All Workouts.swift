import SwiftUI
import SwiftData

struct AllWorkoutsView: View {
    
    @Query private var allExercises: [Exercise]
    @Query private var allWorkouts: [Workout]
    
    @Namespace private var namespace
    @State private var showCreateDay: Bool = false
    @AppStorage("daySortMethod") private var sortType: WorkoutSortTypes = .alphabetical
    @AppStorage("dayViewType") private var viewType: WorkoutViewTypes = .grid

    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 10)
    ]
    
    private var sortedWorkouts: [Workout] {
        switch sortType {
        case .alphabetical:
            allWorkouts.sorted { $0.name < $1.name }
        case .created:
            allWorkouts.sorted { $0.created > $1.created }
        case .modified:
            allWorkouts.sorted { $0.modified < $1.modified }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewType {
                case .grid:
                    GridView()
                case .verticalList:
                    ListView()
                }
            }
            .navigationTitle("Workouts")
            .sheet(isPresented: $showCreateDay) {
                CreateWorkoutView()
            }
            .toolbar {
                ToolbarItem {
                    ReusedViews.Buttons.CreateButton(toggleCreateSheet: $showCreateDay)
                }
                ToolbarItem {
                    ReusedViews.Pickers.WorkoutMenu(sortType: $sortType, viewType: $viewType)
                }
            }
        }
    }
    
    private func ListView() -> some View {
        List {
            ForEach(sortedWorkouts, id: \.self) { workout in
                NavigationLink {
                    EditWorkoutView(selectedWorkout: workout)
                } label: {
                    ReusedViews.WorkoutViews.WorkoutListPreview(workout: workout)
                }
            }
        }
    }
    
    private func GridView() -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(sortedWorkouts, id: \.self) { workout in
                    NavigationLink {
                        EditWorkoutView(selectedWorkout: workout)
                            .navigationTransition(.zoom(sourceID: workout.id, in: namespace))
                    } label: {
                        ReusedViews.WorkoutViews.HorizontalListPreview(workout: workout)
                    }.buttonStyle(.plain)
                    .matchedTransitionSource(id: workout.id, in: namespace)
                }
            }
        }
        .padding(.horizontal)
    }
    
}
