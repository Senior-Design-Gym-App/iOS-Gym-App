import Foundation
import SwiftUI
import Combine
import AWSCognitoIdentityProvider

struct AuthTokens: Codable {
    let accessToken: String
    let idToken: String
    let refreshToken: String
}

enum CognitoConfig {
    private static func getConfigValue(for key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            fatalError("Missing \(key) in Info.plist")
        }
        return value
    }
    
    static let region = CognitoConfig.getConfigValue(for: "AWSRegion")
    static let userPoolId = CognitoConfig.getConfigValue(for: "AWSUserPoolId")
    static let clientId = CognitoConfig.getConfigValue(for: "AWSClientId")
    static let identityPoolId = getConfigValue(for: "AWSIdentityPoolId")
    static let apiBaseUrl = CognitoConfig.getConfigValue(for: "AWSAPIBaseUrl")
}

class CognitoManager: NSObject, ObservableObject {

    private let client: CognitoIdentityProviderClient
    private let userPoolId: String
    private let clientId: String
    
    static func create() async throws -> CognitoManager {
        let config = try await CognitoIdentityProviderClient.CognitoIdentityProviderClientConfiguration(
            region: CognitoConfig.region
        )
        let client = CognitoIdentityProviderClient(config: config)
        
        return CognitoManager(client: client)
    }
    
    private init(client: CognitoIdentityProviderClient) {
        self.client = client
        self.userPoolId = CognitoConfig.userPoolId
        self.clientId = CognitoConfig.clientId
        
        print("🔧 Configuration:")
        print("   Region:", CognitoConfig.region)
        print("   UserPoolId:", userPoolId)
        print("   ClientId:", clientId)
    }
    
    // MARK: - Sign Up
    func signUp(email: String, password: String, name: String) async throws {
        print("📝 Attempting sign up for:", email)
        
        let attributes = [
            CognitoIdentityProviderClientTypes.AttributeType(name: "email", value: email),
            CognitoIdentityProviderClientTypes.AttributeType(name: "name", value: name)
        ]
        
        let input = SignUpInput(
            clientId: clientId,
            password: password,
            userAttributes: attributes,
            username: email
        )
        
        do {
            let response = try await client.signUp(input: input)
            print("✅ Sign up successful")
            print("   User confirmed:", response.userConfirmed)
            print("   User sub:", response.userSub ?? "N/A")
        } catch let error as AWSCognitoIdentityProvider.UsernameExistsException {
            print("❌ User already exists")
            throw CognitoError.usernameExists
        } catch let error as AWSCognitoIdentityProvider.InvalidPasswordException {
            print("❌ Invalid password:", error.message ?? "")
            throw CognitoError.invalidPassword
        } catch let error as AWSCognitoIdentityProvider.InvalidParameterException {
            print("❌ Invalid parameter:", error.message ?? "")
            throw CognitoError.requestFailed(error.message ?? "Invalid parameter")
        } catch {
            print("❌ Sign up error:", error)
            throw error
        }
    }
    
    // MARK: - Confirm Sign Up
    func confirmSignUp(email: String, confirmationCode: String) async throws {
        print("📧 Confirming sign up for:", email)
        
        let input = ConfirmSignUpInput(
            clientId: clientId,
            confirmationCode: confirmationCode,
            username: email
        )
        
        do {
            _ = try await client.confirmSignUp(input: input)
            print("✅ User confirmed successfully")
        } catch let error as AWSCognitoIdentityProvider.CodeMismatchException {
            print("❌ Invalid confirmation code")
            throw CognitoError.codeMismatch
        } catch let error as AWSCognitoIdentityProvider.ExpiredCodeException {
            print("❌ Confirmation code expired")
            throw CognitoError.codeExpired
        } catch {
            print("❌ Confirmation error:", error)
            throw error
        }
    }
    
