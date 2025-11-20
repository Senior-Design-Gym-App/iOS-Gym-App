import Foundation
import SwiftUI
import Combine
import AWSCognitoIdentityProvider
import AWSCognitoIdentity
import AuthenticationServices

struct AuthTokens: Codable {
    let accessToken: String
    let idToken: String
    let refreshToken: String
}
enum CognitoConfig {
    static let region = "us-east-1"
    static let userPoolId = "us-east-1_CufyXN1AX"
    static let clientId = "3altkace0jjhoabhguqq4et7om"
    static let apiBaseUrl = "https://mhfwd1sla9.execute-api.us-east-1.amazonaws.com/prod"
    //static let callbackURL = "https://d84l1y8p4kdic.cloudfront.net"
    static let callbackURL = "yourapp://callback"
    static let domainURL = "https://us-east-1cufyxn1ax.auth.us-east-1.amazoncognito.com"
}

class CognitoManager: NSObject, ObservableObject{

    private let client: CognitoIdentityProviderClient
    private let userPoolId: String
    private let clientId: String
    private let apiBaseUrl: String
    private let callbackURL: String
    private let domainURL: String
    
    static func create() async throws -> CognitoManager {
        let config = try await CognitoIdentityProviderClient.CognitoIdentityProviderClientConfiguration(
            region: "us-east-1"
        )
        let client = CognitoIdentityProviderClient(config: config)
        
        return CognitoManager(client:client)
    }
    private init(client: CognitoIdentityProviderClient) {
        self.client = client
        self.userPoolId = CognitoConfig.userPoolId
        self.clientId = CognitoConfig.clientId
        self.apiBaseUrl = CognitoConfig.apiBaseUrl
        self.callbackURL = CognitoConfig.callbackURL
        self.domainURL = CognitoConfig.domainURL
    }
    
    // MARK: - Sign Up
    func signUp(username: String, email: String, password: String) async throws {
        
        let emailAttribute = CognitoIdentityProviderClientTypes.AttributeType(
            name: "email",
            value: email
        )
        let input = SignUpInput(
            clientId: clientId,
            password: password,
            userAttributes: [emailAttribute],
            username: username
        )
        
        let response = try await client.signUp(input: input)
        print("Sign up successful. User confirmed: \(response.userConfirmed)")
        
    }
    
    // MARK: - Confirm Sign Up
    func confirmSignUp(username: String, confirmationCode: String) async throws {
        let input = ConfirmSignUpInput(
            clientId: clientId,
            confirmationCode: confirmationCode,
            username: username
        )
        
        _ = try await client.confirmSignUp(input: input)
        
        print("User confirmed successfully")
    }
    
    // MARK: - Sign In
    func signIn(username: String, password: String) async throws -> AuthTokens {
        let input = InitiateAuthInput(
            authFlow: .userPasswordAuth,
            authParameters: [
                "USERNAME": username,
                "PASSWORD": password
            ],
            clientId: clientId
        )
        
        let response = try await client.initiateAuth(input: input)
        
        guard let authResult = response.authenticationResult,
              let accessToken = authResult.accessToken,
              let idToken = authResult.idToken,
              let refreshToken = authResult.refreshToken else {
            throw CognitoError.authenticationFailed
        }
        
        return AuthTokens(
            accessToken: accessToken,
            idToken: idToken,
            refreshToken: refreshToken
        )
    }
    
    // MARK: - Apple Sign In
    func signInWithApple() async{
        let urlString = """
        https://\(domainURL)/oauth2/authorize?\
        identity_provider=Apple&\
        redirect_uri=\(callbackURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&\
        response_type=CODE&\
        client_id=\(clientId)&\
        scope=openid%20email%20profile
        """
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }
        
        print("🚀 Starting authentication with URL:", url)
        
