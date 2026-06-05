import Foundation

struct DCFCalculator: Sendable {
    private let validationService = ValidationService()

    func calculate(input: DCFInput) -> (result: DCFResult?, errors: [ValidationError]) {
        let errors = validationService.validate(input)
        if !errors.isEmpty {
            return (nil, errors)
        }

        let waccDecimal = input.wacc / 100
        let terminalGrowthDecimal = input.terminalGrowthRate / 100

        // Step 1: Project FCFs based on model type
        var yearlyFCFs: [YearlyFCF] = []
        var currentFCF = input.fcf
        var pvSum = 0.0

        for year in 1...input.forecastYears {
            // Determine the growth rate for this year based on model type
            let rateIndex = input.modelType.growthRateIndex(forYear: year, forecastYears: input.forecastYears)
            let yearGrowthDecimal = input.stageGrowthRates[rateIndex] / 100

            currentFCF = currentFCF * (1 + yearGrowthDecimal)
            let discountFactor = 1.0 / pow(1 + waccDecimal, Double(year))
            let pv = currentFCF * discountFactor
            pvSum += pv

            yearlyFCFs.append(YearlyFCF(
                year: year,
                fcf: currentFCF,
                discountFactor: discountFactor,
                pv: pv,
                growthRate: input.stageGrowthRates[rateIndex]
            ))
        }

        // Step 2: Terminal value (same formula for all models)
        let lastFCF = currentFCF
        let terminalValue = lastFCF * (1 + terminalGrowthDecimal) / (waccDecimal - terminalGrowthDecimal)
        let pvOfTerminalValue = terminalValue / pow(1 + waccDecimal, Double(input.forecastYears))

        // Step 3: Enterprise value
        let enterpriseValue = pvSum + pvOfTerminalValue

        // Step 4: Equity value
        let equityValue = enterpriseValue - input.netDebt

        // Step 5: Intrinsic value per share
        let intrinsicValuePerShare = equityValue / input.sharesOutstanding

        // Warnings
        var warnings: [ValuationWarning] = []
        let terminalValuePct = pvOfTerminalValue / enterpriseValue
        if terminalValuePct > 0.8 {
            warnings.append(.highTerminalValuePct(terminalValuePct))
        }
        let maxGrowth = input.stageGrowthRates.max() ?? 0
        if maxGrowth > 30 {
            warnings.append(.highGrowthRate(maxGrowth))
        }

        let result = DCFResult(
            enterpriseValue: enterpriseValue,
            equityValue: equityValue,
            intrinsicValuePerShare: intrinsicValuePerShare,
            pvOfProjectedFCF: pvSum,
            terminalValue: terminalValue,
            pvOfTerminalValue: pvOfTerminalValue,
            terminalValuePct: terminalValuePct,
            yearlyFCFs: yearlyFCFs,
            input: input,
            calculatedAt: Date(),
            warnings: warnings
        )

        return (result, [])
    }
}
