import SwiftUI

struct ResultView: View {
    @Bindable var viewModel: ResultViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: String

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if !viewModel.result.input.ticker.isEmpty {
                    Text(viewModel.result.input.ticker)
                        .font(.title2.bold())
                }

                ResultSummaryCard(viewModel: viewModel)

                // Breakdown
                VStack(alignment: .leading, spacing: 12) {
                    Text("Valuation Breakdown")
                        .font(.headline)

                    HStack {
                        Text("PV of Projected FCFs")
                        Spacer()
                        Text(viewModel.formattedPVFCF)
                            .monospacedDigit()
                    }
                    .font(.subheadline)

                    HStack {
                        Text("Terminal Value")
                        Spacer()
                        Text(viewModel.formattedTerminalValue)
                            .monospacedDigit()
                    }
                    .font(.subheadline)

                    HStack {
                        Text("PV of Terminal Value")
                        Spacer()
                        Text(viewModel.formattedPVTerminalValue)
                            .monospacedDigit()
                    }
                    .font(.subheadline)

                    Divider()

                    HStack {
                        Text("Terminal Value %")
                            .font(.subheadline.bold())
                        Spacer()
                        Text(viewModel.formattedTerminalValuePct)
                            .font(.subheadline.bold())
                            .monospacedDigit()
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Yearly FCF
                YearlyFCFListView(
                    yearlyFCFs: viewModel.result.yearlyFCFs,
                    currencySymbol: viewModel.currencySymbol
                )
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Warnings
                ForEach(viewModel.result.warnings, id: \.self) { warning in
                    WarningBanner(warning: warning)
                }

                // Actions
                if !viewModel.isReadOnly {
                    HStack(spacing: 16) {
                        Button {
                            viewModel.save()
                            selectedTab = "history"
                        } label: {
                            Label("Save", systemImage: "square.and.arrow.down")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.isSaved)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Valuation Result")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WarningBanner: View {
    let warning: ValuationWarning

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text(message)
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var message: String {
        switch warning {
        case .highTerminalValuePct(let pct):
            "Terminal value accounts for \(Int(pct * 100))% of enterprise value. Results may be highly sensitive to assumptions."
        case .highGrowthRate(let rate):
            "Growth rate of \(Int(rate))% is unusually high for long-term projections."
        }
    }
}
