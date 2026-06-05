import Foundation
import SwiftData

struct PersistenceService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(result: DCFResult, ownerID: String) {
        let record = ValuationRecord(
            ownerID: ownerID,
            ticker: result.input.ticker,
            companyName: result.input.companyName,
            intrinsicValue: result.intrinsicValuePerShare,
            enterpriseValue: result.enterpriseValue,
            currency: result.input.currency.rawValue,
            fcf: result.input.fcf,
            growthRate: result.input.growthRate,
            forecastYears: result.input.forecastYears,
            wacc: result.input.wacc,
            terminalGrowthRate: result.input.terminalGrowthRate,
            netDebt: result.input.netDebt,
            sharesOutstanding: result.input.sharesOutstanding
        )
        modelContext.insert(record)
        try? modelContext.save()
    }

    func delete(_ record: ValuationRecord) {
        modelContext.delete(record)
        try? modelContext.save()
    }

    func deleteAll(ownerID: String) {
        let descriptor = FetchDescriptor<ValuationRecord>(
            predicate: #Predicate { $0.ownerID == ownerID }
        )
        if let records = try? modelContext.fetch(descriptor) {
            records.forEach { modelContext.delete($0) }
            try? modelContext.save()
        }
    }

    func toDCFInput(from record: ValuationRecord) -> DCFInput {
        DCFInput(
            ticker: record.ticker,
            companyName: record.companyName,
            fcf: record.fcf,
            growthRate: record.growthRate,
            forecastYears: record.forecastYears,
            wacc: record.wacc,
            terminalGrowthRate: record.terminalGrowthRate,
            netDebt: record.netDebt,
            sharesOutstanding: record.sharesOutstanding,
            currency: Currency(rawValue: record.currency) ?? .usd
        )
    }
}
