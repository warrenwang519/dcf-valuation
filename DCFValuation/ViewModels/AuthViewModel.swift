import Foundation
import AuthenticationServices
import SwiftUI

@Observable
@MainActor
final class AuthViewModel {
    var authState: AuthState = .unknown
    private let authService = AuthService()

    var isLoggedIn: Bool {
        if case .loggedIn = authState { return true }
        return false
    }

    var currentUser: UserAccount? {
        if case .loggedIn(let user) = authState { return user }
        return nil
    }

    @MainActor
    func checkAuthState() async {
        let isAuthenticated = await authService.checkAppleIDCredentialState()
        if isAuthenticated, let account = authService.getCachedAccount() {
            authState = .loggedIn(account)
        } else {
            authState = .notLoggedIn
        }
    }

    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        Task { @MainActor in
            do {
                let account = try await authService.handleAppleSignIn(result)
                authState = .loggedIn(account)
            } catch {
                authState = .notLoggedIn
            }
        }
    }

    @MainActor
    func logout() {
        authService.logout()
        authState = .notLoggedIn
    }
}
