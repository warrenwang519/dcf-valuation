import Foundation

struct DCFCalculator: Sendable {
    private let validationService = ValidationService()

    func calculate(input: DCFInput) -> Result<DCFResult, [ValidationError]> {
        let errors = validationService.validate(input)
        if !errors.isEmpty {
            return .failure(errors)
        }

        let waccDecimal = input.wacc / 100
        let growthDecimal = input.growthRate / 100
        let terminalGrowthDecimal = input.terminalGrowthRate / 100

        // Step 1: Calculate projected FCFs and their present values
        var yearlyFCFs: [YearlyFCF] = []
        var currentFCF = input.fcf
        var pvSum = 0.0

        for year in 1...input.forecastYears {
            currentFCF = currentFCF * (1 + growthDecimal)
            let discountFactor = 1.0 / pow(1 + waccDecimal, Double(year))
            let pv = currentFCF * discountFactor
            pvSum += pv

            yearlyFCFs.append(YearlyFCF(
                year: year,
                fcf: currentFCF,
                discountFactor: discountFactor,
                pv: pv
            ))
        }

        // Step 2: Terminal value
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
        if input.growthRate > 30 {
            warnings.append(.highGrowthRate(input.growthRate))
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

        return .success(result)
    }
}
