import Foundation

struct DCFInput: Equatable, Sendable {
    var ticker: String = ""
    var companyName: String = ""
    var fcf: Double = 0
    var growthRate: Double = 0
    var forecastYears: Int = 10
    var wacc: Double = 0
    var terminalGrowthRate: Double = 0
    var netDebt: Double = 0
    var sharesOutstanding: Double = 0
    var currency: Currency = .usd
}
