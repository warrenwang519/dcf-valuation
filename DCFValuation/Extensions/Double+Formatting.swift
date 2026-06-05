import Foundation

extension Double {
    func currencyFormatted(symbol: String, decimals: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = symbol
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        return formatter.string(from: NSNumber(value: self)) ?? "\(symbol)\(self)"
    }

    func percentFormatted(decimals: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        formatter.multiplier = 1
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)%"
    }

    func numberFormatted(decimals: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    func compactFormatted() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        if abs(self) >= 1_000_000 {
            return formatter.string(from: NSNumber(value: self / 1_000_000)).map { "\($0)M" } ?? "\(self)M"
        } else if abs(self) >= 1_000 {
            return formatter.string(from: NSNumber(value: self / 1_000)).map { "\($0)K" } ?? "\(self)K"
        }
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
