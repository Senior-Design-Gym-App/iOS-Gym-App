import SwiftUI
import SwiftData

struct AllWorkoutDaysView: View {
    
    @Query private var allDays: [WorkoutDay]
    @Query private var allWorkouts: [Workout]
    
    @State private var showCreateDay: Bool = false
    @AppStorage("daySortMethod") private var daySortMethod: WorkoutSortTypes = .alphabetical

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
    
    private var sortedGroups: [WorkoutDay] {
        switch daySortMethod {
        case .alphabetical:
            allDays.sorted { $0.name < $1.name }
        case .tags, .created, .pinned:
            allDays
        case .modified, .muscleGroups:
            allDays
        }
    }
    
    var body: some View {
        ScrollView {
            GridView()
        }
        .navigationTitle("My Days")
        .sheet(isPresented: $showCreateDay) {
            CreateWorkoutDayView(allWorkouts: allWorkouts)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                CreateDayButton()
            }
            ToolbarItem(placement: .secondaryAction) {
                SortPicker()
            }
        }
    }
    
    private func GridView() -> some View {
        GlassEffectContainer {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(allDays, id: \.self) { day in
                    NavigationLink {
                        EditWorkoutDayView(
                            allWorkouts: allWorkouts,
                            name: day.name,
                            selectedWorkouts: day.workouts ?? [],
                            selectedDay: day
                        )
                    } label: {
                        ReusedPreviews.GridDayView(day: day)
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
