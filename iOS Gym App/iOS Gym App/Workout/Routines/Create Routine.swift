import SwiftUI
import SwiftData

struct CreateWorkoutRoutineView: View {
    
    let allGroups: [WorkoutGroup]
    
    @State private var selectedImage: UIImage?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var newRoutine = WorkoutRoutine(name: "New Routine", groups: [], created: Date.now, modified: Date.now, imageData: nil, pinned: false)
    
    @State private var selectedGroups: [WorkoutGroup] = []
    @State private var selectedColor: Color = .teal
    
    var body: some View {
        NavigationStack {
            List {
                PinnedRoutinePreview(routine: newRoutine)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                RoutineViews.RoutineGroups(selectedGroups: $selectedGroups, allGroups: allGroups)
            }
            .ignoresSafeArea(edges: .top)
            .listStyle(.plain)
            .environment(\.editMode, .constant(.active))
        }
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
                
                RoutineMenuOptionsView(pinned: $newRoutine.pinned, name: $newRoutine.name, selectedImage: $selectedImage, selectedColor: $selectedColor)
                
            }.padding(.bottom)
        }
    }
    
    private func UpdateSection() -> some View {
        HStack {
            Button {
                newRoutine.groups = selectedGroups
        //        let newRoutine = WorkoutRoutine(name: name, created: Date.now, modified: Date.now, imageData: selectedImage?.pngData() ,pinned: pinned)
                context.insert(newRoutine)
                try? context.save()
                dismiss()
                dismiss()
            } label: {
                Label("Save & Exit", systemImage: "square.and.arrow.down.badge.checkmark")
                    .foregroundStyle(.white)
            }.buttonStyle(.glass)
        }
    }
    
}
