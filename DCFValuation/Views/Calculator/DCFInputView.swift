import SwiftUI
import SwiftData

private extension Double {
    /// Display as integer if no fractional part, otherwise show decimals.
    var cleanString: String {
        truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", self)
            : String(self)
    }
}

struct DCFInputView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(SettingsService.self) private var settingsService
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = DCFInputViewModel()
    @State private var navigateToResult = false
    @State private var showErrors = false

    /// Map a validation error to its field identifier.
    private func fieldID(for error: ValidationError) -> String {
        switch error {
        case .fcfMustBePositive: return "fcf"
        case .growthRateOutOfRange: return "growthRate"
        case .forecastYearsOutOfRange: return "forecastYears"
        case .waccOutOfRange: return "wacc"
        case .terminalGrowthRateInvalid: return "terminalGrowthRate"
        case .sharesMustBePositive: return "shares"
        case .tickerTooLong: return "ticker"
        case .waccTooCloseToTerminalGrowth: return "wacc"
        }
    }

    /// Get the error message for a specific field, if it has a validation error.
    private func errorMessage(for targetField: String) -> String? {
        guard showErrors else { return nil }
        return viewModel.validationErrors.first { fieldID(for: $0) == targetField }?.localizedDescription
    }

    /// Clear errors when user edits any field.
    private func clearErrors() {
        if showErrors { showErrors = false }
    }

    var body: some View {
        Form {
            Section("Ticker") {
                InputFieldRow(
                    title: "Ticker",
                    placeholder: "e.g. AAPL",
                    text: $viewModel.input.ticker,
                    keyboardType: .default,
                    numericOnly: false,
                    errorMessage: errorMessage(for: "ticker")
                )
                .onChange(of: viewModel.input.ticker) { clearErrors() }
                InputFieldRow(
                    title: "Company",
                    placeholder: "Apple Inc.",
                    text: $viewModel.input.companyName,
                    keyboardType: .default,
                    numericOnly: false
                )
            }

            Section("Cash Flow") {
                InputFieldRow(
                    title: "FCF",
                    placeholder: "Free Cash Flow (M)",
                    text: Binding(
                        get: { viewModel.input.fcf == 0 ? "" : viewModel.input.fcf.cleanString },
                        set: { viewModel.input.fcf = Double($0) ?? 0 }
                    ),
                    errorMessage: errorMessage(for: "fcf")
                )
                .onChange(of: viewModel.input.fcf) { clearErrors() }
                InputFieldRow(
                    title: "Growth Rate",
                    placeholder: "e.g. 8",
                    text: Binding(
                        get: { viewModel.input.growthRate == 0 ? "" : viewModel.input.growthRate.cleanString },
                        set: { viewModel.input.growthRate = Double($0) ?? 0 }
                    ),
                    suffix: "%",
                    errorMessage: errorMessage(for: "growthRate")
                )
                .onChange(of: viewModel.input.growthRate) { clearErrors() }
                InputStepperRow(
                    title: "Forecast Years",
                    value: $viewModel.input.forecastYears,
                    range: 1...30
                )
            }

            Section("Discount Rate") {
                InputFieldRow(
                    title: "WACC",
                    placeholder: "e.g. 10",
                    text: Binding(
                        get: { viewModel.input.wacc == 0 ? "" : viewModel.input.wacc.cleanString },
                        set: { viewModel.input.wacc = Double($0) ?? 0 }
                    ),
                    suffix: "%",
                    errorMessage: errorMessage(for: "wacc")
                )
                .onChange(of: viewModel.input.wacc) { clearErrors() }
                InputFieldRow(
                    title: "Terminal Growth",
                    placeholder: "e.g. 2.5",
                    text: Binding(
                        get: { viewModel.input.terminalGrowthRate == 0 ? "" : viewModel.input.terminalGrowthRate.cleanString },
                        set: { viewModel.input.terminalGrowthRate = Double($0) ?? 0 }
                    ),
                    suffix: "%",
                    errorMessage: errorMessage(for: "terminalGrowthRate")
                )
                .onChange(of: viewModel.input.terminalGrowthRate) { clearErrors() }
            }

            Section("Equity") {
                InputFieldRow(
                    title: "Net Debt",
                    placeholder: "Net Debt (M)",
                    text: Binding(
                        get: { viewModel.input.netDebt == 0 ? "" : viewModel.input.netDebt.cleanString },
                        set: { viewModel.input.netDebt = Double($0) ?? 0 }
                    )
                )
                InputFieldRow(
                    title: "Shares",
                    placeholder: "Shares Outstanding (M)",
                    text: Binding(
                        get: { viewModel.input.sharesOutstanding == 0 ? "" : viewModel.input.sharesOutstanding.cleanString },
                        set: { viewModel.input.sharesOutstanding = Double($0) ?? 0 }
                    ),
                    errorMessage: errorMessage(for: "shares")
                )
                .onChange(of: viewModel.input.sharesOutstanding) { clearErrors() }
            }

            Section("Currency") {
                Picker("Currency", selection: $viewModel.input.currency) {
                    ForEach(Currency.allCases) { currency in
                        Text("\(currency.displaySymbol) \(currency.rawValue)")
                            .tag(currency)
                    }
                }
            }
        }
        .navigationTitle("DCF Calculator")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Calculate") {
                    if viewModel.calculate() {
                        showErrors = false
                        navigateToResult = true
                    } else {
                        showErrors = true
                    }
                }
            }
        }
        .navigationDestination(isPresented: $navigateToResult) {
            if let result = viewModel.result, let ownerID = authViewModel.currentUser?.userIdentifier {
                ResultView(
                    viewModel: ResultViewModel(
                        result: result,
                        persistenceService: PersistenceService(modelContext: modelContext),
                        ownerID: ownerID
                    )
                )
            }
        }
        .onAppear {
            viewModel.loadFromSettings(settingsService.settings)
        }
    }
}

#Preview {
    DCFInputView()
        .environment(AuthViewModel())
        .environment(SettingsService())
}
