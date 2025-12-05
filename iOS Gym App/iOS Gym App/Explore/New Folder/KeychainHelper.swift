import Foundation
import Security

class KeychainHelper {
    
    static let standard = KeychainHelper()
    
    private init() {}
    
    // MARK: - Store Token
    func storeToken(_ token: String, key: String) {
        guard let data = token.data(using: .utf8) else {
            print("❌ Failed to convert token to data")
            return
        }
        
        // Create query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            print("✅ Stored token for key: \(key)")
        } else {
            print("❌ Failed to store token for key: \(key), status: \(status)")
        }
    }
    
    // MARK: - Retrieve Token
    func retrieveToken(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            if let data = dataTypeRef as? Data,
               let token = String(data: data, encoding: .utf8) {
                print("✅ Retrieved token for key: \(key)")
                return token
            }
        } else if status == errSecItemNotFound {
            print("⚠️ No token found for key: \(key)")
        } else {
            print("❌ Failed to retrieve token for key: \(key), status: \(status)")
        }
        
        return nil
    }
    
    // MARK: - Delete Token
    func deleteToken(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess {
            print("✅ Deleted token for key: \(key)")
        } else if status == errSecItemNotFound {
            print("⚠️ No token to delete for key: \(key)")
        } else {
            print("❌ Failed to delete token for key: \(key), status: \(status)")
        }
    }
    
    // MARK: - Delete All Tokens
    func deleteAllTokens() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess {
            print("✅ Deleted all tokens")
        } else if status == errSecItemNotFound {
            print("⚠️ No tokens to delete")
        } else {
            print("❌ Failed to delete all tokens, status: \(status)")
        }
    }
    
    // MARK: - Update Token
    func updateToken(_ token: String, key: String) {
        guard let data = token.data(using: .utf8) else {
            print("❌ Failed to convert token to data")
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        if status == errSecSuccess {
            print("✅ Updated token for key: \(key)")
        } else if status == errSecItemNotFound {
            // If item doesn't exist, store it
            print("⚠️ Token not found, storing new token for key: \(key)")
            storeToken(token, key: key)
        } else {
            print("❌ Failed to update token for key: \(key), status: \(status)")
        }
    }
    
    // MARK: - Check if Token Exists
    func tokenExists(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // MARK: - Store Generic Data
    func storeData(_ data: Data, key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            print("✅ Stored data for key: \(key)")
        } else {
            print("❌ Failed to store data for key: \(key), status: \(status)")
        }
    }
    
    // MARK: - Retrieve Generic Data
    func retrieveData(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            if let data = dataTypeRef as? Data {
                print("✅ Retrieved data for key: \(key)")
                return data
            }
        } else if status == errSecItemNotFound {
            print("⚠️ No data found for key: \(key)")
        } else {
            print("❌ Failed to retrieve data for key: \(key), status: \(status)")
        }
        
        return nil
    }
}

// MARK: - Convenience Extensions
extension KeychainHelper {
    
    // Store all auth tokens at once
    func storeAuthTokens(accessToken: String, idToken: String, refreshToken: String) {
        storeToken(accessToken, key: "accessToken")
        storeToken(idToken, key: "idToken")
        storeToken(refreshToken, key: "refreshToken")
    }
    
    // Retrieve all auth tokens at once
    func retrieveAuthTokens() -> (accessToken: String?, idToken: String?, refreshToken: String?) {
        return (
            retrieveToken(key: "accessToken"),
            retrieveToken(key: "idToken"),
            retrieveToken(key: "refreshToken")
        )
    }
    
    // Delete all auth tokens
    func deleteAuthTokens() {
        deleteToken(key: "accessToken")
        deleteToken(key: "idToken")
        deleteToken(key: "refreshToken")
    }
    
    // Check if user is logged in (has tokens)
    func isUserLoggedIn() -> Bool {
        return tokenExists(key: "accessToken") &&
               tokenExists(key: "idToken") &&
               tokenExists(key: "refreshToken")
    }
}
