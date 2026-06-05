import SwiftUI

struct ResultSummaryCard: View {
    let viewModel: ResultViewModel

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("Intrinsic Value / Share")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(viewModel.formattedIntrinsicValue)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.blue)
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Enterprise Value")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.formattedEV)
                        .font(.headline)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Equity Value")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.formattedEquityValue)
                        .font(.headline)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
