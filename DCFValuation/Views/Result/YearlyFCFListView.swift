import SwiftUI

struct YearlyFCFListView: View {
    let yearlyFCFs: [YearlyFCF]
    let currencySymbol: String

    var body: some View {
        DisclosureGroup("Yearly FCF Detail") {
            // Column headers
            HStack {
                Text("Year")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 48, alignment: .center)
                Text("Growth")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 52, alignment: .center)
                Text("FCF")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 80, alignment: .center)
                Text("Disc.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 60, alignment: .center)
                Text("PV")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 80, alignment: .center)
            }
            .padding(.vertical, 4)

            ForEach(yearlyFCFs) { item in
                HStack {
                    Text("Year \(item.year)")
                        .font(.caption)
                        .frame(width: 48, alignment: .center)

                    Text("\(item.growthRate, specifier: "%.1f")%")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(width: 52, alignment: .center)

                    Text(item.fcf.currencyFormatted(symbol: currencySymbol))
                        .font(.caption.monospacedDigit())
                        .frame(width: 80, alignment: .center)

                    Text("×\(item.discountFactor.numberFormatted(decimals: 4))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(width: 60, alignment: .center)

                    Text(item.pv.currencyFormatted(symbol: currencySymbol))
                        .font(.caption.monospacedDigit())
                        .frame(width: 80, alignment: .center)
                }
                .padding(.vertical, 2)
            }
        }
    }
}
