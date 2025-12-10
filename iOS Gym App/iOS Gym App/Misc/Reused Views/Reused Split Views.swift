import SwiftUI
import SwiftData
import PhotosUI
import WidgetKit

extension ReusedViews {
    
    struct SplitViews {
        
        @ViewBuilder
        static func MediumIconView(split: Split) -> some View {
            if let image = split.image {
                SplitPreview(splitImage: image, size: Constants.mediumIconSize)
            } else {
                Labels.MediumIconSize(color: Constants.mainAppTheme)
            }
        }
        
        @ViewBuilder
        static func LargeSplitView(split: Split) -> some View {
            if let splitImage = split.image {
                SplitPreview(splitImage: splitImage, size: Constants.largeIconSize)
            } else {
                Labels.LargeIconSize(color: split.color)
            }
        }
        
        static func HorizontalListPreview(split: Split) -> some View {
            VStack(alignment: .leading, spacing: 5) {
                MediumIconView(split: split)
                Labels.TypeListDescription(name: split.name, items: split.sortedWorkouts, type: .split)
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
            Label {
                Text(split.name)
                Text("\(split.sortedWorkouts.count) workout\(split.sortedWorkouts.count == 1 ? "" : "s")")
            } icon: {
                if let splitImage = split.image {
                    Image(uiImage: splitImage)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                } else {
                    Labels.ListIcon(color: split.color)
                }
            }
        }
        
        static func ActiveSplit(split: Binding<Split>, allSplits: [Split]) -> some View {
            Button {
                let wasActive = split.wrappedValue.active
                split.wrappedValue.active.toggle()
                
                // Update widget data when split is activated/deactivated
                if split.wrappedValue.active {
                    // Deactivate other splits
                    for otherSplit in allSplits where otherSplit.id != split.wrappedValue.id {
                        otherSplit.active = false
                    }
                    
                    // Convert to transfer model and save to widget
                    let transferSplit = split.wrappedValue.toTransfer()
                    WidgetDataManager.shared.setActiveSplit(transferSplit)
                    
                    // Reset progress when activating a split
                    WidgetDataManager.shared.resetSplitProgress()
                } else {
                    // Clear widget data when deactivating
                    WidgetDataManager.shared.setActiveSplit(nil)
                }
            } label: {
                Label(split.wrappedValue.active ? "Favorite" : "Unfavorite", systemImage: split.wrappedValue.active ? "star.fill" : "star")
                    .labelStyle(.iconOnly)
                    .frame(width: Constants.tinyIconSIze, height: Constants.tinyIconSIze)
                    .contentTransition(.symbolEffect(.replace))
            }.buttonBorderShape(.circle)
                .buttonStyle(.glass)
                .disabled(allSplits.contains(where: { $0.active }) && !split.wrappedValue.active)
        }
        
        struct SplitControls: View {
            
            @Query private var allWorkouts: [Workout]
            @State var newWorkouts: [Workout]
            @Binding var showAddSheet: Bool
            @Binding var split: Split
            
            var body: some View {
                NavigationStack {
                    List {
                        Section {
                            ForEach(newWorkouts, id: \.self) { workout in
                                WorkoutViews.WorkoutListPreview(workout: workout).id(workout.id)
                            }
                            .onMove { indices, newOffset in
                                newWorkouts.move(fromOffsets: indices, toOffset: newOffset)
                            }
                            .onDelete { indices in
                                newWorkouts.remove(atOffsets: indices)
                            }
                        } header: {
                            Text("Selected Workouts")
                        }
                        Section {
                            ForEach(allWorkouts
                                .filter{ $0.split == nil && !newWorkouts.contains($0) }
                                .sorted { $0.name < $1.name }
                                    , id: \.self) { workout in
                                HStack {
                                    ReusedViews.WorkoutViews.WorkoutListPreview(workout: workout)
                                    Spacer()
                                    Button {
                                        withAnimation {
                                            newWorkouts.append(workout)
                                        }
                                    } label: {
                                        Image(systemName: "plus")
                                    }
                                }
                            }
                        } header: {
                            Text("Available Workouts")
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
                }
            }
            
            private func SaveOptions() {
                split.workouts = newWorkouts
                if let workouts = split.workouts {
                    let newIDs = workouts.map { $0.persistentModelID }
                    split.encodeIDs(ids: newIDs)
                }
                split.modified = Date()
                
                // Update widget if this is the active split
                if split.active {
                    let transferSplit = split.toTransfer()
                    WidgetDataManager.shared.setActiveSplit(transferSplit)
                }
                
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
                Menu {
                    Button {
                        showImagePicker = true
                    } label: {
                        Label("Add Image", systemImage: "camera.circle")
                    }
                    if split.image != nil {
                        Button(role: .destructive) {
                            split.imageData = nil
                        } label: {
                            Label("Remove Image", systemImage: "trash")
                        }
                    }
                } label: {
                    Label("CustomImage", systemImage: "photo")
                        .frame(width: Constants.tinyIconSIze, height: Constants.tinyIconSIze)
                        .labelStyle(.iconOnly)
                }
                .buttonBorderShape(.circle)
                .buttonStyle(.glass)
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
