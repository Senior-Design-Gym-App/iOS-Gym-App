import SwiftUI
import SwiftData

struct CreateWorkoutSplitView: View {
    
    let allDays: [WorkoutDay]
    
    @State private var selectedImage: UIImage?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var newSplit = WorkoutSplit(name: "New Split", days: [], created: Date.now, modified: Date.now, imageData: nil, pinned: false)
    
    @State private var selectedDays: [WorkoutDay] = []
    @State private var selectedColor: Color = .teal
    
    var body: some View {
        NavigationStack {
            SplitOptionsView(allDays: allDays, pinned: $newSplit.pinned, name: $newSplit.name, selectedColor: $selectedColor, selectedImage: $selectedImage, selectedDays: $selectedDays)
            .environment(\.editMode, .constant(.active))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        
                        newSplit.days = selectedDays
                        context.insert(newSplit)
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
