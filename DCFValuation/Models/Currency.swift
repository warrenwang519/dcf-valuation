import Foundation

enum Currency: String, Codable, CaseIterable, Identifiable, Sendable {
    case usd = "USD"
    case hkd = "HKD"
    case cny = "CNY"

    var id: String { rawValue }

    var displaySymbol: String {
        switch self {
        case .usd: "$"
        case .hkd: "HK$"
        case .cny: "¥"
        }
    }

    var localizedName: String {
        switch self {
        case .usd: "US Dollar"
        case .hkd: "Hong Kong Dollar"
        case .cny: "Chinese Yuan"
        }
    }
}
