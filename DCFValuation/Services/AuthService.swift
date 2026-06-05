import Foundation
import AuthenticationServices

struct AuthService: Sendable {
    private let keychainService = "com.dcfvaluation.auth"

    func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) async throws -> UserAccount {
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else {
                throw AuthError.invalidCredential
            }

            let userIdentifier = credential.user
            let email = credential.email
            let fullName = credential.fullName?.formatted(.name(style: .medium))

            // Store in Keychain
            saveToKeychain(userIdentifier: userIdentifier)

            // Cache email and name if provided (only on first sign-in)
            if let email {
                UserDefaults.standard.set(email, forKey: "user_email")
            }
            if let fullName {
                UserDefaults.standard.set(fullName, forKey: "user_fullname")
            }

            return UserAccount(
                userIdentifier: userIdentifier,
                email: email ?? UserDefaults.standard.string(forKey: "user_email"),
                fullName: fullName ?? UserDefaults.standard.string(forKey: "user_fullname"),
                createdAt: Date()
            )
        case .failure(let error):
            throw error
        }
    }

    func getStoredUserIdentifier() -> String? {
        guard let data = KeychainHelper.read(service: keychainService, account: "userIdentifier"),
              let identifier = String(data: data, encoding: .utf8) else {
            return nil
        }
        return identifier
    }

    func getCachedAccount() -> UserAccount? {
        guard let userIdentifier = getStoredUserIdentifier() else { return nil }
        return UserAccount(
            userIdentifier: userIdentifier,
            email: UserDefaults.standard.string(forKey: "user_email"),
            fullName: UserDefaults.standard.string(forKey: "user_fullname"),
            createdAt: Date()
        )
    }

    func checkAppleIDCredentialState() async -> Bool {
        guard let userIdentifier = getStoredUserIdentifier() else { return false }
        let provider = ASAuthorizationAppleIDProvider()
        do {
            let state = try await provider.credentialState(forUserID: userIdentifier)
            return state == .authorized
        } catch {
            return false
        }
    }

    func logout() {
        KeychainHelper.delete(service: keychainService, account: "userIdentifier")
    }

    private func saveToKeychain(userIdentifier: String) {
        guard let data = userIdentifier.data(using: .utf8) else { return }
        KeychainHelper.save(service: keychainService, account: "userIdentifier", data: data)
    }
}

enum AuthError: LocalizedError, Sendable {
    case invalidCredential

    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            "Invalid Apple credential"
        }
    }
}

enum KeychainHelper {
    static func save(service: String, account: String, data: Data) {
        // Delete existing item first to avoid duplicate
        delete(service: service, account: account)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    static func read(service: String, account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    static func delete(service: String, account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}
