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
        // TODO: Re-enable real auth once Apple Developer Program is active
        // Dev mode: auto-login with a local dev account
        let devAccount = UserAccount(
            userIdentifier: "dev-local-user",
            email: "dev@local",
            fullName: "Dev User",
            createdAt: .now
        )
        authState = .loggedIn(devAccount)

        // --- Original auth flow (restore when paid) ---
        // let isAuthenticated = await authService.checkAppleIDCredentialState()
        // if isAuthenticated, let account = authService.getCachedAccount() {
        //     authState = .loggedIn(account)
        // } else {
        //     authState = .notLoggedIn
        // }
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
