import Foundation

struct DCFResult: Equatable, Sendable {
    let enterpriseValue: Double
    let equityValue: Double
    let intrinsicValuePerShare: Double
    let pvOfProjectedFCF: Double
    let terminalValue: Double
    let pvOfTerminalValue: Double
    let terminalValuePct: Double
    let yearlyFCFs: [YearlyFCF]
    let input: DCFInput
    let calculatedAt: Date
    let warnings: [ValuationWarning]
}

enum ValuationWarning: Hashable, Sendable {
    case highTerminalValuePct(Double)
    case highGrowthRate(Double)
}
