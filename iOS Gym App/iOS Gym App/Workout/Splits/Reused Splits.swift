import SwiftUI
import PhotosUI

struct SplitViews {
    
    static func CardView(split: WorkoutSplit, size: CGFloat) -> some View {
        VStack {
            GlassEffectContainer {
                if let image = split.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(.rect(cornerRadius: 10))
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(split.color)
                }
            }
        }
        .frame(width: size, height: size)
    }
    
    static func CardViewOverlay(split: WorkoutSplit) -> some View {
        CardView(split: split, size: 160)
            .overlay(alignment: .bottom) {
                Text(split.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.bottom ,Constants.subtitlePadding)
            }
    }
    
}

struct SplitOptionsView: View {
    
    let allDays: [WorkoutDay]
    @Binding var pinned: Bool
    @Binding var name: String
    @Binding var selectedColor: Color
    @Binding var selectedImage: UIImage?
    @Binding var selectedDays: [WorkoutDay]
    
    @State private var showRename = false
    @State private var changedImage = false
    @State private var showColorPicker = false
    @State private var showImagePicker = false
    @State private var showImageCropper = false
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        List {
            GlassEffectContainer {
                Section {
                    SplitHeader()
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                }
                SplitDays()
            }
        }
        .alert("Edit Day Name", isPresented: $showRename) {
            TextField("Enter new username", text: $name)
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
    
    private func SplitHeader() -> some View {
        VStack {
            Header()
            Text(name)
                .font(.title)
                .bold()
            let dayCount = selectedDays.count
            let exerciseCount = selectedDays.compactMap(\.workouts).count
            Text("\(dayCount) Day\(dayCount == 1 ? "" : "s"), \(exerciseCount) Exercise\(exerciseCount == 1 ? "" : "s")")
                .font(.subheadline)
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
            Label("Routine Theme", systemImage: "paintbrush")
                .labelStyle(.iconOnly)
                .foregroundStyle(.white)
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
            ForEach(selectedDays, id: \.self) { day in
                DayViews.Info(day: day)
            }
            .onDelete { indices in
                $selectedDays.wrappedValue.remove(atOffsets: indices)
            }
            .onMove { indices, newOffset in
                $selectedDays.wrappedValue.move(fromOffsets: indices, toOffset: newOffset)
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
                ForEach(allDays.sorted(by: { $0.name < $1.name })) { day in
                    Button {
                        selectedDays.append(day)
                    } label: {
                        Text(day.name)
                    }
                }
            } label: {
                Label("Add to Routine", systemImage: "plus")
            }
        }
    }
    
}
