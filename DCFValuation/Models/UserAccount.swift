import Foundation

struct UserAccount: Equatable, Sendable {
    let userIdentifier: String
    let email: String?
    let fullName: String?
    let createdAt: Date

    var displayName: String {
        if let fullName, !fullName.isEmpty {
            return fullName
        }
        return email ?? ""
    }
}

enum AuthState: Equatable, Sendable {
    case unknown
    case notLoggedIn
    case loggedIn(UserAccount)
}

enum SyncState: Equatable, Sendable {
    case idle
    case syncing
    case synced(Date)
    case failed(String)

    static func == (lhs: SyncState, rhs: SyncState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.syncing, .syncing):
            return true
        case let (.synced(d1), .synced(d2)):
            return d1 == d2
        case let (.failed(s1), .failed(s2)):
            return s1 == s2
        default:
            return false
        }
    }
}
