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

    @EnvironmentObject var authManager: AuthManager
    @State private var editingProfile: UserProfileContent = .empty
    @State private var didLoadInitialState = false
    @State private var showImageOptions: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showPreview: Bool = false
    @State private var showCoverImageOptions: Bool = false
    @State private var showCoverImagePicker: Bool = false
    @State private var coverPickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    @Environment(\.dismiss) private var dismiss
    
    private let cloudManager = CloudManager.shared
    
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
                TextField("Name", text: $editingProfile.displayName)
                    .textFieldStyle(.plain)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 4)
                
                HStack {
                    Text("@")
                        .foregroundStyle(.secondary)
                    TextField("Username", text: $editingProfile.username)
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
                    Task {
                        await saveChanges()
                    }
                } label: {
                    if isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Save Changes")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(accentTint)
                .disabled(isSaving)
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
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "Failed to save changes")
        }
        .onAppear {
            cloudManager.setAuthManager(authManager)
        }
    }
    
    private func saveChanges() async {
        isSaving = true
        errorMessage = nil
        
        // Validate required fields
        guard !editingProfile.displayName.isEmpty else {
            await MainActor.run {
                errorMessage = "Name cannot be empty"
                showError = true
                isSaving = false
            }
            return
        }
        
        guard !editingProfile.username.isEmpty else {
            await MainActor.run {
                errorMessage = "Username cannot be empty"
                showError = true
                isSaving = false
            }
            return
        }
        
        // Always save images to Keychain first (local storage)
        if let profileImage = editingProfile.profileImage,
           let imageData = profileImage.jpegData(compressionQuality: 0.8) {
            KeychainHelper.standard.storeData(imageData, key: "userProfileImage")
            print("✅ Saved profile image to Keychain")
        }
        
        if let coverImage = editingProfile.coverImage,
           let imageData = coverImage.jpegData(compressionQuality: 0.8) {
            KeychainHelper.standard.storeData(imageData, key: "userCoverImage")
            print("✅ Saved cover image to Keychain")
        }
        
        // Always save to local storage first (UserDefaults and Keychain)
        // This ensures data persists even if cloud save fails
        UserDefaults.standard.set(editingProfile.displayName, forKey: "userProfileName")
        UserDefaults.standard.set(editingProfile.username, forKey: "userProfileDisplayName")
        UserDefaults.standard.set(editingProfile.bio, forKey: "userProfileBio")
        UserDefaults.standard.set(editingProfile.location, forKey: "userProfileLocation")
        
        // Save timestamp to track when local data was last updated
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "userProfileLastUpdated")
        print("✅ Saved profile data to UserDefaults")
        
        // Try to update profile on cloud with retry logic
        var cloudSaveSucceeded = false
        var lastError: Error?
        
        // Try update first
        do {
            try await cloudManager.updateUserProfile(
                username: editingProfile.username,
                displayName: editingProfile.displayName,
                bio: editingProfile.bio,
                location: editingProfile.location.isEmpty ? nil : editingProfile.location
            )
            cloudSaveSucceeded = true
            print("✅ Profile updated on cloud")
        } catch let error as CloudError {
            lastError = error
            // If profile doesn't exist (404), create it first
            if case .serverError(let message) = error, message.contains("404") || message.contains("not found") {
                print("⚠️ Profile not found, creating new profile...")
                do {
                    try await cloudManager.createUserProfile(
                        username: editingProfile.username,
                        displayName: editingProfile.displayName,
                        bio: editingProfile.bio
                    )
                    // Try updating again with location
                    if !editingProfile.location.isEmpty {
                        do {
                            try await cloudManager.updateUserProfile(
                                username: editingProfile.username,
                                displayName: editingProfile.displayName,
                                bio: editingProfile.bio,
                                location: editingProfile.location
                            )
                            cloudSaveSucceeded = true
                            print("✅ Profile created and updated on cloud")
                        } catch {
                            print("⚠️ Failed to update profile with location: \(error)")
                        }
                    } else {
                        cloudSaveSucceeded = true
                        print("✅ Profile created on cloud")
                    }
                } catch {
                    print("⚠️ Failed to create profile: \(error), but saved locally")
                }
            } else if case .serverError(let message) = error, message.contains("403") {
                // 403 error - permission denied
                print("⚠️ Cloud update failed with 403 (permission denied), but saved locally")
                // Try to create profile as fallback
                do {
                    try await cloudManager.createUserProfile(
                        username: editingProfile.username,
                        displayName: editingProfile.displayName,
                        bio: editingProfile.bio
                    )
                    cloudSaveSucceeded = true
                    print("✅ Profile created on cloud after 403 error")
                } catch {
                    print("⚠️ Failed to create profile after 403: \(error)")
                }
            } else {
                // For other errors, still save locally but show warning
                print("⚠️ Cloud update failed: \(error), but saved locally")
            }
        } catch {
            // For any other errors, still save locally
            lastError = error
            print("⚠️ Cloud update failed: \(error), but saved locally")
        }
        
        // Always update local profile binding (even if cloud save failed)
        // This ensures the UI reflects the saved changes immediately
        await MainActor.run {
            profile.username = editingProfile.username
            profile.displayName = editingProfile.displayName
            profile.bio = editingProfile.bio
            profile.location = editingProfile.location
            profile.profileImage = editingProfile.profileImage
            profile.coverImage = editingProfile.coverImage
            
            // Show error alert if cloud save failed
            if !cloudSaveSucceeded {
                if let error = lastError as? CloudError,
                   case .serverError(let message) = error, message.contains("403") {
                    errorMessage = "Changes saved locally, but couldn't sync to cloud (permission denied). Your data is safe."
                    showError = true
                } else {
                    errorMessage = "Changes saved locally, but couldn't sync to cloud. Your data is safe."
                    showError = true
                }
            }
            
            dismiss()
        }
        
        await MainActor.run {
            isSaving = false
        }
    }

    private func loadInitialState() {
        guard !didLoadInitialState else { return }
        
        // Always start with the profile passed from UserProfileView
        editingProfile = profile
        
        // Load local saved data first (UserDefaults) - this is the most recent
        loadFromUserDefaults()
        
        // Load images from Keychain (they persist locally)
        if let profileImageData = KeychainHelper.standard.retrieveData(key: "userProfileImage"),
           let image = UIImage(data: profileImageData) {
            editingProfile.profileImage = image
        }
        
        if let coverImageData = KeychainHelper.standard.retrieveData(key: "userCoverImage"),
           let image = UIImage(data: coverImageData) {
            editingProfile.coverImage = image
        }
        
        // Try to load from cloud as backup (only if local data is missing)
        // But don't overwrite local data if it exists
        if authManager.isAuthenticated {
            Task {
                await loadProfileFromCloud(onlyIfLocalMissing: true)
            }
        }
        
        didLoadInitialState = true
    }
    
    private func loadFromUserDefaults() {
        // Load from UserDefaults (local backup - most recent)
        if let savedName = UserDefaults.standard.string(forKey: "userProfileName"), !savedName.isEmpty {
            editingProfile.displayName = savedName
        }
        if let savedUsername = UserDefaults.standard.string(forKey: "userProfileDisplayName"), !savedUsername.isEmpty {
            editingProfile.username = savedUsername
        }
        if let savedBio = UserDefaults.standard.string(forKey: "userProfileBio") {
            editingProfile.bio = savedBio
        }
        if let savedLocation = UserDefaults.standard.string(forKey: "userProfileLocation") {
            editingProfile.location = savedLocation
        }
    }
    
    private func loadProfileFromCloud(onlyIfLocalMissing: Bool = false) async {
        do {
            let userProfile = try await cloudManager.getCurrentUserProfile()
            let cloudProfile = UserProfileContent(from: userProfile)
            
            // Update editingProfile with cloud data
            await MainActor.run {
                // Only update if local data is missing, or if not in "onlyIfLocalMissing" mode
                if !onlyIfLocalMissing || editingProfile.displayName.isEmpty {
                    editingProfile.username = cloudProfile.username
                    editingProfile.displayName = cloudProfile.displayName
                    editingProfile.bio = cloudProfile.bio
                    editingProfile.location = cloudProfile.location
                    
                    // Also update the binding so UserProfileView gets updated
                    profile.username = cloudProfile.username
                    profile.displayName = cloudProfile.displayName
                    profile.bio = cloudProfile.bio
                    profile.location = cloudProfile.location
                }
            }
        } catch {
            print("❌ Failed to load profile from cloud in edit view: \(error)")
        }
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
