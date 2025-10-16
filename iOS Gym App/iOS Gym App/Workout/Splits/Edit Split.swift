import SwiftUI
import SwiftData

struct EditWorkoutSplitView: View {
    
    let allDays: [WorkoutDay]
    @State var pinned: Bool
    @State var name: String
    @State var selectedImage: UIImage?
    @State var split: WorkoutSplit
    @State var selectedDays: [WorkoutDay]
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var selectedColor: Color = .teal
    
    var body: some View {
        NavigationStack {
            SplitOptionsView(allDays: allDays, pinned: $pinned, name: $name, selectedColor: $selectedColor, selectedImage: $selectedImage, selectedDays: $selectedDays)
            .environment(\.editMode, .constant(.active))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        
                        split.name = name
                        split.modified = Date.now
                        split.days = selectedDays
                        split.pinned = pinned
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
