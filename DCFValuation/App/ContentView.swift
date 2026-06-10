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
    @State private var selectedTab = "calculator"

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: "home") {
                HomeView()
            }

            Tab("Calculator", systemImage: "function", value: "calculator") {
                NavigationStack {
                    DCFInputView(selectedTab: $selectedTab)
                }
            }

            Tab("History", systemImage: "clock.fill", value: "history") {
                HistoryView()
            }

            Tab("Settings", systemImage: "gearshape.fill", value: "settings") {
                SettingsView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthViewModel())
}
