import SwiftUI

extension ReusedViews {
    
    struct SessionViews {
        
        static func SessionLink(session: WorkoutSession) -> some View {
            NavigationLink {
                SessionRecap(session: session)
            } label: {
                Label {
                    Text(session.name)
                    Text("\(session.exercises?.count ?? 0) exercise\(session.exercises?.count == 1 ? "" : "s")")
                } icon: {
                    Labels.ListIcon(color: session.color)
                }
            }
        }
        
        static func WorkoutSessionView(workout: Workout, start: @escaping (Workout) -> Void) -> some View {
            HStack {
                ReusedViews.WorkoutViews.WorkoutListPreview(workout: workout)
                Spacer()
                Menu {
                    Section {
                        ForEach(workout.sortedExercises, id: \.self) { exercise in
                            Label {
                                Text(exercise.name)
                                Text("\(exercise.recentSetData.setData.count) Set\(exercise.recentSetData.setData.count == 1 ? "" : "s")")
                            } icon: {
                                exercise.icon
                            }
                        }
                    } header: {
                        Text(workout.name)
                    }
                    if workout.sortedExercises.count == 0 {
                        Text("You must add exercises to start.")
                    } else {
                        Button {
                            start(workout)
                        } label: {
                            Label("Start Session", systemImage: "play")
                        }.disabled(workout.sortedExercises.count == 0)
                    }
                } label: {
                    Image(systemName: "play.circle.fill")
                }
            }
        }
        
    }
    
}

