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
        case .forecastYearsInvalid: return "forecastYears"
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

    /// Get growth rate error (for any stage).
    private var growthRateError: String? {
        guard showErrors else { return nil }
        return viewModel.validationErrors.first {
            if case .growthRateOutOfRange = $0 { return true }
            return false
        }?.localizedDescription
    }

    /// Clear errors when user edits any field.
    private func clearErrors() {
        if showErrors { showErrors = false }
    }

    /// Binding for a specific stage growth rate (safe indexing, preserves raw input).
    private func stageGrowthBinding(at index: Int) -> Binding<String> {
        Binding(
            get: {
                viewModel.ensureStageTextsSynced()
                guard index < viewModel.stageInputTexts.count else { return "" }
                return viewModel.stageInputTexts[index]
            },
            set: { newValue in
                guard index < viewModel.stageInputTexts.count else { return }
                viewModel.stageInputTexts[index] = newValue
                if index < viewModel.input.stageGrowthRates.count {
                    viewModel.input.stageGrowthRates[index] = Double(newValue) ?? 0
                }
            }
        )
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
                // Forecast Years — moved above Growth Rate, Picker with 5/10
                Picker("Forecast Years", selection: Binding(
                    get: { viewModel.input.forecastYears },
                    set: { viewModel.input.forecastYears = $0; viewModel.onForecastYearsChanged() }
                )) {
                    Text("5 years").tag(5)
                    Text("10 years").tag(10)
                }

                // DCF Model Type
                Picker("DCF Model", selection: Binding(
                    get: { viewModel.input.modelType },
                    set: { viewModel.input.modelType = $0; viewModel.onModelTypeChanged() }
                )) {
                    ForEach(DCFModelType.availableModels(forecastYears: viewModel.input.forecastYears)) { model in
                        Text(model.rawValue).tag(model)
                    }
                }

                // FCF
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

                // Dynamic Growth Rate inputs based on model type
                let labels = viewModel.input.modelType.stageLabels(forecastYears: viewModel.input.forecastYears)
                let ratesCount = viewModel.input.stageGrowthRates.count
                ForEach(Array(labels.enumerated()), id: \.offset) { index, label in
                    if index < ratesCount {
                        InputFieldRow(
                            title: label,
                            placeholder: "e.g. 8",
                            text: stageGrowthBinding(at: index),
                            numericOnly: false,
                            suffix: "%",
                            errorMessage: (index == 0) ? growthRateError : nil
                        )
                        .onChange(of: viewModel.input.stageGrowthRates) { clearErrors() }
                    }
                }
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

            Section {
                Button {
                    if viewModel.calculate() {
                        showErrors = false
                        navigateToResult = true
                    } else {
                        showErrors = true
                    }
                } label: {
                    Text("Calculate")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
                .listRowBackground(Color.blue)
                .foregroundStyle(.white)
            }
        }
        .navigationTitle("DCF Calculator")
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
