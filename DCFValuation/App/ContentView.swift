import SwiftUI

struct ContentView: View {
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        Group {
            switch authViewModel.authState {
            case .unknown:
                ProgressView()
            case .notLoggedIn:
                LoginView()
            case .loggedIn:
                MainTabView()
            }
        }
        .task {
            await authViewModel.checkAuthState()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomeView()
            }

            Tab("Calculator", systemImage: "function") {
                NavigationStack {
                    DCFInputView()
                }
            }

            Tab("History", systemImage: "clock.fill") {
                HistoryView()
            }

            Tab("Settings", systemImage: "gearshape.fill") {
                SettingsView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthViewModel())
}
