import SwiftUI
import SwiftData

struct DeletePage: View {
    
    @Query private var session: [WorkoutSession]
    @Query private var exercises: [Exercise]
    @Query private var workouts: [Workout]
    @Query private var splits: [Split]
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                         deleteAllObjects(session)
                    } label: {
                        Label("Session", systemImage: "timer")
                    }.disabled(session.isEmpty)
                } header: {
                    Text("Progress")
                }
                Section {
                    Button {
                         deleteAllObjects(exercises)
                    } label: {
                        Label("Exerckses", systemImage: "dumbbell")
                    }.disabled(exercises.isEmpty)
                    Button {
                         deleteAllObjects(workouts)
                    } label: {
                        Label("Workouts", systemImage: "tag")
                    }.disabled(workouts.isEmpty)
                    Button {
                         deleteAllObjects(splits)
                    } label: {
                        Label("Workout Routines", systemImage: "folder")
                    }.disabled(splits.isEmpty)
                } header: {
                    Text("Workouts")
                }
            }
            .navigationTitle("Delete Data")
        }
    }
    
    private func deleteAllObjects<T>(_ items: [T]) where T: PersistentModel {
        for item in items {
            context.delete(item)
        }
    }
    
}
