import SwiftUI

struct YearlyFCFListView: View {
    let yearlyFCFs: [YearlyFCF]
    let currencySymbol: String

    var body: some View {
        DisclosureGroup("Yearly FCF Detail") {
            // Column headers
            HStack {
                Text("Year")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 60, alignment: .center)
                Spacer()
                Text("FCF")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 100, alignment: .center)
                Text("Disc.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 80, alignment: .center)
                Text("PV")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 100, alignment: .center)
            }
            .padding(.vertical, 4)

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
