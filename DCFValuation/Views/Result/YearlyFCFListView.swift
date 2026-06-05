import SwiftUI

struct YearlyFCFListView: View {
    let yearlyFCFs: [YearlyFCF]
    let currencySymbol: String

    var body: some View {
        DisclosureGroup("Yearly FCF Detail") {
            ForEach(yearlyFCFs) { item in
                HStack {
                    Text("Year \(item.year)")
                        .font(.caption)
                        .frame(width: 60, alignment: .leading)

                    Spacer()

                    Text(item.fcf.currencyFormatted(symbol: currencySymbol))
                        .font(.caption.monospacedDigit())
                        .frame(width: 100, alignment: .trailing)

                    Text("×\(item.discountFactor.numberFormatted(decimals: 4))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(width: 80, alignment: .trailing)

                    Text(item.pv.currencyFormatted(symbol: currencySymbol))
                        .font(.caption.monospacedDigit())
                        .frame(width: 100, alignment: .trailing)
                }
                .padding(.vertical, 2)
            }
        }
    }
}
