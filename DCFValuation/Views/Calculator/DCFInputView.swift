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

    var body: some View {
        Form {
            Section("Ticker") {
                InputFieldRow(
                    title: "Ticker",
                    placeholder: "e.g. AAPL",
                    text: $viewModel.input.ticker,
                    keyboardType: .default
                )
                InputFieldRow(
                    title: "Company",
                    placeholder: "Apple Inc.",
                    text: $viewModel.input.companyName,
                    keyboardType: .default
                )
            }

            Section("Cash Flow") {
                InputFieldRow(
                    title: "FCF",
                    placeholder: "Free Cash Flow (M)",
                    text: Binding(
                        get: { viewModel.input.fcf == 0 ? "" : viewModel.input.fcf.cleanString },
                        set: { viewModel.input.fcf = Double($0) ?? 0 }
                    )
                )
                InputFieldRow(
                    title: "Growth Rate",
                    placeholder: "e.g. 8",
                    text: Binding(
                        get: { viewModel.input.growthRate == 0 ? "" : viewModel.input.growthRate.cleanString },
                        set: { viewModel.input.growthRate = Double($0) ?? 0 }
                    ),
                    suffix: "%"
                )
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
                    suffix: "%"
                )
                InputFieldRow(
                    title: "Terminal Growth",
                    placeholder: "e.g. 2.5",
                    text: Binding(
                        get: { viewModel.input.terminalGrowthRate == 0 ? "" : viewModel.input.terminalGrowthRate.cleanString },
                        set: { viewModel.input.terminalGrowthRate = Double($0) ?? 0 }
                    ),
                    suffix: "%"
                )
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
                    )
                )
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
                        navigateToResult = true
                    }
                }
                .disabled(!viewModel.isValid)
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
        .errorAlert(errors: $viewModel.validationErrors)
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
