import SwiftUI
import SwiftData

extension ReusedViews {
    
    struct WorkoutViews {
        
        static func WorkoutListPreview(workout: Workout) -> some View {
            HStack {
                Labels.SmallIconSize(color: workout.color)
                Labels.TypeListDescription(name: workout.name, items: workout.exercises ?? [], type: .workout)
            }
        }
        
        static func HorizontalListPreview(workout: Workout) -> some View {
            VStack(alignment: .leading, spacing: 5) {
                Labels.MediumIconSize(color: workout.color)
                ReusedViews.Labels.MediumTextLabel(title: workout.name)
            }
        }
        
        struct WorkoutControls: View {
            
            @Query private var allExercises: [Exercise]
            let saveAction: () -> Void
            @State var newExercises: [Exercise]
            @Binding var showAddSheet: Bool
            @Binding var oldExercises: [Exercise]
            
            var body: some View {
                NavigationStack {
                    List {
                        Section {
                            ForEach(newExercises, id: \.self) { exercise in
                                ExerciseViews.ExerciseListPreview(exercise: exercise)
                            }
                            .onMove { indices, newOffset in
                                newExercises.move(fromOffsets: indices, toOffset: newOffset)
                            }
                            .onDelete { indices in
                                newExercises.remove(atOffsets: indices)
                            }
                        } header: {
                            Text("Current Exercises")
                        }
                        Section {
                            ForEach(allExercises.filter({ !newExercises.contains($0) }), id: \.self) { exercise in
                                HStack {
                                    ExerciseViews.ExerciseListPreview(exercise: exercise)
                                    Spacer()
                                    Button {
                                        withAnimation {
                                            newExercises.append(exercise)
                                        }
                                    } label: {
                                        Image(systemName: "plus.circle")
                                    }
                                }
                            }
                        } header: {
                            
                        }
                    }
                    .environment(\.editMode, .constant(.active))
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            ReusedViews.Buttons.CancelButton(cancel: CancelOptions)
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            ReusedViews.Buttons.SaveButton(disabled: newExercises.isEmpty, save: SaveOptions)
                        }
                    }
                }
            }
            
            private func SaveOptions() {
                oldExercises = newExercises
                saveAction()
                showAddSheet = false
            }
            
            private func CancelOptions() {
                showAddSheet = false
            }
            
        }
        
        static func MostRecentSession(workout: Workout) -> String {
            if let sessions = workout.sessions,
               let recent = sessions.compactMap({ $0.completed }).sorted(by: { $0 > $1 }).first {
                return DateHandler().RelativeTime(from: recent)
            } else {
                return "No Sessions"
            }
        }
        
    }
    
}
