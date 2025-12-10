//
//  CreateProfileView.swift
//  iOS Gym App
//
//  Created by Zachary Andrew Kolano on 12/8/25.
//

import SwiftUI

struct CreateProfileView: View {
    @State private var username = ""
    @State private var displayName = ""
    @State private var bio = ""
    @State private var isCreating = false
    @State private var errorMessage = ""
    
    @Environment(\.dismiss) private var dismiss
    let onProfileCreated: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 20) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.blue.gradient)
                        
                        Text("Create Your Profile")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Set up your profile to connect with friends")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                .listRowBackground(Color.clear)
                
                Section {
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    TextField("Display Name", text: $displayName)
                    
                    TextField("Bio (optional)", text: $bio, axis: .vertical)
                        .lineLimit(3...5)
                } header: {
                    Text("Profile Information")
                } footer: {
                    Text("Username must be unique and can only contain letters, numbers, and underscores")
                }
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.callout)
                    }
                }
                
                Section {
                    Button {
                        Task { await createProfile() }
                    } label: {
                        HStack {
                            Spacer()
                            if isCreating {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .scaleEffect(0.8)
                                Text("Creating...")
                            } else {
                                Text("Create Profile")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(username.isEmpty || isCreating)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(true)
        }
    }
    
    private func createProfile() async {
        isCreating = true
        errorMessage = ""
        
        // Validate username
        guard isValidUsername(username) else {
            errorMessage = "Username can only contain letters, numbers, and underscores"
            isCreating = false
            return
        }
        
        do {
            try await CloudManager.shared.createUserProfile(
                username: username,
                displayName: displayName.isEmpty ? username : displayName,
                bio: bio.isEmpty ? nil : bio
            )
            
            print("✅ Profile created successfully")
            onProfileCreated()
            dismiss()
        } catch {
            errorMessage = "Failed to create profile: \(error.localizedDescription)"
            print("❌ Error creating profile: \(error)")
        }
        
        isCreating = false
    }
    
    private func isValidUsername(_ username: String) -> Bool {
        let usernameRegex = "^[a-zA-Z0-9_]{3,20}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        return predicate.evaluate(with: username)
    }
}

#Preview {
    CreateProfileView(onProfileCreated: {})
}
