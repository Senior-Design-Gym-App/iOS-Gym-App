import SwiftUI
import SwiftData

struct AllWorkoutsView: View {
    
    @Query private var workout: [Workout]
    @Environment(\.modelContext) private var context
    @State private var showCreateWorkout: Bool = false
    
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
            HeaderView()
//                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                VerticalListView()
        }
//        .listStyle(.plain)
//        .ignoresSafeArea(edges: .top)
        .navigationTitle("My Workouts")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                CreateWorkoutButton()
            }
        }
        .sheet(isPresented: $showCreateWorkout) {
            CreateWorkoutView()
        }
    }
    
    private func VerticalListView() -> some View {
        ForEach(sortedLetters, id: \.self) { letter in
            Section {
                ForEach((groupedWorkouts[letter] ?? []).sorted(by: { $0.name < $1.name })) { workout in
                    EditLink(workout: workout)
                }
            } header: {
                Text(letter)
            }
            .sectionIndexLabel(letter)
        }
    }
    
    private func HeaderView() -> some View {
        ReusedViews.HeaderCard(fill: Constants.mainAppTheme)
            .overlay(alignment: .bottom) {
                VStack {
                    ReusedViews.HeaderTitle(title: "Select a workout to edit")
                        .padding(.bottom, 10)
                }
            }
    }
    
    private func EditLink(workout: Workout) -> some View {
        NavigationLink {
            EditWorkoutView(workout: workout, rest: Double(workout.rest), name: workout.name, setData: workout.setData, selectedMuscle: workout.muscleInfo?.muscle)
        } label: {
            Text(workout.name)
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
