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
            Tab("Home", systemImage: "house.fill") {
                HomeView()
            }
            .tag("home")

            Tab("Calculator", systemImage: "function") {
                NavigationStack {
                    DCFInputView(selectedTab: $selectedTab)
                }
            }
            .tag("calculator")

            Tab("History", systemImage: "clock.fill") {
                HistoryView()
            }
            .tag("history")

            Tab("Settings", systemImage: "gearshape.fill") {
                SettingsView()
            }
            .tag("settings")
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthViewModel())
}
