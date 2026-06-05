import Foundation
import SwiftData

@Observable
@MainActor
final class ResultViewModel {
    let result: DCFResult
    let isReadOnly: Bool
    private let persistenceService: PersistenceService
    private let ownerID: String

    var isSaved = false

    init(result: DCFResult, isReadOnly: Bool = false, persistenceService: PersistenceService, ownerID: String) {
        self.result = result
        self.isReadOnly = isReadOnly
        self.persistenceService = persistenceService
        self.ownerID = ownerID
    }

    func save() {
        persistenceService.save(result: result, ownerID: ownerID)
        isSaved = true
    }

    var currencySymbol: String {
        result.input.currency.displaySymbol
    }

    var formattedEV: String {
        result.enterpriseValue.currencyFormatted(symbol: currencySymbol)
    }

    var formattedEquityValue: String {
        result.equityValue.currencyFormatted(symbol: currencySymbol)
    }

    var formattedIntrinsicValue: String {
        result.intrinsicValuePerShare.currencyFormatted(symbol: currencySymbol)
    }

    var formattedPVFCF: String {
        result.pvOfProjectedFCF.currencyFormatted(symbol: currencySymbol)
    }

    var formattedTerminalValue: String {
        result.terminalValue.currencyFormatted(symbol: currencySymbol)
    }

    var formattedPVTerminalValue: String {
        result.pvOfTerminalValue.currencyFormatted(symbol: currencySymbol)
    }

    var formattedTerminalValuePct: String {
        (result.terminalValuePct * 100).numberFormatted() + "%"
    }
}
