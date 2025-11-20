//
//  SignInView.swift
//  iOS Gym App
//
//  Created by Zachary Andrew Kolano on 11/13/25.
//
import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var username = ""
    @State private var password = ""
    @State private var email = ""
    @State private var showingSignUp = false
    @State private var showingConfirmation = false
    @State private var confirmationCode = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if authManager.isAuthenticated {
                    // Success view
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Welcome!")
                            .font(.title)
                        
                        if let user = authManager.currentUser {
                            Text("Signed in as: \(user)")
                                .foregroundColor(.secondary)
                        }
                        
                        Button("Sign Out") {
                            Task {
                                try? await authManager.signOut()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    VStack(spacing: 25) {
                        // Logo or App Name
                        Text("My App")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.bottom, 30)
                        
                        if showingConfirmation {
                            confirmationView
                        } else if showingSignUp {
                            signUpView
                        } else {
                            signInView
                        }
                        
                        // Error message
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding(30)
                }
                
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            do {
                try await authManager.initialize()
            } catch {
                errorMessage = "Failed to initialize: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Sign In View
    private var signInView: some View {
        VStack(spacing: 20) {
            // Username field
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            // Password field
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Sign In button
            Button(action: handleSignIn) {
                Text("Sign In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(username.isEmpty || password.isEmpty)
            
            // Divider
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.3))
                Text("or")
                    .foregroundColor(.gray)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.3))
            }
            .padding(.vertical, 10)
            
            // Sign in with Apple button
            SignInWithAppleButton(
                onRequest: { request in
                    request.requestedScopes = [.email, .fullName]
                },
                onCompletion: { result in
                    handleAppleSignIn(result: result)
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .cornerRadius(10)
            
            // Sign Up link
            Button(action: {
                showingSignUp = true
                errorMessage = nil
            }) {
                Text("Don't have an account? Sign Up")
                    .foregroundColor(.blue)
            }
            .padding(.top, 10)
        }
    }
    
    // MARK: - Sign Up View
    private var signUpView: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.title2)
                .fontWeight(.semibold)
            
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: handleSignUp) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(username.isEmpty || email.isEmpty || password.isEmpty)
            
            Button(action: {
                showingSignUp = false
                errorMessage = nil
            }) {
                Text("Already have an account? Sign In")
                    .foregroundColor(.blue)
            }
        }
    }
    
    // MARK: - Confirmation View
    private var confirmationView: some View {
        VStack(spacing: 20) {
            Text("Verify Your Account")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Enter the confirmation code sent to your email")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            TextField("Confirmation Code", text: $confirmationCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            
            Button(action: handleConfirmation) {
                Text("Confirm")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(confirmationCode.isEmpty)
            
            Button(action: {
                showingConfirmation = false
                showingSignUp = false
                errorMessage = nil
            }) {
                Text("Back to Sign In")
                    .foregroundColor(.blue)
            }
        }
    }
    
    // MARK: - Actions
    private func handleSignIn() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authManager.signIn(username: username, password: password)
            } catch {
                errorMessage = "Sign in failed: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    private func handleSignUp() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authManager.signUp(username: username, password: password, email: email)
                showingSignUp = false
                showingConfirmation = true
            } catch {
                errorMessage = "Sign up failed: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    private func handleConfirmation() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authManager.confirmSignUp(username: username, code: confirmationCode)
                showingConfirmation = false
                // Auto sign in after confirmation
                try await authManager.signIn(username: username, password: password)
            } catch {
                errorMessage = "Confirmation failed: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    private func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        isLoading = true
        errorMessage = nil
        
        switch result {
        case .success(let authorization):
            Task {
                do {
                    try await authManager.signInWithApple(authorization: authorization)
                } catch {
                    errorMessage = "Apple sign in failed: \(error.localizedDescription)"
                }
                isLoading = false
            }
        case .failure(let error):
            errorMessage = "Apple sign in failed: \(error.localizedDescription)"
            isLoading = false
        }
    }
}

// MARK: - Preview
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
