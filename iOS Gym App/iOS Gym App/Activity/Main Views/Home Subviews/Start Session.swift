import SwiftUI
import SwiftData

struct StartSessionsView: View {
    
    let allSplits: [Split]
    @Environment(SessionManager.self) private var sm: SessionManager
    @Environment(\.modelContext) private var context
    @State private var showAlert: Bool = false
    
    var pinnedSplits: [Split] {
        allSplits.filter({ $0.pinned })
    }
    
    var body: some View {
        VStack(spacing: 10) {
            ReusedViews.HorizontalHeader(text: "Quick Start", showNavigation: false)
            PinnedRoutineSection()
        }
        .alert("Session Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please end your current session before starting another.")
        }
    }
    
    private func PinnedRoutineSection() -> some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(pinnedSplits, id: \.self) { split in
                    SplitMenu(split: split)
                }
            }
        }.scrollIndicators(.hidden)
    }
    
    private func SplitMenu(split: Split) -> some View {
        Menu {
            Section {
//                ForEach(split.workouts ?? [], id: \.self) { workout in
//                    Button {
//                        QueueWorkout(workout: workout)
//                    } label: {
//                        SplitLabel(workout: workout)
//                    }
//                }
            } header: {
                Text("Queue Workouts")
            }
            SplitPinSection(split: split)
        } label: {
            ReusedViews.SplitViews2.SplitGridPreview(split: split, bottomText: "Split")
        }
    }
    
    private func SplitLabel(workout: Workout) -> some View {
        Group {
            Text(workout.name)
            let count = workout.exercises?.count ?? 0
            Text("\(count) Workout\(count == 1 ? "" : "s")")
        }
    }
    
    private func SplitPinSection(split: Split) -> some View {
        Section {
            Button {
                split.pinned.toggle()
            } label: {
                Label(split.pinned ? "Unpin" : "Pin", systemImage: split.pinned ? "pin.slash" : "pin")
            }
        } header: {
            Text("Options")
        }
    }
    
    private func QueueWorkout(workout: Workout) {
        if sm.session != nil {
            showAlert = true
            return
        }
        let newSession = WorkoutSession(name: workout.name, started: Date(), workout: workout)
        for exercise in workout.exercises ?? [] {
            sm.QueueExercise(exercise: exercise)
        }
        sm.session = newSession
        context.insert(newSession)
    }
    
}
