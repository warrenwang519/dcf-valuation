import SwiftUI

struct HistoryRowView: View {
    let record: ValuationRecord

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(displayName)
                    .font(.headline)

                Text(record.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(formattedValue)
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(.blue)

                Text(currencySymbol)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var displayName: String {
        if !record.ticker.isEmpty {
            return record.companyName.isEmpty ? record.ticker : "\(record.ticker) - \(record.companyName)"
        }
        return record.companyName.isEmpty ? "Untitled" : record.companyName
    }

    private var currencySymbol: String {
        Currency(rawValue: record.currency)?.displaySymbol ?? record.currency
    }

    private var formattedValue: String {
        record.intrinsicValue.currencyFormatted(symbol: currencySymbol)
    }
}
