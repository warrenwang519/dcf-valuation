import SwiftUI

struct CurrencyPickerView: View {
    @Binding var currency: Currency

    var body: some View {
        Picker("Default Currency", selection: $currency) {
            ForEach(Currency.allCases) { currency in
                Text("\(currency.displaySymbol) \(currency.rawValue)")
                    .tag(currency)
            }
        }
    }
}
