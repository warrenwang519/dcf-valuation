import SwiftUI
import SwiftData

private extension Double {
    var cleanString: String {
        truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", self)
            : String(self)
    }
}

struct SettingsView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(SettingsService.self) private var settingsService
    @Environment(\.modelContext) private var modelContext
    @State private var showClearConfirm = false

    private var waccError: String? {
        let wacc = settingsService.settings.defaultWACC
        guard wacc != 0 else { return nil } // Don't show error for empty/default state
        if wacc <= 0 || wacc >= 50 {
            return "WACC must be between 0% and 50% (exclusive)."
        }
        return nil
    }

    private var terminalGrowthError: String? {
        let tgr = settingsService.settings.defaultTerminalGrowthRate
        let wacc = settingsService.settings.defaultWACC
        guard tgr != 0 || wacc != 0 else { return nil }
        if tgr < 0 {
            return "Terminal growth rate must be non-negative."
        }
        if wacc > 0 && tgr >= wacc {
            return "Terminal growth rate must be strictly less than WACC."
        }
        return nil
    }

    var body: some View {
        @Bindable var settings = settingsService
        NavigationStack {
            Form {
                AccountSectionView()

                Section("Defaults") {
                    CurrencyPickerView(currency: $settings.settings.defaultCurrency)

                    Stepper(
                        "\(settings.settings.defaultForecastYears) years",
                        value: $settings.settings.defaultForecastYears,
                        in: 1...30
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Default WACC")
                            Spacer()
                            TextField("e.g. 10", text: Binding(
                                get: { settings.settings.defaultWACC == 0 ? "" : settings.settings.defaultWACC.cleanString },
                                set: { settings.settings.defaultWACC = Double($0) ?? 0 }
                            ))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                            Text("%")
                                .foregroundStyle(.secondary)
                        }
                        if let error = waccError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Default Terminal Growth")
                            Spacer()
                            TextField("e.g. 2.5", text: Binding(
                                get: { settings.settings.defaultTerminalGrowthRate == 0 ? "" : settings.settings.defaultTerminalGrowthRate.cleanString },
                                set: { settings.settings.defaultTerminalGrowthRate = Double($0) ?? 0 }
                            ))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                            Text("%")
                                .foregroundStyle(.secondary)
                        }
                        if let error = terminalGrowthError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
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

                    NavigationLink("Contact Us") {
                        ContactView()
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
