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
            DayOptionsView(allWorkouts: allWorkouts, name: $name, selectedWorkouts: $selectedWorkouts)
            .environment(\.editMode, .constant(.active))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        selectedDay.name = name
                        selectedDay.workouts = selectedWorkouts
                        try? context.save()
                        dismiss()
                    } label: {
                        Label("Save", systemImage: "checkmark")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    } label: {
                        Label("Exit", systemImage: "xmark")
                    }
                }
            }
        }
    }
    
}
