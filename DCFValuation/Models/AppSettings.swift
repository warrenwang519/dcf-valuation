import Foundation

struct AppSettings: Codable, Sendable {
    var defaultCurrency: Currency = .usd
    var defaultForecastYears: Int = 10
    var defaultWACC: Double = 10.0
    var defaultTerminalGrowthRate: Double = 2.5
}