        let session = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: callbackURL.components(separatedBy: "://").first
        ) { [weak self] callbackURL, error in
            if let error = error {
                print("❌ Auth session error:", error)
                return
            }
            
            guard let callbackURL = callbackURL else {
                print("❌ No callback URL")
                return
            }
            
            print("✅ Received callback URL:", callbackURL)
            
            // Extract authorization code
            let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)
            
            if let code = components?.queryItems?.first(where: { $0.name == "code" })?.value {
                print("✅ Got authorization code")
                Task {
                    do {
                        try await self?.exchangeCodeForTokens(code: code)
                    } catch {
                        print("❌ Token exchange failed:", error)
                    }
                }
            } else {
                print("❌ No authorization code in callback")
            }
        }
        session.start()
    }
    
    private func exchangeCodeForTokens(code: String) async throws {
        let tokenURL = URL(string: "https://\(domainURL)/oauth2/token")!
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyParams = [
            "grant_type": "authorization_code",
            "client_id": clientId,
            "code": code,
            "redirect_uri": callbackURL
        ]
        
        let body = bodyParams
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
        
        request.httpBody = body.data(using: .utf8)
        
        print("🔄 Exchanging code for tokens...")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CognitoError.tokenExchangeFailed
        }
        
        print("📥 Token response status:", httpResponse.statusCode)
        
        if httpResponse.statusCode != 200 {
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ Token error response:", errorString)
            }
            throw CognitoError.tokenExchangeFailed
        }
        
        struct TokenResponse: Codable {
            let access_token: String
            let id_token: String
            let refresh_token: String
            let token_type: String
            let expires_in: Int
        }
        
        let tokens = try JSONDecoder().decode(TokenResponse.self, from: data)
        
        print("✅ Successfully received tokens")
        
        // Parse the ID token to get user info
        if let userInfo = parseJWT(tokens.id_token) {
            await MainActor.run {
                print(userInfo["sub"] ?? "aaaa")
            }
        }
        
        // TODO: Store tokens securely in Keychain
        UserDefaults.standard.set(tokens.access_token, forKey: "accessToken")
        UserDefaults.standard.set(tokens.id_token, forKey: "idToken")
        UserDefaults.standard.set(tokens.refresh_token, forKey: "refreshToken")
    }
    
    private func parseJWT(_ jwt: String) -> [String: Any]? {
        let segments = jwt.components(separatedBy: ".")
        guard segments.count > 1 else { return nil }
        
        var base64 = segments[1]
        // Add padding if needed
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }
        
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        return json
    }
    
    
    // MARK: - Sign Out
    func signOut() async throws {
        print("trying to sign out")
        
        print("Signed out successfully")
    }
    
    func refreshSession(refreshToken: String) async throws -> AuthTokens {
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
        
        return AuthTokens(
            accessToken: accessToken,
            idToken: idToken,
            refreshToken: refreshToken // Keep the same refresh token
        )
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
        case invalidAppleCredential
        case invalidAppleToken
        case refreshFailed
        case federationFailed
        case tokenExchangeFailed
        
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
                return "Invalid password"
            case .usernameExists:
                return "Username already exists"
            case .codeExpired:
                return "Verification code expired"
            case .codeMismatch:
                return "Invalid verification code"
            case .invalidAppleCredential:
                return "Invalid Apple credential"
            case .invalidAppleToken:
                return "Invalid Apple identity token"
            case .federationFailed:
                return "Federation Failed"
            case .refreshFailed:
                return "Refresh Failed"
            case .tokenExchangeFailed:
                return "Token Exchange Failed"
            }
        }
    }

}
// MARK: - Auth Manager
@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: String?
    
    private var cognitoService: CognitoManager?
    private var currentTokens: AuthTokens?
    
    func initialize() async throws {
        cognitoService = try await CognitoManager.create()
    }
    
    func signIn(username: String, password: String) async throws {
        guard let service = cognitoService else { return }
        currentTokens = try await service.signIn(username: username, password: password)
        
        // Store tokens securely (implement keychain storage)
        isAuthenticated = true
        currentUser = username
    }
    
    func signUp(username: String, password: String, email: String) async throws {
        guard let service = cognitoService else { return }
        try await service.signUp(username: username, email: email, password: password)
    }
    
    func confirmSignUp(username: String, code: String) async throws {
        guard let service = cognitoService else { return }
        try await service.confirmSignUp(username: username, confirmationCode: code)
    }
    
    func signInWithApple(authorization: ASAuthorization) async throws {
        guard let service = cognitoService,
              let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = appleIDCredential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            throw CognitoManager.CognitoError.invalidAppleToken
        }
        print("has everything that it needs")
        let _ = await service.signInWithApple()
        print("successfully signed in with Apple")
        isAuthenticated = true
        currentUser = appleIDCredential.user
    }
    
    func signOut() async throws {
        currentTokens = nil
        isAuthenticated = false
        currentUser = nil
    }
}
