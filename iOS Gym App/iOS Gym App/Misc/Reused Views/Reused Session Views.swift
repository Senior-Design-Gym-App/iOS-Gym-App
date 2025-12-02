import SwiftUI

extension ReusedViews {
    
    struct SessionViews {
        
        static func SessionLink(session: WorkoutSession) -> some View {
            NavigationLink {
                SessionRecap(session: session)
            } label: {
                HStack {
                    ReusedViews.Labels.SmallIconSize(color: session.color)
                    ReusedViews.Labels.Description(topText: session.name, bottomText: "\(DateHandler().RelativeTime(from: session.completed!)) ago")
                    Spacer()
                }
            }
        }
        
        static func WorkoutSessionView(workout: Workout, start: @escaping (Workout) -> Void) -> some View {
            HStack {
                ReusedViews.Labels.SmallIconSize(color: workout.color)
                ReusedViews.Labels.ListDescription(title: workout.name, subtitle: ReusedViews.WorkoutViews.MostRecentSession(workout: workout), extend: true)
                Spacer()
                Menu {
                    Section {
                        ForEach(workout.sortedExercises, id: \.self) { exercise in
                            Label {
                                Text(exercise.name)
                                Text("\(exercise.recentSetData.setData.count) Set\(exercise.recentSetData.setData.count == 1 ? "" : "s")")
                            } icon: {
                                Image(systemName: exercise.workoutEquipment?.imageName ?? Constants.defaultEquipmentIcon)
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

