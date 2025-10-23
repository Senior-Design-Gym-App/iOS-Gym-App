import SwiftUI
import SwiftData

struct AllWorkoutsView: View {
    
    @Query private var allExercises: [Exercise]
    @Query private var allWorkouts: [Workout]
    
    @State private var showCreateDay: Bool = false
    @AppStorage("daySortMethod") private var daySortMethod: WorkoutSortTypes = .alphabetical
    @AppStorage("dayViewType") private var dayViewType: WorkoutViewTypes = .grid

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
    
    private var sortedGroups: [Workout] {
        switch daySortMethod {
        case .alphabetical:
            allWorkouts.sorted { $0.name < $1.name }
        case .tags, .created, .pinned:
            allWorkouts
        case .modified, .muscleGroups:
            allWorkouts
        }
    }
    
    var body: some View {
        ScrollView {
            GridView()
        }
        .navigationTitle("My Days")
        .sheet(isPresented: $showCreateDay) {
            CreateWorkoutView(allExercises: allExercises)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                CreateDayButton()
            }
            ToolbarItemGroup(placement: .secondaryAction) {
                Section {
                    ReusedPickers.ViewTypePicker(viewType: $dayViewType)
                }
                Section {
                    SortPicker()
                }
            }
        }
    }
    
    private func GridView() -> some View {
        GlassEffectContainer {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(allWorkouts, id: \.self) { workout in
                    NavigationLink {
                        EditWorkoutView(allExercises: allExercises, name: workout.name, selectedExercises: workout.exercises ?? [], selectedWorkout: workout)
                    } label: {
                        ReusedViews.WorkoutViews.DayGridPreview(workout: workout, bottomText: "\(workout.exercises?.count ?? 0) Workout\(workout.exercises?.count == 1 ? "" : "s")")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .padding()
        }
    }
    
    private func SortPicker() -> some View {
        Picker("Sort & Filter", selection: $daySortMethod) {
            Text(WorkoutSortTypes.alphabetical.rawValue).tag(WorkoutSortTypes.alphabetical)
            Text(WorkoutSortTypes.modified.rawValue).tag(WorkoutSortTypes.modified)
        }
    }
    
    private func CreateDayButton() -> some View {
        Button {
            showCreateDay = true
        } label: {
            Label("Add Workout", systemImage: "plus")
        }
    }
    
}
