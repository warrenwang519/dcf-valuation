import SwiftUI

struct AccountSectionView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var showLogoutConfirm = false

    var body: some View {
        Section("Account") {
            if let user = authViewModel.currentUser {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.title)
                        .foregroundStyle(.blue)

                    VStack(alignment: .leading) {
                        Text(user.displayName.isEmpty ? "Apple User" : user.displayName)
                            .font(.headline)
                        if let email = user.email {
                            Text(email)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                HStack {
                    Image(systemName: "icloud.fill")
                        .foregroundStyle(.blue)
                    Text("iCloud Sync")
                    Spacer()
                    Text("Active")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }

            Button(role: .destructive) {
                showLogoutConfirm = true
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
            }
        }
        .alert("Sign Out", isPresented: $showLogoutConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                authViewModel.logout()
            }
        } message: {
            Text("Your data will remain in iCloud. You can sign in again anytime.")
        }
    }
}

#Preview {
    Form {
        AccountSectionView()
    }
    .environment(AuthViewModel())
}
