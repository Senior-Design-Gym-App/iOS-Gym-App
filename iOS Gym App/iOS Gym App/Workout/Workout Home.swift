import SwiftUI
import SwiftData

struct WorkoutHome: View {
    
    @Query private var allWorkouts: [Workout]
    @Query private var allExercises: [Exercise]
    @Query private var allSplits: [Split]
    
    @State private var selectedExercise: Exercise?
    @State private var selectedWorkout: Workout?
    @State private var selectedSplit: Split?
    
    @Namespace private var namespace
    @AppStorage("workoutSortMethod") private var workoutSortMethod: WorkoutSortTypes = .alphabetical
    
    var recentItems: [RecentWorkoutItem] {
        let allItems: [RecentWorkoutItem] =
        allWorkouts.map { .workout($0) } + allSplits.map { .split($0) } + allExercises.map { .exercise($0) }
        
        return Array(allItems.sorted { $0.created > $1.created }.prefix(20))
    }
    
    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
    
    var body: some View {
        NavigationStack {
            List {
                MyWorkoutSection()
                RecentlyAddedSection()
                    .padding(.top)
                    .listRowSeparator(.hidden)
            }
            .toolbarTitleDisplayMode(.inlineLarge)
            .listStyle(.plain)
            .navigationTitle("Workouts")
            .navigationDestination(item: $selectedWorkout) { workout in
                EditWorkoutView(allExercises: allExercises, name: workout.name, selectedExercises: workout.exercises ?? [], selectedWorkout: workout)
                    .navigationTransition(.zoom(sourceID: workout.id, in: namespace))
            }
            .navigationDestination(item: $selectedExercise) { exercise in
                EditExerciseView(exercise: exercise, name: exercise.name, setData: exercise.setData.last ?? [])
                    .navigationTransition(.zoom(sourceID: exercise.id, in: namespace))
            }
            .navigationDestination(item: $selectedSplit) { split in
                EditSplitView(allWorkouts: allWorkouts, pinned: split.pinned, name: split.name, split: split, selectedWorkouts: split.workouts ?? [])
                    .navigationTransition(.zoom(sourceID: split.id, in: namespace))
            }
        }
    }
    
    private func MyWorkoutSection() -> some View {
        Section {
            NavigationLink {
                AllExerciseView()
            } label: {
                Label("Workouts", systemImage: Constants.workoutIcon)
            }
            NavigationLink {
                AllWorkoutsView()
            } label: {
                Label("Workout Days", systemImage: Constants.workoutDayIcon)
            }
            NavigationLink {
                AllWorkoutSplitsView()
            } label: {
                Label("Workout Splits", systemImage: Constants.workoutSplitIcon)
            }
        }
    }
    
    private func RecentlyAddedSection() -> some View {
        VStack {
            ReusedViews.HorizontalHeader(text: "Recently Added", showNavigation: false)
            LazyVGrid(columns: columns) {
                ForEach(recentItems, id: \.self) { item in
                    switch item {
                    case .exercise(let exercise):
                        RecentExercise(exercise: exercise)
                    case .split(let split):
                        RecentSplit(split: split)
                    case .workout(let workout):
                        RecentWorkout(workout: workout)
                    }
                }
            }
        }
    }
    
    private func RecentExercise(exercise: Exercise) -> some View {
        Button {
            selectedExercise = exercise
        } label: {
            ReusedViews.ExerciseViews.WorkoutGridPreview(exercise: exercise, bottomText: "Workout")
        }.buttonStyle(.plain)
        .matchedTransitionSource(id: exercise.id, in: namespace)
    }
    
    private func RecentWorkout(workout: Workout) -> some View {
        Button {
            selectedWorkout = workout
        } label: {
            ReusedViews.WorkoutViews.DayGridPreview(workout: workout, bottomText: "Workout")
        }.buttonStyle(.plain)
        .matchedTransitionSource(id: workout.id, in: namespace)
    }
    
    private func RecentSplit(split: Split) -> some View {
        Button {
            selectedSplit = split
        } label: {
            ReusedViews.SplitViews2.SplitGridPreview(split: split, bottomText: "Split")
        }.buttonStyle(.plain)
        .matchedTransitionSource(id: split.id, in: namespace)
    }
    
    private func SortPicker() -> some View {
        Picker("Sort Method", selection: $workoutSortMethod) {
            Group {
                Text("Alphabetical")
                Text("A-Z")
            }.tag(WorkoutSortTypes.alphabetical)
            Text("Created").tag(WorkoutSortTypes.created)
        }
    }
    
}
