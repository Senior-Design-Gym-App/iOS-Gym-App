////
////  AuthenticatorView.swift
////  iOS Gym App
////
////  Created by Zachary Andrew Kolano on 11/9/25.
////
//import SwiftUI
//
//struct AuthenticationView: View {
//    @EnvironmentObject var cognitoManager: CognitoManager
//    @State private var showingCreateAccount = false
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var isLoading = false
//    @State private var errorMessage: String?
//    @State private var showError = false
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            Spacer()
//            
//            Text("Welcome")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//            
//            Text("Sign in to continue")
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//            
//            Spacer()
//            
//            VStack(spacing: 15) {
//                TextField("Email", text: $email)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .textInputAutocapitalization(.never)
//                    .keyboardType(.emailAddress)
//                    .autocorrectionDisabled()
//                
//                SecureField("Password", text: $password)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                
//                Button(action: {
//                    Task {
//                        await signIn()
//                    }
//                }) {
//                    if isLoading {
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                            .frame(maxWidth: .infinity)
//                    } else {
//                        Text("Sign In")
//                            .fontWeight(.semibold)
//                            .frame(maxWidth: .infinity)
//                    }
//                }
//                .frame(height: 50)
//                .background(Color.accentColor)
//                .foregroundColor(.white)
//                .cornerRadius(10)
//                .disabled(email.isEmpty || password.isEmpty || isLoading)
//                
//                Button("Don't have an account? Create one") {
//                    showingCreateAccount = true
//                }
//                .foregroundColor(.accentColor)
//            }
//            .padding(.horizontal, 30)
//            
//            Spacer()
//        }
//        .navigationTitle("Sign In")
//        .navigationBarHidden(true)
//        .alert("Error", isPresented: $showError) {
//            Button("OK", role: .cancel) { }
//        } message: {
//            Text(errorMessage ?? "An unknown error occurred")
//        }
//        .sheet(isPresented: $showingCreateAccount) {
//            NavigationView {
//                AccountCreateView()
//                    .environmentObject(cognitoManager)
//            }
//        }
//        .onAppear {
//            cognitoManager.checkAuthenticationStatus()
//        }
//    }
//    
//    private func signIn() async {
//        isLoading = true
//        errorMessage = nil
//        
//        do {
//            _ = try await cognitoManager.signIn(email: email, password: password)
//            isLoading = false
//        } catch {
//            isLoading = false
//            errorMessage = error.localizedDescription
//            showError = true
//        }
//    }
//}
