import SwiftUI
import SwiftData

extension ReusedViews {
    
    struct WorkoutViews {
        
        static func WorkoutListPreview(workout: Workout) -> some View {
            HStack {
                Labels.SmallIconSize(key: workout.id.hashValue.description)
                Labels.ListDescription(name: workout.name, items: workout.exercises ?? [], type: .workout)
            }
        }
        
        static func HorizontalListPreview(workout: Workout) -> some View {
            VStack(alignment: .leading, spacing: 5) {
                Labels.MediumIconSize(key: workout.id.hashValue.description)
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
                AddSheet()
            }
            
            private func AddSheet() -> some View {
                NavigationStack {
                    List {
                        ForEach(allExercises, id: \.self) { exercise in
                            HStack {
                                ExerciseViews.ExerciseListPreview(exercise: exercise)
                                Spacer()
                                Button {
                                    if newExercises.contains(where: { $0 == exercise }) {
                                        newExercises.removeAll(where: { $0 == exercise })
                                    } else {
                                        newExercises.append(exercise)
                                    }
                                } label: {
                                    if newExercises.contains(where: { $0 == exercise }) {
                                        Image(systemName: "checkmark")
                                    } else {
                                        Image(systemName: "plus.circle")
                                    }
                                }
                            }
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
                    //                .onMove { indices, newOffset in
                    //                    newSetData.move(fromOffsets: indices, toOffset: newOffset)
                    //                }
                    //                .onDelete { indices in
                    //                    newSetData.remove(atOffsets: indices)
                    //                }
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
