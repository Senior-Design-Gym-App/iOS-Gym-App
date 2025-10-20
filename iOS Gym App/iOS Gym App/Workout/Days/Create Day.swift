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
            DayOptionsView(allWorkouts: allWorkouts, name: $name, selectedWorkouts: $selectedWorkouts)
            .environment(\.editMode, .constant(.active))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        let newGroup = WorkoutDay(groupName: name, workouts: selectedWorkouts)
                        context.insert(newGroup)
                        try? context.save()
                        dismiss()
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
