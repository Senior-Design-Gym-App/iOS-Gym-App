//
//  AccountEditView.swift
//  iOS Gym App
//
//  Created by 鄭承典 on 11/4/25.
//
import SwiftUI
import UIKit

struct AccountEditView: View {
    @State private var displayName: String = ""
    @State private var bio: String = ""
    @State private var location: String = ""
    @State private var isPrivate: Bool = false
    @State private var profileImage: UIImage? = nil
    @State private var showImageOptions: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showPreview: Bool = false
    var body: some View {
        Form {
            Section(header: Text("Profile")) {
                VStack(spacing: 10) {
                    ZStack {
                        if let uiImage = profileImage {
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
                    .onLongPressGesture { if profileImage != nil { showPreview = true } }
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
                TextField("Display Name", text: $displayName)
                TextField("Location", text: $location)
                TextField("Bio", text: $bio, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
            }
            Section(header: Text("Privacy")) {
                Toggle("Private Account", isOn: $isPrivate)
            }
            Section {
                Button("Save Changes") {}
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .overlay(alignment: .center) {
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
                            if profileImage != nil {
                                Button(role: .destructive, action: {
                                    profileImage = nil
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
            ImagePicker(sourceType: pickerSource, selectedImage: $profileImage)
        }
        .fullScreenCover(isPresented: $showPreview) {
            ZStack {
                Color.black.ignoresSafeArea()
                if let ui = profileImage {
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















#Preview{
    AccountEditView()
}
