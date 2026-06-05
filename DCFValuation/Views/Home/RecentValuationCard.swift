import SwiftUI

struct RecentValuationCard: View {
    let record: ValuationRecord

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(displayName)
                    .font(.subheadline.bold())

                Text(record.createdAt.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(formattedValue)
                .font(.headline.monospacedDigit())
                .foregroundStyle(.blue)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var displayName: String {
        if !record.ticker.isEmpty { return record.ticker }
        return record.companyName.isEmpty ? "Untitled" : record.companyName
    }

    private var currencySymbol: String {
        Currency(rawValue: record.currency)?.displaySymbol ?? record.currency
    }

    private var formattedValue: String {
        record.intrinsicValue.currencyFormatted(symbol: currencySymbol)
    }
}
