import SwiftUI
import PhotosUI

struct RoutineViews {
    
    static func CardView(routine: WorkoutRoutine) -> some View {
        VStack {
            GlassEffectContainer {
                if let image = routine.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(.rect(cornerRadius: 10))
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(routine.color)
                }
            }
        }
        .frame(width: 160, height: 160)
        .overlay(alignment: .bottom) {
            Text(routine.name)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.bottom)
        }
    }
    
    static func Header(routineImage: UIImage?, selectedColor: Color) -> some View {
        VStack {
            GlassEffectContainer {
                if let routineImage {
                    Image(uiImage: routineImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .clipped()
                } else {
                    Rectangle()
                        .foregroundStyle(selectedColor)
                        .aspectRatio(contentMode: .fill)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .clipped()
                }
            }
        }
    }
    
    static func RoutineGroups(selectedGroups: Binding<[WorkoutGroup]>, allGroups: [WorkoutGroup]) -> some View {
        Section {
            ForEach(selectedGroups, id: \.self) { group in
                Text(group.groupName.wrappedValue)
            }
            .onDelete { indices in
                selectedGroups.wrappedValue.remove(atOffsets: indices)
            }
            .onMove { indices, newOffset in
                selectedGroups.wrappedValue.move(fromOffsets: indices, toOffset: newOffset)
            }
        } header: {
            RoutineViews.AddGroupHeader(selectedGroups: selectedGroups, allGroups: allGroups)
        }
    }
    
    static private func AddGroupHeader(selectedGroups: Binding<[WorkoutGroup]>, allGroups: [WorkoutGroup]) -> some View {
        HStack {
            Label("Groups", systemImage: "tag")
            Spacer()
            Menu {
                ForEach(allGroups.sorted(by: { $0.groupName < $1.groupName })) { group in
                    Button {
                        selectedGroups.wrappedValue.append(group)
                    } label: {
                        Text(group.groupName)
                    }
                }
            } label: {
                Label("Add to Routine", systemImage: "plus")
            }
        }
    }
    
}

struct RoutineMenuOptionsView: View {
    
    @Binding var pinned: Bool
    @Binding var name: String
    @Binding var selectedImage: UIImage?
    
    @Binding var selectedColor: Color
    @State private var selectedItem: PhotosPickerItem?
    
    @State private var showColorPicker = false
    @State private var showRename = false
    @State private var changedImage = false
    @State private var showImageCropper = false
    @State private var showImagePicker = false
    
    var body: some View {
        HStack {
            RoutinePinToggle()
            RoutineRename()
            RoutineOptions()
        }
        .alert("Change Username", isPresented: $showRename) {
            TextField("Enter new username", text: $name)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            Button("Cancel", role: .cancel) {
                
            }
            Button("Save", role: .confirm) {
                
            }
        }
        .photosPicker(isPresented: $showImagePicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem, initial: false) { _, newItem in
            if let newItem = newItem {
                Task {
                    if let imageData = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: imageData) {
                        selectedImage = uiImage
                        showImageCropper = true
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showImageCropper) {
            WorkoutPlanImageCropper(image: $selectedImage, visible: $showImageCropper)
                .onDisappear {
                    self.selectedItem = nil
                }
        }
        
    }
    
    private func RoutinePinToggle() -> some View {
        Button {
            withAnimation {
                pinned.toggle()
            }
        } label: {
            Label(pinned ? "Unpin" : "Pin", systemImage: pinned ? "pin.slash" : "pin")
                .labelStyle(.iconOnly)
                .contentTransition(.symbolEffect(.replace))
                .foregroundStyle(.white)
        }.buttonStyle(.glass)
    }
    
    private func RoutineRename() -> some View {
        Button {
            showRename = true
        } label: {
            Text("Rename Routine")
                .foregroundStyle(.white)
        }.buttonStyle(.glass)
    }
    
    private func RoutineOptions() -> some View {
        Menu {
            if selectedImage == nil {
                Button {
                    showImagePicker = true
                } label: {
                    Label("Add Image", systemImage: "photo.badge.plus")
                }
                Button {
                    
                } label: {
                    Label("Pick Color", systemImage: "paintpalette")
                }
            } else {
                Button {
                    selectedImage = nil
                } label: {
                    Label("Remove Image", systemImage: "photo.badge.exclamationmark")
                }
                Button {
                    showImagePicker = true
                } label: {
                    Label("Change Image", systemImage: "photo.badge.arrow.down")
                }
                Button {
                    selectedImage = nil
                } label: {
                    Label("Remove Image and Pick Color", systemImage: "paintpalette")
                }
            }
        } label: {
            Label("Routine Theme", systemImage: "paintbrush")
                .labelStyle(.iconOnly)
                .foregroundStyle(.white)
        }
        .buttonStyle(.glass)
    }
    
}