    // MARK: - Sign In (USER_PASSWORD_AUTH)
    func signIn(email: String, password: String) async throws -> AuthTokens {
        print("🔐 Attempting sign in for:", email)
        
        let input = InitiateAuthInput(
            authFlow: .userPasswordAuth,
            authParameters: [
                "USERNAME": email,
                "PASSWORD": password
            ],
            clientId: clientId
        )
        
        do {
            let response = try await client.initiateAuth(input: input)
            
            guard let authResult = response.authenticationResult,
                  let accessToken = authResult.accessToken,
                  let idToken = authResult.idToken,
                  let refreshToken = authResult.refreshToken else {
                print("❌ Missing tokens in response")
                throw CognitoError.authenticationFailed
            }
            
            print("✅ Sign in successful")
            
            return AuthTokens(
                accessToken: accessToken,
                idToken: idToken,
                refreshToken: refreshToken
            )
            
        } catch let error as AWSCognitoIdentityProvider.NotAuthorizedException {
            print("❌ Not authorized:", error.message ?? "")
            throw CognitoError.invalidPassword
        } catch let error as AWSCognitoIdentityProvider.UserNotFoundException {
            print("❌ User not found")
            throw CognitoError.userNotFound
        } catch let error as AWSCognitoIdentityProvider.UserNotConfirmedException {
            print("❌ User not confirmed")
            throw CognitoError.userNotConfirmed
        } catch let error as AWSCognitoIdentityProvider.InvalidParameterException {
            print("❌ Invalid parameter:", error.message ?? "")
            throw CognitoError.requestFailed(error.message ?? "Invalid parameter - make sure USER_PASSWORD_AUTH is enabled in Cognito")
        } catch {
            print("❌ Sign in error:", error)
            throw error
        }
    }
    
    // MARK: - Get User
    func getUser(accessToken: String) async throws -> [String: String] {
        print("👤 Getting user info...")
        
        let input = GetUserInput(accessToken: accessToken)
        
        do {
            let response = try await client.getUser(input: input)
            
            var userInfo: [String: String] = [:]
            userInfo["username"] = response.username
            
            if let attributes = response.userAttributes {
                for attr in attributes {
                    if let name = attr.name, let value = attr.value {
                        userInfo[name] = value
                    }
                }
            }
            
            print("✅ Got user info for:", response.username ?? "unknown")
            return userInfo
            
        } catch {
            print("❌ Get user error:", error)
            throw error
        }
    }
    
    // MARK: - Delete User
    func deleteUser(accessToken: String) async throws {
        print("🗑️ Deleting user...")
        
        let input = DeleteUserInput(accessToken: accessToken)
        
        do {
            _ = try await client.deleteUser(input: input)
            print("✅ User deleted successfully")
        } catch {
            print("❌ Delete user error:", error)
            throw error
        }
    }
    
    // MARK: - Refresh Session
    func refreshSession(refreshToken: String) async throws -> AuthTokens {
        print("🔄 Refreshing session...")
        
        let input = InitiateAuthInput(
            authFlow: .refreshTokenAuth,
            authParameters: [
                "REFRESH_TOKEN": refreshToken
            ],
            clientId: clientId
        )
        
        let response = try await client.initiateAuth(input: input)
        
        guard let authResult = response.authenticationResult,
              let accessToken = authResult.accessToken,
              let idToken = authResult.idToken else {
            throw CognitoError.refreshFailed
        }
        
        print("✅ Session refreshed")
        
        return AuthTokens(
            accessToken: accessToken,
            idToken: idToken,
            refreshToken: refreshToken
        )
    }
    
    // MARK: - Sign Out
    func signOut() async throws {
        print("👋 Signed out successfully")
    }
    
    // MARK: - Errors
    enum CognitoError: LocalizedError {
        case poolNotInitialized
        case invalidResponse
        case requestFailed(String)
        case authenticationFailed
        case noCurrentUser
        case userNotFound
        case invalidPassword
        case usernameExists
        case codeExpired
        case codeMismatch
        case refreshFailed
        case userNotConfirmed
        
