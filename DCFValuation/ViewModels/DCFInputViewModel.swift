import Foundation
import SwiftUI

@Observable
@MainActor
final class DCFInputViewModel {
    var input = DCFInput()
    var validationErrors: [ValidationError] = []
    var result: DCFResult?
    /// Raw user input text for each stage growth rate field (preserves "8." etc.).
    var stageInputTexts: [String] = [""]

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
        syncStageInputTexts()
    }

    func loadFromRecord(_ dcfInput: DCFInput) {
        input = dcfInput
        let expectedCount = input.modelType.resolvedStageCount(forecastYears: input.forecastYears)
        if input.stageGrowthRates.count != expectedCount {
            input.resetGrowthRates()
        }
        syncStageInputTexts()
    }

    /// Call when forecast years changes — reset model type if incompatible.
    func onForecastYearsChanged() {
        let available = DCFModelType.availableModels(forecastYears: input.forecastYears)
        if !available.contains(input.modelType) {
            input.modelType = .constantGrowth
        }
        input.resetGrowthRates()
        syncStageInputTexts()
    }

    /// Call when model type changes — reset growth rates.
    func onModelTypeChanged() {
        input.resetGrowthRates()
        syncStageInputTexts()
    }

    /// Sync stageInputTexts from stageGrowthRates (called on model/type change only).
    func syncStageInputTexts() {
        stageInputTexts = input.stageGrowthRates.map {
            if $0 == 0 { return "" }
            return $0.truncatingRemainder(dividingBy: 1) == 0
                ? String(format: "%.0f", $0)
                : String($0)
        }
    }
}
