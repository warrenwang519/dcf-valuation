import Foundation

struct YearlyFCF: Equatable, Identifiable, Sendable {
    let year: Int
    let fcf: Double
    let discountFactor: Double
    let pv: Double
    let growthRate: Double // Per-year growth rate applied (percentage)

    var id: Int { year }
}
