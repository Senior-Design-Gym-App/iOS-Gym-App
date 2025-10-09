import SwiftUI
import SwiftData

struct EditWorkoutRoutineView: View {
    
    let allGroups: [WorkoutGroup]
    @State var pinned: Bool
    @State var name: String
    @State var selectedImage: UIImage?
    @State var routine: WorkoutRoutine
    @State var selectedGroups: [WorkoutGroup]
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var selectedColor: Color = .teal
    
    var body: some View {
        NavigationStack {
            List {
                PinnedRoutinePreview(routine: routine)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                RoutineViews.RoutineGroups(selectedGroups: $selectedGroups, allGroups: allGroups)
            }
            .ignoresSafeArea(edges: .top)
            .listStyle(.plain)
            .environment(\.editMode, .constant(.active))
        }
    }
    
    private func UpdateSection() -> some View {
        HStack {
            Button {
                ModifyRoutine()
                dismiss()
            } label: {
                Text("Save & Exit")
                    .foregroundStyle(.white)
            }.buttonStyle(.glass)
            Button(role: .destructive) {
                context.delete(routine)
                dismiss()
            } label: {
                Text("Delete")
                    .foregroundStyle(.white)
            }.buttonStyle(.glass)
        }
    }
    
    private func ModifyRoutine() {
        routine.name = name
        routine.modified = Date.now
        routine.groups = selectedGroups
        routine.pinned = pinned
        try? context.save()
        dismiss()
    }
    
    private func PinnedRoutinePreview(routine: WorkoutRoutine) -> some View {
        RoutineViews.Header(routineImage: selectedImage, selectedColor: selectedColor)
        .overlay(alignment: .bottom) {
            VStack {
                Text(routine.name)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.bottom)
                
                UpdateSection()
                
                RoutineMenuOptionsView(pinned: $pinned, name: $name, selectedImage: $selectedImage, selectedColor: $selectedColor)
                
            }.padding(.bottom)
        }
    }
    
}
