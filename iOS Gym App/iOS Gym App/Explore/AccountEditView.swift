//
//  AccountEditView.swift
//  iOS Gym App
//
//  Created by 鄭承典 on 11/4/25.
//
import SwiftUI
import UIKit

struct AccountEditView: View {
    @Binding var coverImage: UIImage?
    @Binding var profileImage: UIImage?
    @Binding var username: String
    @Binding var displayName: String
    @Binding var bio: String
    @Binding var location: String
    
    // Temporary editing values
    @State private var editingUsername: String = ""
    @State private var editingDisplayName: String = ""
    @State private var editingBio: String = ""
    @State private var editingLocation: String = ""
    @State private var editingCoverImage: UIImage?
    @State private var editingProfileImage: UIImage?
    
    @State private var isPrivate: Bool = false
    @State private var showImageOptions: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showPreview: Bool = false
    @State private var showCoverImageOptions: Bool = false
    @State private var showCoverImagePicker: Bool = false
    @State private var coverPickerSource: UIImagePickerController.SourceType = .photoLibrary
    
    @Environment(\.dismiss) private var dismiss
    
    init(
        coverImage: Binding<UIImage?>? = nil,
        profileImage: Binding<UIImage?>? = nil,
        username: Binding<String>? = nil,
        displayName: Binding<String>? = nil,
        bio: Binding<String>? = nil,
        location: Binding<String>? = nil
    ) {
        if let coverImage = coverImage {
            self._coverImage = coverImage
        } else {
            self._coverImage = Binding(
                get: { nil },
                set: { _ in }
            )
        }
        if let profileImage = profileImage {
            self._profileImage = profileImage
        } else {
            self._profileImage = Binding(
                get: { nil },
                set: { _ in }
            )
        }
        if let username = username {
            self._username = username
        } else {
            self._username = Binding(
                get: { "" },
                set: { _ in }
            )
        }
        if let displayName = displayName {
            self._displayName = displayName
        } else {
            self._displayName = Binding(
                get: { "" },
                set: { _ in }
            )
        }
        if let bio = bio {
            self._bio = bio
        } else {
            self._bio = Binding(
                get: { "" },
                set: { _ in }
            )
        }
        if let location = location {
            self._location = location
        } else {
            self._location = Binding(
                get: { "" },
                set: { _ in }
            )
        }
        
        // Initialize editing values from bindings
        if let username = username {
            _editingUsername = State(initialValue: username.wrappedValue)
        } else {
            _editingUsername = State(initialValue: "")
        }
        if let displayName = displayName {
            _editingDisplayName = State(initialValue: displayName.wrappedValue)
        } else {
            _editingDisplayName = State(initialValue: "")
        }
        if let bio = bio {
            _editingBio = State(initialValue: bio.wrappedValue)
        } else {
            _editingBio = State(initialValue: "")
        }
        if let location = location {
            _editingLocation = State(initialValue: location.wrappedValue)
        } else {
            _editingLocation = State(initialValue: "")
        }
        if let coverImage = coverImage {
            _editingCoverImage = State(initialValue: coverImage.wrappedValue)
        } else {
            _editingCoverImage = State(initialValue: nil)
        }
        if let profileImage = profileImage {
            _editingProfileImage = State(initialValue: profileImage.wrappedValue)
        } else {
            _editingProfileImage = State(initialValue: nil)
        }
    }
    var body: some View {
        Form {
            Section(header: Text("Cover Photo")) {
                VStack(spacing: 10) {
                    ZStack {
                        if let coverImage = editingCoverImage {
                            Image(uiImage: coverImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Color.gray.opacity(0.3)
                                .overlay {
                                    Image(systemName: "photo.fill")
                                        .font(.system(size: 48))
                                        .foregroundStyle(.secondary)
                                }
                        }
                    }
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
            Section(header: Text("Profile")) {
                VStack(spacing: 10) {
                    ZStack {
                        if let uiImage = editingProfileImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Color.gray.opacity(0.3)
                                .overlay {
                                Image(systemName: "person.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                                }
                        }
                    }
                    .clipShape(Circle())
                    .frame(width: 96, height: 96)
                    .contentShape(Circle())
                    .onTapGesture { showImageOptions = true }
                    .onLongPressGesture { if editingProfileImage != nil { showPreview = true } }
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
                TextField("Name", text: $editingUsername)
                HStack {
                    Text("@")
                        .foregroundStyle(.secondary)
                    TextField("Username", text: $editingDisplayName)
                }
                TextField("Location", text: $editingLocation)
                TextField("Bio", text: $editingBio, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
            }
// Privacy account button
//            Section(header: Text("Privacy")) {
//                Toggle("Private Account", isOn: $isPrivate)
//            }
            Section {
                Button("Save Changes") {
                    saveChanges()
                }
                    .frame(maxWidth: .infinity, alignment: .center)
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
                                        .foregroundStyle(Color.accentColor)
                                        .background(Color.secondary.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
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
                                    .foregroundStyle(Color.accentColor)
                                    .background(Color.secondary.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            if editingCoverImage != nil {
                                Button(role: .destructive, action: {
                                    editingCoverImage = nil
                                    showCoverImageOptions = false
                                }) {
                                    Text("Remove Photo")
                                        .font(.body.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color.secondary.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
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
                                        .foregroundStyle(Color.accentColor)
                                        .background(Color.secondary.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
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
                                    .foregroundStyle(Color.accentColor)
                                    .background(Color.secondary.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            if editingProfileImage != nil {
                                Button(role: .destructive, action: {
                                    editingProfileImage = nil
                                    showImageOptions = false
                                }) {
                                    Text("Remove Photo")
                                        .font(.body.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color.secondary.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
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
            ImagePicker(sourceType: pickerSource, selectedImage: $editingProfileImage)
        }
        .sheet(isPresented: $showCoverImagePicker) {
            ImagePicker(sourceType: coverPickerSource, selectedImage: $editingCoverImage)
        }
        .fullScreenCover(isPresented: $showPreview) {
            ZStack {
                Color.black.ignoresSafeArea()
                if let ui = editingProfileImage {
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
    }
    
    private func saveChanges() {
        // Update bindings directly (they are already @Binding, not optional Binding)
        username = editingUsername
        displayName = editingDisplayName
        bio = editingBio
        location = editingLocation
        coverImage = editingCoverImage
        profileImage = editingProfileImage
        
        // Dismiss the view to return to profile page
        dismiss()
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

