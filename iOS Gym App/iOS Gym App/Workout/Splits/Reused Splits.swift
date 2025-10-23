import SwiftUI
import PhotosUI

struct SplitViews {
    
    static func CardView(split: Split, size: CGFloat) -> some View {
        GlassEffectContainer {
            if let image = split.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipShape(.rect(cornerRadius: 10))
                    .frame(idealWidth: size, idealHeight: size)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(ColorManager.shared.GetColor(key: split.id.hashValue.description))
                    .frame(idealWidth: size, idealHeight: size)
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
    }
    
}

struct SplitOptionsView: View {
    
    let allWorkouts: [Workout]
    @Binding var pinned: Bool
    @Binding var name: String
    @Binding var selectedColor: Color
    @Binding var selectedImage: UIImage?
    @Binding var selectedWorkouts: [Workout]
    
    @State private var showRename = false
    @State private var changedImage = false
    @State private var showColorPicker = false
    @State private var showImagePicker = false
    @State private var showImageCropper = false
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        GlassEffectContainer {
            List {
                Section {
                    SplitHeader()
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                }
                SplitDays()
            }
        }
        .alert("Edit Split Name", isPresented: $showRename) {
            TextField("Enter split name", text: $name)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            Button("Ok", role: .confirm) {
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
            CustomLabelView(text: pinned ? "Unpin" : "Pin", image: pinned ? "pin.slash" : "pin")
                .contentTransition(.symbolEffect(.replace))
        }.buttonStyle(.glass)
    }
    
    private func RoutineRename() -> some View {
        Button {
            showRename = true
        } label: {
            CustomLabelView(text: "Rename", image: "pencil")
        }.buttonStyle(.glass)
    }
    
    private func SplitHeader() -> some View {
        VStack {
            Header()
            ReusedViews.HeaderTitle(title: name)
            let workoutCount = selectedWorkouts.count
            let exerciseCount = selectedWorkouts
                .flatMap { $0.exercises ?? [] }
                .count
            ReusedViews.HeaderSubtitle(subtitle: "\(workoutCount) Day\(workoutCount == 1 ? "" : "s"), \(exerciseCount) Exercise\(exerciseCount == 1 ? "" : "s")")
            HStack {
                RoutinePinToggle()
                RoutineRename()
                RoutineOptions()
            }
        }
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
            CustomLabelView(text: "Icon", image: "paintbrush")
        }
        .buttonStyle(.glass)
    }
    
    private func Header() -> some View {
        Group {
            GlassEffectContainer {
                if let selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                } else {
                    Rectangle()
                        .foregroundStyle(selectedColor)
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .aspectRatio(Constants.headerRatio, contentMode: .fit)
        .clipped()
    }
    
    private func SplitDays() -> some View {
        Section {
            ForEach(selectedWorkouts, id: \.self) { workout in
                Text(workout.name)
                //DayViews.Info(day: day)
            }
            .onDelete { indices in
                $selectedWorkouts.wrappedValue.remove(atOffsets: indices)
            }
            .onMove { indices, newOffset in
                $selectedWorkouts.wrappedValue.move(fromOffsets: indices, toOffset: newOffset)
            }
        } header: {
            AddGroupHeader()
        }
    }
    
    private func AddGroupHeader() -> some View {
        HStack {
            Label("Groups", systemImage: "tag")
            Spacer()
            Menu {
                ForEach(allWorkouts.sorted(by: { $0.name < $1.name })) { workout in
                    Button {
                        selectedWorkouts.append(workout)
                    } label: {
                        Text(workout.name)
                    }
                }
            } label: {
                Label("Add to Routine", systemImage: "plus")
            }
        }
    }
    
}
