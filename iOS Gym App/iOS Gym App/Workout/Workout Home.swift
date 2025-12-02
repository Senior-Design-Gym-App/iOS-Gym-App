import SwiftUI
import SwiftData

struct WorkoutHome: View {
    
    @Query private var allWorkouts: [Workout]
    @Query private var allExercises: [Exercise]
    @Query private var allSplits: [Split]
    @AppStorage("showTips") private var showTips: Bool = true
    
    @Namespace private var namespace
    
    var recentExercises: [Exercise] {
        Array(allExercises.sorted { $0.modified > $1.modified }.prefix(10))
    }
    
    var recentWorkouts: [Workout] {
        Array(allWorkouts.sorted { $0.modified > $1.modified }.prefix(10))
    }
    
    var recentSplits: [Split] {
        Array(allSplits.sorted { $0.modified > $1.modified }.prefix(10))
    }
    
    var body: some View {
        NavigationStack {
            List {
                MyWorkoutSection()
                Section {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(recentExercises, id: \.self) { exercise in
                                RecentExercise(exercise: exercise)
                            }
                        }
                    }.scrollIndicators(.hidden)
                } header: {
                    ReusedViews.Labels.Header(text: "Recent Exercises")
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16))
                Section {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(recentWorkouts, id: \.self) { workout in
                                RecentWorkout(workout: workout)
                            }
                        }
                    }.scrollIndicators(.hidden)
                } header: {
                    ReusedViews.Labels.Header(text: "Recent Workouts")
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16))
                Section {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(recentSplits, id: \.self) { split in
                                RecentSplit(split: split)
                            }
                        }
                    }.scrollIndicators(.hidden)
                } header: {
                    ReusedViews.Labels.Header(text: "Recent Splits")
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16))
            }
            .toolbarTitleDisplayMode(.inlineLarge)
            .navigationTitle("Workouts")
        }
    }
    
    private func MyWorkoutSection() -> some View {
        Section {
            NavigationLink {
                AllExerciseView()
            } label: {
                Label {
                    Text("Exercises")
                    if showTips {
                        Text("Create exercises to add to a workout. An exercise can be in an infinite amount of workouts.")
                            .font(.caption2)
                    }
                } icon: {
                    Image(systemName: Constants.sessionIcon)
                }
            }
            NavigationLink {
                AllWorkoutsView()
            } label: {
                Label {
                    Text("Workouts")
                    if showTips {
                        Text("A workout is a collection of exercises. Add a workout to a split. One workout per split.")
                            .font(.caption2)
                    }
                } icon: {
                    Image(systemName: Constants.workoutIcon)
                }
            }
            NavigationLink {
                AllWorkoutSplitsView(allSplits: allSplits, allWorkouts: allWorkouts, allExercises: allExercises)
            } label: {
                Label {
                    Text("Splits")
                    if showTips {
                        Text("Create a split to organize your workouts and to start a session. Favorite a split to  quickly a session from one of its workouts.")
                            .font(.caption2)
                    }
                } icon: {
                    Image(systemName: Constants.splitIcon)
                }
            }
        } footer: {
            Text("You can turn off tips in the settings.")
        }
    }
    
    private func RecentExercise(exercise: Exercise) -> some View {
        NavigationLink {
            EditExerciseView(exercise: exercise, setData: exercise.recentSetData.setData, selectedMuscle: exercise.muscle, selectedEquipment: exercise.workoutEquipment)
                .navigationTransition(.zoom(sourceID: exercise.id, in: namespace))
        } label: {
            ReusedViews.ExerciseViews.HorizontalListPreview(exercise: exercise)
        }.buttonStyle(.plain)
            .matchedTransitionSource(id: exercise.id, in: namespace)
    }
    
    private func RecentWorkout(workout: Workout) -> some View {
        NavigationLink {
            EditWorkoutView(selectedWorkout: workout)
                .navigationTransition(.zoom(sourceID: workout.id, in: namespace))
        } label: {
            ReusedViews.WorkoutViews.HorizontalListPreview(workout: workout)
        }.buttonStyle(.plain)
            .matchedTransitionSource(id: workout.id, in: namespace)
    }
    
    private func RecentSplit(split: Split) -> some View {
        NavigationLink {
            EditSplitView(selectedSplit: split)
                .navigationTransition(.zoom(sourceID: split.id, in: namespace))
        } label: {
            ReusedViews.SplitViews.HorizontalListPreview(split: split)
        }.buttonStyle(.plain)
            .matchedTransitionSource(id: split.id, in: namespace)
    }
    
}
