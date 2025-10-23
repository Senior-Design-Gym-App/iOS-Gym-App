import SwiftUI
import SwiftData
import PhotosUI

struct CreateWorkoutSplitView: View {
    
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showImageCropper = false
    @State private var selectedItem: PhotosPickerItem?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @FocusState private var focusState
    @State private var newSplit = Split(name: "", workouts: [], created: Date.now, modified: Date.now, imageData: nil, pinned: false)
    
    var body: some View {
        NavigationStack {
            SplitViews.CardView(split: newSplit, size: Constants.gridSize)
                .foregroundStyle(.thickMaterial)
                .padding(.horizontal, Constants.headerPadding * 1.5)
                .overlay(alignment: .center) {
                    Button {
                        showImagePicker = true
                    } label: {
                        Image(systemName: "camera.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75)
                    }
                }
            TextField("Split Name", text: $newSplit.name)
                .focused($focusState)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
                .navigationTitle("New Split")
                .navigationBarTitleDisplayMode(.inline)
            Divider()
                .padding(.horizontal)

            Spacer()
                .onAppear {
                    focusState = true
                }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        context.insert(newSplit)
                        try? context.save()
                        dismiss()
                    } label: {
                        Label("Save", systemImage: "checkmark")
                    }.disabled(newSplit.name.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    } label: {
                        Label("Exit", systemImage: "xmark")
                    }
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
    }
    
    
    
}
