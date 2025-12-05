import SwiftUI

struct SignInView: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""  // Add this
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
                        
                        // Show user attributes
                        if !authManager.userAttributes.isEmpty {
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach(Array(authManager.userAttributes.keys.sorted()), id: \.self) { key in
                                    if let value = authManager.userAttributes[key] {
                                        Text("\(key): \(value)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding()
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
            // Email field
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
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
            .disabled(email.isEmpty || password.isEmpty)
            
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
            
            TextField("Name", text: $name)  // Add name field
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("Password must be at least 8 characters")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(action: handleSignUp) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(name.isEmpty || email.isEmpty || password.isEmpty || password.count < 8)
            
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
            
            Text("Enter the confirmation code sent to \(email)")
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
                try await authManager.signIn(email: email, password: password)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    private func handleSignUp() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authManager.signUp(email: email, password: password, name: name)
                showingSignUp = false
                showingConfirmation = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    private func handleConfirmation() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authManager.confirmSignUp(email: email, code: confirmationCode)
                showingConfirmation = false
                // Auto sign in after confirmation
                try await authManager.signIn(email: email, password: password)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
