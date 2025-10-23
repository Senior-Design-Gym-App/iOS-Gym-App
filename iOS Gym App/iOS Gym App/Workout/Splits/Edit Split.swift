import SwiftUI
import SwiftData

struct EditSplitView: View {
    
    let allWorkouts: [Workout]
    @State var pinned: Bool
    @State var name: String
    @State var selectedImage: UIImage?
    @State var split: Split
    @State var selectedWorkouts: [Workout]
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var selectedColor: Color = .teal
    
    var body: some View {
        NavigationStack {
            SplitOptionsView(allWorkouts: allWorkouts, pinned: $pinned, name: $name, selectedColor: $selectedColor, selectedImage: $selectedImage, selectedWorkouts: $selectedWorkouts)
            .environment(\.editMode, .constant(.active))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        
                        split.name = name
                        split.modified = Date.now
                        split.workouts = selectedWorkouts
                        split.pinned = pinned
                        try? context.save()
                        
                        dismiss()
                    } label: {
                        Label("Save", systemImage: "checkmark")
                    }
                }
            }
        }
    }
    
}
