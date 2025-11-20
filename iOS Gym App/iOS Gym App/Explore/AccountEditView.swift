//
//  AccountEditView.swift
//  iOS Gym App
//
//  Created by 鄭承典 on 11/4/25.
//
import SwiftUI
import UIKit

struct AccountEditView: View {
    @Binding var profile: UserProfileContent

    @State private var editingProfile: UserProfileContent = .empty
    @State private var didLoadInitialState = false
    @State private var showImageOptions: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showPreview: Bool = false
    @State private var showCoverImageOptions: Bool = false
    @State private var showCoverImagePicker: Bool = false
    @State private var coverPickerSource: UIImagePickerController.SourceType = .photoLibrary
    
    @Environment(\.dismiss) private var dismiss
    
    private let cardCornerRadius = Constants.cornerRadius
    private let accentTint = Constants.mainAppTheme
    private let sectionSpacing = Constants.customLabelPadding
    private let avatarSize: CGFloat = 96
    private let photoHeight: CGFloat = 120
    
    var body: some View {
        Form {
            Section(header: ReusedViews.Labels.Header(text: "Cover Photo")) {
                VStack(spacing: sectionSpacing) {
                    ZStack {
                        if let coverImage = editingProfile.coverImage {
                            Image(uiImage: coverImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Color.gray.opacity(0.3)
                                .overlay {
                                    Image(systemName: "photo.fill")
                                        .font(.system(size: Constants.mediumIconSize / 2))
                                        .foregroundStyle(.secondary)
                                }
                        }
                    }
                    .frame(height: photoHeight)
                    .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
                    .contentShape(Rectangle())
                    .onTapGesture { showCoverImageOptions = true }
                    Text("Cover Photo")
                        .font(.subheadline)
                    Text("Tap to change")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                .alignmentGuide(.listRowSeparatorTrailing) { _ in 0 }
            }
            Section(header: ReusedViews.Labels.Header(text: "Profile")) {
                VStack(spacing: sectionSpacing) {
                    ZStack {
                        if let uiImage = editingProfile.profileImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Color.gray.opacity(0.3)
                                .overlay {
                                Image(systemName: "person.fill")
                                .font(.system(size: Constants.mediumIconSize / 2))
                                .foregroundStyle(.secondary)
                                }
                        }
                    }
                    .clipShape(Circle())
                    .frame(width: avatarSize, height: avatarSize)
                    .contentShape(Circle())
                    .onTapGesture { showImageOptions = true }
                    .onLongPressGesture { if editingProfile.profileImage != nil { showPreview = true } }
                    Text("Profile Photo")
                        .font(.subheadline)
                    Text("Tap to change")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                .alignmentGuide(.listRowSeparatorTrailing) { _ in 0 }
                TextField("Name", text: $editingProfile.username)
                    .textFieldStyle(.plain)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 4)
                
                HStack {
                    Text("@")
                        .foregroundStyle(.secondary)
                    TextField("Username", text: $editingProfile.displayName)
                        .textFieldStyle(.plain)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 4)
                
                TextField("Location", text: $editingProfile.location)
                    .textFieldStyle(.plain)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 4)
                
                TextField("Bio", text: $editingProfile.bio, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
                    .textFieldStyle(.plain)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 4)
            }
            Section {
                Button {
                    saveChanges()
                } label: {
                    Text("Save Changes")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(accentTint)
            }
        }
        .overlay(alignment: .center) {
            if showCoverImageOptions {
                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture { showCoverImageOptions = false }
                    VStack(spacing: 16) {
                        Text("Cover Photo")
                            .font(.headline)
                        VStack(spacing: 10) {
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                Button(action: {
                                    coverPickerSource = .camera
                                    showCoverImagePicker = true
                                    showCoverImageOptions = false
                                }) {
                                    Text("Take Photo")
                                        .font(.body.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .foregroundStyle(accentTint)
                                        .background(Color.secondary.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
                                }
                            }
                            Button(action: {
                                coverPickerSource = .photoLibrary
                                showCoverImagePicker = true
                                showCoverImageOptions = false
                            }) {
                                Text("Choose from Library")
                                    .font(.body.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .foregroundStyle(accentTint)
                                    .background(Color.secondary.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
                            }
                            if editingProfile.coverImage != nil {
                                Button(role: .destructive, action: {
                                    editingProfile.coverImage = nil
                                    showCoverImageOptions = false
                                }) {
                                    Text("Remove Photo")
                                        .font(.body.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color.secondary.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
                                }
                            }
                            Button(role: .cancel, action: { showCoverImageOptions = false }) {
                                Text("Cancel")
                                    .font(.body)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: 340)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(radius: 20, y: 8)
                }
            }
            if showImageOptions {
                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture { showImageOptions = false }
                    VStack(spacing: 16) {
                        Text("Profile Photo")
                            .font(.headline)
                        VStack(spacing: 10) {
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                Button(action: {
                                    pickerSource = .camera
                                    showImagePicker = true
                                    showImageOptions = false
                                }) {
                                    Text("Take Photo")
                                        .font(.body.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .foregroundStyle(accentTint)
                                        .background(Color.secondary.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
                                }
                            }
                            Button(action: {
                                pickerSource = .photoLibrary
                                showImagePicker = true
                                showImageOptions = false
                            }) {
                                Text("Choose from Library")
                                    .font(.body.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .foregroundStyle(accentTint)
                                    .background(Color.secondary.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
                            }
                            if editingProfile.profileImage != nil {
                                Button(role: .destructive, action: {
                                    editingProfile.profileImage = nil
                                    showImageOptions = false
                                }) {
                                    Text("Remove Photo")
                                        .font(.body.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color.secondary.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
                                }
                            }
                            Button(role: .cancel, action: { showImageOptions = false }) {
                                Text("Cancel")
                                    .font(.body)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: 340)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(radius: 20, y: 8)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: pickerSource, selectedImage: $editingProfile.profileImage)
        }
        .sheet(isPresented: $showCoverImagePicker) {
            ImagePicker(sourceType: coverPickerSource, selectedImage: $editingProfile.coverImage)
        }
        .fullScreenCover(isPresented: $showPreview) {
            ZStack {
                Color.black.ignoresSafeArea()
                if let ui = editingProfile.profileImage {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .background(Color.black)
                        .ignoresSafeArea()
                }
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { showPreview = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.9))
                        }
                    }
                    .padding()
                    Spacer()
                }
            }
        }
        .navigationTitle("Edit Account")
        .onAppear(perform: loadInitialState)
        .onChange(of: profile) { newValue in
            editingProfile = newValue
        }
    }
    
    private func saveChanges() {
        profile = editingProfile
        dismiss()
    }

    private func loadInitialState() {
        guard !didLoadInitialState else { return }
        editingProfile = profile
        didLoadInitialState = true
    }
}

// MARK: - UIKit Image Picker Wrapper
private struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
