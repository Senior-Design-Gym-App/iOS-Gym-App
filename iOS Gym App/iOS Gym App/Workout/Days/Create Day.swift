import SwiftUI
import SwiftData

struct CreateWorkoutDayView: View {
    
    let allWorkouts: [Workout]
    @State private var name: String = "New Day"
    @State private var selectedWorkouts: [Workout] = []
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            List {
                DayHeader()
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                DayViews.RoutineGroups(selectedWorkouts: $selectedWorkouts, allWorkouts: allWorkouts)
            }
            .ignoresSafeArea(edges: .top)
            .listStyle(.plain)
            .environment(\.editMode, .constant(.active))
        }
    }
    
    private func DayHeader() -> some View {
        DayViews.Header()
            .overlay(alignment: .bottom) {
                VStack {
                    let tags: [MuscleGroup] = selectedWorkouts.compactMap { $0.muscleInfo?.group }

                    VStack(spacing: 0) {
                        ReusedViews.HeaderTitle(title: name)
                        ReusedViews.HeaderSubtitle(subtitle: DayViews.GetTagSubtitle(tags: tags))
                    }
                    
                    SaveButton()
                    
                    DayOptionsView(name: $name)
                    
                }.padding(.bottom)
            }
    }
    
    private func SaveButton() -> some View {
        Button {
            let newGroup = WorkoutDay(groupName: name, workouts: selectedWorkouts)
            context.insert(newGroup)
            try? context.save()
            dismiss()
        } label: {
            Text("Save")
                .foregroundStyle(.white)
        }.buttonStyle(.glass)
    }
    
}
