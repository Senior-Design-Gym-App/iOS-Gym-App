import SwiftUI
import SwiftData

struct AllWorkoutsView: View {
    
    @Query private var workout: [Workout]
    @Environment(\.modelContext) private var context
    @State private var showCreateWorkout: Bool = false
    @State private var selectedWorkout: Workout?
    @State private var searchText: String = ""
    
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
        }
        .sheet(item: $selectedWorkout, content: { workout in
            EditWorkoutView(workout: workout, name: workout.name, setData: workout.setData, selectedMuscle: workout.muscleInfo?.muscle, selectedEquipment: workout.workoutEquipment)
        })
        .sheet(isPresented: $showCreateWorkout) {
            CreateWorkoutView()
        }
    }
    
    private func VerticalListView() -> some View {
        ForEach(sortedLetters, id: \.self) { letter in
            Section {
                ForEach((groupedWorkouts[letter] ?? []).sorted(by: { $0.name < $1.name })) { workout in
                    HStack {
                        Image(systemName: workout.workoutEquipment?.imageName ?? "dumbbell")
                        VStack(alignment: .leading, spacing: 0) {
                            Text(workout.name)
                            Text("\(workout.setData.count) set\(workout.setData.count == 1 ? "" : "s")")
                                .font(.callout)
                                .fontWeight(.thin)
                        }
                        Spacer()
                        Menu {
                            ControlGroup {
                                Button {
                                    selectedWorkout = workout
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                Button(role: .destructive) {
                                    
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                        .tint(.red)
                                }
                            }
                            Button {
                                
                            } label: {
                                Label("Add to Queue", systemImage: "text.badge.plus")
                            }
                            Button {
                                
                            } label: {
                                Label("Add to Day", systemImage: "document.badge.plus")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                    }
                }
            } header: {
                Text(letter)
            }
            .sectionIndexLabel(letter)
        }
    }
    
    private func EditLink(workout: Workout) -> some View {
        NavigationLink {
            EditWorkoutView(workout: workout, name: workout.name, setData: workout.setData, selectedMuscle: workout.muscleInfo?.muscle, selectedEquipment: workout.workoutEquipment)
        } label: {
            Label(workout.name, systemImage: workout.workoutEquipment?.imageName ?? "dumbbell")
        }
    }
    
    private func CreateWorkoutButton() -> some View {
        Button {
            showCreateWorkout = true
        } label: {
            Label("Add Workout", systemImage: "plus")
        }
    }
    
}
