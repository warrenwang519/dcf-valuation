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

        let output = calculator.calculate(input: input)
        if let result = output.result {
            self.result = result
            return true
        } else {
            validationErrors = output.errors
            return false
        }
    }

    func loadFromSettings(_ settings: AppSettings) {
        input.currency = settings.defaultCurrency
        input.forecastYears = settings.defaultForecastYears
        input.modelType = settings.defaultDCFModelType
        input.wacc = settings.defaultWACC
        input.terminalGrowthRate = settings.defaultTerminalGrowthRate
        input.resetGrowthRates()
    }

    func loadFromRecord(_ dcfInput: DCFInput) {
        input = dcfInput
    }

    /// Call when forecast years changes — reset model type if incompatible.
    func onForecastYearsChanged() {
        let available = DCFModelType.availableModels(forecastYears: input.forecastYears)
        if !available.contains(input.modelType) {
            input.modelType = .constantGrowth
        }
        input.resetGrowthRates()
    }

    /// Call when model type changes — reset growth rates.
    func onModelTypeChanged() {
        input.resetGrowthRates()
    }
}
