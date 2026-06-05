import Foundation

struct YearlyFCF: Equatable, Identifiable, Sendable {
    let year: Int
    let fcf: Double
    let discountFactor: Double
    let pv: Double

    var id: Int { year }
}
