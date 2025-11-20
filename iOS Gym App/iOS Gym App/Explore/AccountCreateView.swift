////
////  AccountCreateView.swift
////  iOS Gym App
////
////  Created by 鄭承典 on 11/4/25.
////
//import SwiftUI
//import AuthenticationServices
//
//struct AccountCreateView: View {
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var cognitoManager: CognitoManager
//    
//    @State private var username: String = ""
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var agree: Bool = false
//    
//    @State private var showingVerification = false
//    @State private var verificationCode: String = ""
//    @State private var isLoading = false
//    @State private var errorMessage: String?
//    @State private var showError = false
//    
//    var body: some View {
//        Form {
//            Section(header: Text("Account")) {
//                TextField("Username", text: $username)
//                TextField("Email", text: $email)
//                    .textInputAutocapitalization(.never)
//                    .keyboardType(.emailAddress)
//                    .autocorrectionDisabled()
//                SecureField("Password", text: $password)
//            }
//            
//            Section(header: Text("Terms")) {
//                Toggle("I agree to the Terms", isOn: $agree)
//            }
//            
//            Section {
//                Button("Create Account") {
//                    Task {
//                        await createAccount()
//                    }
//                }
//                .frame(maxWidth: .infinity, alignment: .center)
//                .disabled(!agree || email.isEmpty || password.isEmpty || isLoading)
//            }
//            
//            Section {
//                SignInWithAppleButton(.signIn) { request in
//                    request.requestedScopes = [.fullName, .email]
//                } onCompletion: { result in
//                    switch result {
//                    case .success(let authorization):
//                        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//                            print("User ID: \(appleIDCredential.user)")
//                            print("Email: \(appleIDCredential.email ?? "N/A")")
//                            print("Full Name: \(appleIDCredential.fullName?.givenName ?? "") \(appleIDCredential.fullName?.familyName ?? "")")
//                        }
//                    case .failure(let error):
//                        print("Sign in with Apple failed: \(error.localizedDescription)")
//                    }
//                }
//                .signInWithAppleButtonStyle(.black)
//                .frame(height: 50)
//                .frame(maxWidth: .infinity)
//                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
//            }
//            .listRowBackground(Color.clear)
//        }
//        .navigationTitle("Create Account")
//        .overlay {
//            if isLoading {
//                ProgressView()
//                    .scaleEffect(1.5)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .background(Color.black.opacity(0.2))
//            }
//        }
//        .alert("Error", isPresented: $showError) {
//            Button("OK", role: .cancel) { }
//        } message: {
//            Text(errorMessage ?? "An unknown error occurred")
//        }
//        .sheet(isPresented: $showingVerification) {
//            VerificationView(email: email, verificationCode: $verificationCode) {
//                Task {
//                    await confirmSignUp()
//                }
//            }
//        }
//    }
//    
//    private func createAccount() async {
//        isLoading = true
//        errorMessage = nil
//        
//        do {
//            let response: () = try await cognitoManager.signUp(username: username, email: email, password: password)
//            
//            isLoading = false
//            
//            if response.success {
//                showingVerification = true
//            }
//        } catch {
//            isLoading = false
//            errorMessage = error.localizedDescription
//            showError = true
//        }
//    }
//    
//    private func confirmSignUp() async {
//        isLoading = true
//        errorMessage = nil
//        
//        do {
//            let response = try await cognitoManager.confirmSignUp(username: email, confirmationCode: verificationCode)
//            
//            if response.success {
//                // Now sign in automatically
//                _ = try await cognitoManager.signIn(username: email, password: password)
//                
//                isLoading = false
//                showingVerification = false
//                dismiss()
//            }
//        } catch {
//            isLoading = false
//            errorMessage = error.localizedDescription
//            showError = true
//        }
//    }
//}
//

//  Created by 鄭承典 on 11/4/25.
//
import SwiftUI
import AuthenticationServices

struct AccountCreateView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var agree: Bool = false
    
    private let buttonCornerRadius = Constants.cornerRadius
    private let primaryTint = Constants.mainAppTheme
    private let formSpacing: CGFloat = Constants.customLabelPadding
    
    var body: some View {
        Form {
            Section(header: ReusedViews.Labels.Header(text: "Account")) {
                TextField("Username", text: $username)
                    .textFieldStyle(.plain)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 4)
                
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(.plain)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 4)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.plain)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 4)
            }
            Section(header: ReusedViews.Labels.Header(text: "Terms")) {
                Toggle("I agree to the Terms", isOn: $agree)
            }
            Section {
                Button {
                    // TODO: Wire up account creation flow
                } label: {
                    Text("Create Account")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(primaryTint)
            }
            Section {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                            print("User ID: \(appleIDCredential.user)")
                            print("Email: \(appleIDCredential.email ?? "N/A")")
                            print("Full Name: \(appleIDCredential.fullName?.givenName ?? "") \(appleIDCredential.fullName?.familyName ?? "")")
                        }
                    case .failure(let error):
                        print("Sign in with Apple failed: \(error.localizedDescription)")
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: buttonCornerRadius, style: .continuous))
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("Create Account")
    }
}




//// MARK: - Verification View
//struct VerificationView: View {
//    let email: String
//    @Binding var verificationCode: String
//    let onConfirm: () -> Void
//    
//    @Environment(\.dismiss) var dismiss
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Verification")) {
//                    Text("A verification code has been sent to \(email)")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                    
//                    TextField("Verification Code", text: $verificationCode)
//                        .keyboardType(.numberPad)
//                }
//                
//                Section {
//                    Button("Confirm") {
//                        onConfirm()
//                    }
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .disabled(verificationCode.isEmpty)
//                }
//            }
//            .navigationTitle("Verify Email")
//            .navigationBarItems(trailing: Button("Cancel") {
//                dismiss()
//            })
//        }
//    }
//}
