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
                    newName = oldName
                    showRename = true
                } label: {
                    Label("Rename", systemImage: "pencil")
                        .frame(width: Constants.tinyIconSIze, height: Constants.tinyIconSIze)
                        .labelStyle(.iconOnly)
                }
                .buttonBorderShape(.circle)
                .buttonStyle(.glass)
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
                        .foregroundStyle(.red)
                        .frame(width: Constants.tinyIconSIze, height: Constants.tinyIconSIze)
                        .labelStyle(.iconOnly)
                }
                .buttonBorderShape(.circle)
                .buttonStyle(.glass)
                .confirmationDialog("Are you sure?", isPresented: $showDelete) {
                    Button("Delete", role: .destructive) {
                        deleteAction()
                    }
                } message: {
                    Text("\(type.deleteOption)")
                }
            }
        }
        @MainActor
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
                Text(type.listLabel)
                Spacer()
                Button {
                    toggleEdit.wrappedValue = true
                } label: {
                    if items.isEmpty {
                        Label("Add", systemImage: "plus")
                    } else {
                        Label("Edit", systemImage: "pencil")
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
