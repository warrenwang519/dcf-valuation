import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(SettingsService.self) private var settingsService
    @Environment(\.modelContext) private var modelContext
    @State private var showClearConfirm = false

    var body: some View {
        NavigationStack {
            Form {
                AccountSectionView()

                Section("Defaults") {
                    CurrencyPickerView(currency: $settingsService.settings.defaultCurrency)

                    Stepper(
                        "\(settingsService.settings.defaultForecastYears) \("years")",
                        value: $settingsService.settings.defaultForecastYears,
                        in: 1...30
                    )

                    HStack {
                        Text("Default WACC")
                        Spacer()
                        Text("\(settingsService.settings.defaultWACC, specifier: "%.1f")%")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Default Terminal Growth")
                        Spacer()
                        Text("\(settingsService.settings.defaultTerminalGrowthRate, specifier: "%.1f")%")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Data") {
                    Button(role: .destructive) {
                        showClearConfirm = true
                    } label: {
                        Label("Clear All History", systemImage: "trash")
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Language")
                        Spacer()
                        Text("Follow System")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Clear All History", isPresented: $showClearConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    if let ownerID = authViewModel.currentUser?.userIdentifier {
                        PersistenceService(modelContext: modelContext).deleteAll(ownerID: ownerID)
                    }
                }
            } message: {
                Text("This action cannot be undone. All valuation records will be permanently deleted.")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(AuthViewModel())
        .environment(SettingsService())
}
