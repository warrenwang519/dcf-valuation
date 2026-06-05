import Foundation

enum DCFModelType: String, CaseIterable, Codable, Sendable, Identifiable {
    case constantGrowth = "Constant Growth DCF"
    case multiPeriod = "Multi-period DCF"
    case twoStage = "Two-Stage DCF"
    case threeStage = "Three-Stage DCF"

    var id: String { rawValue }

    /// Available models for a given forecast years count.
    static func availableModels(forecastYears: Int) -> [DCFModelType] {
        switch forecastYears {
        case 5:  return [.constantGrowth, .multiPeriod, .twoStage]
        case 10: return [.constantGrowth, .multiPeriod, .twoStage, .threeStage]
        default: return [.constantGrowth]
        }
    }

    /// Stage labels for display, given the forecast years.
    func stageLabels(forecastYears: Int) -> [String] {
        switch self {
        case .constantGrowth:
            return ["Growth Rate"]
        case .multiPeriod:
            return (1...forecastYears).map { "Year \($0) Growth" }
        case .twoStage:
            switch forecastYears {
            case 5:
                return ["Stage 1 (Year 1-3): High Growth g₁",
                        "Stage 2 (Year 4-5): Transition g₂"]
            default: // 10
                return ["Stage 1 (Year 1-5): High Growth g₁",
                        "Stage 2 (Year 6-10): Low Growth g₂"]
            }
        case .threeStage:
            return ["Stage 1 (Year 1-3): High Growth g₁",
                    "Stage 2 (Year 4-7): Transition g₂",
                    "Stage 3 (Year 8-10): Terminal Approach g₃"]
        }
    }

    /// Number of growth rate inputs needed.
    var stageCount: Int {
        switch self {
        case .constantGrowth: return 1
        case .multiPeriod:    return -1 // depends on forecast years
        case .twoStage:       return 2
        case .threeStage:     return 3
        }
    }

    /// Resolve actual stage count given forecast years.
    func resolvedStageCount(forecastYears: Int) -> Int {
        if self == .multiPeriod { return forecastYears }
        return stageCount
    }

    /// Map a year (1-based) to its stage growth rate index.
    func growthRateIndex(forYear year: Int, forecastYears: Int) -> Int {
        switch self {
        case .constantGrowth:
            return 0
        case .multiPeriod:
            return year - 1
        case .twoStage:
            switch forecastYears {
            case 5:
                return year <= 3 ? 0 : 1
            default: // 10
                return year <= 5 ? 0 : 1
            }
        case .threeStage:
            if year <= 3 { return 0 }
            if year <= 7 { return 1 }
            return 2
        }
    }
}

struct DCFInput: Equatable, Sendable {
    var ticker: String = ""
    var companyName: String = ""
    var fcf: Double = 0
    var modelType: DCFModelType = .constantGrowth
    var stageGrowthRates: [Double] = [0]
    var forecastYears: Int = 10
    var wacc: Double = 0
    var terminalGrowthRate: Double = 0
    var netDebt: Double = 0
    var sharesOutstanding: Double = 0
    var currency: Currency = .usd

    /// Convenience: single growth rate for constant growth model.
    var growthRate: Double {
        get { stageGrowthRates.first ?? 0 }
        set {
            if stageGrowthRates.isEmpty {
                stageGrowthRates = [newValue]
            } else {
                stageGrowthRates[0] = newValue
            }
        }
    }

    /// Reset stageGrowthRates when model type or forecast years change.
    mutating func resetGrowthRates() {
        let count = modelType.resolvedStageCount(forecastYears: forecastYears)
        stageGrowthRates = Array(repeating: 0, count: count)
    }
}
