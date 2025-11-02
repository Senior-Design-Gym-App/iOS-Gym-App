import SwiftUI
import SwiftData

struct WorkoutHome: View {
    
    @Query private var allWorkouts: [Workout]
    @Query private var allExercises: [Exercise]
    @Query private var allSplits: [Split]
    
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
                
                Section {
                    MyWorkoutSection()
                }
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
                Label("Exercises", systemImage: Constants.exerciseIcon)
            }
            NavigationLink {
                AllWorkoutsView()
            } label: {
                Label("Workouts", systemImage: Constants.workoutIcon)
            }
            NavigationLink {
                AllWorkoutSplitsView(allSplits: allSplits, allWorkouts: allWorkouts, allExercises: allExercises)
            } label: {
                Label("Splits", systemImage: Constants.splitIcon)
            }
        }
    }
    
    private func RecentExercise(exercise: Exercise) -> some View {
        NavigationLink {
            EditExerciseView(exercise: exercise, setData: exercise.setData.last ?? [])
                .navigationTransition(.zoom(sourceID: exercise.id, in: namespace))
        } label: {
            ReusedViews.ExerciseViews.HorizontalListPreview(exercise: exercise)
        }.buttonStyle(.plain)
        .matchedTransitionSource(id: exercise.id, in: namespace)
    }
    
    private func RecentWorkout(workout: Workout) -> some View {
        NavigationLink {
            EditWorkoutView(selectedExercises: workout.exercises ?? [], selectedWorkout: workout)
                .navigationTransition(.zoom(sourceID: workout.id, in: namespace))
        } label: {
            ReusedViews.WorkoutViews.HorizontalListPreview(workout: workout)
        }.buttonStyle(.plain)
        .matchedTransitionSource(id: workout.id, in: namespace)
    }
    
    private func RecentSplit(split: Split) -> some View {
        NavigationLink {
            EditSplitView(selectedSplit: split, selectedWorkouts: split.workouts ?? [])
                .navigationTransition(.zoom(sourceID: split.id, in: namespace))
        } label: {
            ReusedViews.SplitViews.HorizontalListPreview(split: split)
        }.buttonStyle(.plain)
        .matchedTransitionSource(id: split.id, in: namespace)
    }
    
}
