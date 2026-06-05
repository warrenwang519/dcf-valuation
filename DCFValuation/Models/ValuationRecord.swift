import Foundation
import SwiftData

/// V1 schema — needed for lightweight migration from old `growthRate` field.
@Model
final class ValuationRecordV1 {
    var id: UUID
    var ownerID: String
    var ticker: String
    var companyName: String
    var intrinsicValue: Double
    var enterpriseValue: Double
    var currency: String
    var fcf: Double
    var growthRate: Double
    var forecastYears: Int
    var wacc: Double
    var terminalGrowthRate: Double
    var netDebt: Double
    var sharesOutstanding: Double
    var createdAt: Date
    var updatedAt: Date
    var note: String
}

@Model
final class ValuationRecord {
    var id: UUID
    var ownerID: String
    var ticker: String
    var companyName: String
    var intrinsicValue: Double
    var enterpriseValue: Double
    var currency: String
    var fcf: Double
    var modelType: String        // DCFModelType rawValue
    var stageGrowthRates: String // Comma-separated percentages, e.g. "8,5,3"
    var forecastYears: Int
    var wacc: Double
    var terminalGrowthRate: Double
    var netDebt: Double
    var sharesOutstanding: Double
    var createdAt: Date
    var updatedAt: Date
    var note: String

    /// Backward-compatible accessor: first stage growth rate.
    var growthRate: Double {
        stageGrowthRates.split(separator: ",").first.flatMap { Double($0) } ?? 0
    }

    init(
        ownerID: String,
        ticker: String,
        companyName: String,
        intrinsicValue: Double,
        enterpriseValue: Double,
        currency: String,
        fcf: Double,
        modelType: String,
        stageGrowthRates: String,
        forecastYears: Int,
        wacc: Double,
        terminalGrowthRate: Double,
        netDebt: Double,
        sharesOutstanding: Double,
        note: String = ""
    ) {
        self.id = UUID()
        self.ownerID = ownerID
        self.ticker = ticker
        self.companyName = companyName
        self.intrinsicValue = intrinsicValue
        self.enterpriseValue = enterpriseValue
        self.currency = currency
        self.fcf = fcf
        self.modelType = modelType
        self.stageGrowthRates = stageGrowthRates
        self.forecastYears = forecastYears
        self.wacc = wacc
        self.terminalGrowthRate = terminalGrowthRate
        self.netDebt = netDebt
        self.sharesOutstanding = sharesOutstanding
        self.createdAt = Date()
        self.updatedAt = Date()
        self.note = note
    }
}
