import SwiftUI
import SwiftData
import PhotosUI

extension ReusedViews {
    
    struct SplitViews {
        
        @ViewBuilder
        static func LargeIconView(split: Split) -> some View {
            if let image = split.image {
                HStack {
                    Spacer()
                    SplitPreview(splitImage: image, size: Constants.largeIconSize)
                    Spacer()
                }
            } else {
                Labels.LargeIconSize(key: split.id.hashValue.description)
            }
        }
        
        @ViewBuilder
        static func MediumIconView(split: Split) -> some View {
            if let image = split.image {
                SplitPreview(splitImage: image, size: Constants.mediumIconSize)
            } else {
                Labels.MediumIconSize(key: split.id.hashValue.description)
            }
        }
        
        @ViewBuilder
        static func SmallIconView(split: Split) -> some View {
            if let image = split.image {
                SplitPreview(splitImage: image, size: Constants.smallIconSize)
            } else {
                Labels.SmallIconSize(key: split.id.hashValue.description)
            }
        }
        
        static func HorizontalListPreview(split: Split) -> some View {
            VStack(alignment: .leading, spacing: 5) {
                MediumIconView(split: split)
                Labels.MediumTextLabel(title: split.name)
            }
        }
        
        static func SplitPreview(splitImage: UIImage, size: CGFloat) -> some View {
                Image(uiImage: splitImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(.rect(cornerRadius: Constants.cornerRadius))
        }
        
        static func ListPreview(split: Split) -> some View {
            HStack {
                if let image = split.image {
                    SplitPreview(splitImage: image, size: Constants.smallIconSize)
                } else {
                    Labels.SmallIconSize(key: split.id.hashValue.description)
                }
                Labels.ListDescription(name: split.name, items: split.workouts ?? [], type: .split)
            }
        }
        
        struct SplitControls: View {
            
            @Query private var allWorkouts: [Workout]
            let saveAction: () -> Void
            @State var newWorkouts: [Workout]
            @Binding var showAddSheet: Bool
            @Binding var oldWorkouts: [Workout]
            
            var body: some View {
                AddSheet()
            }
            
            private func AddSheet() -> some View {
                NavigationStack {
                    List {
                        ForEach(allWorkouts
                            .filter{ $0.split == nil }
                            .sorted { $0.name < $1.name }
                                , id: \.self) { workout in
                            HStack {
                                ReusedViews.WorkoutViews.WorkoutListPreview(workout: workout)
                                Spacer()
                                Button {
                                    if newWorkouts.contains(where: { $0 == workout }) {
                                        withAnimation {
                                            newWorkouts.removeAll(where: { $0 == workout })
                                        }
                                    } else {
                                        withAnimation {
                                            newWorkouts.append(workout)
                                        }
                                    }
                                } label: {
                                    if newWorkouts.contains(where: { $0 == workout }) {
                                        Image(systemName: "checkmark")
                                            .contentTransition(.symbolEffect(.replace))
                                    } else {
                                        Image(systemName: "plus")
                                            .contentTransition(.symbolEffect(.replace))
                                    }
                                }
                            }
                        }
                    }
                    .environment(\.editMode, .constant(.active))
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            ReusedViews.Buttons.CancelButton(cancel: CancelOptions)
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            ReusedViews.Buttons.SaveButton(disabled: newWorkouts.isEmpty, save: SaveOptions)
                        }
                    }
                    //                .onMove { indices, newOffset in
                    //                    newSetData.move(fromOffsets: indices, toOffset: newOffset)
                    //                }
                    //                .onDelete { indices in
                    //                    newSetData.remove(atOffsets: indices)
                    //                }
                }
            }
            
            private func SaveOptions() {
                oldWorkouts = newWorkouts
                saveAction()
                showAddSheet = false
            }
            
            private func CancelOptions() {
                showAddSheet = false
            }
            
        }
        
        struct ImagePicker: View {
            
            @Binding var split: Split
            @State private var selectedImage: UIImage?
            @State private var showImagePicker = false
            @State private var showImageCropper = false
            @State private var selectedItem: PhotosPickerItem?
            
            var body: some View {
                if split.image != nil {
                    Button(role: .destructive) {
                        split.imageData = nil
                    } label: {
                        Label("Remove Image", systemImage: "trash")
                    }
                }
                Button {
                    showImagePicker = true
                } label: {
                    Label("Add Image", systemImage: "camera.circle")
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
                            split.imageData = selectedImage?.pngData()
                        }
                }
            }
        }
        
    }
    
}
