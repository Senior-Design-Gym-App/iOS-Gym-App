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
    var body: some View {
        Form {
                Section(header: Text("Account")) {
                    TextField("Username", text: $username)
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    SecureField("Password", text: $password)
                }
                Section(header: Text("Terms")) {
                    Toggle("I agree to the Terms", isOn: $agree)
                }
                Section {
                    Button("Create Account") {}
                        .frame(maxWidth: .infinity, alignment: .center)
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
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("Create Account")
    }
}



