//
//  AccountCreateView.swift
//  iOS Gym App
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
                VStack(spacing: formSpacing) {
                    TextField("Username", text: $username)
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    SecureField("Password", text: $password)
                }
                .padding(.vertical, formSpacing)
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




