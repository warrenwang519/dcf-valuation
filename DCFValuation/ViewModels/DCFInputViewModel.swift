import Foundation
import SwiftUI

@Observable
@MainActor
final class DCFInputViewModel {
    var input = DCFInput()
    var validationErrors: [ValidationError] = []
    var result: DCFResult?

    private let calculator = DCFCalculator()
    private let validationService = ValidationService()

    var isValid: Bool {
        validationService.validate(input).isEmpty
    }

    func validate() -> [ValidationError] {
        validationService.validate(input)
    }

    func calculate() -> Bool {
        let errors = validationService.validate(input)
        validationErrors = errors
        guard errors.isEmpty else { return false }

        switch calculator.calculate(input: input) {
        case .success(let result):
            self.result = result
            return true
        case .failure(let errors):
            validationErrors = errors
            return false
        }
    }

    func loadFromSettings(_ settings: AppSettings) {
        input.currency = settings.defaultCurrency
        input.forecastYears = settings.defaultForecastYears
        input.wacc = settings.defaultWACC
        input.terminalGrowthRate = settings.defaultTerminalGrowthRate
    }

    func loadFromRecord(_ dcfInput: DCFInput) {
        input = dcfInput
    }
}
