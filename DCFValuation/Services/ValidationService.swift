import Foundation

enum ValidationError: Equatable, Sendable, Error {
    case fcfMustBePositive
    case growthRateOutOfRange
    case forecastYearsOutOfRange
    case waccOutOfRange
    case terminalGrowthRateInvalid
    case sharesMustBePositive
    case tickerTooLong
    case waccTooCloseToTerminalGrowth

    var localizedDescription: String {
        switch self {
        case .fcfMustBePositive:
            "FCF is required. Enter a positive free cash flow value."
        case .growthRateOutOfRange:
            "Revenue growth rate must be between -50% and 100%."
        case .forecastYearsOutOfRange:
            "Projection period must be between 1 and 30 years."
        case .waccOutOfRange:
            "WACC must be between 0% and 50% (exclusive)."
        case .terminalGrowthRateInvalid:
            "Terminal growth rate must be non-negative and strictly less than WACC."
        case .sharesMustBePositive:
            "Shares outstanding is required. Enter a positive share count."
        case .tickerTooLong:
            "Ticker symbol must not exceed 10 characters."
        case .waccTooCloseToTerminalGrowth:
            "Spread between WACC and terminal growth rate must exceed 0.1%."
        }
    }
}

struct ValidationService: Sendable {
    func validate(_ input: DCFInput) -> [ValidationError] {
        var errors: [ValidationError] = []

        if input.fcf <= 0 {
            errors.append(.fcfMustBePositive)
        }

        if input.growthRate < -50 || input.growthRate > 100 {
            errors.append(.growthRateOutOfRange)
        }

        if input.forecastYears < 1 || input.forecastYears > 30 {
            errors.append(.forecastYearsOutOfRange)
        }

        if input.wacc <= 0 || input.wacc >= 50 {
            errors.append(.waccOutOfRange)
        }

        if input.terminalGrowthRate < 0 || input.terminalGrowthRate >= input.wacc {
            errors.append(.terminalGrowthRateInvalid)
        }

        if input.sharesOutstanding <= 0 {
            errors.append(.sharesMustBePositive)
        }

        if !input.ticker.isEmpty && input.ticker.count > 10 {
            errors.append(.tickerTooLong)
        }

        if input.wacc > 0 && abs(input.wacc - input.terminalGrowthRate) < 0.1 {
            errors.append(.waccTooCloseToTerminalGrowth)
        }

        return errors
    }
}
