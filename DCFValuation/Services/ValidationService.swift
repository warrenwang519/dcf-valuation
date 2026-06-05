import Foundation

enum ValidationError: Equatable, Sendable {
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
            "Free cash flow must be greater than 0"
        case .growthRateOutOfRange:
            "Growth rate must be between -50% and 100%"
        case .forecastYearsOutOfRange:
            "Forecast years must be between 1 and 30"
        case .waccOutOfRange:
            "WACC must be between 0% and 50%"
        case .terminalGrowthRateInvalid:
            "Terminal growth rate must be >= 0% and less than WACC"
        case .sharesMustBePositive:
            "Shares outstanding must be greater than 0"
        case .tickerTooLong:
            "Ticker must be 10 characters or less"
        case .waccTooCloseToTerminalGrowth:
            "WACC must be significantly greater than terminal growth rate (difference > 0.1%)"
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
