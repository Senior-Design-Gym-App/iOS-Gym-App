import SwiftUI
import SwiftData

struct EditWorkoutDayView: View {
    
    let allWorkouts: [Workout]
    @State var name: String
    @State var selectedWorkouts: [Workout]
    @State var selectedDay: WorkoutDay
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

                    UpdateButton()
                    
                    DayOptionsView(name: $name)
                    
                }.padding(.bottom)
            }
    }
    
    private func UpdateButton() -> some View {
        Button {
            selectedDay.name = name
            selectedDay.workouts = selectedWorkouts
            try? context.save()
            dismiss()
        } label: {
            Text("Update")
                .foregroundStyle(.white)
        }.buttonStyle(.glass)
    }
    
}