        var errorDescription: String? {
            switch self {
            case .poolNotInitialized:
                return "User pool not initialized"
            case .invalidResponse:
                return "Invalid response from server"
            case .requestFailed(let message):
                return message
            case .authenticationFailed:
                return "Authentication failed"
            case .noCurrentUser:
                return "No current user"
            case .userNotFound:
                return "User not found"
            case .invalidPassword:
                return "Incorrect email or password"
            case .usernameExists:
                return "An account with this email already exists"
            case .codeExpired:
                return "Verification code expired"
            case .codeMismatch:
                return "Invalid verification code"
            case .refreshFailed:
                return "Failed to refresh session"
            case .userNotConfirmed:
                return "Please verify your email first"
            }
        }
    }
}

// MARK: - Auth Manager
@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: String?
    @Published var userAttributes: [String: String] = [:]
    
    private var cognitoService: CognitoManager?
    private var currentTokens: AuthTokens?
    
    func initialize() async throws {
        cognitoService = try await CognitoManager.create()
        
        // Check for existing tokens
        if let accessToken = KeychainHelper.standard.retrieveToken(key: "accessToken"),
           let idToken = KeychainHelper.standard.retrieveToken(key: "idToken"),
           let refreshToken = KeychainHelper.standard.retrieveToken(key: "refreshToken") {
            
            currentTokens = AuthTokens(
                accessToken: accessToken,
                idToken: idToken,
                refreshToken: refreshToken
            )
            
            // Try to get user info
            do {
                let userInfo = try await cognitoService?.getUser(accessToken: accessToken)
                userAttributes = userInfo ?? [:]
                
                // FIX: Use "sub" for currentUser (the unique Cognito ID)
                // Store email separately if you need it
                currentUser = userInfo?["sub"]  // CHANGED FROM email/username
                isAuthenticated = true
                
                print("✅ Initialized with user ID: \(currentUser ?? "unknown")")
                print("📧 User email: \(userInfo?["email"] ?? "unknown")")
                
            } catch {
                // Token might be expired, try to refresh
                print("⚠️ Failed to get user info, trying to refresh token...")
                do {
                    let newTokens = try await cognitoService?.refreshSession(refreshToken: refreshToken)
                    if let newTokens = newTokens {
                        KeychainHelper.standard.storeAuthTokens(
                            accessToken: newTokens.accessToken,
                            idToken: newTokens.idToken,
                            refreshToken: newTokens.refreshToken
                        )
                        currentTokens = newTokens
                        
                        let userInfo = try await cognitoService?.getUser(accessToken: newTokens.accessToken)
                        userAttributes = userInfo ?? [:]
                        currentUser = userInfo?["sub"]  // CHANGED
                        isAuthenticated = true
                        
                        print("✅ Refreshed and initialized with user ID: \(currentUser ?? "unknown")")
                    }
                } catch {
                    // Refresh failed, clear tokens
                    print("❌ Refresh failed, clearing tokens")
                    KeychainHelper.standard.deleteAuthTokens()
                }
            }
        }
    }
    
    
    func signIn(email: String, password: String) async throws {
        guard let service = cognitoService else { return }
        let tokens = try await service.signIn(email: email, password: password)
        
        // Store tokens
        KeychainHelper.standard.storeAuthTokens(
            accessToken: tokens.accessToken,
            idToken: tokens.idToken,
            refreshToken: tokens.refreshToken
        )
        
        // Get user info
        let userInfo = try await service.getUser(accessToken: tokens.accessToken)
        userAttributes = userInfo
        
        currentTokens = tokens
        isAuthenticated = true
        currentUser = email
    }
    
    func signOut() async throws {
        // Clear tokens
        KeychainHelper.standard.deleteAuthTokens()
        
        currentTokens = nil
        userAttributes = [:]
        isAuthenticated = false
        currentUser = nil
    }
    
    func signUp(email: String, password: String, name: String) async throws {
        guard let service = cognitoService else { return }
        try await service.signUp(email: email, password: password, name: name)
    }
    
    func confirmSignUp(email: String, code: String) async throws {
        guard let service = cognitoService else { return }
        try await service.confirmSignUp(email: email, confirmationCode: code)
    }
}
