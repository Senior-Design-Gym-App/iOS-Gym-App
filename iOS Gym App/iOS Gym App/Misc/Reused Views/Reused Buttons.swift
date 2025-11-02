import SwiftUI

extension ReusedViews {
    
    struct Buttons {
        
        struct RenameButtonAlert: View {
            
            let type: WorkoutItemType
            @Binding var oldName: String
            @State private var newName: String = ""
            @State private var showRename: Bool = false
            
            var body: some View {
                Button {
                    newName = oldName // Initialize with current name
                    showRename = true
                } label: {
                    Label("Rename", systemImage: "pencil")
                }
                .alert("Rename \(type.rawValue)", isPresented: $showRename) {
                    TextField("Enter new name", text: $newName)
                    Button("Cancel", role: .cancel) {
                        newName = ""
                    }
                    Button("Rename", role: .confirm) {
                        oldName = newName
                    }
                }
            }
        }
        
        struct DeleteButtonConfirmation: View {
            
            let type: WorkoutItemType
            let deleteAction: () -> Void
            @State private var showDelete: Bool = false
            
            var body: some View {
                Button(role: .destructive) {
                    showDelete = true
                } label: {
                    Label("Delete", systemImage: "trash")
                    Text("This cannot be undone.")
                }
                .confirmationDialog("Are you sure?", isPresented: $showDelete) {
                    Button("Delete", role: .destructive) {
                        deleteAction()
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("\(type.deleteOption)")
                }
            }
        }
        
        static func SaveButton(disabled: Bool, save: @escaping () -> Void) -> some View {
            Button(role: .confirm) {
                save()
            } label: {
                Label("Save", systemImage: "checkmark")
            }.disabled(disabled)
        }
        
        static func CancelButton(cancel: @escaping () -> Void) -> some View {
            Button(role: .cancel) {
                cancel()
            } label: {
                Label("Cancel", systemImage: "xmark")
            }
        }
        
        static func EditHeaderButton<C: Collection>(toggleEdit: Binding<Bool>, type: WorkoutItemType, items: C) -> some View {
            HStack {
                Text(type.rawValue)
                Spacer()
                Button {
                    toggleEdit.wrappedValue = true
                } label: {
                    if items.isEmpty {
                        Label("\(type.addType)", systemImage: "plus")
                    } else {
                        Label("\(type.editType)", systemImage: "pencil")
                    }
                }
            }
        }
        
        static func CreateButton(toggleCreateSheet: Binding<Bool>) -> some View {
            Button {
                toggleCreateSheet.wrappedValue = true
            } label: {
                Label("Add Workout", systemImage: "plus")
            }
        }
        
    }
    
}
